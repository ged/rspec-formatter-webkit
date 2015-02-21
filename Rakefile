#!/usr/bin/env rake

begin
	require 'hoe'
rescue LoadError
	abort "This Rakefile requires 'hoe' (gem install hoe)"
end

GEMSPEC = 'rspec-formatter-webkit.gemspec'

require 'rake/clean'

Hoe.plugin :mercurial
Hoe.plugin :signing

Hoe.plugins.delete :rubyforge

hoespec = Hoe.spec 'rspec-formatter-webkit' do
	self.readme_file = 'README.rdoc'
	self.history_file = 'History.rdoc'
	self.extra_rdoc_files = Rake::FileList[ '*.rdoc' ]
	self.license 'BSD'

	self.developer 'Michael Granger', 'ged@FaerieMUD.org'
	self.license 'Ruby'

	self.dependency 'rspec-core', '~> 3.2'
	self.dependency 'hoe-bundler', '~> 1.2', :development

	self.spec_extras[:post_install_message] = %{

		You can use this formatter from TextMate by setting the TM_RSPEC_OPTS 
		shell variable (in the 'Advanced' preference pane) to:

		    --format RSpec::Core::Formatters::WebKit

		Have fun!

	}.gsub( /^\t+/m, '' )

	self.require_ruby_version( '>=2.0.0' )
	self.hg_sign_tags = true if self.respond_to?( :hg_sign_tags )
	self.rdoc_locations << "deveiate:/usr/local/www/public/code/#{remote_rdoc_dir}"
end

ENV['VERSION'] ||= hoespec.spec.version.to_s

# Ensure history is updated before checking in
task 'hg:precheckin' => [ :check_history, :gemspec ]

task :legacy_gem do
	Dir.chdir( 'legacy' ) do
		sh 'rake gem'
	end
end
CLEAN.include( 'legacy/pkg' )


task :gemspec => GEMSPEC

desc "Refresh the .gemspec"
file GEMSPEC => 'Rakefile' do |task|
	spec = hoespec.spec.dup
	spec.files.delete( '.gemtest' )
	spec.signing_key = nil
	spec.version = "#{spec.version}.pre.#{Time.now.strftime("%Y%m%d%H%M%S")}"
	File.open( task.name, 'w' ) do |fh|
		fh.write( spec.to_ruby )
	end
end
CLOBBER.include( '*.gemspec' )

