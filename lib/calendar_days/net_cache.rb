#
#
#
require 'fileutils'

module NetCache

  #
  # ==== Description
  # ユーザは, repo_{uri,dir,file}, およびdownload_repoを実装すればよい.
  #
  def repo_uri
    'http://files.apple.com/calendars/Japanese32Holidays.ics'
  end
  def repo_dir
    # "#{ENV['HOME']}/lib/ics"
    File.expand_path("~/lib/ics")
  end
  def repo_file
    "Japanese32Holidays.ics"
  end
  def repo_file_fullpath
    File.join(repo_dir, repo_file)
  end
  def download_repo
    ret = `curl -L '#{repo_uri}' -o '#{repo_file_fullpath}'; echo $?`.chomp.to_i
    ret
  end
  # module_function :repo_uri, :repo_dir, :repo_file
  # module_function :download_repo

  #
  def create_repo_dir
    unless repo_dir_exist?
      FileUtils.mkdir_p repo_dir
    end
  end
  def repo_dir_exist?
    File.exist? repo_dir
  end
  def repo_exist?
    File.exist? File.join(repo_dir, repo_file)
  end
  # module_function :create_repo_dir
  # module_function :repo_dir_exist?, :repo_exist?

  #
  def prepare_repo!
    create_repo_dir
    download_repo
  end
  def prepare_repo
    unless repo_exist?
      prepare_repo!
    else
      nil
    end
  end
  # module_function :prepare_repo!, :prepare_repo

end


####
