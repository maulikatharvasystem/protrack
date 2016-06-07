class ManageUrl < ActiveRecord::Base
  attr_accessible :admin_id, :car_manual_pdf, :fb_url, :formula_url, :media_pdf, :prema_url, :regulation_pdf, :twitter_url
  belongs_to :admin
end
