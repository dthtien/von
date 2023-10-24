require 'test_helper'

describe Von::Counter do
  Counter = Von::Counter

  before :each do
    Timecop.freeze(Time.local(2013, 01, 01, 01, 01))
    Von.config.init!
    @redis = Redis.new
    @redis.flushall
  end

  it "returns count for key" do
    3.times { Von.increment('foo') }
    assert_equal Counter.new('foo').total, 3
  end

  it "returns count for key and parent keys" do
    3.times { Von.increment('foo:bar') }
    assert_equal Counter.new('foo').total, 3
    assert_equal Counter.new('foo:bar').total, 3
  end

  it "returns counts for a given period" do
    Von.configure do |config|
      config.counter 'foo', monthly: 2
    end

    Von.increment('foo')
    Timecop.freeze(Time.local(2013, 02))
    Von.increment('foo')
    Timecop.freeze(Time.local(2013, 03))
    Von.increment('foo')

    assert_equal Counter.new('foo').per(:month), [{ timestamp: "2013-02", count: 1 }, { timestamp: "2013-03", count: 1 }]
  end

  it "returns best count for a given period" do
    Von.configure do |config|
      config.counter 'foo', best: [:minute, :week]
    end

    Von.increment('foo')

    Timecop.freeze(Time.local(2013, 01, 13, 06, 05))
    4.times { Von.increment('foo') }
    Timecop.freeze(Time.local(2013, 01, 20, 06, 10))
    3.times { Von.increment('foo') }

    assert_equal Counter.new('foo').best(:minute), { timestamp: "2013-01-13 06:05", count: 4 }
    assert_equal Counter.new('foo').best(:week), { timestamp: "2013-01-07", count: 4 }
  end

  it "returns current count for a given period" do
    Von.configure do |config|
      config.counter 'foo', current: [:minute, :day]
    end

    4.times { Von.increment('foo') }
    Timecop.freeze(Time.local(2013, 01, 20, 06, 10))
    3.times { Von.increment('foo') }

    assert_equal Counter.new('foo').this(:minute), 3
    assert_equal Counter.new('foo').current(:minute), 3
    assert_equal Counter.new('foo').this(:day), 3
    assert_equal Counter.new('foo').current(:day), 3
    assert_equal Counter.new('foo').today, 3
  end
end
