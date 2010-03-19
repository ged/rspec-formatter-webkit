
rspec_rails_plugin = File.join( ENV['TM_PROJECT_DIRECTORY'], 'vendor', 'plugins', 'rspec', 'lib' )

if File.directory?( rspec_rails_plugin )
	$LOAD_PATH.unshift( rspec_rails_plugin )
elsif ENV['TM_RSPEC_HOME']
	rspec_lib = File.join( ENV['TM_RSPEC_HOME'], 'lib' )
	raise "TM_RSPEC_HOME points to a bad location: #{ENV['TM_RSPEC_HOME']}" unless
		File.directory?( rspec_lib )
	$LOAD_PATH.unshift( rspec_lib )
end

begin
	require 'spec'
	require 'spec/runner'
rescue LoadError => err
	unless Object.const_defined?( :Gem )
		require 'rubygems'
		retry
	end
	raise
end

class SpecMate
	def run_files(stdout, options={})
		files = ENV['TM_SELECTED_FILES'].split(" ").map do |path|
			File.expand_path(path[1..-2])
		end
		options.merge!({:files => files})
		run(stdout, options)
	end

	def run_file(stdout, options={})
		options.merge!({:files => [single_file]})
		run(stdout, options)
	end

	def run_focussed(stdout, options={})
		options.merge!({:files => [single_file], :line => ENV['TM_LINE_NUMBER']})
		run(stdout, options)
	end

	def run(stdout, options)
		formatter = ENV['TM_RSPEC_FORMATTER'] || 'Spec::Runner::Formatter::TextMateFormatter'

		argv = []
		argv += ENV['TM_RSPEC_OPTS'].split(" ") if ENV['TM_RSPEC_OPTS']
		argv += options[:files].dup
		argv << '--format' << formatter
		argv << '--line' << options[:line] if options[:line]

		Dir.chdir(ENV['TM_PROJECT_DIRECTORY']) do
			::Spec::Runner::CommandLine.run(Spec::Runner::OptionParser.parse(argv, STDERR, stdout))
		end
	end

	protected
	def single_file
		File.expand_path(ENV['TM_FILEPATH'])
	end

	def project_directory
		File.expand_path(ENV['TM_PROJECT_DIRECTORY'])
	end
end
