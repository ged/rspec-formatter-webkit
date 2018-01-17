#!/usr/bin/env rspec -cfd

require_relative '../../../spec_helper'

require 'stringio'
require 'rspec/core/formatters/webkit'


RSpec.describe RSpec::Core::Formatters::WebKit do

	let( :output ) { StringIO.new }


	it "renders a header when the run starts" do
		notification = instance_double( RSpec::Core::Notifications::StartNotification,
			count: 8, load_time: 0.245 )
		formatter = described_class.new( output )
		formatter.start( notification )

		expect( output.string ).to include(
			'<html lang="en">',
			'<title>RSpec results</title>',
			'<div id="rspec-header">'
		)
	end


	it "renders a top-level definition list for a top-level example group" do
		group = class_double( RSpec::Core::ExampleGroup, ancestors: [Object],
			name: 'DefinitionListExample', description: "something something" )
		notification = instance_double( RSpec::Core::Notifications::GroupNotification,
			group: group )
		formatter = described_class.new( output )
		formatter.example_group_started( notification )

		expect( output.string ).to include(
			'<dl>',
			'something something',
			'id="definitionlistexample"'
		)
		expect( output.string ).to_not include( '<dd class="nested-group">' )
	end


	it "renders a nested definition list for a nested example group" do
		group = class_double( RSpec::Core::ExampleGroup, ancestors: [Object, Object],
			name: 'NestedDefinitionListExample', description: "something nested something" )
		notification = instance_double( RSpec::Core::Notifications::GroupNotification,
			group: group )
		formatter = described_class.new( output )
		formatter.example_group_started( notification )

		expect( output.string ).to include(
			'<dd class="nested-group">',
			'<dl>',
			'something nested something',
			'id="nesteddefinitionlistexample"'
		)
	end


	it "closes previous more-deeply nested definition lists" do
		group1 = class_double( RSpec::Core::ExampleGroup, ancestors: [Object, Object, Object, Object],
			name: 'DefinitionListExampleOne', description: "first group" )
		notification1 = instance_double( RSpec::Core::Notifications::GroupNotification,
			group: group1 )

		group2 = class_double( RSpec::Core::ExampleGroup, ancestors: [Object, Object],
			name: 'DefinitionListExampleTwo', description: "second group" )
		notification2 = instance_double( RSpec::Core::Notifications::GroupNotification,
			group: group2 )

		formatter = described_class.new( output )

		formatter.example_group_started( notification1 )
		output.truncate( 0 )
		output.rewind
		formatter.example_group_started( notification2 )

		expect( output.string ).to match( %r{</dd>.*</dl>.*</dd>.*</dl>}m )
	end

end

