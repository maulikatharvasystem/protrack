require 'digest/sha1'

class RaceEngineer < ActiveRecord::Base
  attr_accessible :last_updated_ip, :encrypt_pwd, :email
  attr_accessor :old_password, :new_password, :confirmation_pwd, :password, :encrypt_pwd_confirmation, :user_type
  has_many :track_session 
    
  validates :race_engineer_name, :presence => {:message => I18n.t('presence') } 
  validates :email,  :presence => {:message => I18n.t('presence') } 
  
  validates :contact_person, :presence => {:message => I18n.t('presence') } 
  validates :phone,  :presence => {:message => I18n.t('presence') } 
  validates :address,  :presence => {:message => I18n.t('presence') } 
  validates :website,  :presence => {:message => I18n.t('presence') } 
  
  validates :encrypt_pwd, :presence => {:message => I18n.t('presence') } , :on => :create   
  validates_confirmation_of :encrypt_pwd, {:message => I18n.t('validates_confirmation_of') } 
   
  validates :encrypt_pwd, :length => {:minimum => 5, :message => I18n.t('length_Min_5')}, :on => :create, :allow_blank => true
  validates :encrypt_pwd, :length => {:maximum => 32, :message => I18n.t('length_Max_32')}, :on => :create, :allow_blank => true 
  validates :email, :format => { :with => /^(|(([A-Za-z0-9]+_+)|([A-Za-z0-9]+\-+)|([A-Za-z0-9]+\.+)|([A-Za-z0-9]+\++))*[A-Za-z0-9]+@((\w+\-+)|(\w+\.))*\w{1,63}\.[a-zA-Z]{2,6})$/i, :message => I18n.t('format') }
  
  validate :exist_raceengg, :on => :create
 
  def exist_raceengg
    if RaceEngineer.where("email = ? AND status_code != '403'",email).present?
      errors.add(:email, "already exist in database.")
    end
  end

  attr_protected :hashed_password, :salt   
   
  ## Events call before and after save..-------------
  before_create  :fill_current, :create_hashed_password
  before_save  :fill_update
  before_update :create_hashed_password, :if => :encrypt_pwd_changed?
 	 
   def valCampaign?
    if status_code == 403
        return false
    else 
        return true
    end
   end

   def self.get_engn_list(client_id, per_page, page_no)
		
    where_cond = " where CL.status_code in(401,402) "
		#where_cond = " where 1=1"
		
		if client_id.to_i > 0		
			where_cond= where_cond + " and CL.fk_client_id=" +  client_id.to_s  + " "	
		end 
		
		@race_enginner=RaceEngineer.paginate_by_sql("select pk_engn_id, " +
			" race_engineer_name, contact_person, phone, email, last_updated_at, status_code from race_engineers as CL	" +		
			where_cond + " order by pk_engn_id desc ", :per_page => per_page , :page => page_no)
			
		return @race_enginner
   end
   
  def self.get_all_engn_list()
		where_cond = " where CL.status_code in(401,402) "		
		
		#if admin_id > 0		
		#	where_cond= where_cond + " and CL.fk_client_id=" +  admin_id.to_s  + " "	
		#end
		
		@race_enginner=RaceEngineer.find_by_sql("select pk_engn_id, race_engineer_name from race_engineers as CL	" +		
			where_cond + " order by race_engineer_name asc ")			
		return @race_enginner
   end
       
   def self.get_selected_engn(engn_id)
		where_cond = " where CL.status_code in(401,402,400) "
		
		#if admin_id > 0		
		#	where_cond= where_cond + " and CL.fk_client_id=" +  admin_id.to_s  + " "	
		#end
		where_cond= where_cond + " and CL.pk_engn_id=" +  engn_id.to_s  + " "
		
		@race_enginner=RaceEngineer.find_by_sql("select pk_engn_id, " +
			" race_engineer_name, contact_person, phone, email, last_updated_at from race_engineers as CL	" +		
			where_cond + "  ")
			
		return @race_enginner.first
	end
   
   #### Get Client info using ID...
   def self.getUserID(id)
     @race_enginner = RaceEngineer.find_by(id: id)
     return @race_enginner
   end
   
   # Authentication at login.. -------------------
   def self.authenticate(email="", password="")
   
     if email.blank? == true
       return false 
     end 

	if password.blank? == true
       return false     
     end 	 
   
     race_engineer = RaceEngineer.where(email: email, status_code: '401')
       
     if race_engineer.count <= 0
       return false
     end	
	 race_engineer=race_engineer.first
	   
     logger.error "db password: " + race_engineer[:encrypt_pwd]
     logger.error "db salt: " + race_engineer[:salt]
     logger.error "User Password: " + password
     logger.error "Convert Password: " + RaceEngineer.hash_with_salt(race_engineer[:encrypt_pwd], race_engineer[:salt])

     if race_engineer.password_match(race_engineer[:encrypt_pwd ], password, race_engineer[:salt])       
          return race_engineer
     else
          return false
     end
        
    rescue      
       return false
   end

   def password_match(encrypted_password,password="", salt="")
     encrypted_password == RaceEngineer.hash_with_salt(password, salt)
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
	
    if RaceEngineer.authenticate(self.email,self.old_password) == false
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
      if RaceEngineer.new
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
        self.salt = RaceEngineer.make_salt(email) if salt.blank?
        self.encrypt_pwd = RaceEngineer.hash_with_salt(encrypt_pwd, salt)
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
