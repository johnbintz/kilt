require 'rubygems'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'kilt'
require 'spec'
require 'spec/autorun'
require 'ruby-debug'

Spec::Runner.configure do |config|
  
end

def read(name)
  File.open(File.join(File.dirname(__FILE__), 'data', "#{name}.xml")).read
end

def latests_activities
  read "latests_activities"
end

def silence_warnings(&block)
  old_verbose, $VERBOSE = $VERBOSE, nil
  yield
ensure
  $VERBOSE = old_verbose
end

require 'fakeweb'

#FakeWeb.register_uri(:get, "http://www.pivotaltracker.com/services/v3/activities?limit=10", :body => latests_activities)
FakeWeb.register_uri(:get, %r|http://www.pivotaltracker\.com/|, :body => latests_activities)