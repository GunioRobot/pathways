class ::Visit
  include MongoMapper::EmbeddedDocument

  key :url,    String
  key :path,    String
  key :controller,    String
  key :action,   String
  key :params,   Hash
  key :time_active,  Integer
  key :created_at,  Integer
  key :updated_at,  Integer

  key :session_id,  ObjectId

  validates_uniqueness_of :created_at
end