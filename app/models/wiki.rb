class Wiki
  include ActionController::UrlWriter

  attr_reader :page, :name, :email, :date
  attr_accessor :contents

  def initialize(project, page, name, email, date, contents)
    @project = project
    @page = File.join page.split('/').map { |file| file.parameterize }
    @name = name
    @mail = email
    @date = date
    @contents = contents
  end

  def self.find(hash)
    return nil unless hash.has_key?(:project) && hash.has_key?(:page)

    page = hash[:page].to_s
    filename = File.join hash[:project].directory, 'wiki', page, 'index.txt'
    contents = self.file_contents hash[:project], filename, hash[:revision]

    if (File.exists? filename)
      git_repository = Git.open hash[:project].directory
      author = git_repository.log.path(filename).first.author

      Wiki.new hash[:project], page, author.name, author.email, author.date, contents
    else
      Wiki.new hash[:project], page, '', '', '', contents
    end
  end

  def save!(message)
    page_dir = File.join @project.directory, 'wiki', @page
    Dir.mkdir page_dir unless File.exists? page_dir

    filename =  File.join page_dir, 'index.txt'
    File.open(filename, 'w') do |f|
      f.puts @contents
    end

    git_repository = Git.open @project.directory
    git_repository.add filename
    git_repository.commit message rescue nil
  end

  def destroy!(message)
    page_dir = File.join @project.directory, 'wiki', @page

    if (File.exists?(page_dir) && File.directory?(page_dir))
      git_repository = Git.open @project.directory
      git_repository.remove page_dir, { :recursive => true }
      git_repository.commit message rescue nil
    end
  end

  def parent
    dirs = File.split @page
    parent_dir = dirs[0]
    parent = File.join @project.directory, 'wiki', parent_dir
    if (File.exists? parent)
      Wiki.find({:project => @project, :page => parent_dir})
    else
      nil
    end
  end

  def pages
    Dir.chdir File.join @project.directory, 'wiki', @page
    pages = Dir['*/'].map do |p|
      if (@page.empty?)
        p.delete('/')
      else
        File.join @page, p.delete('/')
      end
    end
  end

  def revisions
    git_repository = Git.open @project.directory
    revisions = git_repository.log(500).path(File.join('wiki', @page, 'index.txt')).map do |commit|
      commit
    end
  end

  def index?
    @page.empty?
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

