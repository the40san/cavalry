# Cavalry

Cavalry is whole data validation DSL.


# Strength

The situation: When you need to validate some data, with foreign-key or has some constraints on associations(like Online-game's master-data), you need to insert all data first for validation.

Cavalry can:
  1. Write some validation with DSL like ActiveModel implementation.
  2. Validate to each records, or grouped records.
  3. Validations will not depend it's data-model.
  3. Integrate friendly.

# Workflow

1. Prepare your data via ActiveModel or Insert your data to database via ActiveRecord. (like rake db:seed)
2. Write your Validation
3. Run Cavalry.run
4. Fix the data if you need.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cavalry'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cavalry

## Usage

### How to write Validation

Here is example model and validator!


```:person.rb
class Person < ActiveRecord::Base
  has_many :books
  has_one  :life
end
```

```:person_validator.rb
# 1. inherit Cavalry::Validator to define validator
class PersonValidator < Cavalry::Validator
  # 2. call Cavalry::Validator.validate_for, to define target model
  validate_for Person

  # 3. pass a block to Cavalry::Validator.validate_each. it runs EVERY data-record.
  validate_each do
    # people needs life...
    validates :life, presence: true

    validate :name_is_downcased

    def name_is_downcased
      if name != name.downcase
        errors.add(:name, "should be downcase.")
      end
    end
  end

  # 4. pass a block to Cavalry::Validator.validate_group. it runs ONCE for whole data-record
  validate_group do

    # 5. call validate and give it block. it receives Person.all as argument "records"
    validate do |records|
      return unless records.count > 5
      errors.add(:base, "Too many people.")
    end

    # 5. call validate and chain any methods. it receives Person.method as argument "records"
    validate.where(name: "bob") do |records|
      return if records.count == 1
      errors.add(:base, "bob must be unique.")
    end

    # 6. call validate with symbol, it calls method that you defined same scope.
    validate :books_are_unique

    def number_of_books
      all_books = Person.all.flat_map(&:book)

      return if all_books == all_books.uniq

      errors.add(:books, "books that people have should be unique")
    end
  end
end
```

### How to execute

Here is sample rake task file.
I'm waiting some PR for improve!

```:Rakefile
namespace :data do
  task check: :environment do
    Cavalry.configure do |config|
      config.modelss_path = "app/models"
      config.validators_path = "app/validators"
    end

    unless Cavalry.valid?
      print Cavalry.dump.to_yaml
    end
  end
end
```

Then,

```
bundle exec rake data:check
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/the40san/cavalry.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
