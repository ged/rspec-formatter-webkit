#!/usr/bin/env ruby

require 'rubygems'
require 'erb'
require 'pathname'
require 'logger'
require 'spec'
require 'spec/runner/formatter/base_text_formatter'
require 'spec/runner/formatter/snippet_extractor'

class Spec::Runner::Formatter::WebKit < Spec::Runner::Formatter::BaseTextFormatter
	include ERB::Util

	VERSION = '0.0.3'

	Spec::Runner::Options::EXAMPLE_FORMATTERS['webkit'] =
	 	['spec/runner/formatter/webkit', self.name ]

	# Look up the datadir either via Rubygems' mechanism, or by relative path
	if dir = Gem.datadir('webkit-rspec-formatter')
		BASE_PATH = Pathname( dir ).parent
	else
		BASE_PATH    = Pathname( __FILE__ ).dirname.parent.parent.parent.parent + 'data'
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
	def initialize( options, output ) # :notnew:
		super
		@example_group_number = 0
		@example_number = 0
		@snippet_extractor = Spec::Runner::Formatter::SnippetExtractor.new
		@example_template = ERB.new( File.read(EXAMPLE_TEMPLATE), nil, '<>' ).freeze

		Thread.current['logger-output'] = []
	end


	######
	public
	######

	# Attributes made readable for ERb
	attr_reader :example_group_number, :example_number, :example_count

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
	def example_failed( example, counter, failure )
		extra = self.extra_failure_content( failure )
		status = failure.pending_fixed? ? 'pending-fixed' : 'failed'

		@output.puts( @example_template.result(binding()) )
		@output.flush
	end


	### Callback -- called when an example is exited via a 'pending'.
	def example_pending( example, message )
		status = 'pending'
		@output.puts( @example_template.result(binding()) )
		@output.flush
	end


	### Format backtrace lines to include a textmate link to the file/line in question.
	def format_backtrace_line( line )
		return nil if line =~ /webkit-rspec-formatter/i
		return line.gsub( /([^:]*\.rb):(\d*)/ ) do
			"<a href=\"txmt://open?url=file://#{File.expand_path($1)}&line=#{$2}\">#{$1}:#{$2}</a> "
		end
	end


	### Return any stuff that should be appended to the current example
	### because it's failed. Returns a snippet of the source around the
	### failure.
	def extra_failure_content(failure)
		snippet = @snippet_extractor.snippet( failure.exception )
		return "    <pre class=\"ruby\"><code>#{snippet}</code></pre>"
	end


	### Returns content to be output when a failure occurs during the run; overridden to
	### do nothing, as failures are handled by #example_failed.
	def dump_failure( counter, failure )
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

end # class Spec::Runner::Formatter::WebKitFormatter
