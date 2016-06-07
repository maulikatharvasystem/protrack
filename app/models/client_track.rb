class ClientTrack < ActiveRecord::Base
  # attr_accessible :title, :body
  attr_accessible :track_name, :note

  belongs_to :client
  has_one :product_price
  has_many :transaction
  has_many :client_track_image
  
  attr_accessor :extra_image, :track_overview_page_image
  
  validates :no_turns, :presence => {:message => I18n.t('presence') } 
  validates :no_turns, :numericality => {:only_integer => true, :greater_than => 0}
  
  validates :fk_product_id, :presence => {:message => I18n.t('presence') } 
  validates :track_name, :presence => {:message => I18n.t('presence') } 
  validates :display_id,  :presence => {:message => I18n.t('presence') } 
  
  validates :track_image, :presence => {:message => I18n.t('presence') } 
  validates :track_info_image,  :presence => {:message => I18n.t('presence') } 
   
  validates :display_id, :uniqueness => {:scope => :fk_client_id, :message => I18n.t('uniqueness') }   
  validates :track_name, :length => {:maximum => 30, :message => I18n.t('length_Max_30')}
  
  before_create  :fill_current 
  before_save  :fill_update 
  
  def self.get_client_tracks(client_id, per_page, page_no)
	where_cond = " where CT.status_code in(401,402) "
	
	if client_id > 0		
		where_cond= where_cond + " and CT.fk_client_id=" +  client_id.to_s  + " "	
	end
	
	@client_track=ClientTrack.paginate_by_sql("select pk_track_id , CT.fk_client_id as client_id,
		 display_id as display_id, track_name as track_name, track_tip as track_tip, CT.description,
		track_image as track_image, track_info_image as track_info_image, 
		 ios_product_id as product_id, 	ios_price as price, no_turns as no_turns, CT.last_updated_at as last_updated_at
		from client_tracks  CT
		left outer join product_prices  PP on PP.pk_product_id=CT.fk_product_id	" +		
		where_cond + " order by pk_track_id desc ", :per_page => per_page , :page => page_no)
		
	return @client_track
  end
  
  def self.get_selected_tracks(client_id, track_id)
	where_cond = " where CT.status_code in(401,402) "
	
	if client_id > 0		
		where_cond= where_cond + " and CT.fk_client_id=" +  client_id.to_s  + " "			
	end
	where_cond= where_cond + " and CT.pk_track_id=" +  track_id.to_s  + " "
	
	@client_track=ClientTrack.find_by_sql("select pk_track_id , CT.fk_client_id as fk_client_id,
		 display_id as display_id, track_name as track_name, track_tip as track_tip, CT.description,
		track_image as track_image, track_info_image as track_info_image, fk_product_id as fk_product_id ,
		ios_product_id as ios_product_id, ios_price as ios_price, no_turns as no_turns, CT.last_updated_at as last_updated_at,
    note, timing_url, media_url, weather_url, lap_video_url, schedule_pdf_url
		from client_tracks  CT
		left outer join product_prices  PP on PP.pk_product_id=CT.fk_product_id	" +		
		where_cond + " ")
		
	return @client_track.first
  end

  def self.get_all_client_tracks
    @client_track =  ClientTrack.select('pk_track_id, track_name')
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
