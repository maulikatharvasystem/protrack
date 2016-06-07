class CreateRaceEngineerReports < ActiveRecord::Migration
  def change
    create_table :race_engineer_reports do |t|
      t.integer :client_id, :limit => 6
      t.integer :race_engineer_id, :limit => 6
      t.string :name
      t.date  :report_date
      t.integer :driver_id, :limit => 6
      t.string :engineer_name
      t.string :championship
      t.string :circuit
      t.string :event
      t.text :report_info
      t.string :create_ip
      t.string :last_updated_ip
      t.integer :status_code
      t.timestamps
    end
  end
end
