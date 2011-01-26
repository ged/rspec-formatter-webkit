#!/usr/bin/env rake

begin
	require 'hoe'
rescue LoadError
	abort "This Rakefile requires 'hoe' (gem install hoe)"
end

require 'rake/clean'

Hoe.plugin :mercurial
Hoe.plugin :yard
Hoe.plugin :signing

Hoe.plugins.delete :rubyforge

hoespec = Hoe.spec 'rspec-formatter-webkit' do
	self.readme_file = 'README.md'

	self.developer 'Michael Granger', 'ged@FaerieMUD.org'

	self.extra_deps.push *{
		'rspec' => '~> 2.3',
	}

	self.spec_extras[:licenses] = ["BSD"]
	self.spec_extras[:post_install_message] = %{

		You can use this formatter from TextMate (if you're using RSpec 2.3.0 
		or later) bysetting the TM_RSPEC_OPTS shell variable (in the 
		'Advanced' preference pane) to:

		    --format RSpec::Core::Formatters::WebKit

		Have fun!

	}.gsub( /^\t+/m, '' )
	self.spec_extras[:signing_key] = '/Volumes/Keys/ged-private_gem_key.pem'

	self.require_ruby_version( '>=1.8.7' )

	self.hg_sign_tags = true if self.respond_to?( :hg_sign_tags )
	self.yard_opts = [ '--use-cache', '--protected', '--verbose' ] if
		self.respond_to?( :yard_opts )

	self.rdoc_locations << "deveiate:/usr/local/www/public/code/#{remote_rdoc_dir}"
end

ENV['VERSION'] ||= hoespec.spec.version.to_s


task :legacy_gem do
	Dir.chdir( 'legacy' ) do
		sh 'rake gem'
	end
end
CLEAN.include( 'legacy/pkg' )


