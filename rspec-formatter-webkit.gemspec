# -*- encoding: utf-8 -*-
# stub: rspec-formatter-webkit 2.5.0.pre.20151116130016 ruby lib

Gem::Specification.new do |s|
  s.name = "rspec-formatter-webkit"
  s.version = "2.5.0.pre.20151116130016"

  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Michael Granger"]
  s.cert_chain = ["/Users/ged/.gem/gem-public_cert.pem"]
  s.date = "2015-11-16"
  s.description = "This is a formatter for RSpec 2 that takes advantage of features in\nWebKit[http://webkit.org/] to make the output from RSpec in Textmate more\nfun.\n\nTest output looks like this:\n\nhttp://deveiate.org/images/tmrspec-example.png"
  s.email = ["ged@FaerieMUD.org"]
  s.extra_rdoc_files = ["History.rdoc", "Manifest.txt", "README.rdoc", "History.rdoc", "README.rdoc"]
  s.files = ["ChangeLog", "History.rdoc", "LICENSE", "Manifest.txt", "README.rdoc", "Rakefile", "data/rspec-formatter-webkit/css/textmate-rspec.css", "data/rspec-formatter-webkit/images/clock.png", "data/rspec-formatter-webkit/images/cross_circle.png", "data/rspec-formatter-webkit/images/cross_circle_frame.png", "data/rspec-formatter-webkit/images/cross_octagon.png", "data/rspec-formatter-webkit/images/cross_octagon_frame.png", "data/rspec-formatter-webkit/images/cross_shield.png", "data/rspec-formatter-webkit/images/exclamation.png", "data/rspec-formatter-webkit/images/exclamation_frame.png", "data/rspec-formatter-webkit/images/exclamation_shield.png", "data/rspec-formatter-webkit/images/exclamation_small.png", "data/rspec-formatter-webkit/images/plus_circle.png", "data/rspec-formatter-webkit/images/plus_circle_frame.png", "data/rspec-formatter-webkit/images/question.png", "data/rspec-formatter-webkit/images/question_frame.png", "data/rspec-formatter-webkit/images/question_shield.png", "data/rspec-formatter-webkit/images/question_small.png", "data/rspec-formatter-webkit/images/tick.png", "data/rspec-formatter-webkit/images/tick_circle.png", "data/rspec-formatter-webkit/images/tick_circle_frame.png", "data/rspec-formatter-webkit/images/tick_shield.png", "data/rspec-formatter-webkit/images/tick_small.png", "data/rspec-formatter-webkit/images/tick_small_circle.png", "data/rspec-formatter-webkit/images/ticket.png", "data/rspec-formatter-webkit/images/ticket_arrow.png", "data/rspec-formatter-webkit/images/ticket_exclamation.png", "data/rspec-formatter-webkit/images/ticket_minus.png", "data/rspec-formatter-webkit/images/ticket_pencil.png", "data/rspec-formatter-webkit/images/ticket_plus.png", "data/rspec-formatter-webkit/images/ticket_small.png", "data/rspec-formatter-webkit/js/jquery-2.1.0.min.js", "data/rspec-formatter-webkit/js/textmate-rspec.js", "data/rspec-formatter-webkit/templates/deprecations.rhtml", "data/rspec-formatter-webkit/templates/error.rhtml", "data/rspec-formatter-webkit/templates/failed.rhtml", "data/rspec-formatter-webkit/templates/footer.rhtml", "data/rspec-formatter-webkit/templates/header.rhtml", "data/rspec-formatter-webkit/templates/page.rhtml", "data/rspec-formatter-webkit/templates/passed.rhtml", "data/rspec-formatter-webkit/templates/pending-fixed.rhtml", "data/rspec-formatter-webkit/templates/pending.rhtml", "data/rspec-formatter-webkit/templates/seed.rhtml", "data/rspec-formatter-webkit/templates/summary.rhtml", "docs/tmrspec-example.png", "docs/tmrspecopts-shellvar.png", "lib/rspec/core/formatters/web_kit.rb", "lib/rspec/core/formatters/webkit.rb"]
  s.homepage = "http://deveiate.org/webkit-rspec-formatter.html"
  s.licenses = ["BSD", "Ruby"]
  s.post_install_message = "\n\nYou can use this formatter from TextMate by setting the TM_RSPEC_OPTS \nshell variable (in the 'Advanced' preference pane) to:\n\n    --format RSpec::Core::Formatters::WebKit\n\nHave fun!\n\n"
  s.rdoc_options = ["--main", "README.rdoc"]
  s.required_ruby_version = Gem::Requirement.new(">= 2.2.0")
  s.rubygems_version = "2.4.5.1"
  s.summary = "This is a formatter for RSpec 2 that takes advantage of features in WebKit[http://webkit.org/] to make the output from RSpec in Textmate more fun"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rspec-core>, ["~> 3.4"])
      s.add_development_dependency(%q<hoe-mercurial>, ["~> 1.4"])
      s.add_development_dependency(%q<hoe-deveiate>, ["~> 0.7"])
      s.add_development_dependency(%q<hoe-highline>, ["~> 0.2"])
      s.add_development_dependency(%q<rdoc>, ["~> 4.0"])
      s.add_development_dependency(%q<hoe-bundler>, ["~> 1.2"])
      s.add_development_dependency(%q<hoe>, ["~> 3.14"])
    else
      s.add_dependency(%q<rspec-core>, ["~> 3.4"])
      s.add_dependency(%q<hoe-mercurial>, ["~> 1.4"])
      s.add_dependency(%q<hoe-deveiate>, ["~> 0.7"])
      s.add_dependency(%q<hoe-highline>, ["~> 0.2"])
      s.add_dependency(%q<rdoc>, ["~> 4.0"])
      s.add_dependency(%q<hoe-bundler>, ["~> 1.2"])
      s.add_dependency(%q<hoe>, ["~> 3.14"])
    end
  else
    s.add_dependency(%q<rspec-core>, ["~> 3.4"])
    s.add_dependency(%q<hoe-mercurial>, ["~> 1.4"])
    s.add_dependency(%q<hoe-deveiate>, ["~> 0.7"])
    s.add_dependency(%q<hoe-highline>, ["~> 0.2"])
    s.add_dependency(%q<rdoc>, ["~> 4.0"])
    s.add_dependency(%q<hoe-bundler>, ["~> 1.2"])
    s.add_dependency(%q<hoe>, ["~> 3.14"])
  end
end
