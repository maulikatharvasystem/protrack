class EmailsController < ApplicationController    
    skip_before_filter :require_login, :only => [:race_engineer_userverified, :device_userverified, :userverified, :saveforgotpwd]    
      
    def saveforgotpwd   
	  begin	  
		  #render :json => params 
		  #return
		 
		  uid=params[:uid]
		  uval=params[:uval]      
		  user_type=params[:ut].to_s
	  
		  today = DateTime.now    
				
		  if uid.blank? == true || uval.blank? == true || user_type.blank? == true
			render :text => "Your link is not valid"
			return        
		  end     

		  #render :json => params 
		  #return		  
			 
		  if user_type == "1"
			@user=Admin.where(pk_admin_id: uid, reset_pswd_token: uval)
		  else
			@user=Client.where(pk_client_id: uid, reset_pswd_token: uval)
		  end
		  
		  #render :json => @user 
		  #return
						
		  if @user.count <= 0  
			render :text => "Your link is not valid"
			return
		  end  
		  @user=@user.first	  
			  
		  if @user.status_code == 400 
			 render :text => "First you chack your email and verify email."
			 return
		  end  
					  
		  u_expday =  (today - @user.reset_pswd_at.to_date).to_i     
			
		  if u_expday > 7
			 render :text => "Your link is expired"
			 return
		  end       
		  
		  if @user.reset_pswd_token.blank? == false  
			  #@user.last_updated_ip = request.remote_ip         
			  #@user.reset_pswd_token=""         
			  #@user.save
					 
			 render_error :error_code => 'e314'
			 redirect_to :controller => "users", :action => "changeforgotpassword" , :id => @user.id, :ut => user_type, :uval => params[:uval]
			 return
		  end
		  
		  render :text => "Your link is not verified, please try again"
		  
	   rescue => ex
			render :text => "Your link is not valid..."
			return   
	   end
    end
  
    def userverified
        begin	  
		  uid=params[:uid]
		  uval=params[:uval]      
		  user_type=params[:ut].to_s
	  
		  today = DateTime.now    
				
		  if uid.blank? == true || uval.blank? == true || user_type.blank? == true
			render :text => "Your link is not valid"
			return        
		  end     

		  #render :json => params 
		  #return		  
			 
		  if user_type == "1"
			@user=Admin.where(pk_admin_id: uid, encrypt_pwd: uval)
		  else
			@user=Client.where(pk_client_id: uid, encrypt_pwd: uval)
		  end
		  
		  #render :json => @user 
		  #return
						
		  if @user.count <= 0  
			render :text => "Your link is not valid"
			return
		  end  
		  @user=@user.first	  
			  
		  if @user.status_code != 400 
			 render :text => "Your link is already verified"
			 return
		  end  
		 					  
		  u_expday =  (today - @user.create_at.to_date).to_i     
			
		  if u_expday > 7
			 render :text => "Your link is expired"
			 return
		  end       
		  
		  
		  @user.last_updated_ip = request.remote_ip   		 	  
		  @user.status_code=401 
		  
		  if @user.save!					 
			 render_error :error_code => 'e314'
			 redirect_to :controller => "users", :action => "login"
			 return
		   end
		  
		  render :text => "Your link is not verified, please try again"		  
	   rescue => ex
			render :text => "Your link is not valid..."
			return   
	   end  	    
    end
	
	 def device_userverified
        begin	  
		  uid=params[:uid]
		  uval=params[:uval]      
		 	  
		  today = DateTime.now    
				
		  if uid.blank? == true || uval.blank? == true 
			render :text => "Your link is not valid"
			return        
		  end     

		 @user=DeviceUser.where(pk_user_id: uid, sessionid: uval)		 
		  
		  #render :json => @user 
		  #return
						
		  if @user.count <= 0  
			render :text => "Your link is not valid"
			return
		  end  
		  @user=@user.first	  
			  
		  if @user.status_code != 400 
			 render :text => "Your link is already verified"
			 return
		  end  
		 					  
		  u_expday =  (today - @user.create_at.to_date).to_i     
			
		  if u_expday > 7
			 render :text => "Your link is expired"
			 return
		  end       		  
		  
		  @user.last_updated_ip = request.remote_ip   		 	  
		  @user.status_code=401 
		  
		  if @user.save!					 
			 render_error :error_code => 'e314'
			 redirect_to :controller => "users", :action => "login"
			 return
		   end
		  
		  render :text => "Your link is not verified, please try again"		  
	   rescue => ex
			render :text => "Your link is not valid..."
			return   
	   end  	    
    end
	
    def race_engineer_userverified
        begin	  
		  uid=params[:uid]
		  uval=params[:uval]      
		  #user_type=params[:ut].to_s
	  
		  today = DateTime.now    
				
		  if uid.blank? == true || uval.blank? == true 
			render :text => "Your link is not valid"
			return        
		  end     
		  
		  @user=RaceEngineer.where(pk_engn_id: uid, encrypt_pwd: uval)		 
		 						
		  if @user.count <= 0  
			render :text => "Your link is not valid"
			return
		  end  
		  @user=@user.first	  
			  
		  if @user.status_code != 400 
			 render :text => "Your link is already verified"
			 return
		  end  
		 					  
		  u_expday =  (today - @user.create_at.to_date).to_i     
			
		  if u_expday > 7
			 render :text => "Your link is expired"
			 return
		  end       
		  
		  
		  @user.last_updated_ip = request.remote_ip   		 	  
		  @user.status_code=401 
		  
		  if @user.save!					 
			 render_error :error_code => 'e314'
			 redirect_to :controller => "users", :action => "login"
			 return
		   end
		  
		  render :text => "Your link is not verified, please try again"		  
	   rescue => ex
			render :text => "Your link is not valid..."
			return   
	   end  	    
    end
	
end
