class Wiki
  include ActionController::UrlWriter

  attr_reader :project, :id, :name, :email, :date
  attr_accessor :contents

  def initialize(project, id, name, email, date, contents)
    @project = project
    @id = File.join id.split('/').map { |file| file.parameterize }
    @name = name
    @mail = email
    @date = date
    @contents = contents
  end

  def self.find(hash)
    return nil unless hash.has_key?(:project) && hash.has_key?(:id)

    id = hash[:id].to_s
    filename = File.join hash[:project].directory, 'wiki', id, 'index.txt'
    contents = self.file_contents hash[:project], filename, hash[:revision]

    if (File.exists? filename)
      git_repository = Git.open hash[:project].directory
      author = git_repository.log.path(filename).first.author

      Wiki.new hash[:project], id, author.name, author.email, author.date, contents
    else
      Wiki.new hash[:project], id, '', '', '', contents
    end
  end

  def save!(message)
    id_dir = File.join @project.directory, 'wiki', @id
    Dir.mkdir id_dir unless File.exists? id_dir

    filename =  File.join id_dir, 'index.txt'
    File.open(filename, 'w') do |f|
      f.puts @contents
    end

    @project.commit_all message
  end

  def destroy!(message)
    id_dir = File.join @project.directory, 'wiki', @id

    if (File.exists?(id_dir) && File.directory?(id_dir))
      git_repository = Git.open @project.directory
      git_repository.remove id_dir, { :recursive => true }

      @project.commit_all message
    end
  end

  def parent
    dirs = File.split @id
    parent_dir = dirs[0]
    parent = File.join @project.directory, 'wiki', parent_dir
    if (File.exists? parent)
      Wiki.find({:project => @project, :id => parent_dir})
    else
      nil
    end
  end

  def pages
    Dir.chdir File.join @project.directory, 'wiki', @id
    pages = Dir['*/'].map do |p|
      if (@id.empty?)
        p.delete('/')
      else
        File.join @id, p.delete('/')
      end
    end
  end

  def revisions
    git_repository = Git.open @project.directory
    revisions = git_repository.log(500).path(File.join('wiki', @id, 'index.txt')).map do |commit|
      commit
    end
  end

  def index?
    @id.empty?
  end

  def to_html
    RedCloth.new(@contents).to_html.html_safe
  end

  private
    def self.file_contents(project, filename, revision)
      contents = ''
      if (revision.nil?)
        contents = read_file filename
      else
        git_repository = Git.open project.directory
        git_repository.checkout revision
        contents = read_file filename
        git_repository.checkout 'master'
      end
      contents
    end

    def self.read_file(filename)
      contents = ''
      if File.exists? filename
        file = File.open(filename, "r")
        contents = file.read
      end
      contents
    end
end

