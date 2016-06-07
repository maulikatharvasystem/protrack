class CreateManageUrls < ActiveRecord::Migration
  def change
    create_table :manage_urls do |t|
      t.integer :admin_id
      t.string :regulation_pdf
      t.string :media_pdf
      t.string :car_manual_pdf
      t.string :fb_url
      t.string :twitter_url
      t.string :prema_url
      t.string :formula_url

      t.timestamps
    end
  end
end
