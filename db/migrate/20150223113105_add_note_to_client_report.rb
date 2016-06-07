class AddNoteToClientReport < ActiveRecord::Migration
  def change
    add_column :client_tracks, :note, :string, default: nil
    add_column :client_tracks, :timing_url, :string, default: nil
    add_column :client_tracks, :media_url, :string, default: nil
    add_column :client_tracks, :weather_url, :string, default: nil
    add_column :client_tracks, :lap_video_url, :string, default: nil
    add_column :client_tracks, :schedule_pdf_url, :string, default: nil
  end
end
