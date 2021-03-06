class UserDevice < ActiveRecord::Base
  # attr_accessible :title, :body 
  
  attr_accessible :platform_code, :device_token, :device_id 
  
  validates :platform_code, :presence => {:message => I18n.t('presence') } 
  validates :device_token,  :presence => {:message => I18n.t('presence') } 
  validates :device_token, :uniqueness => {:scope => :fk_client_id, :message => I18n.t('uniqueness') }
  
  before_create  :fill_current 
  before_save  :fill_update 
   
   
   private
   
    def fill_current
      self.create_at = Time.now    
	    self.last_timestamp=Time.now .to_i	  
    end
     
    def fill_update
      self.last_updated_at = Time.now 
	    self.last_timestamp=Time.now .to_i
    end
	 
end
