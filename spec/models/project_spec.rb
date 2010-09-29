require 'spec_helper'

describe Project do

  before :each do
    @attr = {
      :name => 'Project 1',
      :description => '',
      :active => false
    }
  end

  it 'should require a name' do
    no_name_project = Project.new @attr.merge(:name => '')
    no_name_project.should_not be_valid
  end

  it 'should have a parameterized slug' do
    project = Project.create @attr
    project.slug.should == project.name.parameterize
  end

  it 'should have a active? method' do
    project = Project.new @attr
    project.active?.should == @attr[:active]
  end

  pending 'should have a config'

  pending 'should have a wiki'

  pending 'should have tickets'
end

