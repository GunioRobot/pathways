module Pathways
  class Session
    include MongoMapper::Document

    key :ip, String
    key :state, String
    key :user_id,  Integer
    key :time_active,  Integer
    key :created_at,  Integer
    key :updated_at,  Integer

    many :visits

    # Other stuff...

    def self.path_map
      <<-MAP
        function() {
          id = this.ip
          this.visits.forEach(function(visit) {
            emit(visit.path, { id: visit.session_id });
          });
        }
      MAP
    end

    def self.path_reduce
      <<-REDUCE
      function(key, values) {
            var sum = new Array();
            values.forEach(function(f) {
                sum.push(f.id);
            });
            return { sessions: sum};
      };
      REDUCE
    end

    def self.controller_map
      <<-MAP
        function() {
          id = this.ip
          this.visits.forEach(function(visit) {
            emit(visit.controller + ":" + visit.action, { id: visit.session_id });
          });
        }
      MAP
    end

    def self.controller_reduce
      <<-REDUCE
      function(key, values) {
            var sum = new Array();
            values.forEach(function(f) {
                sum.push(f.id);
            });
            return { sessions: sum};
      };
      REDUCE
    end


    def self.finder_build(opts={})
      if opts[:filter] == "controller_action"
        self.collection.map_reduce(self.controller_map, self.controller_reduce, opts)
      else
        self.collection.map_reduce(self.path_map, self.path_reduce, opts)
      end
    end

    def self.popular_pages(opts={})
      opts.merge!({
        :out    => {:inline => true},
        :raw    => true
      })
      results = self.finder_build(opts).find()
      pages = {}
      results.to_a.first.last.each do | result |
        id = result["_id"]
        sessions = result["value"]["sessions"].try(:uniq)
        next if sessions.nil?
        pages[id] = sessions
      end
      return pages.sort_by{|k,v|-v.size}
    end

  end
end