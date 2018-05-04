#
#
#

require 'icalendar'
require 'date'

require "calendar_days/net_cache"


#
#
#
class CalendarDays < ::DateTime

  include NetCache

end


#
#
#
class CalendarDays
  #
  # https://stackoverflow.com/questions/9049123/why-does-date-new-not-call-initialize
  #
  def self.new( in_year = DateTime.now.year, since_month = nil )
    since_month_tmp = since_month || 1
    tmp = super(in_year, since_month_tmp, 1)
    tmp.instance_eval{ initialize(in_year, since_month) }
  end
  alias :in_year     :year
  alias :since_month :month
  alias :since_day   :day
  def since; DateTime.new(in_year, since_month, since_day); end

  def initialize( in_year, until_month = nil )

    until_month ||= 12
    @until_month = until_month
    @until_day   = DateTime.new(in_year, until_month, -1).day

    prepare_repo

    #
    ics_file    = File.open(repo_file_fullpath)
    @ics_events = Icalendar::Event.parse(ics_file).sort_by{|ev| ev.dtstart.to_datetime}
    ics_file.close

    self
  end
  attr_accessor :until_month, :until_day
  attr_reader   :ics_events
  def until; DateTime.new(in_year, until_month, until_day); end
  def ics_start
    ics_events.first.dtstart.to_datetime
  end
  def ics_end
    ics_events.last.dtstart.to_datetime
  end
  def ics_since; DateTime.new(ics_start.year, ics_start.month, ics_start.day); end
  def ics_until; DateTime.new(ics_end.year,   ics_end.month,   ics_end.day  ); end

end


#
#
#
class CalendarDays

  def date_to_datetime( date )
    date = DateTime.parse(date) if date.is_a? ::String
    date
  end

  # 指定した年(もしくは月)の平日 Weekday (土日祝日を抜いた日) を得る
  #
  #
  def __weekday_list
    ret = []

    dt_since = DateTime.new(in_year, since_month, since_day)
    dt_until = DateTime.new(in_year, until_month, until_day)

    dt_tmp = dt_since
    begin
      # if is_weekend?(dt_tmp) or is_holiday?(dt_tmp)
      if yield(dt_tmp)
        ret.push dt_tmp
      end

      dt_tmp += 1
    end while dt_tmp <= dt_until

    ret
  end
  def weekday_list
    ret = __weekday_list{|dt| not(is_weekend?(dt)) and not(is_holiday?(dt)) }
    ret
  end

  #
  # ==== Attention
  # there exists such days which are both weekend and holiday.
  def weekend_list
    ret = __weekday_list{|dt| is_weekend?(dt) }
    ret
  end
  alias :weekdays    :weekday_list
  alias :workingdays :weekday_list
  alias :weekends    :weekend_list

  def is_saturday?( date )
    date_to_datetime(date).saturday?
  end
  alias :is_sat? :is_saturday?
  alias :is_sat? :is_saturday?

  def is_sunday?( date )
    date_to_datetime(date).sunday?
  end
  alias :is_sun? :is_sunday?

  def is_weekend?(date)
    is_saturday?(date) or is_sunday?(date)
  end

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
