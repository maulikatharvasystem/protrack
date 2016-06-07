class ApplicationController < ActionController::Base
  include Protrack::Messages 
  protect_from_forgery

  layout 'common_layout' 
  before_filter :require_login, :set_locale
  #, :set_cache_buster
  
  def set_locale
	  #I18n.locale = params[:locale] || I18n.default_locale
	  I18n.locale = session[:lang] || I18n.default_locale
  end

  def set_cache_buster
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end    
  
  private
  
  def is_admin_part
	admin_id=session[:admin_id] || 0			
	if admin_id.to_i <= 0 
		redirect_to :action => "index", :controller => "dashboard"
	end
  end
  
   def is_client_part
	client_id=session[:client_id] || 0			
	if client_id.to_i <= 0 
		redirect_to :action => "index", :controller => "dashboard"
	end
  end
  
  # Check login before access any controller
  def require_login    		  	 
      unless logged_in?
	   logger.debug "login fail"
        flash[:error] = "You must login first"
        redirect_to :controller => 'users', :action => 'login'
      end  
  end
 
  # Method to check user login or not...
  def logged_in?
	logger.debug "login start"
    if session[:admin_id] || session[:client_id] || session[:engn_id]
		logger.debug "session found"
      return true
    else		
		logger.debug "session not found"
		if attempt_login == false
			logger.debug "attempt_login false"
			return false  
		else
			return true
		end
    end
  end  
 
  # Attempt login ---------------------
  def attempt_login    
    @CookiesSet=0
  
    if  cookies[:remember_me_id] and cookies[:remember_me_code] and cookies[:user_type]		
		if cookies[:user_type].to_s == "1"
			@user_data=Admin.getUserID(cookies[:remember_me_id])
		elsif cookies[:user_type].to_s == "2"
			@user_data=Client.getUserID(cookies[:remember_me_id])
		else
			@user_data=RaceEnginner.getUserID(cookies[:remember_me_id])
		end
		
		if (@user_data) 
			if cookies[:user_type].to_s == "1"
				email =	Admin.getUserID(cookies[:remember_me_id]).email 
			elsif cookies[:user_type].to_s == "2"
				email =	Client.getUserID(cookies[:remember_me_id]).email 
			else
				email =	RaceEnginner.getUserID(cookies[:remember_me_id]).email 
			end			
			if ( Digest::SHA1.hexdigest(email)[4,18] == cookies[:remember_me_code] ) == true
				@CookiesSet=1
				if cookies[:user_type].to_s == "1"
					authorized_user = Admin.getUserID(cookies[:remember_me_id])					
				elsif cookies[:user_type].to_s == "2"
					authorized_user = Client.getUserID(cookies[:remember_me_id])
				else
					authorized_user = RaceEnginner.getUserID(cookies[:remember_me_id])
				end						
			end
		end     
    end     		
	user_type = cookies[:user_type].to_s		
	
    if authorized_user.blank? == true  
		logger.debug "  authorized_user is blank"
        return false
    end
	
    if authorized_user.status_code != "401"     
      return false
    end           
    
    if authorized_user           
        if params[:rememberMe]
          userId = (authorized_user._id).to_s    		  
          cookies[:remember_me_id] = { :value => userId, :expires => Javee::Configuration['remember_days'].days.from_now }
		  cookies[:user_type] = { :value => user_type, :expires => Javee::Configuration['remember_days'].days.from_now }
          userCode = Digest::SHA1.hexdigest( authorized_user.email )[4,18]
          cookies[:remember_me_code] = { :value => userCode, :expires => Javee::Configuration['remember_days'].days.from_now }
        end
         
		if(user_type == "1") 	 
			session[:admin_id] = (authorized_user.pk_admin_id).to_s  
			session[:user_name] = authorized_user.admin_name
		elsif(user_type == "2") 	
			session[:client_id] = (authorized_user.pk_client_id).to_s  							
			session[:user_name] = authorized_user.client_name
		else
			session[:engn_id] = (authorized_user.pk_engn_id).to_s  							
			session[:user_name] = authorized_user.race_engineer_name
		end	
		#session[:user_id] = (authorized_user._id).to_s    
       
      #  lastsign = authorized_user.current_sign_in_at
        
        ##### save last login in publisher table..
       # @publisher.last_login_at = Time.now
       # @publisher.save      
        
        # User.update_attributes(params[:user])        
        return true
   end  
  end  

  
end
