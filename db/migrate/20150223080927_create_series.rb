class CreateSeries < ActiveRecord::Migration
  def change
    create_table :series do |t|
      t.string :series
      t.string :regulations_pdf_url
      t.string :media_pdf_url
      t.string :car_manual_pdf_url

      t.timestamps
    end
  end
end
