require "spec_helper"

class Pony

  attr_accessor :name

  def initialize(name)
    self.name = name
  end

  def ==(other)
    self.name == other.name
  end

end

describe SqliteCache::Store do


  describe "#fetch" do
    describe "with cache hit" do
      before { subject.write("foo", "bar") }

      it "will return the cached value" do
        expect(subject.fetch("foo") { "baz" }).to eq("bar")
      end

      it "will the block value when forced" do
        expect(subject.fetch("foo", force: true) { "baz" }).to eq("baz")
      end

      describe "when nil is cached" do
        before { subject.write("foo", nil) }

        it "will stick to the cache " do
          expect(subject.fetch("foo") { "baz" }).to be_nil
        end
      end

    end

    describe "with cache miss" do
      before { subject.clear }

      it "will return the value from the block" do
        expect(subject.fetch("foo") { "baz" }).to eq("baz")
      end
    end

  end

  describe "#read" do

    describe "value that wont expire" do
      before { subject.write("foo", "bar") }

      it "will return the value from the cache" do
        expect(subject.read("foo")).to eq("bar")
      end
    end

    describe "when a value expires" do
      let(:time) { Time.local(2008, 4, 24) }
      before do
        Time.stub(now: time)
        subject.write("foo", "bar", expires_in: 60.second)
      end

      it "will be removed from the cache" do
        expect{ Time.stub(now: time + 61) }.to change{subject.read("foo")}.from("bar").to(nil)
      end
    end

    describe "value is a complex type" do
      let(:pony) { Pony.new("name") }

      before { subject.write("foo", pony) }
      it "will return the value from the cache" do
        expect(subject.read("foo")).to eq(pony)
      end
    end
  end

  describe "#write" do

    it "will persist a value into the cache" do
      expect{subject.write("foo", "bar")}.not_to raise_error
      expect(subject.read("foo")).to eq("bar")
    end

    describe "updating a existing key" do
      before { subject.write("foo", "bar") }

      it "will update a value in the cache" do
        expect{subject.write("foo", "baz")}.to change{ subject.read("foo")}.from("bar").to("baz")
      end
    end

  end

  describe "#delete" do

    before { subject.write("foo", "bar") }
    it "will delte a key from the cache" do
      expect{subject.delete("foo")}.to change{ subject.read("foo")}.from("bar").to(nil)
    end
  end

  describe "#exist?" do
    it "will delte a key from the cache" do
      expect{subject.write("foo", "bar")}.to change{ subject.exist?("foo")}.from(nil).to(true)
    end
  end

  describe "#clear" do
    before do
      subject.write("foo", "bar")
      subject.write("john", "doe")
    end

    it "will delte all keys from the cache" do
      subject.clear

      expect(subject.exist?("foo")).to be_nil
      expect(subject.exist?("john")).to be_nil
    end
  end

  describe "#cleanup" do
    let(:time) { Time.local(2008, 4, 24) }

    before do
      subject.clear

      Time.stub(now: time)

      subject.write("john", "doe", expires_in: 120.second)
      subject.write("foo", "bar", expires_in: 60.second)

      Time.stub(now: time + 61)
    end

    it "will delte all expired keys from the cache" do
      expect{ subject.cleanup }.to change{ subject.send(:read_entry, "foo", {})}.to(nil)
    end

    it "will leave the others untouched" do
      expect{ subject.cleanup }.not_to change{ subject.send(:read_entry, "john", {})}.to(nil)
    end

    describe "with max_time applied" do
      before do
        subject.clear

        Time.stub(now: time)

        subject.write("john", "doe", expires_in: 30.second)
        subject.write("foo", "bar", expires_in: 30.second)

        Time.stub(now: time + 60)
      end

      it "cannot cleanup all items when running out of time" do
        expect{ subject.cleanup(-12) }.to change{ subject.send(:count)}.by(-1)
      end

      it "can cleanup all items when time is plenty" do
        expect{ subject.cleanup(2) }.to change{ subject.send(:count)}.by(-2)
      end
    end

  end

end