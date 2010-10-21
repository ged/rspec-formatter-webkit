#!/usr/bin/env ruby

require 'rbconfig'
require 'erb'
require 'pathname'

require 'rspec' 
require 'rspec/core/formatters/base_text_formatter'
require 'rspec/core/formatters/snippet_extractor'

class RSpec::Core::Formatters::WebKit < RSpec::Core::Formatters::BaseTextFormatter
	include ERB::Util

	# Version constant
	VERSION = '2.0.0'

	# Look up the datadir falling back to a relative path (mostly for prerelease testing)
	DEFAULT_DATADIR = Pathname( Config.datadir('webkit-rspec-formatter') )
	if DEFAULT_DATADIR.exist?
		BASE_PATH = DEFAULT_DATADIR
	else
		BASE_PATH = Pathname( __FILE__ ).dirname.parent.parent.parent.parent +
		 	'data/webkit-rspec-formatter'
	end

	# The base HREF used in the header to map stuff to the datadir
	BASE_HREF        = "file://#{BASE_PATH}/"

	# The directory to grab ERb templates out of
	TEMPLATE_DIR     = BASE_PATH + 'templates'

	# The page part templates
	HEADER_TEMPLATE  = TEMPLATE_DIR + 'header.rhtml'
	EXAMPLE_TEMPLATE = TEMPLATE_DIR + 'example.rhtml'
	FOOTER_TEMPLATE  = TEMPLATE_DIR + 'footer.rhtml'


	### Create a new formatter
	def initialize( output ) # :notnew:
		super
		@example_group_number = 0
		@example_number = 0
		@failcounter = 0
		@snippet_extractor = RSpec::Core::Formatters::SnippetExtractor.new
		@example_template = ERB.new( File.read(EXAMPLE_TEMPLATE), nil, '%<>' ).freeze

		Thread.current['logger-output'] = []
	end


	######
	public
	######

	# Attributes made readable for ERb
	attr_reader :example_group_number, :example_number, :example_count

	# The counter for failed example IDs
	attr_accessor :failcounter


	### Start the page by rendering the header.
	def start( example_count )
		@output.puts self.render_header( example_count )
		@output.flush
	end


	### Callback called by each example group when it's entered --
	def example_group_started( example_group )
		super
		@example_group_number += 1

		# Close the previous example group if this isn't the first one
		unless example_group_number == 1
			@output.puts "  </dl>", "</div>"
		end

		@output.puts %{<div class="example-group">},
			%{  <dl>},
			%{  <dt id="example-group-%d">%s</dt>} % [
			 	example_group_number,
				h(example_group.description)
			]
		@output.flush
	end
	alias_method :add_example_group, :example_group_started


	### Fetch any log messages added to the thread-local Array
	def log_messages
		return Thread.current[ 'logger-output' ] || []
	end


	### Callback -- called when the examples are finished.
	def start_dump
		@output.puts "  </dl>"
		@output.puts "</div>"
		@output.flush
	end


	### Callback -- called when an example is entered
	def example_started( example )
		@example_number += 1
		Thread.current[ 'logger-output' ] ||= []
		Thread.current[ 'logger-output' ].clear
	end


	### Callback -- called when an example is exited with no failures.
	def example_passed( example )
		status = 'passed'
		@output.puts( @example_template.result(binding()) )
		@output.flush
	end


	### Callback -- called when an example is exited with a failure.
	def example_failed( example )
		super
		counter = self.failcounter += 1
		exception = example.metadata[:execution_result][:exception_encountered]
		extra = self.extra_failure_content( exception )
		status = if exception.is_a?( RSpec::Core::PendingExampleFixedError )
			then 'pending-fixed'
			else 'failed'
			end

		@output.puts( @example_template.result(binding()) )
		@output.flush
	end


	### Callback -- called when an example is exited via a 'pending'.
	def example_pending( example )
		status = 'pending'
		@output.puts( @example_template.result(binding()) )
		@output.flush
	end


	### Format backtrace lines to include a textmate link to the file/line in question.
	def backtrace_line( line )
		return nil unless line = super
		return nil if line =~ %r{rspec/mate|textmate-command}
		return line.gsub( /([^:]*\.rb):(\d*)/ ) do
			"<a href=\"txmt://open?url=file://#{File.expand_path($1)}&line=#{$2}\">#{$1}:#{$2}</a> "
		end
	end


	### Return any stuff that should be appended to the current example
	### because it's failed. Returns a snippet of the source around the
	### failure.
	def extra_failure_content( failure )
		return '' if failure.is_a?( RSpec::Core::PendingExampleFixedError )
		snippet = @snippet_extractor.snippet( failure.exception )
		return "    <pre class=\"ruby\"><code>#{snippet}</code></pre>"
	end


	### Returns content to be output when a failure occurs during the run; overridden to
	### do nothing, as failures are handled by #example_failed.
	def dump_failures( *unused )
	end


	### Output the content generated at the end of the run.
	def dump_summary( duration, example_count, failure_count, pending_count )
		@output.puts self.render_footer( duration, example_count, failure_count, pending_count )
		@output.flush
	end


	### Render the header template in the context of the receiver.
	def render_header( example_count )
		template = ERB.new( File.read(HEADER_TEMPLATE) )
		return template.result( binding() )
	end


	### Render the footer template in the context of the receiver.
	def render_footer( duration, example_count, failure_count, pending_count )
		template = ERB.new( File.read(FOOTER_TEMPLATE) )
		return template.result( binding() )
	end

end # class RSpec::Core::Formatter::WebKitFormatter
