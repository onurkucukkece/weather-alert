require 'launchy'
require 'nokogiri'
require 'time'
require 'open-uri'
require 'openweather2'
require 'aws-sdk'

def init_aws
  Aws.config.update({
    region: ENV['AWS_REGION'],
    credentials: Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY'])
  })
end

def init_openweather
  Openweather2.configure do |config|
    config.endpoint = 'http://api.openweathermap.org/data/2.5/weather'
    config.apikey = ENV['OPENWEATHER_APPID']
  end
end

def run
  init_aws
  init_openweather

  # Istanbul average weather
  url = "http://www.holiday-weather.com/istanbul/averages/#{Time.now.strftime('%B')}/"
  page = Nokogiri::HTML(open(url))
  average = page.css('.destination-info').at('li:contains("High Temperature") .destination-info__details').text.to_i


  # Istanbul weather
  weather = Openweather2.get_weather(city: 'istanbul', units: 'metric')
  current = weather.temperature

  puts "Current: #{current}°C, Highest average: #{average}°C"

  # TODO: compare weather
  # puts "#{current - average} hot than average" if current - average > 4

  client = Aws::SNS::Client.new

  aps = {
    aps: {
      alert: "Weather is currently #{current.to_i.to_s}°C, highest average is: #{average.to_i.to_s}°C",
      sound: 'default',
      badge: 1
    }
  }

  payload = {
    default: "Weather is currently #{current.to_i.to_s}°C, highest average is: #{average.to_i.to_s}°C",
    APNS_SANDBOX: aps.to_json
  }

  resp = client.publish({
    message: payload.to_json,
    message_structure: 'json',
    target_arn: ENV['PLATFORM_ENDPOINT']
  })

end

run
