require 'rubygems'
require 'sinatra'
require "models"
require "card_service"

limit = 50

get '/' do
  redirect "/cards/1"
end

get '/cards/:page' do |page|
  @card = Card.new
  @current_page = page.to_i
  @cards = Card.all(:order => "created_at desc", :limit => limit, :offset => (@current_page - 1) * limit )
  haml :index
end

post "/cards" do
  @card = Card.new(params[:card])
  @card.text = @card.text.gsub("\n", "<br/>").gsub("\s", "&nbsp;")
  if (@card.save)
    haml '%p.text= text', :locals => { :text => @card.text }, :layout => false
  else
    haml '%p.error error', :locals => { :card => @card }, :layout => false
  end
end

get '/stylesheet.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass :stylesheet
end

get '/hello/:name' do |name|
  "Hello!" + name
end