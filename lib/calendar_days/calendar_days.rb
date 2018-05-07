#
#
#

require 'icalendar'
require 'date'

require "calendar_days/net_cache"


#
#
#
# class CalendarDays < ::DateTime
class CalendarDays

  include NetCache

end


#
#
#
class CalendarDays

  def to_s_date( date )
    date.to_s.gsub(/T.+$/, '')
  end

  def date_to_datetime( date )
    date = DateTime.parse(date) if date.is_a? ::String
    date
  end

  def valid_date?(date_since = self.since, date_until = self.until)
    if ics_start <= date_since and date_until <= ics_end
      true
    else
      false
    end
  end

  #
  # ==== Args
  # _y :: year[opt.]
  # _m :: month[opt.]
  #
  def initialize( _y = nil, _m = nil )

    #
    self.prepare_repo
    ics_file    = File.open(repo_file_fullpath)
    @ics_events = Icalendar::Event.parse(ics_file).sort_by{|ev| ev.dtstart.to_datetime}
    ics_file.close

    @since_year  = (_y || self.ics_start.year).to_i
    @since_month = (_m ||  1).to_i
    @since_day   = 1

    @until_year  = (_y || self.ics_end.year).to_i

    #ng. @until_month = _m || (_y.nil?)? self.ics_end.month : 12
    @until_month = (_m || ((_y.nil?)? self.ics_end.month : 12)).to_i
    @until_day   = DateTime.new(@until_year, @until_month, -1).day


    raise ArgumentError, "You specified #{[_y, _m].compact.join(' and ')}."+
      " Specify year (and month) in the date range #{to_s_date(ics_start)}"+
      " - #{to_s_date(ics_end)}." unless valid_date?

    self
  end

  attr_reader :since_year, :since_month, :since_day
  attr_reader :until_year, :until_month, :until_day
  attr_reader :ics_events

  def since; DateTime.new(since_year, since_month, since_day); end
  def until; DateTime.new(until_year, until_month, until_day); end

  def __ics_start
    ics_events.first.dtstart.to_datetime
  end
  def __ics_end
    ics_events.last.dtstart.to_datetime
  end
  def ics_start
    tmp = __ics_start
    DateTime.new(tmp.year, tmp.month, 1)
  end
  def ics_end
    tmp = __ics_end
    DateTime.new(tmp.year, tmp.month, -1)
  end
  alias :ics_since :ics_start
  alias :ics_until :ics_end

end


#
#
#
class CalendarDays

  # get the weekdays from the specified date range except saturday, sunday, and holiday.
  # 指定した年(もしくは月)の平日 Weekday (土日祝日を抜いた日) を得る
  #
  #
  def __weekday_list( dt_since = self.since, dt_until = self.until )
    (dt_since..dt_until).select{|d| yield(d) }
  end

  # get the weekdays from the user-specified date range.
  #
  #
  def weekday_list
    __weekday_list{|dt|
      not(is_weekend?(dt)) and not(is_holiday?(dt))
    }
  end

  # get the weekdays defined in the ics file.
  #
  #
  def ics_weekday_list
    __weekday_list(ics_start, ics_end){|dt|
      not(is_weekend?(dt)) and not(is_holiday?(dt))
    }
  end

  alias :week_days      :weekday_list
  alias :working_days   :weekday_list
  alias :buisiness_days :weekday_list

  alias :weekdays      :weekday_list
  alias :workingdays   :weekday_list
  alias :buisinessdays :weekday_list

  alias :ics_week_days     :ics_weekday_list
  alias :ics_working_days  :ics_weekday_list
  alias :ics_business_days :ics_weekday_list

  alias :ics_weekdays     :ics_weekday_list
  alias :ics_workingdays  :ics_weekday_list
  alias :ics_businessdays :ics_weekday_list

  # get saturdays and sundays.
  # ==== Attention
  # there exists such days which are both weekend and holiday.
  def weekend_list
    __weekday_list{|dt| is_weekend?(dt) }
  end
  def ics_weekend_list
    __weekday_list(ics_start, ics_end){|dt| is_weekend?(dt) }
  end
  alias :weekends     :weekend_list
  alias :ics_weekends :ics_weekend_list

  #
  #
  #
  def is_saturday?( date )
    date_to_datetime(date).saturday?
  end
  alias :is_sat?   :is_saturday?
  alias :saturday? :is_saturday?

  def is_sunday?( date )
    date_to_datetime(date).sunday?
  end
  alias :is_sun? :is_sunday?
  alias :sunday? :is_sunday?

  def is_weekend?(date)
    is_saturday?(date) or is_sunday?(date)
  end
  alias :weekend? :is_weekend?

end


#
#
#
class CalendarDays

  # all holidays defined in ics file.
  #
  #
  def ics_holiday_list( events: self.ics_events )
    events.map{|ev| [ev.dtstart.to_datetime, ev.summary] }
  end
  alias :ics_holidays :ics_holiday_list

  # holidays in since..until
  #
  #
  def holiday_list( events: self.ics_events )
    idx_since = ics_holiday_list.bsearch_index{|al| self.since <= al.first }
    idx_until = ics_holiday_list.bsearch_index{|al| self.until <= al.first } - 1
    # $stderr.puts "idx_since: #{idx_since}, idx_until: #{idx_until}"
    ics_holiday_list[idx_since..idx_until]
  end
  alias :holidays :holiday_list

  def is_holiday?( date )
    if date.is_a? ::String
      date = DateTime.parse(date)
    end
    __dt = date

    #
    dt_first = ics_events().first.dtstart.to_datetime
    dt_last  = ics_events().last.dtstart.to_datetime
    if __dt.year < dt_first.year
      # return nil
      raise ArgumentError,
        "year #{__dt.year} in #{date} is too old;" \
        " specify after #{dt_first.year}."
    elsif __dt.year > dt_last.year
      # return nil
      raise ArgumentError,
        "year #{__dt.year} in #{date} is too new;" \
        " specify before #{dt_last.year}."
    end

    dt = __dt.to_s.gsub(/T.+$/, '')
    holiday_list.map{|e| e.first.to_s }.grep( /^#{dt}/ ).size > 0
  end
  alias :holiday? :is_holiday?

  def holiday_name( date )
    if date.is_a? ::String
      date = DateTime.parse(date)
    end
    __dt = date
    dt = __dt.to_s.gsub(/T.+$/, '')

    if is_holiday?(date)
      holiday_list.select{|e| e.first.to_s =~ /^#{dt}/}.first.last
    else
      nil
    end
  end

  # get the date of holiday from name.
  # ==== Args
  # name :: name of holiday.
  # ==== Return
  # Name or [ Name, ... ] (in case two or more dates are matched)
  def holiday_date( name )
    ret = unless block_given?
            holiday_list.select{|e| e.last =~ /#{name}/i }.map{|e| e.first }
          else
            holiday_list.select{|e| yield(e) }.map{|e| e.first }
          end
    ret = ret.first if ret.size == 1
    ret
  end

end


####
