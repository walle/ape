class Versionable
  attr_reader :project, :id, :name, :email, :date
  attr_accessor :contents

  def initialize(hash)
    raise ArgumentError unless hash.has_key?(:project) && hash.has_key?(:type_identifier)

    @project = hash[:project]
    id = hash[:id].to_s
    @id = File.join id.split('/').map { |file| file.parameterize }
    @name = hash[:name]
    @email = hash[:email]
    @date = hash[:date]
    @contents = hash[:contents]
    @type_identifier = hash[:type_identifier]
  end

  def self.all(hash)
    raise ArgumentError unless hash.has_key?(:project) && hash.has_key?(:type_identifier)

    directories = []
    Find.find(File.join hash[:project].directory, hash[:type_identifier]) do |file|
      if (File.directory? (file))
        file.gsub(/.?\/#{Regexp.escape(hash[:type_identifier])}\/(.+)/) do
          directories << $1
        end
      end
    end

    items = []

    git_repository = Git.open hash[:project].directory

    directories.each do |dir|
      filename = File.join hash[:project].directory, hash[:type_identifier], dir, 'index.txt'
      contents = read_file(filename)
      author = git_repository.log.path(filename).first.author

      hash = {
        :project => hash[:project],
        :id => dir,
        :name => author.name,
        :email => author.email,
        :date => author.date,
        :contents => contents,
        :type_identifier => hash[:type_identifier]
      }

      items << hash[:type_identifier].singularize.classify.constantize.new(hash) unless contents.empty?
    end

    items
  end

  def self.find(hash)
    raise ArgumentError unless hash.has_key?(:project) && hash.has_key?(:type_identifier)

    id = hash[:id].to_s
    filename = File.join hash[:project].directory, hash[:type_identifier], id, 'index.txt'
    contents = self.file_contents hash[:project], filename

    hash = {
      :project => hash[:project],
      :id => id,
      :contents => contents,
      :type_identifier => hash[:type_identifier]
    }

    if (File.exists? filename)
      git_repository = Git.open hash[:project].directory
      author = git_repository.log.path(filename).first.author
      hash = hash.merge({
        :name => author.name,
        :email => author.email,
        :date => author.date
      })
    end

    hash[:type_identifier].singularize.classify.constantize.new hash
  end

  def save!(message)
    id_dir = File.join @project.directory, @type_identifier, @id
    Dir.mkdir id_dir unless File.exists? id_dir

    filename =  File.join id_dir, 'index.txt'
    File.open(filename, 'w') do |f|
      f.puts @contents
    end

    @project.commit_all message
  end

  def destroy!(message)
    id_dir = File.join @project.directory, @type_identifier, @id

    if (File.exists?(id_dir) && File.directory?(id_dir))
      git_repository = Git.open @project.directory
      git_repository.remove id_dir, { :recursive => true }

      @project.commit_all message
    end
  end

  def parent
    dirs = File.split @id
    parent_dir = dirs[0]
    parent = File.join @project.directory, @type_identifier, parent_dir
    if (File.exists? parent)
      @type_identifier.singularize.classify.constantize.find({:project => @project, :id => parent_dir})
    else
      nil
    end
  end

  def children
    Dir.chdir File.join @project.directory, @type_identifier, @id
    children = Dir['*/'].map do |p|
      if (@id.empty?)
        p.delete('/')
      else
        File.join @id, p.delete('/')
      end
    end
  end

  def revisions
    git_repository = Git.open @project.directory
    revisions = git_repository.log(500).path(File.join(@type_identifier, @id, 'index.txt')).map do |commit|
      commit
    end
  end

  def to_html
    RedCloth.new(@contents).to_html.html_safe
  end

  private
    def self.file_contents(project, filename, revision = nil)
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

