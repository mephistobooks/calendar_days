
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "calendar_days/version"

Gem::Specification.new do |spec|
  spec.name          = "calendar_days"
  spec.version       = CalendarDays::VERSION
  spec.authors       = ["YAMAMOTO, Masayuki"]
  spec.email         = ["martin.route66.blues+github@gmail.com"]

  spec.summary       = %q{calendar_days.gem is to know weekdays, holidays and weekends.}
  spec.description   = %q{calendar_days uses webcal (ics file). the installation of icalendar.gem is needed.}
  spec.homepage      = "TODO: Put your gem's website or public repo URL here."
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  # spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "test-unit", "~> 3.2"
  spec.add_development_dependency "icalendar", "~> 2.4"
end
