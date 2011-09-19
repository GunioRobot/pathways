module Pathways
  module Tracker

    mattr_accessor :iteration

    def log_visit

      unless client_id = cookies[:pathways_token]
        client_id = Digest::MD5.hexdigest("#{request.ip}:#{Time.now}")
        cookies[:pathways_token] = {
          :value => client_id,
          :expires => 20.years.from_now.utc
        }
      end

      Rails.logger.info "PathwaysTracker:" << { :url => request.url,
        :request_method => request.method,
        :path => request.request_uri,
        :controller => controller_name,
        :action => action_name,
        :params => params,
        :ip => request.ip,
        :client_id => client_id,
        :created_at => Time.now,
        :iteration => Pathways::Tracker.iteration,
        :user_id => (current_user) ? current_user.id : nil}.to_json
    end
  end
end