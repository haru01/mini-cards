require 'rubygems'
require 'mongo_mapper'

MongoMapper.database = 'mini-card'

class Tag
  include MongoMapper::Document
  key :key, String, :required  => true, :unique => true
  many :tag_card_lks, :order =>  'created_at desc'
  timestamps!
  
  #throught あるっけ
  def cards
    tag_card_lks.map{|lk| lk.card }
  end
  
end

class TagCardLk
  include MongoMapper::Document
  key :tag_id, ObjectId
  key :card_id, ObjectId
  timestamps!
  
  belongs_to :tag
  belongs_to :card
end

class Card
  include MongoMapper::Document
  
  key :text, String, :required  => true
  many :tag_card_lks
  timestamps!
  
  def r_text
    text.gsub(/(#[^\s\n]+)/){ "<a href='/cards/tagged/#{$1[1..-1]}'>#{$1}</a>" }
  end
end

