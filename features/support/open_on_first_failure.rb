# The first scenario that fails, we want to save and launch the page in the Browser.
# We don't want to to open subsequent failures, as that can be HIGHLY annoying when running from the command line.
#
# Also, this https://gist.github.com/398643
# has good info on how to save Assets/CSS so we can see the full version of the page.
#
module LaunchOnFirstFailure
  class << self
    attr_accessor :failed_tests
    def failure_occurred
      self.failed_tests = 0 unless failed_tests
      self.failed_tests += 1
    end
    def failed_tests?
      failed_tests && failed_tests >= 0
    end
  end
end

After('~@cli')do |scenario|
  if scenario.failed? && !LaunchOnFirstFailure.failed_tests? && ENV['launch_on_failure'] != 'false'
    LaunchOnFirstFailure.failure_occurred
    save_and_open_page
  end
end