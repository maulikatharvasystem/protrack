class UserReportField < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :user_report  
   
  validates :fk_user_id, :presence => {:message => I18n.t('presence') } 
  validates :fk_client_id, :presence => {:message => I18n.t('presence') } 
  validates :fk_report_id, :presence => {:message => I18n.t('presence') }
  
  validates :key, :presence => {:message => I18n.t('presence') } 
  validates :name, :presence => {:message => I18n.t('presence') }
  #validates :value, :presence => {:message => I18n.t('presence') }
  #validates :need_rating, :presence => {:message => I18n.t('presence') }
  validates :rating, :presence => {:message => I18n.t('presence') }
  
  # validates :tn_step_id, :uniqueness => {:scope => [:fk_track_id, :fk_plactype_id], :message => I18n.t('uniqueness') }
  # validates :tn_name, :uniqueness => {:scope => [:fk_track_id, :fk_plactype_id], :message => I18n.t('uniqueness') }
      
 # before_create  :fill_current 
 # before_save  :fill_update 
  
  private
   
  def fill_current
       self.create_at = Time.now  
	   self.last_updated_at = Time.now 	
  end
     
  def fill_update
      self.last_updated_at = Time.now 	 
  end  
  
end
