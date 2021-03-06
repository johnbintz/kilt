require 'psych'

require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name                      = "kilt"
    gem.summary                   = "A client that listens to Pivotal Tracker activities and notifies them with Growl." 
    gem.description               = "A client that listens to Pivotal Tracker activities and notifies them with Growl."
    gem.email                     = "john@coswellproductions.com"
    gem.homepage                  = "http://github.com/johnbintz/kilt"
    gem.authors                   = ["Original - Diego Carrion", "Marco Singer", "John Bintz"]
    gem.add_dependency              "pivotal-tracker"
    gem.add_dependency              "rufus-scheduler"
    gem.add_development_dependency  "rspec"
    gem.add_development_dependency  "fakeweb"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :spec => :check_dependencies

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "pivotal-tracker-client #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
