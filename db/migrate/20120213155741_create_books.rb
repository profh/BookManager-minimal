class CreateBooks < ActiveRecord::Migration
  def change
    create_table :books do |t|
      t.string :title
      t.integer :category_id
      t.integer :units_sold, :default => 0
      t.date :proposal_date
      t.date :contract_date
      t.date :published_date
      t.text :notes

      t.timestamps
    end
  end
end
