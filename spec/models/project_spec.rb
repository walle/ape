require 'spec_helper'

describe Project do

  before :each do
    @attr = {
      :name => 'Project 1',
      :description => '',
      :default => false
    }
  end

  it 'should require a name' do
    no_name_project = Project.new @attr.merge(:name => '')
    no_name_project.should_not be_valid
  end

  it 'should have a default? method' do
    project = Project.new @attr
    project.default?.should == @attr[:default]
  end

  pending 'only one project at a time should be default'

  describe 'after create' do
    before :each do
      @attr = {
        :name => 'Project 1',
        :description => '',
        :default => false
      }
      @project = Project.create @attr
    end

    it 'should have a parameterized slug' do
      @project.slug.should == @project.name.parameterize
    end

    pending 'is should have unique slug'

    it 'should have a config file' do
      File.exists?(@project.config_file).should be_true
    end

    it 'should have a wiki directory' do
      File.exists?(@project.wiki_directory).should be_true
      File.directory?(@project.wiki_directory).should be_true
    end

    it 'should have a tickets directory' do
      File.exists?(@project.tickets_directory).should be_true
      File.directory?(@project.tickets_directory).should be_true
    end
  end
end

