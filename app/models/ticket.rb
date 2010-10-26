class Ticket < Versionable
  def initialize(hash)
    super hash.merge(:type_identifier => 'tickets')
  end

  def self.type_identifier
    'tickets'
  end

  def self.all(hash)
    super hash.merge(:type_identifier => self.type_identifier)
  end

  def self.find(hash)
    super hash.merge(:type_identifier => self.type_identifier)
  end

  def self.roots(hash)
    raise ArgumentError unless hash.has_key?(:project)

    items = []

    git_repository = Git.open hash[:project].directory

    Dir.chdir File.join hash[:project].directory, self.type_identifier
    children = Dir['*/'].map do |dir|
      filename = File.join hash[:project].directory, self.type_identifier, dir, 'index.txt'
      contents = read_file(filename)
      author = git_repository.log.path(filename).first.author

      hash = {
        :project => hash[:project],
        :id => dir,
        :name => author.name,
        :email => author.email,
        :date => author.date,
        :contents => contents,
        :type_identifier => self.type_identifier
      }

      items << Ticket.new(hash) unless contents.empty?
    end

    items
  end

  def config_file
    File.join directory, 'config.yml'
  end

  def save_config
    unless @config.nil?
      file = File.new config_file, 'w'
      file.puts YAML.dump @config
      file.close

      @project.commit_all 'Update config'
    end
  end

  def save!(message)
    super message

    create_config_file
    save_config
  end

  private
    def create_config_file
      unless File.exists? config_file
        @config = {}
        @config['status'] = 'Open'
      end
      save_config
    end

    def load_config
      file = File.new config_file, 'r'
      @config = YAML.load file.read
      file.close
    end
end

