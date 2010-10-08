class Ticket
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

      tickets << Ticket.new(project, dir, author.name, author.email, author.date, contents) unless contents.empty?
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

      Ticket.new hash[:project], id, author.name, author.email, author.date, contents
    else
      Ticket.new hash[:project], id, '', '', '', contents
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

