class TrackSessionReport < ActiveRecord::Base
  attr_accessible :fk_session_id, :report_code, :session_report, :status_code
  belongs_to :track_session
end
