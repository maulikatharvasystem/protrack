class Transaction < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :client_track
  has_one :product_price
  
  #attr_accessible :email, :first_name, :last_name, :phone, :address, :dob
  
  validates :gateway, :presence => {:message => I18n.t('presence') } 
  validates :platform_code, :presence => {:message => I18n.t('presence') } 
  validates :fk_track_id,  :presence => {:message => I18n.t('presence') } 
  validates :fk_client_id, :presence => {:message => I18n.t('presence') } , :on => :create
  validates :fk_device_id, :presence => {:message => I18n.t('presence') }   
  validates :transaction_id, :presence => {:message => I18n.t('presence') }  
  validates :transaction_id, :uniqueness => {:message => I18n.t('uniqueness') }
  
  #validates :transaction_id, :uniqueness => {:scope => :fk_client_id, :message => I18n.t('uniqueness') }

   before_create  :fill_current
  # before_save  :fill_update 
   #after_save :clear_password
     
   def self.get_transaction(client_id, per_page, page_no)
	where_cond = " where TR.status_code in(401,402) "
	
	if client_id > 0		
		where_cond= where_cond + " and CT.fk_client_id=" +  client_id.to_s  + " "	
	end
	
	@transaction=Transaction.paginate_by_sql("select pk_trans_id, CT.track_name as track_name, product_id," +
		" original_purchase_date as purchase_date, transaction_id, price, gateway " +
		" from transactions TR " +		
		" left outer join client_tracks CT on CT.pk_track_id=TR.fk_track_id " +		
		where_cond + " order by pk_trans_id desc ", :per_page => per_page , :page => page_no)
		
	return @transaction
  end
  
  def self.get_selected_transaction(client_id, transaction_id)
	where_cond = " where TR.status_code in(401,402) "
	
	if client_id.to_i > 0		
		where_cond= where_cond + " and TR.fk_client_id=" +  client_id.to_s  + " "			
	end
	where_cond= where_cond + " and TR.pk_trans_id=" +  transaction_id.to_s  + " "
	
	@transaction=Transaction.find_by_sql("select pk_trans_id, CT.track_name as track_name, product_id," +
		" original_purchase_date as purchase_date, transaction_id, price, gateway " +
		" from transactions TR " +		
		" left outer join client_tracks CT on CT.pk_track_id=TR.fk_track_id " +		
		where_cond + " ")
		
	return @transaction.first
  end
  
   private  
	
    def fill_current
       self.create_at = Time.now    	  
    end
       
	 
end
