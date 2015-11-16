#!/usr/bin/env ruby

require 'pp'
require 'erb'
require 'pathname'
require 'set'

gem 'rspec', '~> 3.4.0'

require 'rspec'
require 'rspec/core/formatters/base_text_formatter'
require 'rspec/core/formatters/html_snippet_extractor'
require 'rspec/core/pending'

# Work around a bug in the null colorizer.
module NullColorizerFix
	def wrap( line, _ )
		line
	end
end
RSpec::Core::Notifications::NullColorizer.extend( NullColorizerFix )


class RSpec::Core::Formatters::WebKit < RSpec::Core::Formatters::BaseFormatter
	include ERB::Util

	# Version constant
	VERSION = '2.6.0'

	# Look up the datadir falling back to a relative path (mostly for prerelease testing)
	DATADIR = begin
		dir = Gem.datadir('rspec-formatter-webkit') ||
		      Pathname( __FILE__ ).dirname.parent.parent.parent.parent +
		           'data/rspec-formatter-webkit'
		Pathname( dir )
	end

	# The base HREF used in the header to map stuff to the datadir
	BASE_HREF        = "file://#{DATADIR}/"

	# The directory to grab ERb templates out of
	TEMPLATE_DIR     = DATADIR + 'templates'

	# The page part templates
	HEADER_TEMPLATE          = TEMPLATE_DIR + 'header.rhtml'
	PASSED_EXAMPLE_TEMPLATE  = TEMPLATE_DIR + 'passed.rhtml'
	FAILED_EXAMPLE_TEMPLATE  = TEMPLATE_DIR + 'failed.rhtml'
	PENDING_EXAMPLE_TEMPLATE = TEMPLATE_DIR + 'pending.rhtml'
	PENDFIX_EXAMPLE_TEMPLATE = TEMPLATE_DIR + 'pending-fixed.rhtml'
	SUMMARY_TEMPLATE         = TEMPLATE_DIR + 'summary.rhtml'
	DEPRECATIONS_TEMPLATE    = TEMPLATE_DIR + 'deprecations.rhtml'
	SEED_TEMPLATE            = TEMPLATE_DIR + 'seed.rhtml'
	FOOTER_TEMPLATE          = TEMPLATE_DIR + 'footer.rhtml'


	# Pattern to match for excluding lines from backtraces
	BACKTRACE_EXCLUDE_PATTERN = %r{spec/mate|textmate-command|rspec(-(core|expectations|mocks))?/}

	# Figure out which class pending-example-fixed errors are (2.8 change)
	PENDING_FIXED_EXCEPTION = if defined?( RSpec::Core::Pending::PendingExampleFixedError )
		RSpec::Core::Pending::PendingExampleFixedError
	else
		RSpec::Core::PendingExampleFixedError
	end


	# Register this formatter with RSpec
	RSpec::Core::Formatters.register self,
		:start,
		:example_group_started,
		:start_dump,
		:example_started,
		:example_passed,
		:example_failed,
		:example_pending,
		:dump_summary,
		:deprecation,
		:deprecation_summary,
		:seed,
		:close


	### Create a new formatter
	def initialize( output ) # :notnew:
		super
		@previous_nesting_depth = 0
		@failcounter = 0
		@snippet_extractor = RSpec::Core::Formatters::HtmlSnippetExtractor.new
		@example_templates = {
			:passed        => self.load_template(PASSED_EXAMPLE_TEMPLATE),
			:failed        => self.load_template(FAILED_EXAMPLE_TEMPLATE),
			:pending       => self.load_template(PENDING_EXAMPLE_TEMPLATE),
			:pending_fixed => self.load_template(PENDFIX_EXAMPLE_TEMPLATE),
		}

		@deprecation_stream = []
		@summary_stream     = []
		@failed_examples    = []

		@deprecations = Set.new

		Thread.current['logger-output'] = []
	end


	######
	public
	######

	# Attributes made readable for ERb
	attr_reader :example_count

	# The counter for failed example IDs
	attr_accessor :failcounter

	# The Set of deprecation notifications
	attr_reader :deprecations

	# The Array of failed examples
	attr_reader :failed_examples


	### Fetch any log messages added to the thread-local Array
	def log_messages
		return Thread.current[ 'logger-output' ] ||= []
	end


	#
	# Formatter notification callbacks
	#

	### Start the page by rendering the header.
	def start( notification )
		super
		@output.puts self.render_header( notification )
		@output.flush
	end


	### Callback called by each example group when it's entered --
	def example_group_started( notification )
		super
		example_group = notification.group
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


	### Callback -- called when the examples are finished.
	def start_dump( notification )
		@previous_nesting_depth.downto( 1 ) do |i|
			@output.puts "  </dl>",
			             "</section>"
			@output.puts "  </dd>" unless i == 1
		end

		@output.flush
	end


	### Callback -- called when an example is entered
	def example_started( notification )
		self.log_messages.clear
	end


	### Callback -- called when an example is exited with no failures.
	def example_passed( notification )
		example = notification.example
		status = 'passed'
		@output.puts( @example_templates[:passed].result(binding()) )
		@output.flush
	end


	### Callback -- called when an example is exited with a failure.
	def example_failed( notification )
		example   = notification.example

		self.failed_examples << example
		counter   = self.failed_examples.size

		exception = notification.exception
		extra     = self.extra_failure_content( exception )
		template  = if exception.is_a?( PENDING_FIXED_EXCEPTION )
			then @example_templates[:pending_fixed]
			else @example_templates[:failed]
			end

		@output.puts( template.result(binding()) )
		@output.flush
	end


	### Callback -- called when an example is exited via a 'pending'.
	def example_pending( notification )
		example = notification.example
		status = 'pending'
		@output.puts( @example_templates[:pending].result(binding()) )
		@output.flush
	end


	### Output the content generated at the end of the run.
	def dump_summary( summary )
		html = self.render_summary( summary )
		@output.puts( html )
		@output.flush
	end


	### Callback -- Add a deprecation warning.
	def deprecation( notification )
		@deprecations.add( notification )
	end


	### Callback -- Called at the end with a summary of any deprecations encountered
	### during the run.
	def deprecation_summary( notification )
		html = self.render_deprecations
		@output.puts( html )
		@output.flush
	end


	### Callback -- called with the random seed if the test suite is run with random ordering.
	def seed( notification )
		return unless notification.seed_used?
		html = self.render_seed( notification )
		@output.puts( html )
	end


	### Callback -- called at the very end.
	def close( notification )
		footer = self.render_footer( notification )
		@output.puts( footer )
		@output.flush
	end


	#
	# Utility methods
	#

	### Overriden to add txmt: links to the file paths in the backtrace.
	def format_backtrace( notification )
		lines = notification.formatted_backtrace
		return lines.map do |line|
			link_backtrace_line( line )
		end
	end


	### Link the filename and line number in the given +line+ from a backtrace.
	def link_backtrace_line( line )
		return line.strip.sub( /(?<filename>[^:]*\.rb):(?<line>\d*)(?<rest>.*)/ ) do
			match = $~
			fullpath = File.expand_path( match[:filename] )
			%|<a href="txmt://open?url=file://%s&amp;line=%s">%s:%s</a>%s| %
				[ fullpath, match[:line], match[:filename], match[:line], h(match[:rest]) ]
		end
	end


	### Return any stuff that should be appended to the current example
	### because it's failed. Returns a snippet of the source around the
	### failure.
	def extra_failure_content( exception )
		return '' unless exception

		backtrace = ( exception.backtrace || [] ).map do |line|
			RSpec.configuration.backtrace_formatter.backtrace_line( line )
		end.compact

		snippet = @snippet_extractor.snippet( backtrace )
		return "    <pre class=\"ruby\"><code>#{snippet}</code></pre>"
	end


	### Find the innermost shared example group for the given +example+.
	def find_shared_group( example )
		groups = example.example_group.parent_groups + [example.example_group]
		return groups.find {|group| group.metadata[:shared_group_name]}
	end


	#
	# Template methods
	#

	### Render the header template in the context of the receiver.
	def render_header( notification )
		template = self.load_template( HEADER_TEMPLATE )
		return template.result( binding() )
	end


	### Render the summary template in the context of the receiver.
	def render_summary( summary )
		template = self.load_template( SUMMARY_TEMPLATE )
		return template.result( binding() )
	end


	### Render the deprecation summary template in the context of the receiver.
	def render_deprecations
		template = self.load_template( DEPRECATIONS_TEMPLATE )
		return template.result( binding() )
	end


	### Render the seed template in the context of the receiver.
	def render_seed( notification )
		template = self.load_template( SEED_TEMPLATE )
		return template.result( binding() )
	end


	### Render the footer template in the context of the receiver.
	def render_footer( notification )
		template = self.load_template( FOOTER_TEMPLATE )
		return template.result( binding() )
	end


	### Load the ERB template at +templatepath+ and return it.
	def load_template( templatepath )
		return ERB.new( templatepath.read, nil, '%<>' ).freeze
	end

end # class RSpec::Core::Formatter::WebKitFormatter
