class Project < ActiveRecord::Base
  attr_accessible :name, :description, :slug, :active

  before_save :setup

  validates :name, :presence => true
  validates :slug, :presence => true

  def active?
    self.active
  end

  private
    def setup
      debugger
      slugify
      #create_project_structure
    end

    def slugify
      debugger
      self.slug = name.parameterize
      debugger
    end

    def create_project_structure
      #project_dir = File.join(BASE_DIR, 'data', slug)
      #Git.init project_dir
      #Dir.mkdir File.join(project_dir, 'wiki')
      #Dir.mkdir File.join(project_dir, 'tickets')
      #Fite.touch project_dir + '/config.yml'
    end
end

