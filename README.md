# Xerohttp

For fun wrapper around httprb

## Filtered logging
Filters sensitive information out of logging
```ruby
XeroHTTP.filtered_logging(logger, filters: [/Authorization/])
```

## Raise for status
Raises when http request returns 400/500.
```ruby
XeroHTTP.raise_for_status(except: [])
```

## Downloading a file
```ruby
XeroHTTP.download(url, destination) do |chunk|
  
end
```

## Streaming an object
```ruby
XeroHTTP.stream(url, io) do |chunk|
  
end
```
