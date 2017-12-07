require 'launchy'

def run
  url = "http://www.holiday-weather.com/istanbul/averages/#{Time.now.strftime('%B')}/"
  puts "http://www.holiday-weather.com/istanbul/averages/#{Time.now.strftime('%B')}/"
  page = Nokogiri::HTML(open(url))
  average = page.css('.destination-info').at('li:contains("High Temperature") .destination-info__details').text.to_i


  # options = { units: "metric", APPID: ENV['OPENWEATHER_APPID'] }
  # weather = OpenWeather::Current.city('Istanbul, TR', options)
  weather = Openweather2.get_weather(city: 'istanbul', units: 'metric')
  current = weather.temperature

  puts "Current: #{current}, Highest average: #{average}"

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
