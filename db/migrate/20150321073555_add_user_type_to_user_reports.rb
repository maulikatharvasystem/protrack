class AddUserTypeToUserReports < ActiveRecord::Migration
  def change
    add_column :user_reports, :user_type, :string
  end
end
