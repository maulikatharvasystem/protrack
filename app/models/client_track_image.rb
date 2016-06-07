class ClientTrackImage < ActiveRecord::Base 
  belongs_to :client_track  
  
  validates :track_image, :presence => {:message => I18n.t('presence') } 
  validates :fk_track_id,  :presence => {:message => I18n.t('presence') } 
  
  
end
