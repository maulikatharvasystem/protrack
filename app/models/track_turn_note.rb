class TrackTurnNote < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :client_track  
  has_many :track_turn_image
  
  validates :tn_step_id, :presence => {:message => I18n.t('presence') } 
  validates :tn_name,  :presence => {:message => I18n.t('presence') } 
  
  validates :tn_picture, :presence => {:message => I18n.t('presence') } 
  validates :tn_video,  :presence => {:message => I18n.t('presence') } 
  
  validates :tn_step_id, :uniqueness => {:scope => [:fk_track_id, :fk_plactype_id], :message => I18n.t('uniqueness') }
  validates :tn_name, :uniqueness => {:scope => [:fk_track_id, :fk_plactype_id], :message => I18n.t('uniqueness') }
      
  before_create  :fill_current 
  before_save  :fill_update 
   
  def self.get_track_turn_notes(client_id, per_page, page_no)
	where_cond = " where status_code in(401,402) "
	
	if client_id >0		
		where_cond= where_cond + " and fk_client_id=" +  client_id.to_s  + " "	
	end
	
	@track_turn=TrackTurn.paginate_by_sql("select 
		pk_product_id, ios_product_id, ios_price
		from product_prices  " +		
		where_cond + " ", :per_page => per_page , :page => page_no)
		
	return @track_turn
  end
  
  def self.get_track_turns_paginate(client_id, track_id, per_page, page_no)
	where_cond = " where TTN.status_code in(401,402) "
	
	if client_id > 0		
	#	where_cond= where_cond + " and CT.fk_client_id=" +  client_id.to_s  + " "	
	end
	where_cond= where_cond + " and TTN.fk_track_id=" +  track_id.to_s  + " "
	
	@track_turn_notes=TrackTurnNote.paginate_by_sql("SELECT `pk_tn_id`, `fk_track_id`, `fk_client_id`," +
	" `fk_plactype_id`, `tn_step_id`, `tn_name`, tn_video, `tn_data`, tn_type, " +
	"tn_strategy, tn_marker, tn_picture, `tn_note`, " +
	"`x_pos`, `y_pos`, `sort_no`, `status_code`, last_updated_at " +
 	" FROM `track_turn_notes` TTN " +		
    where_cond + " order by sort_no asc ", :per_page => per_page , :page => page_no)
		
	return @track_turn_notes
  end
  
  def self.get_selected_track_turns(client_id, track_id)
	where_cond = " where TTN.status_code in(401,402) "
	
	if client_id > 0		
	#	where_cond= where_cond + " and CT.fk_client_id=" +  client_id.to_s  + " "			
	end
	where_cond= where_cond + " and TTN.fk_track_id=" +  track_id.to_s  + " "
	
	@track_turn_notes=TrackTurnNote.find_by_sql("SELECT `pk_tn_id`, `fk_track_id`, `fk_client_id`," +
	" `fk_plactype_id`, `tn_step_id`, `tn_name`, tn_video, `tn_data`, tn_type, " +
	"tn_strategy, tn_marker, tn_picture, `tn_note`, " +
	"`x_pos`, `y_pos`, `sort_no`, `status_code`, last_updated_at " +
 	" FROM `track_turn_notes` TTN " +		
	where_cond + " ")
		
	return @track_turn_notes
  end
  
  def self.get_turn_info(client_id, turn_id)
	where_cond = " where TTN.status_code in(401,402) "
	
	if client_id > 0		
	#	where_cond= where_cond + " and CT.fk_client_id=" +  client_id.to_s  + " "			
	end
	where_cond= where_cond + " and TTN.pk_tn_id=" +  turn_id.to_s  + " "
	
	@track_turn_notes=TrackTurnNote.find_by_sql("SELECT `pk_tn_id`, `fk_track_id`, `fk_client_id`," +
	" `fk_plactype_id`, `tn_step_id`, `tn_name`, tn_video, `tn_data`, tn_type, " +
	"tn_strategy, tn_marker, tn_picture, `tn_note`, " +
	"`x_pos`, `y_pos`, `sort_no`, `status_code`, last_updated_at " +
 	" FROM `track_turn_notes` TTN " +		
	where_cond + " ")
		
	return @track_turn_notes.first
  end
  
  def self.get_turn_last_sort_no(client_id, track_id)
	where_cond = " where TTN.status_code in(401,402) "
	
	if client_id.to_i > 0		
	#	where_cond= where_cond + " and CT.fk_client_id=" +  client_id.to_s  + " "			
	end
	where_cond= where_cond + " and TTN.fk_track_id=" +  track_id.to_s  + " "
	
	@track_turn_notes=TrackTurnNote.find_by_sql("SELECT  IFNULL( max( sort_no ) , 0 ) +1 AS last_sort_no" +
		" FROM `track_turn_notes` TTN " +		
		where_cond + " ")
		
	return @track_turn_notes.first.last_sort_no
  end
  
  private
   
  def fill_current
       self.create_at = Time.now  
	   self.last_updated_at = Time.now 	
  end
     
  def fill_update
      self.last_updated_at = Time.now 	 
  end  
  
end
