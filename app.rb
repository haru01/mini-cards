require 'rubygems'
require 'sinatra'
require "models"
require "card_service"
require "uri"

limit = 50
service = CardService.new
 
get '/' do
  redirect "/cards/page/1"
end

get '/cards/page/:page' do |page|
  @card = Card.new
  @current_page = page.to_i
  @cards = Card.all(:order => "created_at desc", :limit => limit, :offset => (@current_page - 1) * limit )
  haml :index
end

post "/cards" do
  @card = Card.new(params[:card])
  @card.title = @card._id  unless @card.title
  begin
    service.save!(@card)
    haml '%pre.text= @card.r_text', :locals => { :text => @card.r_text }, :layout => false
  rescue Exception => e
    haml '%p.error= error', :locals => { :error =>  e.message }, :layout => false    
  end
end

get '/cards/tagged/:key' do |key|
  @cards = Tag.find_by_key(key).cards
  puts @cards[0].text
  @current_page = 1
  haml :index
end

get '/cards/title/:title' do |title|
  @title = title
  @card = Card.find_by_title(title)
  if @card == nil
    @card = Card.create(:title => title, :text => "無")
  end
  haml :card
end

post '/cards/title/:title/save' do |title|
  @card = Card.find_by_id(params[:id])
  @card.attributes = params[:card]
  @card.save
  redirect "/cards/title/#{URI.escape title}"
end

get '/stylesheet.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass :stylesheet
end

get '/hello/:name' do |name|
  "Hello!" + name
end