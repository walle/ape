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
end

