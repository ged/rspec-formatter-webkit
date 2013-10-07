#!/usr/bin/env rake

begin
	require 'hoe'
rescue LoadError
	abort "This Rakefile requires 'hoe' (gem install hoe)"
end

require 'rake/clean'

Hoe.plugin :mercurial
Hoe.plugin :signing
Hoe.plugin :bundler

Hoe.plugins.delete :rubyforge

hoespec = Hoe.spec 'rspec-formatter-webkit' do
	self.readme_file = 'README.rdoc'
	self.history_file = 'History.rdoc'
	self.extra_rdoc_files = Rake::FileList[ '*.rdoc' ]

	self.developer 'Michael Granger', 'ged@FaerieMUD.org'
	self.license 'Ruby'

	self.dependency 'hoe-bundler', '~> 1.2', :development

	self.spec_extras[:post_install_message] = %{

		You can use this formatter from TextMate by setting the TM_RSPEC_OPTS 
		shell variable (in the 'Advanced' preference pane) to:

		    --format RSpec::Core::Formatters::WebKit

		Have fun!

	}.gsub( /^\t+/m, '' )

	self.require_ruby_version( '>=1.9.3' )
	self.hg_sign_tags = true if self.respond_to?( :hg_sign_tags )
	self.rdoc_locations << "deveiate:/usr/local/www/public/code/#{remote_rdoc_dir}"
end

ENV['VERSION'] ||= hoespec.spec.version.to_s

# Ensure history is updated before checking in
task 'hg:precheckin' => [ :check_history, 'Gemfile' ]

task :legacy_gem do
	Dir.chdir( 'legacy' ) do
		sh 'rake gem'
	end
end
CLEAN.include( 'legacy/pkg' )


file 'Gemfile'
task 'Gemfile' => ['bundler:gemfile']


