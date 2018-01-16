# -*- encoding: utf-8 -*-
# stub: rspec-formatter-webkit 2.6.0.pre.20180116155739 ruby lib

Gem::Specification.new do |s|
  s.name = "rspec-formatter-webkit".freeze
  s.version = "2.6.0.pre.20180116155739"

  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Michael Granger".freeze]
  s.date = "2018-01-16"
  s.description = "This is a formatter for RSpec 2 that takes advantage of features in\nWebKit[http://webkit.org/] to make the output from RSpec in Textmate more\nfun.\n\nTest output looks like this:\n\nhttp://deveiate.org/images/tmrspec-example.png".freeze
  s.email = ["ged@FaerieMUD.org".freeze]
  s.extra_rdoc_files = ["History.rdoc".freeze, "Manifest.txt".freeze, "README.rdoc".freeze, "History.rdoc".freeze, "README.rdoc".freeze]
  s.files = ["ChangeLog".freeze, "History.rdoc".freeze, "LICENSE".freeze, "Manifest.txt".freeze, "README.rdoc".freeze, "Rakefile".freeze, "data/rspec-formatter-webkit/css/textmate-rspec.css".freeze, "data/rspec-formatter-webkit/images/clock.png".freeze, "data/rspec-formatter-webkit/images/cross_circle.png".freeze, "data/rspec-formatter-webkit/images/cross_circle_frame.png".freeze, "data/rspec-formatter-webkit/images/cross_octagon.png".freeze, "data/rspec-formatter-webkit/images/cross_octagon_frame.png".freeze, "data/rspec-formatter-webkit/images/cross_shield.png".freeze, "data/rspec-formatter-webkit/images/exclamation.png".freeze, "data/rspec-formatter-webkit/images/exclamation_frame.png".freeze, "data/rspec-formatter-webkit/images/exclamation_shield.png".freeze, "data/rspec-formatter-webkit/images/exclamation_small.png".freeze, "data/rspec-formatter-webkit/images/plus_circle.png".freeze, "data/rspec-formatter-webkit/images/plus_circle_frame.png".freeze, "data/rspec-formatter-webkit/images/question.png".freeze, "data/rspec-formatter-webkit/images/question_frame.png".freeze, "data/rspec-formatter-webkit/images/question_shield.png".freeze, "data/rspec-formatter-webkit/images/question_small.png".freeze, "data/rspec-formatter-webkit/images/tick.png".freeze, "data/rspec-formatter-webkit/images/tick_circle.png".freeze, "data/rspec-formatter-webkit/images/tick_circle_frame.png".freeze, "data/rspec-formatter-webkit/images/tick_shield.png".freeze, "data/rspec-formatter-webkit/images/tick_small.png".freeze, "data/rspec-formatter-webkit/images/tick_small_circle.png".freeze, "data/rspec-formatter-webkit/images/ticket.png".freeze, "data/rspec-formatter-webkit/images/ticket_arrow.png".freeze, "data/rspec-formatter-webkit/images/ticket_exclamation.png".freeze, "data/rspec-formatter-webkit/images/ticket_minus.png".freeze, "data/rspec-formatter-webkit/images/ticket_pencil.png".freeze, "data/rspec-formatter-webkit/images/ticket_plus.png".freeze, "data/rspec-formatter-webkit/images/ticket_small.png".freeze, "data/rspec-formatter-webkit/js/jquery-2.1.0.min.js".freeze, "data/rspec-formatter-webkit/js/textmate-rspec.js".freeze, "data/rspec-formatter-webkit/templates/deprecations.rhtml".freeze, "data/rspec-formatter-webkit/templates/error.rhtml".freeze, "data/rspec-formatter-webkit/templates/failed.rhtml".freeze, "data/rspec-formatter-webkit/templates/footer.rhtml".freeze, "data/rspec-formatter-webkit/templates/header.rhtml".freeze, "data/rspec-formatter-webkit/templates/page.rhtml".freeze, "data/rspec-formatter-webkit/templates/passed.rhtml".freeze, "data/rspec-formatter-webkit/templates/pending-fixed.rhtml".freeze, "data/rspec-formatter-webkit/templates/pending.rhtml".freeze, "data/rspec-formatter-webkit/templates/seed.rhtml".freeze, "data/rspec-formatter-webkit/templates/summary.rhtml".freeze, "docs/tmrspec-example.png".freeze, "docs/tmrspecopts-shellvar.png".freeze, "lib/rspec/core/formatters/web_kit.rb".freeze, "lib/rspec/core/formatters/webkit.rb".freeze]
  s.homepage = "http://deveiate.org/webkit-rspec-formatter.html".freeze
  s.licenses = ["BSD".freeze, "Ruby".freeze]
  s.post_install_message = "\n\nYou can use this formatter from TextMate by setting the TM_RSPEC_OPTS \nshell variable (in the 'Advanced' preference pane) to:\n\n    --format RSpec::Core::Formatters::WebKit\n\nHave fun!\n\n".freeze
  s.rdoc_options = ["--main".freeze, "README.rdoc".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.2.0".freeze)
  s.rubygems_version = "2.7.3".freeze
  s.summary = "This is a formatter for RSpec 2 that takes advantage of features in WebKit[http://webkit.org/] to make the output from RSpec in Textmate more fun".freeze

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rspec-core>.freeze, ["~> 3.7"])
      s.add_development_dependency(%q<hoe-mercurial>.freeze, ["~> 1.4"])
      s.add_development_dependency(%q<hoe-deveiate>.freeze, ["~> 0.9"])
      s.add_development_dependency(%q<hoe-highline>.freeze, ["~> 0.2"])
      s.add_development_dependency(%q<rdoc>.freeze, ["~> 4.0"])
      s.add_development_dependency(%q<hoe>.freeze, ["~> 3.16"])
    else
      s.add_dependency(%q<rspec-core>.freeze, ["~> 3.7"])
      s.add_dependency(%q<hoe-mercurial>.freeze, ["~> 1.4"])
      s.add_dependency(%q<hoe-deveiate>.freeze, ["~> 0.9"])
      s.add_dependency(%q<hoe-highline>.freeze, ["~> 0.2"])
      s.add_dependency(%q<rdoc>.freeze, ["~> 4.0"])
      s.add_dependency(%q<hoe>.freeze, ["~> 3.16"])
    end
  else
    s.add_dependency(%q<rspec-core>.freeze, ["~> 3.7"])
    s.add_dependency(%q<hoe-mercurial>.freeze, ["~> 1.4"])
    s.add_dependency(%q<hoe-deveiate>.freeze, ["~> 0.9"])
    s.add_dependency(%q<hoe-highline>.freeze, ["~> 0.2"])
    s.add_dependency(%q<rdoc>.freeze, ["~> 4.0"])
    s.add_dependency(%q<hoe>.freeze, ["~> 3.16"])
  end
end
