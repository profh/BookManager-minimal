class Category < ActiveRecord::Base
  # Relationships
  has_many :books
  
  # Validations
  validates :name, :presence => true
  
  # Scopes
  scope :alphabetical, order('name')
  scope :active, where('active = ?', true)
end
