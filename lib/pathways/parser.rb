require 'time'
require 'json'

module Pathways
  class Parser
    def initialize(env)
      path = "#{RAILS_ROOT}/log/#{env || Rails.env}.log"
      raise ArgumentError unless File.exists?( path )
      @log            = File.open( path )
    end

    def self.execute(env="development")
      parser = self.new(env)
      most_recent_session_updated_at = Pathways::Session.first(:order => "updated_at DESC").try(:updated_at)
      while true
        puts "Processing"
        parser.run(most_recent_session_updated_at)
        sleep 5;
      end
    end

    def run(most_recent_session_updated_at)
      visits = []
      @log.each_line do |line|

        next unless timestamp = line.match( /^PathwaysTracker\:(.*)/)
        visit_hash = JSON.parse(timestamp[1].to_s)

        session = Pathways::Session.find_or_create_by_client_id_and_state(visit_hash["client_id"], :active)
        session.update_attributes(:user_id => visit_hash["user_id"], :iteration => visit_hash["iteration"])

        updated_at = Time.parse(visit_hash["created_at"]).to_i
        next if most_recent_session_updated_at and updated_at < most_recent_session_updated_at
        session.created_at = updated_at if session.created_at.nil?
        session.updated_at = updated_at
        most_recent_session_updated_at = updated_at

        last_visit = session.visits.last
        unless last_visit.nil?
          next if last_visit.created_at == updated_at
          time_since_last_visit = updated_at.to_i - last_visit.created_at.to_i
          if time_since_last_visit > 600
            session.state = :closed
            session.save
            session = Pathways::Session.find_or_create_by_client_id_and_state(visit_hash["client_id"], :active)
            session.update_attributes(:user_id => visit_hash["user_id"], :iteration => visit_hash["iteration"])
            session.created_at = updated_at
          end
          last_visit.time_active =  (time_since_last_visit > 60) ? 60 : time_since_last_visit
        end
        puts session.inspect
        session.updated_at = updated_at
        visit_opts = {}
        [:url, :path, :controller, :action].each do | key |
          visit_opts[key] = visit_hash[key.to_s]
        end
        [:created_at].each do | key |
          visit_opts[key] = Time.parse(visit_hash[key.to_s]).to_i
        end
        visit_opts[:session_id] = session.id
        session.visits << Visit.new(visit_opts)
        session.time_active = session.updated_at - session.created_at
        session.save
        puts session.visits.last.inspect
      end
    end
  end
end