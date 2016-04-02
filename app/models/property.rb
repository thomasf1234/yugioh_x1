class Property < ActiveRecord::Base
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