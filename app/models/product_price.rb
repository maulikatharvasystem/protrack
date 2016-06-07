class ProductPrice < ActiveRecord::Base
  # attr_accessible :title, :body
   belongs_to :client_track   
  
  #validates :ios_price, :numericality => {:only_integer => true}
  validates :ios_price, :format => { :with => /^\d+??(?:\.\d{0,2})?$/ }, :numericality =>{:greater_than_or_equal_to => 0}
  validates :ios_product_id, :presence => {:message => I18n.t('presence') } 
  validates :ios_price,  :presence => {:message => I18n.t('presence') }   
  validates :ios_product_id, :uniqueness => {:scope => :fk_client_id, :message => I18n.t('uniqueness') }
    
  before_create  :fill_current 
  before_save  :fill_update
  
  def combined_value
    "$#{self.ios_price} (#{self.ios_product_id})"
  end
  
  def self.get_track_price_page(client_id, per_page, page_no)
	where_cond = " where status_code in(401,402) "
	
	if(client_id > 0)		
		where_cond= where_cond + " and fk_client_id=" +  client_id.to_s  + " "	
	end
	
	@track_price=ProductPrice.paginate_by_sql("select 
		pk_product_id, ios_product_id, ios_price
		from product_prices  " +		
		where_cond + " ", :per_page => per_page, :page => page_no)
		
	return @track_price
  end
  
  def self.get_track_price(client_id)
	where_cond = " where status_code in(401,402) "
	
	if client_id >0		
		where_cond= where_cond + " and fk_client_id=" +  client_id.to_s  + " "	
	end
	
	@track_price=ProductPrice.find_by_sql("select 
		pk_product_id, ios_product_id, ios_price
		from product_prices  " +		
		where_cond + " ")
		
	return @track_price
  end
  
   
  def self.get_selected_track_price(client_id, price_id)
	where_cond = " where status_code in(401,402) "
	
	if client_id >0		
		where_cond= where_cond + " and fk_client_id=" +  client_id.to_s  + " "	
	end
	
	where_cond= where_cond + " and pk_product_id=" +  price_id.to_s  + " "	
	
	@track_price=ProductPrice.find_by_sql("select 
		pk_product_id, ios_product_id, ios_price, description, last_updated_at
		from product_prices  " +		
		where_cond + " ").first
		
	return @track_price
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
