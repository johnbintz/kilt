require 'pivotal-tracker'
require 'rufus/scheduler'
require 'time'
#require 'snarl' if RUBY_PLATFORM =~ /mswin|mingw|win32/

class Kilt
  attr_reader :id, :date_last_activity

  ICON = File.expand_path(File.join(File.dirname(__FILE__), '..', 'img', 'pivotal.png'))
  
  def date_last_activity
    # FIXME Diferença de 3hrs no UTC do Pivotal
    (@date_last_activity ||= Time.now) - 60*60*3
  end

  def self.init(token) 
    new token
  end
  
  def update
    activities = fetch_activities
    activities.reverse.each do |activity|
      if activity.occurred_at > date_last_activity
        notify_about activity.description
      end
    end
    update_date_from activities
  end

  protected

  def initialize(token)
    PivotalTracker::Client.token = token

    update_date_from fetch_activities
    Rufus::Scheduler.start_new.every('30s') { update }
  end

  private

  def update_date_from(activities)
    @date_last_activity = activities.first.occurred_at
  end

  def fetch_activities
    PivotalTracker::Activity.all(nil, :occurred_since_date => date_last_activity)
  end

  def notify_about(message)
    title = 'Pivotal Tracker'
    case RUBY_PLATFORM
    when /linux/
      system "notify-send '#{title}' '#{message}' --icon #{Kilt::ICON}"
    when /darwin/
      system "growlnotify -t '#{title}' -m '#{message}' --image #{Kilt::ICON}"
    # when /mswin|mingw|win32/
    #   Snarl.show_message title, message, Kilt::ICON
    end
  end
end
