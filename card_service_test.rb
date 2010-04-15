require 'app'
require 'test/unit'
require 'shoulda'

set :environment, :test
MongoMapper.database = 'mini-card-test'

class CardServiceTest < Test::Unit::TestCase

  context "Card Service" do
    setup do
      Card.delete_all
      Tag.delete_all
      TagCardLk.delete_all
      @subject = CardService.new
    end  
    
    context "save card no tag" do
      should "save card" do
        expected = "card_text"
        card = Card.new(:text => expected)
        @subject.save!(card)
        assert_equal(expected, Card.last(:order => "created_at").text)
      end
    end

    context "save card with one new #tag" do
      setup do
        @expected_tag = "my_new_tag#{Time.now.to_s.gsub(" ", "_")}"
        @expected = "card_text ##{@expected_tag}"
        @card = Card.new(:text => @expected)
      end
      should "save card" do
        @subject.save!(@card)
        assert_save_card_lk_tag
      end      
    end

    context "save card with aleady one #tag" do
      setup do
        @expected_tag = "#{Time.now.to_s.gsub(" ", "_")}"
        Tag.new(:key => @expected_tag_key).save # 既存のタグ
        @expected = "card_text ##{@expected_tag}"
        @card = Card.new(:text => @expected)
      end
      
      should "save card" do
        @subject.save!(@card)
        assert_save_card_lk_tag
      end      
    end

    context "save card with some #tag" do
      setup do
        @expected_tag = "aleady#{Time.now.to_s.gsub(" ", "_")}"
        @expected_tag2 = "new#{Time.now.to_s.gsub(" ", "_")}"

        Tag.new(:key => @expected_tag_key).save # 既存のタグ
        @expected = "card_text ##{@expected_tag} ##{@expected_tag2}"
        @card = Card.new(:text => @expected)
      end
      
      should "save card" do
        @subject.save!(@card)
        actual_card = Card.last(:order => "created_at")
        assert_equal(@expected, actual_card.text)
        acutal_tag_keys = actual_card.tag_card_lks.map { |lk| lk.tag.key }.sort
        assert_equal 2, acutal_tag_keys.size
        assert_equal [@expected_tag, @expected_tag2].sort, acutal_tag_keys
      end      
    end
    
    context "save card with tag" do
      setup do
        s = CardService.new
        s.save!(Card.new(:text => "textA1 #memo_tag", :title => "A1"))
        s.save!(Card.new(:text => "textB1 #anther_tag", :title => "B1"))
        s.save!(Card.new(:text => "textA2 #memo_tag", :title => "A2"))
        t = Tag.find_by_key("memo_tag")
        assert_equal 2, t.cards.size
      end
      
      should "find card with tag" do
        t = Tag.find_by_key("memo_tag")
        assert_equal "textA2 #memo_tag", t.cards[0].text
        assert_equal "textA1 #memo_tag", t.cards[1].text
      end 
    end
  end
  
  def assert_save_card_lk_tag
    actual_card = Card.last(:order => "created_at")
    actual_tag = Tag.last(:order => "created_at")
    actual_lk  = TagCardLk.last(:order => "created_at")
  
    assert_equal(@expected, actual_card.text)
    assert_equal(@expected_tag, actual_tag.key)
    assert_not_nil(actual_lk.card)
    assert_not_nil(actual_lk.tag)
    assert_equal(actual_card, actual_lk.card)
    assert_equal(actual_tag, actual_lk.tag)
  end
end