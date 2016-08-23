require 'rubygems'
require 'sinatra'
require 'twilio-ruby'

# Load configuration from system environment variables - see the README for more
# on these variables.
TWILIO_ACCOUNT_SID = "AC889ac7aa02337f7c1b23d8179bf97227"
TWILIO_AUTH_TOKEN = "e58a822608938316f945ba1e2d75326a"
TWILIO_NUMBER = 15014830254

set :bind, '0.0.0.0'
set :port, ENV['TWILIO_STARTER_RUBY_PORT'] || 4567

# Create an authenticated client to call Twilio's REST API
client = Twilio::REST::Client.new TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN

# Sinatra route for your app's home page at "http://localhost:4567/" or your
# public web server
get '/' do
  erb :index
end

# Handle a form POST to send a message
post '/message' do
  # Use the REST API client to send a text message
  client.account.sms.messages.create(
    :from => TWILIO_NUMBER,
    :to => params[:to],
    :body => 'Good luck on your Twilio quest!'
  )

  # Send back a message indicating the text is inbound
  'Message on the way!'
end

# Handle a form POST to make a call
post '/call' do
  # Use the REST API client to make an outbound call
  client.account.calls.create(
    :from => TWILIO_NUMBER,
    :to => params[:to],
    :url => 'http://twimlets.com/message?Message%5B0%5D=http://zeldauniverse.s3.amazonaws.com/soundtracks/legendofzeldaost/01%20-%20Intro.mp3'
  )

  # Send back a text string with just a "hooray" message
  'Call is inbound!'
end


# Render a TwiML document that will say a message back to the user
get '/hello' do
  # Build a TwiML response
  response = Twilio::TwiML::Response.new do |r|
    r.Say "hello!"
    r.Gather :numDigits => '1', :action => '/hello/gather_music', :method => 'get' do |g|
      g.Say "If you want to hear some sweet music, press 1. Otherwise, be boring and press any other key"
    end
  end
  # Render an XML (TwiML) document
  content_type 'text/xml'
  response.text
end

get '/hello/gather_music' do
  redirect '/hello' unless params['Digits'] == '1'
  Twilio::TwiML::Response.new do |r|
    r.Play "http://zeldauniverse.s3.amazonaws.com/soundtracks/legendofzeldaost/01%20-%20Intro.mp3"
  end.text
end