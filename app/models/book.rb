class Book < ActiveRecord::Base
  # Relationships
  belongs_to :category
  has_many :book_authors
  has_many :authors, :through => :book_authors
  
  
  # Validations built into rails
  validates :title, :presence => true
  validates :units_sold, :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}
  
  # Date validations
  validates_date :proposal_date, :on_or_before => lambda { Date.current }
  validates_date :contract_date, :after => :proposal_date, :on_or_before => lambda { Date.current }, :allow_blank => true
  validates_date :published_date, :after => :contract_date, :on_or_before => lambda { Date.current }, :allow_blank => true  
  
  # Custom validation
  validate :category_is_active_in_system
  
  
  # Scopes
  scope :by_title, order('title')
  scope :by_category, joins(:category).order('categories.name, books.title')
  
  scope :published, where('published_date IS NOT NULL')
  scope :under_contract, where('contract_date IS NOT NULL AND published_date IS NULL')
  scope :proposed, where('proposal_date IS NOT NULL AND contract_date IS NULL')
  
  scope :for_category, lambda {|category_id| where("category_id = ?", category_id) }
  
  # Other methods
  private
  def category_is_active_in_system
    active_categories = Category.active.all.map{|c| c.id}
    unless active_categories.include?(self.category_id)
      errors.add(:category, "is not currently active in BookManager")
    end
  end
end
