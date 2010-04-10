require 'rubygems'
require 'mongo_mapper'

MongoMapper.database = 'mini-card'

class Tag
  include MongoMapper::Document
    
  key :key, String, :required  => true, :unique => true
  timestamps!
end

class Card
  include MongoMapper::Document
  
  key :title, String
  key :text, String, :required  => true
  timestamps!
end