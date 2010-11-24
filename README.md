# A WebKit RSpec Formatter

This is a formatter for RSpec 2 that takes advantage of features in [WebKit](http://webkit.org/) to make the output from RSpec in Textmate more fun.

Test output looks like this:

![Example Output](http://deveiate.org/images/tmrspec-example.png)

## Installation

To get started, install the `webkit-rspec-formatter` gem:

    $ gem install webkit-rspec-formatter

If you're running specs in Textmate via [the RSpec bundle](http://github.com/rspec/rspec-tmbundle), you can use the webkit formatter by opening Textmate's 'Advanced' Preferences and adding a `TM_RSPEC_OPTS` Shell Variable with the value `--format RSpec::Core::Formatters::WebKit`:

![Setting TM_RSPEC_OPTS](http://deveiate.org/images/tmrspecopts-shellvar.png)

That's it!

## Miscellaneous

It's also usable anywhere else the standard HTML formatter is, of course. Also, while it's specifically intended to be used under the Textmate HTML viewer that the RSpec bundle uses, the output should work fine under recent Gecko/Firefox-based viewers, as well. 

Patches/suggestions welcomed.

