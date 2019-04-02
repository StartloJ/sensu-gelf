## Sensu-Plugins-gelf

[![Gem Version](https://badge.fury.io/rb/sensu-plugins-gelf.svg)](http://badge.fury.io/rb/sensu-plugins-gelf)
[![Dependency Status](https://gemnasium.com/sensu-plugins/sensu-plugins-gelf.svg)](https://gemnasium.com/sensu-plugins/sensu-plugins-gelf)

## Functionality
Handler
- **handler-gelf.rb**


## Files
 * bin/handler-gelf.rb

## Usage
### Example with use optional [json_config]
sensu/conf.d/gelf.json
```json
{
  "gelf": {
    "server": "graylog.dom.tld",
    "port": "12201"
  }
}
```
\
sensu/conf.d/handler/handlers-gelf.json
```json
{
  "handlers": {
    "gelf": {
      "type": "pipe",
      "command": "handler-gelf.rb --json 'gelf'",
    }
  }
}
```

## Installation
This not official plugin you must use `./gem` in path [ `/opt/sensu/embedded/bin/` ] \n
* install [specific_install](https://github.com/rdp/specific_install) in gem lib.
```
sudo ./gem install specific_install
```
* install sensu-gelf plugins with specific_install
```
sudo ./gem specific_install https://github.com/StartloJ/sensu-gelf.git
```

## Notes