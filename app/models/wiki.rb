class Wiki < Versionable
  def initialize(hash)
    super hash.merge(:type_identifier => 'wiki')
  end

  def self.type_identifier
    'wiki'
  end

  def self.all(hash)
    super hash.merge(:type_identifier => self.type_identifier)
  end

  def self.find(hash)
    super hash.merge(:type_identifier => self.type_identifier)
  end

  def index?
    @id.empty?
  end
end

