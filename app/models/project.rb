class Project < ActiveRecord::Base
  attr_accessible :name, :description, :slug, :active

  before_validation :slugify
  before_save :create_project_structure

  validates :name, :presence => true
  validates :slug, :presence => true

  def active?
    self.active
  end

  def project_dir
    File.join(Rails.root, 'data', slug)
  end

  def to_param
    slug
  end

  private

    def slugify
      debugger
      self.slug = name.parameterize
      debugger
    end

    def create_project_structure
      data_dir = File.join(Rails.root, 'data')
      Dir.mkdir data_dir if not File.exists? data_dir
      Dir.mkdir project_dir

      git_repository = Git.init project_dir

      wiki_dir = File.join project_dir, 'wiki'
      Dir.mkdir wiki_dir
      File.open File.join(wiki_dir, 'index.txt'), 'a' do |f|
        f.puts 'h2. Welcome'
      end

      tickets_dir = File.join project_dir, 'tickets'
      Dir.mkdir tickets_dir

      FileUtils.touch File.join(project_dir, 'config.yml')

      git_repository.add '.'
      git_repository.commit 'Create project structure'
    end
end

