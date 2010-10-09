class Ticket
  attr_reader :project, :id, :name, :email, :date
  attr_accessor :contents

  def initialize(hash)
    @project = hash[:project]
    id = hash[:id].to_s
    @id = File.join id.split('/').map { |file| file.parameterize }
    @name = hash[:name]
    @mail = hash[:email]
    @date = hash[:date]
    @contents = hash[:contents]
  end

  def self.all(project)
    directories = []
    Find.find(File.join project.directory, 'tickets') do |file|
      if (File.directory? (file))
        file.gsub(/.?\/tickets\/(.+)/) do
          directories << $1
        end
      end
    end

    tickets = []

    git_repository = Git.open project.directory

    directories.each do |dir|
      filename = File.join project.directory, 'tickets', dir, 'index.txt'
      contents = read_file(filename)
      author = git_repository.log.path(filename).first.author

      hash = {
        :project => project,
        :id => dir,
        :name => author.name,
        :email => author.email,
        :date => author.date,
        :contents => contents
      }

      tickets << Ticket.new(hash) unless contents.empty?
    end

    tickets
  end

  def self.find(hash)
    return nil unless hash.has_key?(:project) && hash.has_key?(:id)

    id = hash[:id].to_s
    filename = File.join hash[:project].directory, 'tickets', id, 'index.txt'
    contents = self.file_contents hash[:project], filename

    if (File.exists? filename)
      git_repository = Git.open hash[:project].directory
      author = git_repository.log.path(filename).first.author

      hash = {
        :project => hash[:project],
        :id => id,
        :name => author.name,
        :email => author.email,
        :date => author.date,
        :contents => contents
      }

      Ticket.new hash
    else
      Ticket.new({:project => hash[:project], :id => id, :contents => contents})
    end
  end

  def save!(message)
    id_dir = File.join @project.directory, 'tickets', @id
    Dir.mkdir id_dir unless File.exists? id_dir

    filename =  File.join id_dir, 'index.txt'
    File.open(filename, 'w') do |f|
      f.puts @contents
    end

    @project.commit_all message
  end

  def destroy!(message)
    id_dir = File.join @project.directory, 'tickets', @id

    if (File.exists?(id_dir) && File.directory?(id_dir))
      git_repository = Git.open @project.directory
      git_repository.remove id_dir, { :recursive => true }

      @project.commit_all message
    end
  end

  def to_html
    RedCloth.new(@contents).to_html.html_safe
  end

  private
    def self.file_contents(project, filename)
      read_file filename
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

