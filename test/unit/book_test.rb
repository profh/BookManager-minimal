require 'test_helper'

class BookTest < ActiveSupport::TestCase
  # Start by using Shoulda's ActiveRecord matchers
  # Relationship macros...
  should belong_to(:category)
  should have_many(:book_authors)
  should have_many(:authors).through(:book_authors)
  
  # Validation macros...
  should validate_presence_of(:title)
  should allow_value(1000).for(:units_sold)
  should_not allow_value(-1000).for(:units_sold)
  should_not allow_value(3.14159).for(:units_sold)
  should_not allow_value("bad").for(:units_sold)
  
  # Test dates as much as you can with matchers...
  should allow_value(1.year.ago).for(:proposal_date)
  should_not allow_value(1.week.from_now).for(:proposal_date)
  should_not allow_value("bad").for(:proposal_date)
  should_not allow_value(nil).for(:proposal_date)
  # should allow_value(1.year.ago).for(:contract_date)

  # ---------------------------------
  # Testing other methods with a context
  context "Creating 4 books from 5 authors" do
    # create the objects I want with factories
    setup do 
      @ruby = Factory.create(:category)
      @rails = Factory.create(:category, :name => "Rails")
      @testing = Factory.create(:category, :name => "Testing")
      @dblack = Factory.create(:author)
      @michael = Factory.create(:author, :first_name => "Michael", :last_name => "Hartl")
      @aslak = Factory.create(:author, :first_name => "Aslak", :last_name => "Hellesoy")
      @dchel = Factory.create(:author, :first_name => "David", :last_name => "Chelimsky")
      @wgr = Factory.create(:book, :category => @ruby)
      @r3t = Factory.create(:book, :title => "Rails 3 Tutorial", :category => @rails)
      @rfm = Factory.create(:book, :title => "Ruby for Masters", :category => @ruby, :published_date => nil)
      @rspec = Factory.create(:book, :title => "The RSpec Book", :category => @testing)
      @agt = Factory.create(:book, :title => "Agile Testing", :category => @testing, :contract_date => nil, :published_date => nil)
      @ba1 = Factory.create(:book_author, :book => @wgr, :author => @dblack)
      @ba2 = Factory.create(:book_author, :book => @r3t, :author => @michael)
      @ba3 = Factory.create(:book_author, :book => @rfm, :author => @dblack)
      @ba4 = Factory.create(:book_author, :book => @rspec, :author => @aslak)
      @ba5 = Factory.create(:book_author, :book => @rspec, :author => @dchel)
      @ba6 = Factory.create(:book_author, :book => @agt, :author => @dchel)
    end  
    
    # and provide a teardown method as well
    teardown do
      @ruby.destroy
      @rails.destroy
      @testing.destroy
      @dblack.destroy
      @michael.destroy
      @aslak.destroy
      @dchel.destroy
      @wgr.destroy
      @r3t.destroy
      @rfm.destroy
      @rspec.destroy
      @agt.destroy
      @ba1.destroy
      @ba2.destroy
      @ba3.destroy
      @ba4.destroy
      @ba5.destroy
      @ba6.destroy
    end
  
    # now run the tests:
    # test one of each factory (not really required, but not a bad idea)
    should "show that all factories are properly created" do
      assert_equal "Ruby", @ruby.name
      assert_equal "Rails", @rails.name
      assert_equal "Testing", @testing.name
      assert_equal "Black, David", @dblack.name
      assert_equal "Hartl, Michael", @michael.name
      assert_equal "Hellesoy, Aslak", @aslak.name
      assert_equal "Chelimsky, David", @dchel.name
      assert_equal "The Well-Grounded Rubyist", @wgr.title
      assert_equal "Rails 3 Tutorial", @r3t.title
      assert_equal "Ruby for Masters", @rfm.title
      assert_equal "The RSpec Book", @rspec.title
      assert_equal "Black, David", @wgr.authors.first.name
      assert_equal "Hartl, Michael", @r3t.authors.first.name
      assert_equal 2, @rspec.authors.size
      assert_equal "Chelimsky, David", @rspec.authors.alphabetical.first.name
      assert_equal "Black, David", @rfm.authors.first.name
      assert_nil @agt.contract_date
      assert_nil @rfm.published_date
    end
    
    # TESTING SCOPES 
    # scope :by_title, order('title')
    # scope :by_category, joins(:category).order('categories.name, books.title')
    # scope :published, where('published_date IS NOT NULL')
    # scope :under_contract, where('contract_date IS NOT NULL AND published_date IS NULL')
    # scope :proposed, where('proposal_date IS NOT NULL AND contract_date IS NULL')
    # scope :for_category, lambda {|category_id| where("category_id = ?", category_id) }
    
    should "have all the books listed alphabetically by title" do
      assert_equal ["Agile Testing", "Rails 3 Tutorial", "Ruby for Masters", "The RSpec Book", "The Well-Grounded Rubyist"], Book.by_title.map{|b| b.title}
    end
    
    should "have all the books listed alphabetically by category, then by title" do
      assert_equal ["Rails 3 Tutorial", "Ruby for Masters", "The Well-Grounded Rubyist", "Agile Testing", "The RSpec Book"], Book.by_category.map{|b| b.title}
    end
    
    should "have all the published books" do
      assert_equal ["Rails 3 Tutorial", "The RSpec Book", "The Well-Grounded Rubyist"], Book.published.by_title.map{|b| b.title}
    end
    
    should "have all the books under contract" do
      assert_equal ["Ruby for Masters"], Book.under_contract.by_title.map{|b| b.title}
    end
    
    should "have all the books that are only at proposal stage" do
      assert_equal ["Agile Testing"], Book.proposed.by_title.map{|b| b.title}
    end
    
    should "have all the books for a particular category" do
      assert_equal ["Ruby for Masters", "The Well-Grounded Rubyist"], Book.for_category(@ruby.id).by_title.map{|b| b.title}
      assert_equal ["Rails 3 Tutorial"], Book.for_category(@rails.id).by_title.map{|b| b.title}
      assert_equal ["Agile Testing", "The RSpec Book"], Book.for_category(@testing.id).by_title.map{|b| b.title}
    end
    
    # TESTING CONTRACT AND PUBLISHED DATES
    # validates_date :contract_date, :after => :proposal_date, :on_or_before => lambda { Date.current }, :allow_blank => true
    # validates_date :published_date, :after => :contract_date, :on_or_before => lambda { Date.current }, :allow_blank => true  
    
    should "allow for a contract date in the past after the proposal date" do
      # since the default proposal date is a year ago
      big_ruby_book = Factory.build(:book, :contract_date => 50.weeks.ago, :category => @ruby, :title => "The Big Book of Ruby")
      assert big_ruby_book.valid?
    end
    
    should "allow for contract and published dates to be nil" do
      # make pub date also nil otherwise it will fail b/c default pub date is 3 weeks ago, which is before a nil contract date
      big_ruby_book = Factory.build(:book, :contract_date => nil, :published_date => nil, :category => @ruby, :title => "The Big Book of Ruby")
      assert big_ruby_book.valid?
    end
    
    should "not allow for a contract date in the past before the proposal date" do
      big_ruby_book = Factory.build(:book, :contract_date => 14.months.ago, :category => @ruby, :title => "The Big Book of Ruby")
      deny big_ruby_book.valid?
    end
    
    should "not allow for a contract date in the future" do
      big_ruby_book = Factory.build(:book, :contract_date => 1.month.from_now, :category => @ruby, :title => "The Big Book of Ruby")
      deny big_ruby_book.valid?
    end
    
    should "allow for a published date in the past after the contract date" do
      # since the default proposal date is 10 months ago
      big_ruby_book = Factory.build(:book, :published_date => 5.weeks.ago, :category => @ruby, :title => "The Big Book of Ruby")
      assert big_ruby_book.valid?
    end
    
    should "allow for just the published date to be nil" do
      big_ruby_book = Factory.build(:book, :published_date => nil, :category => @ruby, :title => "The Big Book of Ruby")
      assert big_ruby_book.valid?
    end
    
    should "not allow for a published date in the past before the contract date" do
      big_ruby_book = Factory.build(:book, :published_date => 11.months.ago, :category => @ruby, :title => "The Big Book of Ruby")
      deny big_ruby_book.valid?
    end
    
    should "not allow for a published date in the future" do
      big_ruby_book = Factory.build(:book, :published_date => 3.weeks.from_now, :category => @ruby, :title => "The Big Book of Ruby")
      deny big_ruby_book.valid?
    end
    
    
    # TESTING CUSTOM VALIDATIONS
    # test the custom validation 'category_is_active_in_system'
    should "identify an inactive category as invalid" do
      @python = Factory.create(:category, :name => "Python", :active => false)
      python_book = Factory.build(:book, :category => @python, :title => "Learning Python")
      deny python_book.valid?
      @python.destroy
    end
    
  end
end
