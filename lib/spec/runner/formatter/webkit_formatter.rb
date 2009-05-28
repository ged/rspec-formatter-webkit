#!/usr/bin/env ruby

require 'rubygems'
require 'erb'
require 'pathname'
require 'logger'
require 'spec'
require 'spec/runner/formatter/base_text_formatter'
require 'spec/runner/formatter/snippet_extractor'

class Spec::Runner::Formatter::WebKitFormatter < Spec::Runner::Formatter::BaseTextFormatter
	include ERB::Util

	VERSION = '0.0.1'

	Spec::Runner::Options::EXAMPLE_FORMATTERS['webkit'] =
	 	['spec/runner/formatter/webkit_formatter', self.name ]

	if dir = Gem.datadir('webkit-rspec-formatter')
		BASE_PATH = Pathname( dir ).parent
	else
		BASE_PATH    = Pathname( __FILE__ ).dirname.parent.parent.parent.parent + 'data'
	end
	BASE_HREF        = "file://#{BASE_PATH}/"

	TEMPLATE_DIR     = BASE_PATH + 'templates'

	HEADER_TEMPLATE  = TEMPLATE_DIR + 'header.rhtml'
	EXAMPLE_TEMPLATE = TEMPLATE_DIR + 'example.rhtml'
	FOOTER_TEMPLATE  = TEMPLATE_DIR + 'footer.rhtml'

	
	### Initializer
	def initialize( options, output ) # :notnew:
		super
		@example_group_number = 0
		@example_number = 0
		@snippet_extractor = Spec::Runner::Formatter::SnippetExtractor.new
		@example_template = ERB.new( File.read(EXAMPLE_TEMPLATE), nil, '<>' ).freeze
		
		Thread.current['logger-output'] = []
	end


	attr_reader :example_group_number, :example_number, :example_count

	def start( example_count )
		@output.puts self.render_header( example_count )
		@output.flush
	end

	def example_group_started( example_group )
		super
		@example_group_number += 1

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

	def start_dump
		@output.puts "  </dl>"
		@output.puts "</div>"
		@output.flush
	end

	def log_messages
		return Thread.current[ 'logger-output' ] || []
	end

	def example_started( example )
		@example_number += 1
		Thread.current[ 'logger-output' ] ||= []
		Thread.current[ 'logger-output' ].clear
	end

	def example_passed( example )
		status = 'passed'
		@output.puts( @example_template.result(binding()) )
		@output.flush
	end

	def example_failed( example, counter, failure )
		extra = self.extra_failure_content( failure )
		status = failure.pending_fixed? ? 'pending-fixed' : 'failed'

		@output.puts( @example_template.result(binding()) )
		@output.flush
	end

	def example_pending( example, message )
		status = 'pending'
		@output.puts( @example_template.result(binding()) )
		@output.flush
	end


	def format_backtrace_line( line )
		return '' if line =~ /textmate-command/i
		return line.gsub( /([^:]*\.rb):(\d*)/ ) do
			"<a href=\"txmt://open?url=file://#{File.expand_path($1)}&line=#{$2}\">#{$1}:#{$2}</a> "
		end
	end

	def extra_failure_content(failure)
		snippet = @snippet_extractor.snippet( failure.exception )
		return "    <pre class=\"ruby\"><code>#{snippet}</code></pre>"
	end

	def dump_failure( counter, failure )
	end

	def dump_summary( duration, example_count, failure_count, pending_count )
		@output.puts self.render_footer( duration, example_count, failure_count, pending_count )
		@output.flush
	end

	def render_header( example_count )
		template = ERB.new( File.read(HEADER_TEMPLATE) )
		return template.result( binding() )
	end

	def render_footer( duration, example_count, failure_count, pending_count )
		template = ERB.new( File.read(FOOTER_TEMPLATE) )
		return template.result( binding() )
	end

end # class Spec::Runner::Formatter::WebKitFormatter
