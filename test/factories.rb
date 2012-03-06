FactoryGirl.define do
  
  factory :category do
    name "Ruby"
    active true
  end
  
  factory :book do
    title "The Well-Grounded Rubyist"
    association :category
    proposal_date 1.year.ago.to_date
    contract_date 10.months.ago.to_date
    published_date 3.weeks.ago.to_date
    units_sold 1000
    notes "It is a very good book for learning Ruby."
  end
  
  factory :author do
    first_name "David"
    last_name "Black"
    active true
  end
  
  factory :book_author do 
    association :book
    association :author
  end
  
end