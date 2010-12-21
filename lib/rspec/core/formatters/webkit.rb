#!/usr/bin/env ruby

require 'pp'
require 'rbconfig'
require 'erb'
require 'pathname'

require 'rspec' 
require 'rspec/core/formatters/base_text_formatter'
require 'rspec/core/formatters/snippet_extractor'

class RSpec::Core::Formatters::WebKit < RSpec::Core::Formatters::BaseTextFormatter
	include ERB::Util

	# Version constant
	VERSION = '2.2.0'

	# Look up the datadir falling back to a relative path (mostly for prerelease testing)
	DEFAULT_DATADIR = Pathname( Config.datadir('rspec-formatter-webkit') )
	if DEFAULT_DATADIR.exist?
		BASE_PATH = DEFAULT_DATADIR
	else
		BASE_PATH = Pathname( __FILE__ ).dirname.parent.parent.parent.parent +
		 	'data/rspec-formatter-webkit'
	end

	# The base HREF used in the header to map stuff to the datadir
	BASE_HREF        = "file://#{BASE_PATH}/"

	# The directory to grab ERb templates out of
	TEMPLATE_DIR     = BASE_PATH + 'templates'

	# The page part templates
	HEADER_TEMPLATE          = TEMPLATE_DIR + 'header.rhtml'
	PASSED_EXAMPLE_TEMPLATE  = TEMPLATE_DIR + 'passed.rhtml'
	FAILED_EXAMPLE_TEMPLATE  = TEMPLATE_DIR + 'failed.rhtml'
	PENDING_EXAMPLE_TEMPLATE = TEMPLATE_DIR + 'pending.rhtml'
	PENDFIX_EXAMPLE_TEMPLATE = TEMPLATE_DIR + 'pending-fixed.rhtml'
	FOOTER_TEMPLATE          = TEMPLATE_DIR + 'footer.rhtml'


	### Create a new formatter
	def initialize( output ) # :notnew:
		super
		@previous_nesting_depth = 0
		@example_number = 0
		@failcounter = 0
		@snippet_extractor = RSpec::Core::Formatters::SnippetExtractor.new
		@example_templates = {
			:passed        => self.load_template(PASSED_EXAMPLE_TEMPLATE),
			:failed        => self.load_template(FAILED_EXAMPLE_TEMPLATE),
			:pending       => self.load_template(PENDING_EXAMPLE_TEMPLATE),
			:pending_fixed => self.load_template(PENDFIX_EXAMPLE_TEMPLATE),
		}

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
		nesting_depth = example_group.ancestors.length

		# Close the previous example groups if this one isn't a 
		# descendent of the previous one
		if @previous_nesting_depth.nonzero? && @previous_nesting_depth >= nesting_depth
			( @previous_nesting_depth - nesting_depth + 1 ).times do
				@output.puts "  </dl>", "</section>", "  </dd>"
			end
		end

		@output.puts "<!-- nesting: %d, previous: %d -->" %
			[ nesting_depth, @previous_nesting_depth ]
		@previous_nesting_depth = nesting_depth

		if @previous_nesting_depth == 1
			@output.puts %{<section class="example-group">}
		else
			@output.puts %{<dd class="nested-group"><section class="example-group">}
		end

		@output.puts %{  <dl>},
			%{  <dt id="%s">%s</dt>} % [
			 	example_group.name.gsub(/[\W_]+/, '-').downcase,
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
		@previous_nesting_depth.downto( 1 ) do |i|
			@output.puts "  </dl>",
			             "</section>"
			@output.puts "  </dd>" unless i == 1
		end

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
		@output.puts( @example_templates[:passed].result(binding()) )
		@output.flush
	end


	### Callback -- called when an example is exited with a failure.
	def example_failed( example )
		super

		counter   = self.failcounter += 1
		exception = example.metadata[:execution_result][:exception]
		extra     = self.extra_failure_content( exception )
		template  = if exception.is_a?( RSpec::Core::PendingExampleFixedError )
			then @example_templates[:pending_fixed]
			else @example_templates[:failed]
			end

		@output.puts( template.result(binding()) )
		@output.flush
	end


	### Callback -- called when an example is exited via a 'pending'.
	def example_pending( example )
		status = 'pending'
		@output.puts( @example_templates[:pending].result(binding()) )
		@output.flush
	end


	### Format backtrace lines to include a textmate link to the file/line in question.
	def backtrace_line( line )
		return nil unless line = super
		return nil if line =~ %r{r?spec/mate|textmate-command}
		return h( line.strip ).gsub( /([^:]*\.rb):(\d*)/ ) do
			"<a href=\"txmt://open?url=file://#{File.expand_path($1)}&amp;line=#{$2}\">#{$1}:#{$2}</a> "
		end
	end


	### Return any stuff that should be appended to the current example
	### because it's failed. Returns a snippet of the source around the
	### failure.
	def extra_failure_content( exception )
		return '' unless exception
		snippet = @snippet_extractor.snippet( exception )
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
		template = self.load_template( HEADER_TEMPLATE )
		return template.result( binding() )
	end


	### Render the footer template in the context of the receiver.
	def render_footer( duration, example_count, failure_count, pending_count )
		template = self.load_template( FOOTER_TEMPLATE )
		return template.result( binding() )
	end


	### Load the ERB template at +templatepath+ and return it.
	### @param [Pathname] templatepath  the fully-qualified path to the template file
	def load_template( templatepath )
		return ERB.new( templatepath.read, nil, '%<>' ).freeze
	end

end # class RSpec::Core::Formatter::WebKitFormatter
