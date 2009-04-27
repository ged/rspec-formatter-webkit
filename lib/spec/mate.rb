require 'rubygems'
require 'spec'
require 'spec/runner'

begin
	gem 'webkit-rspec-formatter'
rescue LoadError
	$LOAD_PATH.unshift( '/Users/mgranger/source/ruby/webkit-rspec-formatter/lib' )
end

module Spec
	module Mate
		class Runner
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
				argv = options[:files].dup
				argv << '--require' << 'spec/runner/formatter/webkit_formatter'
				argv << '--format' << 'webkit'
				if options[:line]
					argv << '--line'
					argv << options[:line]
				end
				argv += ENV['TM_RSPEC_OPTS'].split(" ") if ENV['TM_RSPEC_OPTS']
				Dir.chdir(project_directory) do
					::Spec::Runner::CommandLine.run(::Spec::Runner::OptionParser.parse(argv, STDERR, stdout))
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
	end
end
