require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

desc 'Run tests on all database adapters. See README.'
task :default => [:test_mysql, :test_sqlite3, :test_postgresql]

for adapter in %w(mysql postgresql sqlite3)
  Rake::TestTask.new("test_#{adapter}") { |t|
    t.libs << 'lib'
    t.pattern = "test/#{adapter}.rb"
    t.verbose = true
  }
end

PKG_RDOC_OPTS = ['--main=README',
                 '--line-numbers',
                 '--charset=utf-8',
                 '--promiscuous']

desc 'Generate documentation'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'doc'
  rdoc.title    = 'BetterNestedSet.'
  rdoc.options  = PKG_RDOC_OPTS
  rdoc.rdoc_files.include('README', 'lib/*.rb')
end
task :doc => :rdoc