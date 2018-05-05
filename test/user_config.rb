#
#
#

ICS_URI  = 'http://www.google.com/calendar/ical/japanese@holiday.calendar.google.com/public/basic.ics'
ICS_DIR  = "pattern/ics"
ICS_FILE = File.basename ICS_URI


# user-defined ics methods (override NetCache).
#
#
class CalendarDays

  def repo_uri
    ICS_URI
  end
  def repo_dir
    File.join(__dir__, ICS_DIR)
  end
  def repo_file
    File.basename repo_uri
  end

end

####
