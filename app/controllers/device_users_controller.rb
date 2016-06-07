class DeviceUsersController < ApplicationController
	skip_before_filter :require_login, :only => [:send_reactivation_link]
	before_filter :is_client_part
	
	def index	
		record_per_page=Protrack::Configuration['pagesize']
	
		client_id=session[:client_id] || 0	
		admin_id=session[:admin_id] || 0			
				
		@device_users=DeviceUser.get_device_user_lists(client_id,record_per_page,params[:page])							
		render :action => "index", :layout => "common_layout"
	end
	
	def index_flash_clear
		flash[:message]=nil
		redirect_to :action => 'index'
	end
	
	def add			
		@device_user=DeviceUser.new		
		render :action => "add", :layout => "common_layout"
	end	
	
	# create-----------------
	def create	
		begin
			client_id=session[:client_id] || 0	
			 @device_user=DeviceUser.new	   
			
			 @device_user.create_ip = request.remote_ip  
			 @device_user.last_updated_ip = request.remote_ip  
			 @device_user.status_code= 401
						 
			 @device_user.first_name= params[:device_user][:first_name] || ""
			 @device_user.last_name= params[:device_user][:last_name] || ""
			 @device_user.email= params[:device_user][:email] || ""
			 @device_user.phone= params[:device_user][:phone] || ""			
			 @device_user.address= params[:device_user][:address] || ""
			 
			 @device_user.fk_client_id= client_id
			 @device_user.sessionid= Time.now.to_i
		
			# @device_user.dob= params[:device_user][:dob] || ""
			 
			 @device_user.password= params[:device_user][:password] || ""
			 @device_user.password_confirmation= params[:device_user][:confirm_password] || ""
								
			 if @device_user.valid? == false  
				render :action => 'add', :layout => 'common_layout'
				return		    
			 end	
					 
			if @device_user.save	
				#render :json => @device_use
				#return
				UserMailer.register_device_user_email(@device_user).deliver
						
				render_error :error_code => 'e368' # success msg User registration successfully
				redirect_to :action => 'index' 
				return                    
			else   
				render :action => 'add'
				return			                        
			end   
		rescue => ex
			logger.info "thumb error : #{ex.class} , #{ex.message}"
			render_error :error_code => 'e366'  ## Display error message email/password does not match..       
			render :action => 'add'
			return
		end			
		render_error :error_code => 'e366' 
		render :action => "add"
	end
	
	def send_reactivation_link 	
		begin
		    @device_user=DeviceUser.where(pk_user_id: params[:id].to_i)	
			
			if @device_user.count <= 0
				render :json => { :status => "401", :message => "User not found, please try again."}
			    return	
			end
			@device_user=@device_user.first
			
			if  @device_user.status_code.to_s == "400"
				UserMailer.register_device_user_email(@device_user).deliver
				render :json => { :status => "200", :message => "Reactivation account link is successfully sent to " + @device_user.email}
			    return		
			end				
			render :json => { :status => "402", :message => "Please try again."}
			return	
		rescue => ex
			logger.info "thumb error : #{ex.class} , #{ex.message}"
			render :json => { :status => "403", :message => "Some problem is there, please try again."}		
			return
		end					
	end
	
	def valid_email_ajax
		begin					
			@device_user=DeviceUser.where(:email => params[:device_user][:email].to_s)	
								
			if @device_user.count <= 0
				render :json => {:resp_code => "200", :message => "Email id is available"}				
			elsif @device_user.status_code == "403"			
				render :json => {:resp_code => "403", :message => "Email id is already taken. \n It's deleted account, do you want reactivate account ?"}				
			elsif @device_user.status_code == "402"
				render :json => {:resp_code => "403", :message => "Email id is already taken. \n It's de-activated account, do you want reactivate account ?"}				
			elsif @device_user.status_code == "400"	
				render :json => {:resp_code => "403", :message => "Email id is already taken. \n It's un-verified account. Please"}			
			else
				render :json => {:resp_code => "403", :message => "Email id is already taken."}				
			end			
			
		rescue => ex
		    logger.error "erro: #{ex.class} , #{ex.message}"		
			render :json => {:resp_code => "400", :message => "Track turn data is not valid. Please try again. error: #{ex.message}"}
			return
		end					
	end
	
	def edit
		@device_user=DeviceUser.find(params[:id].to_i)		
		render :action => "edit", :layout => "common_layout"
	end
	
	def update
		begin
			 @device_user=DeviceUser.find(params[:id])	   
						
			 @device_user.last_updated_ip = request.remote_ip  			 
			 @device_user.first_name= params[:device_user][:first_name] || ""
			 @device_user.last_name= params[:device_user][:last_name] || ""			
			 @device_user.phone= params[:device_user][:phone] || ""			
			 @device_user.address= params[:device_user][:address] || ""

			 if params[:device_user][:password].blank? == false
			 	@device_user.password= params[:device_user][:password] || ""
			 end

			 if params[:device_user][:confirm_password].blank? == false
			 	@device_user.password_confirmation= params[:device_user][:confirm_password] || ""
			 end

			 if @device_user.valid? == false  
				render :action => 'edit', :layout => 'common_layout'
				return		    
			 end	
			 
			 # render :json => @client
			 #return
			 
			if @device_user.save					
				render_error :error_code => 'e368' # success msg User registration successfully
				redirect_to :action => 'index' 
				return                    
			else   
				render :action => 'edit', :id => params[:id]
				return			                        
			end   
		rescue => ex
			logger.info "thumb error : #{ex.class} , #{ex.message}"
			render_error :error_code => 'e366'  ## Display error message email/password does not match..       
			render :action => 'edit', :id => params[:id]
			return
		end			
		render_error :error_code => 'e366' 
		render :action => "edit", :id => params[:id]
	end
	
	def view				
    	#client_id=session[:client_id] || 0		
		@device_user=DeviceUser.get_selected_device_user(params[:id].to_i)			
		render :action => "view", :layout => "common_layout"
	end
	
	def delete
		begin
			@device_user=DeviceUser.find(params[:id])
			@device_user.status_code=403 # record delete : 403
			
			if @device_user.save!
				render_error :error_code => 'e369'  ## Display error message email/password does not match..       
				redirect_to(:action => 'index')
				return			
			else				     
				redirect_to(:action => 'view', :id => params[:id])
				return
			end
		rescue
			render_error :error_code => 'e366'  ## Display error message email/password does not match..       
			redirect_to(:action => 'view', :id => params[:id])
			return
		end			
		render :action => "view", :id => params[:id]
	end
	
	def user_deactivation
		begin
			@device_user=DeviceUser.find(params[:id])
			@device_user.status_code=402 # record delete : 403
			
			if @device_user.save!
				render_error :error_code => 'e377'  ## Display error message email/password does not match..       
				redirect_to(:action => 'index')
				return			
			else				     
				redirect_to(:action => 'index')
				return
			end
		rescue
			render_error :error_code => 'e366'  ## Display error message email/password does not match..       
			redirect_to(:action => 'index')
			return
		end			
		redirect_to(:action => 'index')
	end
	
	def user_reactivation
		begin
			@device_user=DeviceUser.find(params[:id])
			@device_user.status_code=401 # record delete : 403
			
			if @device_user.save!
				render_error :error_code => 'e378'  ## Display error message email/password does not match..       
				redirect_to(:action => 'index')
				return			
			else				     
				redirect_to(:action => 'index')
				return
			end
		rescue
			render_error :error_code => 'e366'  ## Display error message email/password does not match..       
			redirect_to(:action => 'index')
			return
		end			
		redirect_to(:action => 'index')
	end
	
end
