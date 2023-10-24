require 'test_helper'

describe Von::Counters::Current do
  CurrentCounter = Von::Counters::Current

  before :each do
    Timecop.freeze(Time.local(2013, 01, 01, 06))
    Von.config.init!
    @redis = Redis.new
    @redis.flushall
  end

  it "increments the current counter for a period" do
    counter = CurrentCounter.new('foo', [ Von::Period.new(:day) ])

    4.times { counter.increment }
    Timecop.freeze(Time.local(2013, 01, 02))
    3.times { counter.increment(2) }

    assert_equal @redis.hget('von:counters:currents:foo:day', 'timestamp'), '2013-01-02'
    assert_equal @redis.hget('von:counters:currents:foo:day', 'total'), '6'
  end

  it "increments the current counter for multiple periods" do
    counter = CurrentCounter.new('foo', [
      Von::Period.new(:minute),
      Von::Period.new(:week),
    ])

    4.times { counter.increment }
    Timecop.freeze(Time.local(2013, 01, 20, 06, 10))
    3.times { counter.increment(2) }

    assert_equal @redis.hget('von:counters:currents:foo:minute', 'timestamp'), '2013-01-20 06:10'
    assert_equal @redis.hget('von:counters:currents:foo:minute', 'total'), '6'

    assert_equal @redis.hget('von:counters:currents:foo:week', 'timestamp'), '2013-01-14'
    assert_equal @redis.hget('von:counters:currents:foo:week', 'total'), '6'
  end

  it "counts acurrent counter for a period" do
    counter = CurrentCounter.new('foo', [
      Von::Period.new(:minute),
      Von::Period.new(:day),
    ])

    4.times { counter.increment }
    Timecop.freeze(Time.local(2013, 01, 01, 06, 10))
    3.times { counter.increment(2) }

    assert_equal counter.count(:minute), 6
    assert_equal counter.count(:day), 10
  end
end
