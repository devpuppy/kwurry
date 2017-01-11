# Kwurry

Add `Proc#kwurry` to curry kwargs

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'kwurry'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install kwurry

## Usage

```ruby
require 'kwurry/proc'
```

Or, to use it more cautiously as a refinement:

```ruby
class MyClass
  using Kwurry
  ...
end
```

Now let's curry a kwargs lambda with `kwurry`:

```ruby
mult = ->(multiplier:, multiplicand:) { multiplier * multiplicand }
mult_100 = mult.kwurry.(multiplicand: 100)
mult_100.(multiplier: 5)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/kwurry. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

