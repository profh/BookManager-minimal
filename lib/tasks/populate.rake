namespace :db do
  desc "Erase and fill database"
  # creating a rake task within db namespace called 'populate'
  # executing 'rake db:populate' will cause this script to run
  task :populate => :environment do
    # Invoke rake db:migrate just in case...
    Rake::Task['db:migrate'].invoke
    
    # Need two gems to make this work: faker & populator
    # Docs at: http://populator.rubyforge.org/
    require 'populator'
    # Docs at: http://faker.rubyforge.org/rdoc/
    require 'faker'
    
    # Step 1: clear any old data in the db
    [Book, Author, BookAuthor, Category].each(&:delete_all)
    
    
    # Step 2: add some categories to work with (small set for now...)
    categories = %w[".NET", "Agile Practices", "Android", "Databases", "Design", "Java", "PHP", "Python", "Rails", "Ruby", "Security", "Testing", "iOS"]

    categories = %w[Ruby Rails Python PHP .NET Java Databases iOS Android Design Testing Security Agile\ Practices]
    categories.sort.each do |category|
      # create an Category object and assign the name passed into block
      a = Category.new
      a.name = category
      a.active = true
      # save with bang (!) so exception is thrown on failure
      a.save!
    end
    
    # Step 3: add 30 authors to the system and associated books
    Author.populate 30 do |author|
      # get some fake data using the Faker gem
      author.first_name = Faker::Name.first_name
      author.last_name = Faker::Name.last_name
      # assume 90% or so of authors are active
      chance_active = rand(10)  # will generate numbers 0,1,2,3,4,5,6,7,8,9 at random
      if chance_active.zero?
        author.active = false
      else
        author.active = true
      end
      # set the timestamps
      author.created_at = Time.now
      author.updated_at = Time.now
    end
        
    # Step 4: add some books to the system
    books = [["The Little .NET Book",1],["The Little Agile Book",2],["The Little Android Book",3],["The Little Databases Book",4],["The Little Design Book",5],["The Little Java Book",6],["The Little PHP Book",7],["The Little Python Book",8],["The Little Rails Book",9],["The Little Ruby Book",10],["The Little Security Book",11],["The Little Testing Book",12],["The Little iOS Book",13],["The Secrets of .NET",1],["The Secrets of Agile",2],["The Secrets of Android",3],["The Secrets of Databases",4],["The Secrets of Design",5],["The Secrets of Java",6],["The Secrets of PHP",7],["The Secrets of Python",8],["The Secrets of Rails",9],["The Secrets of Ruby",10],["The Secrets of Security",11],["The Secrets of Testing",12],["The Secrets of iOS",13],["Programming .NET",1],["Programming Agile",2],["Programming Android",3],["Programming Databases",4],["Programming Design",5],["Programming Java",6],["Programming PHP",7],["Programming Python",8],["Programming Rails",9],["Programming Ruby",10],["Programming Security",11],["Programming Testing",12],["Programming iOS",13],[".NET for Idiots",1],["Agile for Idiots",2],["Android for Idiots",3],["Databases for Idiots",4],["Design for Idiots",5],["Java for Idiots",6],["PHP for Idiots",7],["Python for Idiots",8],["Rails for Idiots",9],["Ruby for Idiots",10],["Security for Idiots",11],["Testing for Idiots",12],["iOS for Idiots",13]]
    books.each do |book|
      b = Book.new
      b.title = book[0]
      b.category_id = book[1]
      # decide book status
      book_status = rand(5) + 1
      if book_status == 1
        # the book is proposed, but not under contract
        b.proposal_date = [5.weeks.ago, 4.weeks.ago, 3.weeks.ago, 1.week.ago].sample
        b.contract_date = nil
        b.published_date = nil
        b.units_sold = 0
      elsif book_status == 2
        # the book is under contract, but not yet published
        b.proposal_date = [6.months.ago, 5.months.ago, 4.months.ago].sample
        b.contract_date = [3.months.ago, 2.months.ago, 1.months.ago].sample
        b.published_date = nil
        b.units_sold = 0
      else
        # the book is published
        b.proposal_date = [24.months.ago, 21.months.ago, 19.months.ago].sample
        b.contract_date = [18.months.ago, 16.months.ago, 13.months.ago].sample
        b.published_date = [12.months.ago, 10.months.ago, 9.months.ago].sample
        b.units_sold = [1000, 9000, 20000, 37000, 49000, 82000, 125000, 254000, 491000, 693000, 1045000].sample
      end
      # set the timestamps
      b.created_at = Time.now
      b.updated_at = Time.now
      # save with bang (!) so exception is thrown on failure
      b.save!
    end
    
    # Step 5: connect each book to 1 or 2 authors
    all_book_ids = Book.all.map{|b| b.id}
    all_active_author_ids = Author.active.map{|a| a.id}
    all_book_ids.each do |bid|
      # add a book author
      ba1 = BookAuthor.new
      ba1.book_id = bid
      ba1.author_id = all_active_author_ids.sample
      ba1.save!
      # add a second author if book_id is even
      if bid%2 == 0
         ba2 = BookAuthor.new
         ba2.book_id = bid
         ba2.author_id = all_active_author_ids.sample
         ba2.save!       
      end
      # add a third author if book_id is divisible by ten
      if bid%10 == 0
         ba3 = BookAuthor.new
         ba3.book_id = bid
         ba3.author_id = all_active_author_ids.sample
         ba3.save!       
      end
    end
  end
end
