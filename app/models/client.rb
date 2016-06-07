require 'digest/sha1'

class Client < ActiveRecord::Base
  attr_accessible :last_updated_ip, :encrypt_pwd, :email
  attr_accessor :old_password, :new_password, :confirmation_pwd, :password, :encrypt_pwd_confirmation, :user_type
  has_many :client_track  
    
  validates :client_name, :presence => {:message => I18n.t('presence') } 
  validates :email,  :presence => {:message => I18n.t('presence') } 
  validates :email, :uniqueness => {:message => I18n.t('uniqueness') }
  
  validates :contact_person, :presence => {:message => I18n.t('presence') } 
  validates :phone,  :presence => {:message => I18n.t('presence') } 
  validates :address,  :presence => {:message => I18n.t('presence') } 
  validates :website,  :presence => {:message => I18n.t('presence') } 
  
  validates :encrypt_pwd, :presence => {:message => I18n.t('presence') } , :on => :create   
  validates_confirmation_of :encrypt_pwd, {:message => I18n.t('validates_confirmation_of') } 
   
  validates :encrypt_pwd, :length => {:minimum => 5, :message => I18n.t('length_Min_5')}, :on => :create, :allow_blank => true
  validates :encrypt_pwd, :length => {:maximum => 32, :message => I18n.t('length_Max_32')}, :on => :create, :allow_blank => true 
  validates :email, :format => { :with => /^(|(([A-Za-z0-9]+_+)|([A-Za-z0-9]+\-+)|([A-Za-z0-9]+\.+)|([A-Za-z0-9]+\++))*[A-Za-z0-9]+@((\w+\-+)|(\w+\.))*\w{1,63}\.[a-zA-Z]{2,6})$/i, :message => I18n.t('format') }

  attr_protected :hashed_password, :salt   
   
  ## Events call before and after save..-------------
  before_create  :fill_current, :create_hashed_password
  before_save  :fill_update 
 	
   def self.get_client_list(admin_id, per_page, page_no)
		#where_cond = " where CL.status_code in(401,402,400) "
		where_cond = " where 1=1"
		
		#if admin_id > 0		
		#	where_cond= where_cond + " and CL.fk_client_id=" +  admin_id.to_s  + " "	
		#end
		
		@client=Client.paginate_by_sql("select pk_client_id, " +
			" client_name, contact_person, phone, email, last_updated_at, status_code from clients as CL	" +		
			where_cond + " order by pk_client_id desc ", :per_page => per_page , :page => page_no)
			
		return @client
   end
   
  def self.get_all_client_list()
		where_cond = " where CL.status_code in(401,402) "		
		
		#if admin_id > 0		
		#	where_cond= where_cond + " and CL.fk_client_id=" +  admin_id.to_s  + " "	
		#end
		
		@client=Client.find_by_sql("select pk_client_id, client_name from clients as CL	" +		
			where_cond + " order by client_name asc ")			
		return @client
   end
       
   def self.get_selected_client(client_id)
		where_cond = " where CL.status_code in(401,402,400) "
		
		#if admin_id > 0		
		#	where_cond= where_cond + " and CL.fk_client_id=" +  admin_id.to_s  + " "	
		#end
		where_cond= where_cond + " and CL.pk_client_id=" +  client_id.to_s  + " "
		
		@client=Client.find_by_sql("select pk_client_id, " +
			" client_name, contact_person, phone, email, last_updated_at from clients as CL	" +		
			where_cond + "  ")
			
		return @client.first
	end
   
   #### Get Client info using ID...
   def self.getUserID(id)
     @client = Client.find_by(id: id)
     return @client
   end
   
   # Authentication at login.. -------------------
   def self.authenticate(email="", password="")
   
     if email.blank? == true
       return false 
     end 

	   if password.blank? == true
       return false     
     end 	 
   
     client = Client.where(email: email, status_code: '401')
        
     if client.count <= 0
       return false
     end	
	 client=client.first
	 
     if client.password_match(client[:encrypt_pwd ], password, client[:salt])       
          return client
     else
          return false
     end
        
    rescue      
       return false
   end

   def password_match(encrypted_password,password="", salt="")
     encrypted_password == Client.hash_with_salt(password, salt)
   end
   
   def self.hash_with_salt(password="", salt="")
      Digest::SHA1.hexdigest("Put #{salt} on the #{password}" )
   end
   
  # hash password created when register user... ----------------
   def self.make_salt(username="")
      Digest::SHA1.hexdigest("Use #{username} with #{Time.now} to make salt")
   end

   def valid_change_password()
    #logger.error "valid_change_password : start"
	#logger.error "old_password : " + self.old_password
	
    valid=true
    if self.old_password.blank? ==true
        errors.add(:base, I18n.t('OldPassword')  + ' '+ I18n.t('presence'))
        valid=false
    end
       
    valid=valid_password_cnfrmpwd
    
    if valid == false
      return false
    end
    #logger.error "valid =true"
	
    if Client.authenticate(self.email,self.old_password) == false
       errors.add(:base, I18n.t('OldPassword')  + ' '+ I18n.t('format'))
       return false    
    end
    
	#logger.error "authenticate"
	 
    self.encrypt_pwd=self.new_password
	#logger.error "encrypt_pwd= " + self.encrypt_pwd
    create_hashed_password
	
	#logger.error "create_hashed_password"
    
    return valid
  end
  
   def reset_password()
		#logger.error "valid_change_password : start"
		#logger.error "old_password : " + self.old_password
		
		valid=true           
		valid=valid_password_cnfrmpwd
		
		if valid == false
		  return false
		end    
		
		self.encrypt_pwd=self.new_password
		create_hashed_password    
		return valid
   end
      
   def valid_password_cnfrmpwd()
    valid=true
 
    if self.new_password.blank? ==true
       errors.add(:base, I18n.t('NewPassword')  + ' '+ I18n.t('presence'))
        valid=false
    end   

    if self.confirmation_pwd.blank? ==true
        errors.add(:base, I18n.t('ConfirmPassword')  + ' '+ I18n.t('presence'))
        valid=false
    end
    
    if valid == true      
      if new_password.length < 5
         errors.add(:base, I18n.t('NewPassword')  + ' '+ I18n.t('length_Min_5'))
         valid=false
       elsif new_password.length >32
         errors.add(:base, I18n.t('NewPassword')  + ' '+ I18n.t('length_Max_32'))
         valid=false
       end    
    end
    
    if valid == true
      if  self.confirmation_pwd.strip != self.new_password.strip
        errors.add(:base, I18n.t('Password')  + ' '+ I18n.t('validates_confirmation_of'))
        valid=false
      end
    end      
    
    return valid
  end
  	
   ##############################################
   ################ Private #####################
   ############################################## 
   private

    # Check record is new or not..
    def isnew?
      if Client.new
        return false  
      else
        return true  
      end 
    end 
    # generate hash password.. -------------------
    def create_hashed_password
	  #logger.error " create_hashed_password"
      unless encrypt_pwd.blank?
		#logger.error " create_hashed_password : start"
        self.salt = Client.make_salt(email) if salt.blank?
        self.encrypt_pwd = Client.hash_with_salt(encrypt_pwd, salt)
		#logger.error " create_hashed_password : end, salt: " +   self.salt + ", encrypt_pwd=" + self.encrypt_pwd
      end
    end

    # clear password -----------------
    def clear_password
      self.password = nil
    end
    
     def fill_current
	   self.create_at = Time.now 
       self.last_updated_at = Time.now   
       self.sign_in_count = 1
     end
     
     def fill_update
       self.last_updated_at = Time.now       
       self.sign_in_count = 0 if self.sign_in_count.blank?  
       self.sign_in_count =  self.sign_in_count + 1         
     end
	 
end
