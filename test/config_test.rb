require 'test_helper'

describe Von::Config do

  before :each do
    @config = Von::Config
    @config.init!
  end

  it 'intiializes a config with defaults' do
    assert_equal @config.namespace, 'von'
    assert_equal @config.hourly_format, '%Y-%m-%d %H:00'
  end

  it 'initializes a config and overloads it with a block' do
    @config.namespace = 'something'
    assert_equal @config.namespace, 'something'
  end

  it "sets periods via counter method" do
    Von.configure do |config|
      config.counter 'bar', monthly: 3, daily: 6
    end

    assert_equal Von.config.periods[:bar].length, 2
    assert_equal Von.config.periods[:bar].first.name, :monthly
    assert_equal Von.config.periods[:bar].first.length, 3
    assert_equal Von.config.periods[:bar].last.name, :daily
    assert_equal Von.config.periods[:bar].last.length, 6
  end

  it "sets bests via counter method" do
    Von.configure do |config|
      config.counter 'bar', best: :day
      config.counter 'foo', best: [:month, :year]
    end

    assert Von.config.bests[:bar].first.is_a? Von::Period
    assert_equal Von.config.bests[:bar].first.name, :daily
    assert Von.config.bests[:foo].first.is_a? Von::Period
    assert_equal Von.config.bests[:foo].first.name, :monthly
    assert Von.config.bests[:foo].last.is_a? Von::Period
    assert_equal Von.config.bests[:foo].last.name, :yearly
  end

  it "sets currents via counter method" do
    Von.configure do |config|
      config.counter 'bar', current: :day
      config.counter 'foo', current: [:month, :year]
    end

    assert Von.config.currents[:bar].first.is_a? Von::Period
    assert_equal Von.config.currents[:bar].first.name, :daily
    assert Von.config.currents[:foo].first.is_a? Von::Period
    assert_equal Von.config.currents[:foo].first.name, :monthly
    assert Von.config.currents[:foo].last.is_a? Von::Period
    assert_equal Von.config.currents[:foo].last.name, :yearly
  end
end
