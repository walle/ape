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
end

