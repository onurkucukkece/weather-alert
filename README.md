# Weather Alert

Sends a push message to iOs devices which are registered to topics in AWS SNS

## Usage

    $ bundle

Set the environment variables and run

    $ ruby weather-alert.rb
    
For development, create a file Procfile.dev.env, set the variables in and run

    $ foreman run -e Procfile.dev.env ruby weather-alert.rb

### Environment Variables

```
OPENWEATHER_APPID
PLATFORM_ENDPOINT
AWS_REGION
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
```
