class UserReport < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :device_user  
  has_many :user_report_field
  
  validates :fk_user_id, :presence => {:message => I18n.t('presence') } 
  validates :fk_client_id, :presence => {:message => I18n.t('presence') } 
  
  #validates :name, :presence => {:message => I18n.t('presence') }
  #validates :circuit, :presence => {:message => I18n.t('presence') } 
  #validates :engineer_name, :presence => {:message => I18n.t('presence') }
  #validates :event, :presence => {:message => I18n.t('presence') }
  validates :report_time, :presence => {:message => I18n.t('presence') }
  #validates :championship, :presence => {:message => I18n.t('presence') }
  
  #validates :name, :uniqueness => { :message => I18n.t('uniqueness')}  
  
  #validates :name, :uniqueness => {:scope => [:fk_client_id, :fk_user_id], :message => I18n.t('uniqueness') }
  # validates :tn_name, :uniqueness => {:scope => [:fk_track_id, :fk_plactype_id], :message => I18n.t('uniqueness') }
      
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
