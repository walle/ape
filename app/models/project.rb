class Project < ActiveRecord::Base
  attr_reader :config
  attr_accessible :name, :description, :slug, :default

  before_validation :slugify
  after_create :create_project_structure
  after_initialize :load_config, :unless => :saved?
  after_update :save_config

  validates :name, :presence => true
  validates :slug, :presence => true,
                    :uniqueness => true

  def default?
    self.default
  end

  def directory
    File.join Rails.root, 'data', slug
  end

  def config_file
    File.join self.directory, 'config.yml'
  end

  def wiki_directory
    File.join self.directory, 'wiki'
  end

  def tickets_directory
    File.join self.directory, 'tickets'
  end

  def default_user_name
    @config['default_user']['name']
  end

  def default_user_email
    @config['default_user']['email']
  end

  def default_user_name=(name)
    load_config if @config.nil?
    @config['default_user']['name'] = name
  end

  def default_user_email=(email)
    load_config if @config.nil?
    @config['default_user']['email'] = email
  end

  def save_config
    file = File.new self.config_file, 'w'
    file.puts YAML.dump @config
    file.close

    commit_all 'Update config'
  end

  def commit_all(message)
    git_repository = Git.init self.directory
    git_repository.config('user.name', default_user_name)
    git_repository.config('user.email', default_user_email)

    git_repository.add '.'
    git_repository.commit message rescue nil
  end

  def to_param
    slug
  end

  private

    def saved?
      slug.nil?
    end

    def load_config
      file = File.new self.config_file, 'r'
      @config = YAML.load file.read
      file.close
    end

    def slugify
      self.slug = name.parameterize
    end

    def create_project_structure
      data_dir = File.join(Rails.root, 'data')
      Dir.mkdir data_dir if not File.exists? data_dir
      Dir.mkdir self.directory if not File.exists? self.directory

      Dir.mkdir wiki_directory if not File.exists? wiki_directory
      File.open File.join(wiki_directory, 'index.txt'), 'w' do |f|
        f.puts 'h2. Welcome'
      end

      Dir.mkdir tickets_directory if not File.exists? tickets_directory
      FileUtils.touch File.join(tickets_directory, '.gitinclude')

      default_user_name = 'system'
      default_user_email = 'system@local'

      save_config

      commit_all 'Create project structure'
    end
end

