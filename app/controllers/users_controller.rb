class UsersController < ApplicationController
	skip_before_filter :require_login, :only => [:login_flash_clear, :login, :attempt_login, :forgotpassword, :getforgotpassword, :changeforgotpassword, :savechangedforgotpassword]
	require 'fileutils'
	def login
		#flash[:message]=nil
		render :action => "login", :layout => "login_layout"
	end
	
	def login_flash_clear
		flash[:message]=nil
		redirect_to :action => 'login'
	end
	
	def verified_id(id, get_id)
		verified=false
		return_id = 0
		
		if (id.to_i <= 0 and get_id == false)
			return false
		end
		client_id=session[:client_id] || 0	
		admin_id=session[:admin_id] || 0
		engn_id=session[:engn_id] || 0
				
		if (admin_id.to_i > 0 )
			proxy_client_id = session[:proxy_client_id] || 0 
			if proxy_client_id.to_i > 0
				return_id = proxy_client_id
				if id.to_i == proxy_client_id.to_i
					verified = true					
				end
			else
				return_id = admin_id
				if id.to_i == admin_id.to_i
					verified = true					
				end
			end
		elsif (client_id.to_i > 0)
			return_id = client_id
			if id.to_i == client_id.to_i
				verified = true				
			end
		elsif (engn_id.to_i > 0)
			return_id = engn_id
			if id.to_i == engn_id.to_i
				verified = true				
			end
		end
		
		if (get_id == false)
			if verified == false
				render_error :error_code => 'e375'
			end
			return verified
		else
			if return_id.to_i <= 0
				render_error :error_code => 'e375'
			end
			return return_id
		end				
	end
	
	def change_profile	
		client_id=session[:client_id] || 0	
		admin_id=session[:admin_id] || 0
		
		get_id = verified_id(0,true)
		
		if client_id.to_i > 0 
			redirect_to :action => "change_client_profile", :id => get_id
		else
			redirect_to :action => "change_admin_profile", :id => get_id
		end				
	end
	
	def change_client_profile		
		#render :json => verified_id(params[:id],false)
		#return
								
		if verified_id(params[:id],false) == false
			redirect_to :action => "change_profile"
			return
		end
	
		@client=Client.where(:pk_client_id => params[:id])		
		if @client.count <= 0
			redirect_to :action => "change_profile"
			return
		end		
	    @client= @client.first								
		render :action => "edit_client_profile", :layout => "common_layout"
	end
		
	def update_client_profile
		begin				
			if verified_id(params[:id],false) == false
				redirect_to :action => "change_profile"
				return
			end
   		
			@client=Client.where(:pk_client_id => params[:id])			
			if @client.count <= 0
				redirect_to :action => "change_profile"
				return
			end		
			@client= @client.first
		
			@client.client_name=params[:client][:client_name]
	     	@client.contact_person=params[:client][:contact_person]			
			@client.phone=params[:client][:phone]
	     	@client.address=params[:client][:address]				
			@client.website=params[:client][:website]    				
			@client.last_updated_ip = request.remote_ip
					
			if @client.valid? == false
				render :action => "edit_client_profile", :id => params[:id]
				return
			end
			
			if @client.save!		
				admin_id=session[:admin_id] || 0
				if admin_id.to_i <=0 
					session[:user_name] = @client.client_name
				end
				
				render_error :error_code => 'e358'  ## Display error message email/password does not match..       
				redirect_to(:action => 'index', :controller => "dashboard")
				return	
			else
				#render_error :error_code => 'e359'  ## Display error message email/password does not match..       
				render :action => "edit_client_profile", :id => params[:id]
				return
			end				
		rescue => ex		   
			render_error :error_code => 'e359'  ## Display error message email/password does not match..       
			render :action => "edit_client_profile", :id => params[:id]
			return
		end			
		render_error :error_code => 'e359'  ## Display error message email/password does not match..       
	    render :action => "edit_client_profile", :id => params[:id]
	end
	
	def change_admin_profile	
		if verified_id(params[:id],false) == false
			redirect_to :action => "change_profile"
			return
		end
			
		if verified_id(params[:id],false) == false
			redirect_to :action => "change_profile"
			return
		end
			
		@admin=Admin.where(:pk_admin_id => params[:id])		
		if @admin.count <= 0
			redirect_to :action => "change_profile"
			return
		end
		@admin = @admin.first						
		render :action => "edit_admin_profile", :layout => "common_layout"
	end
	
	def update_admin_profile
		begin	
			if verified_id(params[:id],false) == false
				redirect_to :action => "change_profile"
				return
			end
			
			@admin=Admin.where(:pk_admin_id => params[:id])
		
			if @admin.count <= 0
				redirect_to :action => "change_profile"
				return
			end
			@admin = @admin.first
			
			@admin.admin_name=params[:admin][:admin_name]
	     	@admin.contact_person=params[:admin][:contact_person]			
			@admin.phone=params[:admin][:phone]
	     	@admin.address=params[:admin][:address]				
			@admin.website=params[:admin][:website]  
			@admin.last_updated_ip = request.remote_ip
										
			if @admin.valid? == false
				render :action => "edit_admin_profile", :id => params[:id]
				return
			end
						
			if @admin.save!
				session[:user_name] = @admin.admin_name
				render_error :error_code => 'e358'  ## Display error message email/password does not match..       
				redirect_to(:action => 'index', :controller => "dashboard")
				return	
			else
				#render_error :error_code => 'e359'  ## Display error message email/password does not match..       
				render :action => "edit_admin_profile", :id => params[:id]
				return
			end				
		rescue => ex		   
			render_error :error_code => 'e359'  ## Display error message email/password does not match..       
			render :action => "edit_admin_profile", :id => params[:id]
			return
		end			
		render_error :error_code => 'e359'  ## Display error message email/password does not match..       
	    render :action => "edit_admin_profile", :id => params[:id]
	end
	
	def change_password	
		client_id=session[:client_id] || 0
		admin_id=session[:admin_id] || 0
		
		get_id = verified_id(0,true)
		if client_id.to_i > 0 
			redirect_to :action => "change_client_password", :id => get_id
		else
			redirect_to :action => "change_admin_password", :id => get_id
		end				
	end
	
	def change_client_password
		if verified_id(params[:id],false) == false
			redirect_to :action => "change_password"
			return
		end
		
		@client=Client.where(:pk_client_id => params[:id])
	
		if @client.count <= 0
			redirect_to :action => "change_password"
			return
		end
		@client = @client.first
		render :action => "change_client_password", :layout => "common_layout"
	end
	
	def update_client_password	
		begin		
			if verified_id(params[:id],false) == false
				redirect_to :action => "change_password"
				return
			end		
			
			@client=Client.where(:pk_client_id => params[:id])		
			if @client.count <= 0
				redirect_to :action => "change_password"
				return
			end
			@client = @client.first
		
			@client.old_password=params[:client][:old_password].strip  
			@client.new_password=params[:client][:new_password].strip  
			@client.confirmation_pwd=params[:client][:confirmation_pwd].strip   
			@client.last_updated_ip = request.remote_ip   		
									
			logger.error "controller" + @client.to_s
							
						 
			if @client.valid_change_password() == false			
			  # render_error :error_code => 'e362' 
			   render :action => "change_client_password", :id => params[:id]	
			   return
			end   
			 
			if @client.save!
				render_error :error_code => 'e360'  ## Display error message email/password does not match..       
				redirect_to(:action => 'index', :controller => "dashboard")
				return	
			else
				#render_error :error_code => 'e361'  ## Display error message email/password does not match..       
				render :action => "change_client_password", :id => params[:id]
				return
			end				
		rescue => ex		   
			render_error :error_code => 'e361'  ## Display error message email/password does not match..       
			render :action => "change_client_password", :id => params[:id]
			return
		end			
		render_error :error_code => 'e361'  ## Display error message email/password does not match..       
	    render :action => "change_client_password", :id => params[:id]
	end
	
	def change_admin_password
		if verified_id(params[:id],false) == false
			redirect_to :action => "change_password"
			return
		end		
			
		@admin=Admin.where(:pk_admin_id => params[:id])		
		if @admin.count <= 0
			redirect_to :action => "change_password"
			return
		end
		@admin = @admin.first	
		render :action => "change_admin_password", :layout => "common_layout"
	end
	
	def update_admin_password	
		begin			
			if verified_id(params[:id],false) == false
				redirect_to :action => "change_password"
				return
			end	
		
			@admin=Admin.where(:pk_admin_id => params[:id])		
			if @admin.count <= 0
				redirect_to :action => "change_password"
				return
			end
			@admin = @admin.first				
					
			@admin.old_password=params[:admin][:old_password].strip  
			@admin.new_password=params[:admin][:new_password].strip  
			@admin.confirmation_pwd=params[:admin][:confirmation_pwd].strip    
			@admin.last_updated_ip = request.remote_ip   		
					
			if @admin.valid_change_password() == false			
			  # render_error :error_code => 'e362' 
			   render :action => "change_admin_password", :id => params[:id]	
			   return
			end   
			 
			if @admin.save!
				render_error :error_code => 'e360'  ## Display error message email/password does not match..       
				redirect_to(:action => 'index', :controller => "dashboard")
				return	
			else
				#render_error :error_code => 'e361'  ## Display error message email/password does not match..       
				render :action => "change_admin_password", :id => params[:id]
				return
			end				
		rescue => ex		   
			render_error :error_code => 'e361'  ## Display error message email/password does not match..       
			render :action => "change_admin_password", :id => params[:id]
			return
		end			
		render_error :error_code => 'e361'  ## Display error message email/password does not match..       
	    render :action => "change_admin_password", :id => params[:id]
	end
	
	# Attempt login ---------------------
	def attempt_login 
		@CookiesSet=0
		#render :json => params
		#return
				
		if params[:user][:email].blank? == true
		  render_error :error_code => 'e318'  ## Email can't be blank       
		  redirect_to(:action => 'login')
		  return
		end    
		
		if params[:user][:password].blank? == true
		  render_error :error_code => 'e319'  ## password can't be blank       
		  redirect_to(:action => 'login')
		  return
		end  
		
	   user_type=params[:user][:user_type].to_s
	   logger.debug user_type.to_s
	  		
		if ( cookies[:remember_me_id] and cookies[:remember_me_code] ) == true       
			if ( Digest::SHA1.hexdigest( params[:user][:email] )[4,18] == cookies[:remember_me_code] ) == true
				#user_type
				if(user_type == "1") 
				   logger.debug "admin"
					#Admin
					if (Admin.getUserID(cookies[:remember_me_id]))           
						if ( Digest::SHA1.hexdigest( Admin.getUserID(cookies[:remember_me_id]).email )[4,18] == cookies[:remember_me_code] ) == true
							@CookiesSet=1
							authorized_user = Admin.getUserID(cookies[:remember_me_id])
						end
					end
					#end Admin
				elsif(user_type == "2")
					#client
					 logger.debug "client"
					if (Client.getUserID(cookies[:remember_me_id]))           
						if ( Digest::SHA1.hexdigest( Client.getUserID(cookies[:remember_me_id]).email )[4,18] == cookies[:remember_me_code] ) == true
							@CookiesSet=1
							authorized_user = Client.getUserID(cookies[:remember_me_id])
						end
					end
					#end client
				else
					#enginner
					 logger.debug "enginner"
					if (RaceEngineer.getUserID(cookies[:remember_me_id]))           
						if ( Digest::SHA1.hexdigest( RaceEngineer.getUserID(cookies[:remember_me_id]).email )[4,18] == cookies[:remember_me_code] ) == true
							@CookiesSet=1
							authorized_user = RaceEngineer.getUserID(cookies[:remember_me_id])
						end
					end
					#end enginner
				end
				#end user_type				
			end 
		end
		logger.debug @CookiesSet.to_s
				
		#authorized_user = RaceEngineer.authenticate(params[:user][:email], params[:user][:password])	
				
		if (@CookiesSet == 0)     
			logger.debug "user_type" + user_type.to_s
			if(user_type == "1") 	
				logger.debug "Start to Admin login"
				authorized_user = Admin.authenticate(params[:user][:email], params[:user][:password])	
			elsif(user_type == "2") 
				logger.debug "Start to Client login"
				authorized_user = Client.authenticate(params[:user][:email], params[:user][:password])
			else				
				logger.debug "Start to RaceEngineer login"
				authorized_user = RaceEngineer.authenticate(params[:user][:email], params[:user][:password])	
			end						
		end			

		# render :json => authorized_user		
		# return		
      
		if authorized_user.blank? == true
			render_error :error_code => 'e201'  ## Display error message email/password does not match..       
			redirect_to(:action => 'login')
			return
		end
 
		if authorized_user.status_code == "400"
			render_error :error_code => 'e306'  ## Display error message email/password does not match..       
			redirect_to(:action => 'login')
			return
		end    
        
		if authorized_user     
			#if params[:post][:rememberMe]
			if params[:rememberMe] && params[:rememberMe].to_s == "1"	
				if(user_type == "1") 	
					userId = (authorized_user.pk_admin_id).to_s 
				elsif(user_type == "2") 	
					userId = (authorized_user.pk_client_id).to_s 
				else
					userId = (authorized_user.pk_engn_id).to_s
				end			
				               
				cookies[:remember_me_id] = { :value => userId, :expires => Protrack::Configuration['remember_days'].days.from_now }
				cookies[:user_type] = { :value => user_type, :expires => Protrack::Configuration['remember_days'].days.from_now }
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
			session[:last_logged] = authorized_user.last_updated_at
						 		
			lastsign = authorized_user.last_updated_at          
        	
			params[:user].delete :password
			params[:user].delete :user_type
			
			params[:user][:last_updated_ip]=request.remote_ip
			
			if authorized_user.update_attributes(params[:user])
				render_error :error_code => 'e304'
			else
				render_error :error_code => 'e202'
			end
			
			## END CODE TO UPDATE USER DATA...
			#cookies.delete :attempt_login  ### delete cookies if login success..
			render_error :error_code => 'e301'  # success msg you are logged in
			redirect_to(:controller => 'dashboard')
			end 		
	end	
	
	# logout----------------
	def logout
		#session[:admin_id] = nil      
		#reset all session when user is logout
		reset_session
		
		# Cookie delete
		if cookies[:remember_me_id] then cookies.delete :remember_me_id end
		if cookies[:remember_me_code] then cookies.delete :remember_me_code end    
	 
		render_error :error_code => 'e303' # for msg you have been logged out   
		redirect_to(:action => 'login')
	end
		
	def forgotpassword	
		@user=Client.new
		render :action => "forgotpassword", :layout => 'signup_layout'    
    end 
	
	def getforgotpassword     
		begin
			#render :json => params
			#return	
			
			if (params[:user][:email].blank? == true)         
				@user=Client.new  
				@user.email=params[:user][:email]
				render_error :error_code => 'e318' # Error message for not a blank        
				render :action => 'forgotpassword', :layout => 'signup_layout'   
				return
			end
			
			user_type=params[:user][:user_type].to_s
		
			if user_type == "1" 
				@user = Admin.where(email: params[:user][:email])
			else
				@user = Client.where(email: params[:user][:email])
			end	
			
			
			#render :json => @user
			#return
			
			if @user.count <= 0  
				@user=Client.new  
				@user.email=params[:user][:email]
				render_error :error_code => 'e306'
				render :action => 'forgotpassword', :layout => 'signup_layout'   
				return
			end
			@user=@user.first
					 
			@user.reset_pswd_token=@user.encrypt_pwd
			@user.last_updated_ip = request.remote_ip
			@user.reset_pswd_at=Time.now  
			
			#render :json => @user
			#return
				
			
			@user.save 
							
			UserMailer.forgot_pwd_email(@user, user_type).deliver
			
			flash[:message]=nil
			
			render_error :error_code => 'e315' # success msg User registration successfully
			redirect_to :action => 'login'  
		rescue => ex
			#render :json => {:error => "Mail error : #{ex.class} , #{ex.message}"}
			render :action => 'forgotpassword', :layout => 'signup_layout'  
		end
    end
	
	def changeforgotpassword
		#render :json => params
		#return
		
		if params[:id].nil? == true ||  params[:id].blank? == true
			render :text => "Your link is not valid"
			return
		end	
		
		if 	params[:ut].to_s == "1"
			@user = Admin.where(pk_admin_id: params[:id], reset_pswd_token:  params[:uval])
		elsif params[:ut].to_s == "2"
			@user = Client.where(pk_client_id: params[:id], reset_pswd_token:  params[:uval])
		else
			 render :text => "Your link is not valid"
			 return
		end
		
		if @user.count <= 0
			render :text => "Your link is not valid"
			return
		end			
		@user=@user.first
		@user.user_type=params[:ut]
		
		render :action => "changeforgotpassword", :layout => 'signup_layout'  
	end

	def savechangedforgotpassword				
		if 	params[:ut].to_s == "1"
			@user = Admin.where(pk_admin_id: params[:id], reset_pswd_token:  params[:uval])
		elsif params[:ut].to_s == "2"
			@user = Client.where(pk_client_id: params[:id], reset_pswd_token:  params[:uval])	
		else
			 render :text => "Your link is not valid"
			 return			
		end
				
		if @user.count <= 0
			render :text => "Your link is not valid"
			return
		end	
		@user=@user.first
			
	    if params[:user][:new_password].blank? == true ||  params[:user][:confirmation_pwd].blank? == true
			render_error :error_code => 'e376'
			render :action => "changeforgotpassword", :id => @user.id, :ut => 	params[:ut], :uval => params[:uval] 
			return
		end	
		
		if params[:user][:new_password].to_s != params[:user][:confirmation_pwd].to_s 
			render_error :error_code => 'e363'
			render :action => "changeforgotpassword", :id => @user.id, :ut => 	params[:ut], :uval => params[:uval] 
			return
		end	
						
		@user.new_password=params[:user][:new_password].strip  
		@user.confirmation_pwd=params[:user][:confirmation_pwd].strip           
		@user.last_updated_ip = request.remote_ip   
		@user.reset_pswd_at=Time.now  
		@user.last_updated_at = Time.now
		@user.reset_pswd_token = ""
		   
		if @user.reset_password() == false
		   render :action => "changeforgotpassword", :id => @user.id, :ut => 	params[:ut], :uval => params[:uval] 
		else    
		   if @user.save!
				 reset_session
				 render_error :error_code => 'e360' 
				 redirect_to :action => "login" 
			else				  
				render :action => "changeforgotpassword", :id => @user.id, :ut => 	params[:ut], :uval => params[:uval] 
				return
			end	  
		  
		end       
	end

	def manage_urls
		begin
			@admin = Admin.find(session[:admin_id])
			@manage_url = @admin.manage_url
			if @manage_url.nil?
				@manage_url = ManageUrl.new(admin_id: @admin.id)
			end
		rescue => e
			render :text => "Admin is not authorised to manage urls"
		end
	end

	def update_manage_urls
		@admin = Admin.find(session[:admin_id])
		@manage_url = @admin.manage_url
		if !params[:manage_url][:regulation_pdf].nil?
			track_image_filename_=params[:manage_url][:regulation_pdf].original_filename.to_s
			track_img_name=track_image_filename_.split('/').last
			track_img_extn=track_img_name.split('.').last
			track_newfilename = "Regulation_pdf_#{(Time.now.strftime('%y%m%d'))}"
			track_newfilename = track_newfilename + '.' + track_img_extn
			regulation_pdf_path="/assets/images/admin/admin_#{@admin.id}/regulation_pdf/"
			save_file_url(params[:manage_url][:regulation_pdf],track_newfilename, regulation_pdf_path)
			public_url_pdf_path="/assets/admin/admin_#{@admin.id}/regulation_pdf/"

			@regulation_pdf_path= public_url_pdf_path + track_newfilename
		else
			@regulation_pdf_path= @manage_url.regulation_pdf
		end
		if !params[:manage_url][:media_pdf].nil?
			track_image_filename_=params[:manage_url][:media_pdf].original_filename.to_s
			track_img_name=track_image_filename_.split('/').last
			track_img_extn=track_img_name.split('.').last
			track_newfilename = "Media_pdf_#{(Time.now.strftime('%y%m%d'))}"
			track_newfilename = track_newfilename + '.' + track_img_extn
			media_pdf_path="/assets/images/admin/admin_#{@admin.id}/media_pdf/"
			save_file_url(params[:manage_url][:media_pdf],track_newfilename, media_pdf_path)
			public_url_pdf_path="/assets/admin/admin_#{@admin.id}/media_pdf/"
			@media_pdf_path= public_url_pdf_path + track_newfilename
		else
			@media_pdf_path= @manage_url.media_pdf
		end
		if !params[:manage_url][:car_manual_pdf].nil?
			track_image_filename_=params[:manage_url][:car_manual_pdf].original_filename.to_s
			track_img_name=track_image_filename_.split('/').last
			track_img_extn=track_img_name.split('.').last
			track_newfilename = "Car_manual_pdf_#{Time.now.strftime('%y%m%d')}"
			track_newfilename = track_newfilename + '.' + track_img_extn
			car_manual_pdf_path="/assets/images/admin/admin_#{@admin.id}/car_manual_pdf/"
			save_file_url(params[:manage_url][:car_manual_pdf],track_newfilename, car_manual_pdf_path)
			public_url_pdf_path="/assets/admin/admin_#{@admin.id}/car_manual_pdf/"

			@car_manual_pdf_path= public_url_pdf_path + track_newfilename
		else
			@car_manual_pdf_path= @manage_url.car_manual_pdf
		end
		if @manage_url.nil?
			ManageUrl.create(admin_id: @admin.id, regulation_pdf: @regulation_pdf_path, media_pdf: @media_pdf_path, car_manual_pdf: @car_manual_pdf_path, fb_url: params[:manage_url][:fb_url], twitter_url: params[:manage_url][:twitter_url], prema_url: params[:manage_url][:prema_url], formula_url: params[:manage_url][:formula_url] )
		else
			@manage_url.update_attributes(regulation_pdf: @regulation_pdf_path, media_pdf: @media_pdf_path, car_manual_pdf: @car_manual_pdf_path, fb_url: params[:manage_url][:fb_url], twitter_url: params[:manage_url][:twitter_url], prema_url: params[:manage_url][:prema_url], formula_url: params[:manage_url][:formula_url] )
		end
		sleep(5)
		# redirect_to controller: 'dashboard', action: 'index'
		flash[:notice] = 'Manage URLs uploaded successfully'
		redirect_to action: 'manage_urls'
	end



	def save_file_url(params_name,filename, path)
		begin
			dir= File.join(Rails.root, "app", path)
			FileUtils::mkdir_p dir unless File.exists?(dir)

			path = File.join(Rails.root, "app", path, filename)
			# write the file
			File.open(path, "wb") { |f| f.write(params_name.read) }
		rescue => ex
			logger.info "erro: #{ex.class} , #{ex.message}"
		end
	end
  
  
end
