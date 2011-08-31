# require 'resque/tasks'
# will give you the resque tasks

namespace :pathways do
  task :setup

  desc "Start a Resque worker"
  task :work => :setup do
    while true
      puts "wtf"
      sleep 10;
    end
  end
end
