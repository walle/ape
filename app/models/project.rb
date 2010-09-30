class Project < ActiveRecord::Base
  attr_accessible :name, :description, :slug, :default

  before_validation :slugify
  before_save :create_project_structure

  validates :name, :presence => true
  validates :slug, :presence => true,
                    :uniqueness => true

  def default?
    self.default
  end

  def directory
    File.join(Rails.root, 'data', slug)
  end

  def config_file
    File.join(self.directory, 'config.yml')
  end

  def wiki_directory
    File.join self.directory, 'wiki'
  end

  def tickets_directory
    File.join self.directory, 'tickets'
  end

  def to_param
    slug
  end

  private

    def slugify
      self.slug = name.parameterize
    end

    def create_project_structure
      data_dir = File.join(Rails.root, 'data')
      Dir.mkdir data_dir if not File.exists? data_dir
      Dir.mkdir self.directory if not File.exists? self.directory

      git_repository = Git.init self.directory

      Dir.mkdir wiki_directory if not File.exists? wiki_directory
      File.open File.join(wiki_directory, 'index.txt'), 'w' do |f|
        f.puts 'h2. Welcome'
      end

      Dir.mkdir tickets_directory if not File.exists? tickets_directory
      FileUtils.touch File.join(tickets_directory, '.gitinclude')

      FileUtils.touch config_file

      git_repository.config('user.name', 'system')
      git_repository.config('user.email', 'system@local')

      git_repository.add '.'
      git_repository.commit 'Create project structure'
    end
end

