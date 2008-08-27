require 'yaml'
require 'erb'

class SeleniumOnRailsConfig
  @@defaults = {:environments => ['test']}
  def self.get var, default = nil
    value = configs[var.to_s]
    value ||= @@defaults[var]
    value ||= default
    value ||= yield if block_given?
    value
  end

  private
    def self.configs
      unless defined? @@configs
        files = [File.expand_path(File.dirname(__FILE__) + '/../config.yml')]
        if RUBY_PLATFORM =~ /mswin/
          files << File.join(RAILS_ROOT, 'config', 'platforms', 'windows', 'selenium.yml')
        #elsif RUBY_PLATFORM =~ /darwin/i && command =~ /safari/i
        else
          files << File.join(RAILS_ROOT, 'config', 'platforms', 'mac', 'selenium.yml')
        end
        files.each do |file|
          @@configs = YAML.load(ERB.new(IO.read(file)).result) if File.exist?(file)
        end
        @@configs ||= {}
      end
      @@configs
    end
end
