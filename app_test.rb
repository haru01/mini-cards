require 'app'
require 'test/unit'
require 'rack/test'
require 'shoulda'
require "webrat"

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
        Card.delete_all
        150.times {|i|
          Card.new(:text => "text" + i.to_s).save
        }
        visit "/cards/1"
      end

      should "have form" do
        # assert
        assert_have_tag("form[@method='post'][@action='/cards']")
      end

      should "have limit size cards" do
        limit = 50
        assert_have_tag("p", :class => "text", :count => limit)
      end

      should "post card" do
        # act
        expect_text = "a living world #keyword"
        fill_in "text", :with => expect_text
        click_button "post"
        #assert
        expect_render_text = "a&nbsp;living&nbsp;world&nbsp;#keyword"
        assert_have_selector("p", :class => 'text')
        assert_equal expect_text, Card.last(:order => "created_at").text
        assert last_response.body.include?(expect_render_text)
        assert_equal expect_text, Tag.find_by_key("keyword").cards[0].text
      end
    end

    context "visit /cards/tagged/*" do
      setup do
        s = CardService.new
        2.times {|i|
          s.save!(Card.new(:text => "textA#{i} #memo_tag"))
          s.save!(Card.new(:text => "textB#{i} #anther_tag"))
        }
        s.save!(Card.new(:text => "textAA #memo_tag"))
      end

      should "select cards whith tagged memo_tag" do
        visit "/cards/tagged/memo_tag"
        assert last_response.body.include? "textA"
        assert_have_tag("p", :class => "text", :count => 3)
        assert_not_contain "textB"
      end
    end
  end
end