# encoding: utf-8

$:.unshift File.expand_path('../lib', __FILE__)
require 'rspec-formatter-webkit/version'

Gem::Specification.new do |s|
  s.name          = "rspec-formatter-webkit"
  s.version       = Rspec::Core::Formatters::Webkit::VERSION
  s.authors       = ["Michael Granger"]
  s.email         = ["ged@FaerieMUD.org"]
  s.homepage      = "https://rubygems.org/gems/rspec-formatter-webkit"
  s.summary       = "Webkit formatter for RSpec 2"
  s.description   = "This is a formatter for RSpec 2 that takes advantage of features in WebKit[http://webkit.org/] to make the output from RSpec in Textmate more fun. Test output looks like this: http://deveiate.org/images/tmrspec-example.png"

  s.files         = `git ls-files docs data lib`.split("\n")
  s.platform      = Gem::Platform::RUBY
  s.require_paths = ['lib']
  s.rubyforge_project = '[none]'
end
