require 'rest_client'
require 'crack/xml'
require 'rufus/scheduler'
#require 'snarl' if RUBY_PLATFORM =~ /mswin|mingw|win32/

class Kilt
  include Crack

  attr_reader :id, :date_last_activity

  ICON = File.expand_path(File.join(File.dirname(__FILE__), '..', 'img', 'pivotal.png'))
  
  def date_last_activity
    # FIXME Diferença de 3hrs no UTC do Pivotal
    (@date_last_activity ||= Time.now) - 60*60*3
  end
  
  
  def self.init(token) 
    new token
  end
  
  def pivotal_format_date
    URI.escape(date_last_activity.strftime("%Y/%m/%d %H:%M:%S"))
  end
  
  def update
    activities = fetch_activities
    activities.reverse.each do |activity|
      if activity['occurred_at'] > @date_last_activity
        notify_about activity['description']
      end
    end
    update_date_from activities
  end

  protected

  def initialize(token)
    @token = token
    update_date_from fetch_activities
    Rufus::Scheduler.start_new.every('30s') { update }
  end

  private

  def update_date_from(activities)
    #@id                 = activities.first['id'].to_s
    @date_last_activity = activities.first['occurred_at']
  end

  def fetch_activities
    return XML.parse(RestClient.get("http://www.pivotaltracker.com/services/v3/activities?occurred_since_date=#{pivotal_format_date}",
                                    'X-TrackerToken' => @token).body)['activities']
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