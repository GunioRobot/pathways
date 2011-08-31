module Pathways
  module Tracker
    def log_visit
      Rails.logger.info "PathwaysTracker:" << { :url => request.url,
        :request_method => request.method,
        :path => request.request_uri,
        :controller => controller_name,
        :action => action_name,
        :params => params,
        :ip => request.ip,
        :created_at => Time.now,
        :user_id => (current_user) ? current_user.id : nil}.to_json
    end
  end
end