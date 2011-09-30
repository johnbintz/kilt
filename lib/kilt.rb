require 'pivotal-tracker'
require 'rufus/scheduler'
require 'time'
#require 'snarl' if RUBY_PLATFORM =~ /mswin|mingw|win32/

class Kilt
  attr_reader :id, :date_last_activity

  ICON = File.expand_path(File.join(File.dirname(__FILE__), '..', 'img', 'pivotal.png'))
  
  def self.init(token) 
    new token
  end
  
  def update
    (activities = fetch_activities).each do |activity|
      if (time = activity.occurred_at.to_time) > date_last_activity
        notify_about activity
      end
    end

    @date_last_activity = activities.first.occurred_at.to_time if activities.first
  end

  protected
  def initialize(token)
    case RUBY_PLATFORM
    when /darwin/
      require 'growl_notify'

      GrowlNotify.config do |c|
        c.notifications = %w{Kilt}
        c.default_notifications = c.notifications
        c.application_name = c.notifications.first
        c.icon = Kilt::ICON
      end
    end

    notify "Kilt starting...", "Fetching projects and activity stream from Pivotal Tracker..."
    @date_last_activity = Time.now - (60 * 60 * 24)

    PivotalTracker::Client.token = token

    @projects = Hash[PivotalTracker::Project.all.collect { |project| [ project.id, project ] }]

    Rufus::Scheduler.start_new.every('30s') { update }
  end

  private
  def fetch_activities
    PivotalTracker::Activity.all(nil, :occurred_since_date => date_last_activity)
  end

  def notify_about(activity)
    notify(@projects[activity.project_id].name, activity.description)
  end

  def notify(title, message)
    case RUBY_PLATFORM
    when /linux/
      system "notify-send '#{title}' '#{message}' --icon #{Kilt::ICON}"
    when /darwin/
      GrowlNotify.normal(:title => title, :description => message)
    # when /mswin|mingw|win32/
    #   Snarl.show_message title, message, Kilt::ICON
    end
  end
end
