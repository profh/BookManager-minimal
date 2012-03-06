class AddDefaultUser < ActiveRecord::Migration
  def up
    # create a new instance of User and populate
    admin = User.new
    admin.username = "admin"
    admin.email = "admin@example.com"
    admin.password = "secret"
    admin.password_confirmation = "secret"
    # save with bang will throw exception on failure
   	admin.save!
  end

  def down
    # find the default user created in the 'up' method
    admin = User.find(:first, :conditions => ["username = ?", "admin"])
    # delete the user when rolling back the migration
    User.delete admin
  end
end
