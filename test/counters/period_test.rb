require 'test_helper'

describe Von::Counters::Period do
  PeriodCounter = Von::Counters::Period

  before :each do
    Timecop.freeze(Time.local(2013, 01, 01, 01, 01))
    Von.config.init!
    @redis = Redis.new
    @redis.flushall
  end

  it "increments a month counter" do
    counter = PeriodCounter.new('foo', [
      Von::Period.new(:monthly, 1)
    ])

    counter.increment
    counter.increment(5)

    assert_equal @redis.hget('von:counters:foo:month', '2013-01'), '6'
    assert_equal @redis.lrange('von:lists:foo:month', 0, -1).size, 1
    assert_equal @redis.lrange('von:lists:foo:month', 0, -1).first, '2013-01'
  end

  it 'increments a minute counter' do
    counter = PeriodCounter.new('foo', [
      Von::Period.new(:minutely, 60)
    ])

    counter.increment
    counter.increment(5)

    assert_equal @redis.hget('von:counters:foo:minute', '2013-01-01 01:01'), '6'
    assert_equal @redis.lrange('von:lists:foo:minute', 0, -1).size, 1
    assert_equal @redis.lrange('von:lists:foo:minute', 0, -1).first, '2013-01-01 01:01'
  end

  it "expires counters past the limit" do
    counter = PeriodCounter.new('foo', [
      Von::Period.new(:monthly, 1)
    ])

    counter.increment
    Timecop.freeze(Time.local(2013, 02))
    counter.increment(5)

    assert_equal @redis.hget('von:counters:foo:month', '2013-02'), '5'
    assert_equal @redis.lrange('von:lists:foo:month', 0, -1).size, 1
    assert_equal @redis.lrange('von:lists:foo:month', 0, -1).first, '2013-02'
  end


  it "gets a count for a time period and 0s missing entries" do
    counter = PeriodCounter.new('foo', [
      Von::Period.new(:monthly, 1),
      Von::Period.new(:hourly, 6)
    ])

    counter.increment
    counter.increment
    Timecop.freeze(Time.local(2013, 02, 01, 7))
    counter.increment(5)
    Timecop.freeze(Time.local(2013, 02, 01, 9))
    counter.increment

    assert_equal counter.count(:month), [{ timestamp: "2013-02", count: 6 }]
    assert_equal counter.count(:hour), [
      { timestamp: "2013-02-01 04:00", count: 0 },
      { timestamp: "2013-02-01 05:00", count: 0 },
      { timestamp: "2013-02-01 06:00", count: 0 },
      { timestamp: "2013-02-01 07:00", count: 5 },
      { timestamp: "2013-02-01 08:00", count: 0 },
      { timestamp: "2013-02-01 09:00", count: 1 }
    ]
  end
end
