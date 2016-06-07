class TrackSessionImage < ActiveRecord::Base 
  belongs_to :track_session  
  
  validates :session_image, :presence => {:message => I18n.t('presence') } 
  validates :fk_session_id,  :presence => {:message => I18n.t('presence') } 
    
end
