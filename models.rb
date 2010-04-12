require 'rubygems'
require 'mongo_mapper'

MongoMapper.database = 'mini-card'

class Tag
  include MongoMapper::Document
  key :key, String, :required  => true, :unique => true
  many :tag_card_lks
  
  #throught あるっけ
  def cards
    tag_card_lks.map{|lk| lk.card }
  end
  
  timestamps!
end

class TagCardLk
  include MongoMapper::Document
  key :tag_id, ObjectId
  key :card_id, ObjectId
  
  belongs_to :tag
  belongs_to :card
end

class Card
  include MongoMapper::Document
  
  key :text, String, :required  => true
  many :tag_card_lks
  timestamps!
  
  def r_text
    text.gsub("\n", "<br/>").gsub("\s", "&nbsp;")
  end
end