require 'spec_helper'

describe Versionable do
  before :each do
    @attr = {
      :project => nil,
      :id => 'abc123',
      :type_identifier => 'tickets'
    }
  end

  it 'should be valid' do
    lambda do
      versionable = Versionable.new @attr
    end.should_not raise_error(ArgumentError)
  end

  it 'should be invalid without a project' do
    @attr.delete(:project)
    lambda do
      versionable = Versionable.new @attr
    end.should raise_error(ArgumentError)
  end

  it 'should be invalid without a type_identifier' do
    @attr.delete(:type_identifier)
    lambda do
      versionable = Versionable.new @attr
    end.should raise_error(ArgumentError)
  end
end

