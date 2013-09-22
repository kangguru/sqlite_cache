# SqliteCache

SqliteCache allows to use a SQLite database as storage for your cache. It comes with an API compatible with ActiveSupport::Cache and can though easily used in any Rails Application.

## Installation

Add this line to your application's Gemfile:

    gem 'sqlite_cache'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sqlite_cache

## Usage

To use SqliteCache just head over to e.g. your `production.rb`file and add the following line

```ruby
config.cache_store = SqliteCache::Store.new
```

This will use an inmemory SQLite database. You can also specify a file location

```ruby
config.cache_store = SqliteCache::Store.new("tmp/cache.db")
```

For more information about Rails Caching please have a look at the [Rails Cache Guide](http://guides.rubyonrails.org/caching_with_rails.html)

## Testing

    rake

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
