
[![Gem Version](https://badge.fury.io/rb/doyoubuzz-showcase.svg)](http://badge.fury.io/rb/doyoubuzz-showcase) [![Build Status](https://api.travis-ci.org/mru2/doyoubuzz-showcase.svg)](https://travis-ci.org/mru2/doyoubuzz-showcase) [![Coverage Status](https://coveralls.io/repos/mru2/doyoubuzz-showcase/badge.png?branch=master)](https://coveralls.io/r/mru2/doyoubuzz-showcase?branch=master) [![Code Climate](https://codeclimate.com/github/mru2/doyoubuzz-showcase/badges/gpa.svg)](https://codeclimate.com/github/mru2/doyoubuzz-showcase)

# Doyoubuzz::Showcase

## Description

The `doyoubuzz-showcase` gem is a thin ruby wrapper for the DoYouBuzz Showcase API. Based around the HTTParty gem, it handles the authorization and HTTP calls, and wraps the results in a Hashie::Mash for a simpler usage.

## Requirements

- httparty
- hashie

## Installation

Add this line to your application's Gemfile:

    gem 'doyoubuzz-showcase'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install doyoubuzz-showcase

## Usage


### Authentication

    # Authenticate with your API credentials
    client = Doyoubuzz::Showcase.new('your_api_key', 'your_api_secret')

### Querying

    # Getting a results collection
    response = client.get '/users'

    puts response.users.items.first.email
    # $ john.doe@domain.com

### Queries with parameters

    # Get another page
    response = client.get '/users', :page => 2


### HTTP Verbs support

    # Associate a tag to a user
    response = client.put '/users/12345/associateTags', :tags => [12, 13, 14]


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
