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
  
  context "visit /cards/1" do
    setup do
      # arrange
      Card.delete_all
      150.times {|i|
        Card.new(:text => "text" + i.to_s).save
      }
      visit "/cards/1"
    end
    
    should "have form tag" do
      # assert
      assert_have_tag("form[@method='post'][@action='/cards']")
    end

    should "have limit size cards" do
      limit = 50
      assert_have_tag("p", :class => "text", :count => limit)
    end
    
    should "post card" do
      # act
      fill_in "text", :with => "living a world\nwawawa"
      click_button "post"      
      #assert
      expect = "living&nbsp;a&nbsp;world<br/>"
      # assert_have_selector("p", :content => expect)
      assert_have_selector("p", :class => 'text')
      assert last_response.body.include?(expect)
      assert_equal expect, Card.last(:order => "created_at").text
    end
  end
end