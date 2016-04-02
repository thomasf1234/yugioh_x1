class Property < ActiveRecord::Base
  module Names
    ELEMENT = 'element'
    LEVEL = 'level'
    RANK = 'rank'
    SPECIES = 'species'
    ATTACK = 'attack'
    DEFENSE = 'defense'
    PROPERTY = 'property'
    ALL = constants.collect { |const| module_eval(const.to_s) }
  end

  belongs_to :card

  DATA_MAP = {
      'integer' => :to_i,
      'string' => :to_s,
  }

  validates_presence_of :name, :value, :data_type

  def value
    self.data_type == 'string' ? read_attribute(:value) : read_attribute(:value).send(DATA_MAP[self.data_type])
  end
end