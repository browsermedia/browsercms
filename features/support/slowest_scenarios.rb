# Report on the slowest Scenarios
# From  http://itshouldbeuseful.wordpress.com/2010/11/10/find-your-slowest-running-cucumber-features/
# Other optimization resources include:
#   - cucumber --format usage (http://stackoverflow.com/questions/1265659/profiling-a-cucumber-test-ruby-rails)

should_report = false
scenario_times = {}

Around() do |scenario, block|
  start = Time.now
  block.call
  # Examples don't respond to features, so need guard clause
  scenario_times["#{scenario.feature.file}::#{scenario.name}"] = Time.now - start if scenario.respond_to?(:feature)

end

at_exit do
  if should_report
    max_scenarios = scenario_times.size > 20 ? 20 : scenario_times.size
    puts "------------- Top #{max_scenarios} slowest scenarios -------------"
    sorted_times = scenario_times.sort { |a, b| b[1] <=> a[1] }
    sorted_times[0..max_scenarios - 1].each do |key, value|
      puts "#{value.round(2)}  #{key}"
    end
  end
end