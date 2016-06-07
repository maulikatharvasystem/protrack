class UserTurnNote < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :track_turn_note    
  
  validates :fk_tn_id, :presence => {:message => I18n.t('presence') } 
  #validates :tn_name,  :presence => {:message => I18n.t('presence') } 
  #validates :tn_picture, :presence => {:message => I18n.t('presence') } 
    
  validates :fk_tn_id, :uniqueness => {:scope => [:fk_user_id, :fk_client_id], :message => I18n.t('uniqueness') }
      
  before_create  :fill_current 
  before_save  :fill_update    
  
  private
   
  def fill_current
       self.create_at = Time.now  
	   self.last_updated_at = Time.now 	
  end
     
  def fill_update
      self.last_updated_at = Time.now 	 
  end  
  
end
