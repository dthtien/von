require 'test_helper'

describe Von::Counters::Total do
  TotalCounter = Von::Counters::Total

  before :each do
    Timecop.freeze(Time.local(2013, 01, 01, 01, 01))
    Von.config.init!
    @redis = Redis.new
    @redis.flushall
  end

  it "increments the total counter if given a single key" do
    counter = TotalCounter.new('foo')

    counter.increment
    assert_equal @redis.hget('von:counters:foo', 'total'), '1'

    counter.increment(5)
    assert_equal @redis.hget('von:counters:foo', 'total'), '6'
  end

  it "gets a total count for a counter" do
    counter = TotalCounter.new('foo')
    counter.increment
    counter.increment(3)
    counter.increment

    assert_equal counter.count, 5
  end
end
