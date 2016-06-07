class CreateTrackSessionReports < ActiveRecord::Migration
  def change
    create_table :track_session_reports do |t|
      t.string :session_report
      t.integer :fk_session_id
      t.integer :status_code
      t.integer :report_code

      t.timestamps
    end
  end
end
