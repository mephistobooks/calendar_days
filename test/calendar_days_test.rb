# require "calendar_days"
require "test_helper"
require "user_config"


#
#
#
class CalendarDaysTest < Test::Unit::TestCase

  def self.startup

  end
  def self.shutdown
    FileUtils.rm_f File.join(__dir__, ICS_DIR, ICS_FILE)
  end

  def setup
    @cald_default    = CalendarDays.new('2018')
    @cald_no_arg     = CalendarDays.new()
    @cald_with_month = CalendarDays.new(2018, '5')
  end

  def teardown
  end

end


#
#
#
class CalendarDaysTest

  def test_exceptions

    ret = assert_raise(ArgumentError) do
      CalendarDays.new(1990)
    end
    exp = "You specified 1990. Specify year (and month) in the date range 2017-01-01 - 2019-11-30."
    assert_equal exp, ret.message

    ret = assert_raise(ArgumentError) do
      CalendarDays.new(3000, 5)
    end
    exp = "You specified 3000 and 5. Specify year (and month) in the date range 2017-01-01 - 2019-11-30."
    assert_equal exp, ret.message

  end

  def test_prepare_ics
    ret = @cald_default.repo_exist?
    exp = true
    assert_equal exp, ret

    ret = @cald_default.repo_file
    exp = "basic.ics"
    assert_equal exp, ret
  end

  def test_since_until
    ret = @cald_default.since.to_s
    exp = "2018-01-01"
    assert_match exp, ret

    ret = @cald_default.until.to_s
    exp = "2018-12-31"
    assert_match exp, ret

    ret = @cald_no_arg.since.to_s
    exp = "2017-01-01"
    assert_match exp, ret

    ret = @cald_no_arg.until.to_s
    exp = "2019-11-30"
    assert_match exp, ret

    ret = @cald_with_month.since.to_s
    exp = "2018-05-01"
    assert_match exp, ret

    ret = @cald_with_month.until.to_s
    exp = "2018-05-31"
    assert_match exp, ret

  end

  def test_ics_events

    ret = @cald_default.ics_events.size
    exp = 55
    assert_equal exp, ret

    ret = @cald_default.__ics_start.to_s
    exp = "2017-01-01"
    assert_match exp, ret

    ret = @cald_default.__ics_end.to_s
    exp = "2019-11-23"
    assert_match exp, ret

    ret = @cald_default.ics_since.to_s
    exp = "2017-01-01"
    assert_match exp, ret

    ret = @cald_default.ics_until.to_s
    exp = "2019-11-30"
    assert_match exp, ret

  end

  def test_weekday_list

    ret = @cald_default.weekdays.size
    exp = 248
    assert_equal exp, ret

    ret = @cald_default.weekdays.first.to_s
    exp = "2018-01-02"
    assert_match exp, ret

    ret = @cald_default.weekdays.last(8).map{|e| e.to_s.gsub(/T.+$/, '') }
    exp = [
      "2018-12-19", "2018-12-20", "2018-12-21",
      "2018-12-25", "2018-12-26", "2018-12-27", "2018-12-28",
      "2018-12-31", ]
    assert_equal exp, ret

  end

  def test_weekend_list

    ret = @cald_default.weekends.size
    exp = 104
    assert_equal exp, ret

    ret = @cald_default.weekends.first(8).map{|e| e.to_s.gsub(/T.+$/, '') }
    exp = [
      "2018-01-06", "2018-01-07",
      "2018-01-13", "2018-01-14",
      "2018-01-20", "2018-01-21",
      "2018-01-27", "2018-01-28",
    ]
    assert_equal exp, ret

    ret = @cald_default.weekends.last(8).map{|e| e.to_s.gsub(/T.+$/, '') }
    exp = [
      "2018-12-08", "2018-12-09",
      "2018-12-15", "2018-12-16",
      "2018-12-22", "2018-12-23",
      "2018-12-29", "2018-12-30",
    ]
    assert_equal exp, ret

    ret = @cald_default.is_saturday?("2018-12-29")
    exp = true
    assert_equal exp, ret

    ret = @cald_default.is_sunday?("2018-12-30")
    exp = true
    assert_equal exp, ret

    ret = @cald_default.is_weekend?("2018-12-30")
    exp = true
    assert_equal exp, ret

  end


  def test_holiday_list

    ret = @cald_default.ics_holidays.size
    exp = 55
    assert_equal exp, ret

    ret = @cald_default.holidays.size
    exp = 20
    assert_equal exp, ret

    ret = @cald_default.holidays.first(5).map{|al|
      [al.first.to_s.gsub(/T.+$/, ''), al.last] }
    exp = [
      ["2018-01-01", "New Year's Day"],
      ["2018-01-08", "Coming of Age Day"],
      ["2018-02-11", "National Foundation Day"],
      ["2018-02-12", "National Foundation Day observed"],
      ["2018-03-21", "Spring Equinox"]
    ]
    assert_equal exp, ret
    ret = @cald_default.holidays.last(5).map{|al|
      [al.first.to_s.gsub(/T.+$/, ''), al.last] }
    exp = [
      ["2018-10-08", "Sports Day"],
      ["2018-11-03", "Culture Day"],
      ["2018-11-23", "Labor Thanksgiving Day"],
      ["2018-12-23", "Emperor's Birthday"],
      ["2018-12-24", "Emperor's Birthday observed"],
    ]
    assert_equal exp, ret


    ret = @cald_default.is_holiday?("2018-05-03")
    exp = true
    assert_equal exp, ret

    ret = @cald_default.holiday_name("2018-05-03")
    exp = "Constitution Memorial Day"
    assert_equal exp, ret

    ret = @cald_default.holiday_date("Constitution Memorial Day").to_s
    exp = "2018-05-03"
    assert_match exp, ret

    ret = @cald_default.holiday_date("age").map{|dy| @cald_default.holiday_name(dy) }
    exp = ["Coming of Age Day", "Respect for the Aged Day"]
    assert_equal exp, ret

    ret = @cald_default.is_holiday?("2018-05-06")
    exp = false
    assert_equal exp, ret

    ret = @cald_default.is_weekend?("2018-05-06")
    exp = true
    assert_equal exp, ret

    ret = @cald_default.is_sunday?("2018-05-06")
    exp = true
    assert_equal exp, ret

  end


end
