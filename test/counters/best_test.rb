require 'test_helper'

describe Von::Counters::Best do
  BestCounter = Von::Counters::Best

  before :each do
    Timecop.freeze(Time.local(2013, 01, 01, 06))
    Von.config.init!
    @redis = Redis.new
    @redis.flushall
  end

  it "increments the best counter for a period" do
    counter = BestCounter.new('foo', [ Von::Period.new(:day) ])

    counter.increment

    Timecop.freeze(Time.local(2013, 01, 02))
    4.times { counter.increment(2) }
    Timecop.freeze(Time.local(2013, 01, 03))
    3.times { counter.increment }

    assert_equal @redis.hget('von:counters:bests:foo:day:current', 'timestamp'), '2013-01-03'
    assert_equal @redis.hget('von:counters:bests:foo:day:current', 'total'), '3'
    assert_equal @redis.hget('von:counters:bests:foo:day:best', 'timestamp'), '2013-01-02'
    assert_equal @redis.hget('von:counters:bests:foo:day:best', 'total'), '8'
  end

  it "increments the best counter for multiple periods" do
    counter = BestCounter.new('foo', [
      Von::Period.new(:minute),
      Von::Period.new(:week),
    ])

    counter.increment

    Timecop.freeze(Time.local(2013, 01, 13, 06, 05))
    4.times { counter.increment(2) }
    Timecop.freeze(Time.local(2013, 01, 20, 06, 10))
    3.times { counter.increment }

    assert_equal @redis.hget('von:counters:bests:foo:minute:current', 'timestamp'), '2013-01-20 06:10'
    assert_equal @redis.hget('von:counters:bests:foo:minute:current', 'total'), '3'
    assert_equal @redis.hget('von:counters:bests:foo:minute:best', 'timestamp'), '2013-01-13 06:05'
    assert_equal @redis.hget('von:counters:bests:foo:minute:best', 'total'), '8'

    assert_equal @redis.hget('von:counters:bests:foo:week:current', 'timestamp'), '2013-01-14'
    assert_equal @redis.hget('von:counters:bests:foo:week:current', 'total'), '3'
    assert_equal @redis.hget('von:counters:bests:foo:week:best', 'timestamp'), '2013-01-07'
    assert_equal @redis.hget('von:counters:bests:foo:week:best', 'total'), '8'
  end
end
