class DeviceUser < ActiveRecord::Base
  belongs_to :client
  has_many :user_device
  
  attr_accessible :email, :first_name, :last_name, :phone, :address, :dob, :password, :sessionid, :file_name, :last_timestamp
  attr_accessor :old_password, :new_password, :confirmation_pwd, :encrypt_pwd_confirmation, :user_type
 
  validates :first_name, :presence => {:message => I18n.t('presence') } 
  validates :last_name,  :presence => {:message => I18n.t('presence') } 
  validates :address,  :presence => {:message => I18n.t('presence') } 
  #validates :dob,  :presence => {:message => I18n.t('presence') } 
  
  validates :fk_client_id, :presence => {:message => I18n.t('presence') } , :on => :create
  validates :email, :presence => {:message => I18n.t('presence') }   
  #validates :email, :uniqueness => {:scope => :fk_client_id, :message => I18n.t('uniqueness') }
  validates :password, :presence => {:message => I18n.t('presence') } , :on => :create  
  validates_confirmation_of :password, {:message => I18n.t('validates_confirmation_of') }   
   
  validates :password, :length => {:minimum => 5, :message => I18n.t('length_Min_5')}, :on => :create, :allow_blank => true
  validates :password, :length => {:maximum => 32, :message => I18n.t('length_Max_32')}, :on => :create, :allow_blank => true
 
  validates :email, :format => { :with => /^(|(([A-Za-z0-9]+_+)|([A-Za-z0-9]+\-+)|([A-Za-z0-9]+\.+)|([A-Za-z0-9]+\++))*[A-Za-z0-9]+@((\w+\-+)|(\w+\.))*\w{1,63}\.[a-zA-Z]{2,6})$/i, :message => I18n.t('format') }

  validate :exist_driver, :on => :create

   before_create  :fill_current
   before_save  :fill_update 
   #after_save :clear_password   
 
  def exist_driver
    if DeviceUser.where("email = ? AND status_code != '403'",email).present?
      errors.add(:email, "already exist in database.")
    end
  end
   
    def self.get_device_user_lists(client_id, per_page, page_no)
		where_cond = " where DU.status_code in(401,402) "
		#where_cond = " where 1=1"
		
		if client_id.to_i > 0		
			where_cond= where_cond + " and DU.fk_client_id=" +  client_id.to_s  + " "	
		end
		
		@device_users=DeviceUser.paginate_by_sql("select pk_user_id " +
			" ,first_name, last_name, phone,email, last_updated_at, status_code from device_users as DU	" +		
			where_cond + " order by pk_user_id desc ", :per_page => per_page , :page => page_no)
			 
		return @device_users
   end
   
    def self.get_device_user_list(client_id)
		where_cond = " where status_code=401 "
		
		if client_id.to_i > 0		
			where_cond= where_cond + " and fk_client_id=" +  client_id.to_s  + " "	
		end
		
		@device_users=DeviceUser.find_by_sql("select " +
			" CONCAT(first_name , ' ' , last_name, '(', email ,')') as name, pk_user_id  " +
			" from device_users  " +		
			where_cond + " ")
			
		return @device_users
    end
   
    def self.get_selected_device_user(user_id)
		where_cond = " where DU.status_code in(401,402,400) "
		
		#if admin_id > 0		
		#	where_cond= where_cond + " and CL.fk_client_id=" +  admin_id.to_s  + " "	
		#end
		where_cond= where_cond + " and DU.pk_user_id=" +  user_id.to_s  + " "
		
		@device_users=DeviceUser.find_by_sql("select  pk_user_id " +
			" ,first_name, last_name, phone,email, last_updated_at, status_code from device_users as DU " +	
			where_cond + "  ")
			
		return @device_users.first
	end
	
   private   
	
    def fill_current
       self.create_at = Time.now   
	   self.last_updated_at = Time.now 	   
	  # self.last_timestamp=Time.now.to_i
    end
     
    def fill_update
      self.last_updated_at = Time.now 
	  #self.last_timestamp=Time.now.to_i
    end
	 
  
   
end
