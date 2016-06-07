class TrackTurnImage < ActiveRecord::Base 
  belongs_to :track_turn_note  
  
  validates :turn_image, :presence => {:message => I18n.t('presence') } 
  validates :fk_tn_id,  :presence => {:message => I18n.t('presence') } 
    
end
