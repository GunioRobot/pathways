module Pathways
  class Filter
      def self.map
        <<-JS
        function(){
          this.visits.forEach(function(visit){
            emit(visit.url, 1);
          });
        }
        JS
      end

      def self.reduce
        <<-JS
        function(prev, current) {
          var count = 0;

          for (index in current) {
              count += current[index];
          }

          return count;
        }
        JS
      end

      def self.tag_cloud(opts={})
        opts.merge({
          :out    => {:inline => true},
          :raw    => true
        })
        self.build(opts).find()
      end

      def self.build
        Pathways::Session.collection.map_reduce(map, reduce)
      end
  end
end