module Pathways
  require 'mongo_mapper'
  require "pathways/tracker"
  require "pathways/filter"
  require "pathways/parser"
  require "pathways/server"
  require "pathways/session"
  require "pathways/visit"

  MongoMapper.connection = Mongo::Connection.new('localhost')
  MongoMapper.database = 'pathways'
end
