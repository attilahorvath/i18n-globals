# I18n::Globals

Adds support for I18n global variables, which will be available for interpolation into every translation.

## Description

Extends the Ruby I18n gem with global variables. The globals will be available for interpolation in every translation without explicitly specifying them in a call to `I18n.translate`. The variables can be accessed through `I18n.config.globals`.

## Installation

Add this line to your application's Gemfile:

    gem 'i18n-globals'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install i18n-globals

## Usage

Add your global variables to the `I18n.config.globals` hash:

    I18n.config.globals[:company] = "Initech"

Your global variables will then be automatically interpolated into every translation:

    # If the value of 'greeting' is 'Welcome to %{company}!'
    I18n.t "greeting" # Returns 'Welcome to Initech!'

You can override the globals:

    I18n.t "greeting", company: "Initrode" # Returns 'Welcome to Initrode!'

It's also possible to mix globals and ordinary variables:

    # If the value of 'signature' is '%{president}, President of %{company}'
    I18n.t "signature", president: "Bill Lumbergh" # Returns 'Bill Lumbergh, President of Initech'

If you're using Rails, it can be useful to specify your globals in a `before_filter`:

    class EmployeesController < ApplicationController
      before_filter :set_i18n_globals

      # ...

      private

      def set_i18n_globals
        I18n.config.globals[:company] = Company.current.name
      end
    end

Now you can interpolate the `company` variable into every translation in your template:

    <%= t "greeting" %>
    <%= t "signature", president: "Bill Lumbergh" %>

## Contributing

1. Fork it ( https://github.com/attilahorvath/i18n-globals/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
