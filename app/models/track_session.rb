class TrackSession < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :client
  has_many :track_session_image
  has_many :track_session_reports
  
  attr_accessor :session_image
  
  validates :fk_engn_id, :presence => {:message => I18n.t('presence') }
  validates :fk_client_id, :presence => {:message => I18n.t('presence') }
  validates :name, :presence => {:message => I18n.t('presence') }

  validates :session_date, :presence => {:message => I18n.t('presence') }
  validates :fk_driver_id, :presence => {:message => I18n.t('presence') }
  validates :engineer_name, :presence => {:message => I18n.t('presence') }
  validates :championship, :presence => {:message => I18n.t('presence') }
  validates :circuit, :presence => {:message => I18n.t('presence') }
  validates :event, :presence => {:message => I18n.t('presence') }
  
  
    #session_date
	#fk_driver_id
	#engineer_name
	#championship
	#circuit
	#event
	  
  validates :name, :uniqueness => {:scope => :fk_client_id, :message => I18n.t('uniqueness') }
  
  before_create  :fill_current
  before_save  :fill_update
  
  def self.get_track_sessions(rac_eng_id,client_id, per_page, page_no)
	where_cond = " where CT.status_code in(401,402) and CT.fk_engn_id= "+ rac_eng_id.to_s + " "
	
	if client_id > 0		
		where_cond= where_cond + " and CT.fk_client_id=" +  client_id.to_s  + " "	
	end
	
	@track_session=TrackSession.paginate_by_sql("select pk_session_id , CT.fk_client_id as client_id, " +
		 " name as name, CT.last_updated_at as last_updated_at " +
		 " ,session_date,fk_engn_id,fk_driver_id,engineer_name,championship,circuit,event" +
		" from track_sessions  CT " +	
		where_cond + " order by pk_session_id desc ", :per_page => per_page , :page => page_no)
	
	# render :json
	return @track_session
  end
  
  def self.get_selected_track_sessions(race_eng_id,client_id, session_id)
	where_cond = " where CT.status_code in(401,402) and fk_engn_id=" + race_eng_id.to_s + " "
	
	if client_id.to_i > 0		
		where_cond= where_cond + " and CT.fk_client_id=" +  client_id.to_s  + " "			
	end
	where_cond= where_cond + " and CT.pk_session_id=" +  session_id.to_s  + " "
	
	@track_session=TrackSession.find_by_sql("select pk_session_id , CT.fk_client_id , " + 
		" name as name, CT.last_updated_at as last_updated_at, CT.fk_engn_id " +
		" ,session_date,fk_driver_id,engineer_name,championship,circuit,event" +		
		" from track_sessions  CT	" +	
		where_cond )
		
	return @track_session.first
  end
  
   private
   
    def fill_current
       self.create_at = Time.now  
	   self.last_updated_at = Time.now 	
    end
     
    def fill_update
      self.last_updated_at = Time.now 	 
    end  
	

  
  # ALTER TABLE `track_sessions` ADD `session_date` DATE NOT NULL AFTER `name` ,
# ADD `fk_driver_id` BIGINT NOT NULL AFTER `session_date` ,
# ADD `engineer_name` VARCHAR( 255 ) NOT NULL DEFAULT '' AFTER `fk_driver_id` ,
# ADD `championship` VARCHAR( 255 ) NOT NULL DEFAULT '' AFTER `engineer_name` ,
# ADD `circuit` VARCHAR( 255 ) NOT NULL DEFAULT '' AFTER `championship` ,
# ADD `event` VARCHAR( 255 ) NOT NULL DEFAULT '' AFTER `circuit` ,
# ADD INDEX ( `fk_driver_id` ) 

#ALTER TABLE `track_sessions` CHANGE `session_date` `session_date` DATE NOT NULL DEFAULT '1900-01-01'

# ALTER TABLE `track_sessions` ADD FOREIGN KEY ( `fk_driver_id` ) REFERENCES `protrack`.`device_users` (
# `pk_user_id`
# ) ON DELETE NO ACTION ON UPDATE NO ACTION ;
end
