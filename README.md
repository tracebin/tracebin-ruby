# tracebin-ruby

This is the official Ruby agent for Tracebin, a simple performance monitoring tool for web applications. Go to [traceb.in](https://traceb.in) to get started.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'tracebin'
```

And then execute:

```
$ bundle
```

Configure the gem to point to this bin:

```ruby
Tracebin::Agent.configure do |config|
  config.bin_id = '<YOUR BIN ID>'
end
```

## Configuration

There are several configuration options available for the Tracebin agent. Just set the options in a `configure` block on `Tracebin::Agent`:

```ruby
Tracebin::Agent.configure do |config|
  config.ignored_paths = ['/assets'] # Put any paths you wish to ignore in an array.

  if Rails.env.development? || Rails.env.test?
    config.enabled = false # You can completely disable the agent under the conditions of your choosing.
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/tracebin/tracebin-ruby. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Notes

### Storage and Reporting Strategy

Multiple threads are storing information in a thread-safe array. Every minute or so, we need to access that array, empty it, and send it to our service. If that data transfer fails (i.e., the response is not successful), that payload is simply re-added to the array and will be transmitted with the next try.
