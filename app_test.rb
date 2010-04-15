require 'app'
require 'test/unit'
require 'rack/test'
require 'shoulda'
require "webrat"
require "card_service_test"

set :environment, :test
MongoMapper.database = 'mini-card-test'



Webrat.configure do |config|
  config.mode = :rack
end

class AppTest < Test::Unit::TestCase
  include Rack::Test::Methods
  include Webrat::Methods
  include Webrat::Matchers
  include Webrat::HaveTagMatcher

  def app
    Sinatra::Application.new
  end
  
  context "app" do
    setup do
      Card.delete_all
      Tag.delete_all
      TagCardLk.delete_all
    end
    
    context "visit /cards/1" do
      setup do
        # arrange
        150.times {|i|
          Card.create!(:title => "title#{i}" , :text => "text" + i.to_s)
        }
        visit "/cards/1"
      end

      should "入力フォームが表示される" do
        # assert
        assert_have_tag("form[@method='post'][@action='/cards']")
      end

      should "カード一覧が表示されている" do
        limit = 50
        assert_have_tag("pre", :class => "text", :count => limit)
      end

      context "ポストした場合" do
        setup do
          @expect_text = "a living world"
          # act
          fill_in "text", :with => @expect_text
          click_button "post"          
        end

        should "ポストした内容をのテキストが表示される" do
          assert_have_selector("pre", :class => 'text', :content => @expect_text)
        end
        
        should "ポストした内容が保存される" do
          #assert
          assert_equal @expect_text, Card.last(:order => "created_at").text
        end
      end
    end

    context "#タグ付きでポストされた場合" do
      setup do
        @expect = "text #my_keyword"
        visit "/cards/1"
        # act
        fill_in "text", :with => @expect
        click_button "post"
      end
      
      should "カードがタグ付きで保存できること" do
        #assert
        assert_equal @expect, Tag.find_by_key("my_keyword").cards[0].text
      end
      
      should "タグでリンクされていること" do
        assert_have_tag "a", :href => "/cards/tagged/my_keyword", :content => "my_keyword"
      end
    end
    
    context "visit /cards/tagged/*" do
      context "あらかじめタグ付けされたカードが保存されている" do
        setup do
          s = CardService.new
          2.times {|i|
            s.save!(Card.new(:text => "textA#{i} #memo_tag"))
            s.save!(Card.new(:text => "textB#{i} #anther_tag"))
          }
          s.save!(Card.new(:text => "textAA #memo_tag"))
          visit "/cards/tagged/memo_tag"
        end

        should "タグに関連したカード要素が表示されること" do
          assert_contain "textA"
          assert_have_tag("pre", :class => "text", :count => 3)
          assert_not_contain "textB"
        end
      end
    end
  end
end