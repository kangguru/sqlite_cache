module SqliteCache
  class Store < ActiveSupport::Cache::Store
    attr_accessor :logger

    def initialize(path = "", options = nil)
      @options = options ? options.dup : {}
      @logger = @options[:logger]
      @max_cleanup_time = @options.fetch(:max_prune_time, 2)

      if path.present?
        @db = Sequel.connect("sqlite://#{path}")
      else
        @db = Sequel.sqlite
      end

      @db.create_table(:cache) do
        String :key
        String :value
      end unless @db.table_exists?(:cache)

      @data = @db[:cache]
    end

    def clear(options = nil)
      @data.delete
    rescue Sequel::Error => e
      logger.error("Sequel::Error (#{e}): #{e.message}") if logger
      nil
    end

    def cleanup(max_time = nil)
      instrument(:cleanup, size: @data.count) do
        start_time = Time.now
        @data.each do |row|
          entry = read_entry(row[:key], options)
          delete_entry(row[:key], options) if entry && entry.expired?
          return if (max_time && Time.now - start_time > max_time)
        end
      end
    end

    protected

      def count
        @data.count
      end

      # Read an entry from the cache.
      def read_entry(key, options) # :nodoc:
        deserialize_entry(@data.where(key: key).get(:value))
      rescue Sequel::Error => e
        logger.error("Sequel::Error (#{e}): #{e.message}") if logger
        nil
      end

      # Write an entry to the cache.
      def write_entry(key, entry, options) # :nodoc:
        cleanup(@max_cleanup_time)

        method = exist?(key) ? :update : :insert

        @data.send(method, {key: key, value: Marshal.dump(entry)})
        true
      rescue Sequel::Error => e
        logger.error("Sequel::Error (#{e}): #{e.message}") if logger
        false
      end

      # Delete an entry from the cache.
      def delete_entry(key, options) # :nodoc:
        @data.where(key: key).delete
      rescue Sequel::Error => e
        logger.error("Sequel::Error (#{e}): #{e.message}") if logger
        false
      end

    private

      def serialize_entry(value)
        if value
          entry = Marshal.dump(value) rescue value
          entry.is_a?(Entry) ? entry : Entry.new(entry)
        else
          nil
        end
      end

      def deserialize_entry(raw_value)
        if raw_value
          entry = Marshal.load(raw_value) rescue raw_value
          entry.is_a?(ActiveSupport::Cache::Entry) ? entry : ActiveSupport::Cache::Entry.new(entry)
        else
          nil
        end
      end
  end
end