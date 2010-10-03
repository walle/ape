require 'digest'

class Comment
  attr_reader :id, :type, :type_id
  attr_accessor :contents

  def initialize(project, id, type, type_id, contents)
    @project = project
    @type = type
    @type_id = type_id
    @contents = contents

    if id.nil?
      @id = Time.now.utc.to_i.to_s + '-' + Digest::SHA2.hexdigest(Time.now.utc.to_s + '#!' + type + '!#' + Random.new.rand().to_s)
    else
      @id = id
    end
  end

  def self.all(hash)
    return nil unless hash.has_key?(:project) && hash.has_key?(:type_id) && hash.has_key?(:type)

    type_id = hash[:type_id].to_s
    dirname = File.join hash[:project].directory, hash[:type], type_id

    Dir.chdir dirname
    files = Dir['*.txt']

    files.delete 'index.txt'

    comments = []

    files.sort.each do |file|
      filename = File.join dirname, file
      contents = read_file(filename)
      comments << Comment.new(hash[:project], file.partition('.txt').first, hash[:type], hash[:type_id], contents) unless contents.empty?
    end

    comments
  end

  def self.find(hash)
    return nil unless hash.has_key?(:project) && hash.has_key?(:id) && hash.has_key?(:type_id) && hash.has_key?(:type)

    type_id = hash[:type_id].to_s
    filename = File.join hash[:project].directory, hash[:type], type_id, hash[:id] + '.txt'
    contents = read_file filename

    Comment.new hash[:project], hash[:id], hash[:type], hash[:type_id], contents
  end

  def save!(message)
    dir = File.join @project.directory, @type, @type_id
    Dir.mkdir dir unless File.exists? dir

    filename =  File.join dir, @id + '.txt'
    File.open(filename, 'w') do |f|
      f.puts @contents
    end

    git_repository = Git.open @project.directory
    git_repository.add filename
    git_repository.commit message rescue nil
  end

  def destroy!(message)
    file = File.join @project.directory, @type, @type_id, @id + '.txt'

    if (File.exists?(file))
      git_repository = Git.open @project.directory
      git_repository.remove file
      git_repository.commit message rescue nil
    end
  end

  def to_s
    to_html
  end

  def to_html
    RedCloth.new(@contents).to_html.html_safe
  end

  private

    def self.read_file(filename)
      contents = ''
      if File.exists? filename
        file = File.open(filename, "r")
        contents = file.read
      end
      contents
    end

end

