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
  key :title, String, :unique => true
  key :text, String, :required  => true
  many :tag_card_lks
  timestamps!
  
  def r_text
    taged_text = text.gsub(/(#[^\s\n]+)/){ "<a href='/cards/tagged/#{$1[1..-1]}'>#{$1}</a>" }
    taged_text.gsub(/\[([^\[\]]+)\]/){ "<a href='/cards/title/#{$1}'>#{$1}</a>" }
  end
  
  # def link_cards
  #   Link.all(:from_id => self._id, :order => "no").map{|lk| lk.to }
  # end
  # 
  # def linked_cards
  #   Link.all(:to_id => self._id, :order => "no").map{|lk| lk.from }
  # end
end

# class Link
#   include MongoMapper::Document
#   key :no, Integer
#   key :from_id, ObjectId
#   key :to_id, ObjectId
#   timestamps!
#   
#   belongs_to :from, :class_name => 'Card'
#   belongs_to :to, :class_name => 'Card'
# end
