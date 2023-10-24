require 'test_helper'

describe Von::Period do
  Period = Von::Period

  before :each do
    @config = Von::Config
    @config.init!
    Timecop.freeze(Time.local(2013, 01, 02, 03, 04))
  end

  it "intiializes given a period" do
    period = Period.new(:monthly)
    assert_equal period.name, :monthly
    assert_nil period.length
    assert_equal period.format, '%Y-%m'
  end

  it "intiializes given a time unit" do
    period = Period.new(:month)
    assert_equal period.name, :monthly
    assert_nil period.length
    assert_equal period.format, '%Y-%m'
  end

  it "intiializes given a period and length" do
    period = Period.new(:monthly, 3)
    assert_equal period.name, :monthly
    assert_equal period.length, 3
    assert_equal period.format, '%Y-%m'
  end

  it "generates a timestamp for now" do
    assert_equal Period.new(:minutely).timestamp, '2013-01-02 03:04'
    assert_equal Period.new(:hourly).timestamp, '2013-01-02 03:00'
    assert_equal Period.new(:daily).timestamp, '2013-01-02'
    assert_equal Period.new(:weekly).timestamp, '2012-12-31'
    assert_equal Period.new(:monthly).timestamp, '2013-01'
    assert_equal Period.new(:yearly).timestamp, '2013'
  end

  it "knows the prev time period" do
    assert_equal Period.new(:minutely).prev, '2013-01-02 03:03'
    assert_equal Period.new(:hourly).prev, '2013-01-02 02:00'
    assert_equal Period.new(:daily).prev, '2013-01-01'
    assert_equal Period.new(:weekly).prev, '2012-12-24'
    assert_equal Period.new(:monthly).prev, '2012-12'
    assert_equal Period.new(:yearly).prev, '2012'
  end

  it "checks if the period is an hourly period" do
    assert !Period.new(:minutely).hours?
    assert Period.new(:hourly).hours?
    assert !Period.new(:daily).hours?
    assert !Period.new(:weekly).hours?
    assert !Period.new(:monthly).hours?
    assert !Period.new(:yearly).hours?
  end

  it "checks if the period is an hourly period" do
    assert Period.new(:minutely).minutes?
    assert !Period.new(:hourly).minutes?
    assert !Period.new(:daily).minutes?
    assert !Period.new(:weekly).minutes?
    assert !Period.new(:monthly).minutes?
    assert !Period.new(:yearly).minutes?
  end
  it "knows what time unit it is" do
    assert_equal Period.new(:minutely).time_unit, :minute
    assert_equal Period.new(:hourly).time_unit, :hour
    assert_equal Period.new(:daily).time_unit, :day
    assert_equal Period.new(:weekly).time_unit, :week
    assert_equal Period.new(:monthly).time_unit, :month
    assert_equal Period.new(:yearly).time_unit, :year
  end

  it "gets a time format from config" do
    assert_equal Period.new(:minutely).format, Von.config.minutely_format
    assert_equal Period.new(:hourly).format, Von.config.hourly_format
    assert_equal Period.new(:daily).format, Von.config.daily_format
    assert_equal Period.new(:weekly).format, Von.config.weekly_format
    assert_equal Period.new(:monthly).format, Von.config.monthly_format
    assert_equal Period.new(:yearly).format, Von.config.yearly_format
  end
end
