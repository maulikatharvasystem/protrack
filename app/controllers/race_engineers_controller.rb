class RaceEngineersController < ApplicationController
	skip_before_filter :require_login, :only => [:send_reactivation_link]
	before_filter :is_client_part
	
	def index
		record_per_page=Protrack::Configuration['pagesize']
	
		client_id=session[:client_id] || 0	
		admin_id=session[:admin_id] || 0			
				 
		@race_engineer=RaceEngineer.get_engn_list(client_id,record_per_page,params[:page])							
		render :action => "index", :layout => "common_layout"
	end
	
	def index_flash_clear
		flash[:message]=nil
		redirect_to :action => 'index'
	end
	
	def add
		@race_engineer=RaceEngineer.new		
		render :action => "add", :layout => "common_layout"
	end	
	
	# create-----------------
	def create
		begin
			client_id=session[:client_id] || 0	
			admin_id=session[:admin_id] || 0
			
			 @race_engineer=RaceEngineer.new	   
			
			 @race_engineer.create_ip = request.remote_ip  
			 @race_engineer.last_updated_ip = request.remote_ip  
			 @race_engineer.status_code= 401
			 @race_engineer.fk_user_type_id= 5
			 @race_engineer.fk_client_id= client_id
			 
			 @race_engineer.race_engineer_name= params[:race_engineer][:race_engineer_name] || ""
			 @race_engineer.contact_person= params[:race_engineer][:contact_person] || ""
			 @race_engineer.email= params[:race_engineer][:email] || ""
			 @race_engineer.phone= params[:race_engineer][:phone] || ""
			 @race_engineer.website= params[:race_engineer][:website] || ""
			 @race_engineer.address= params[:race_engineer][:address] || ""
			 
			 @race_engineer.encrypt_pwd= params[:race_engineer][:encrypt_pwd] || ""
			 @race_engineer.encrypt_pwd_confirmation= params[:race_engineer][:confirm_password] || ""
						 
			 if @race_engineer.valid? == false  
				render :action => 'add', :layout => 'common_layout'
				return		    
			 end	
			 
			 #render :json => @race_engineer
			 #return
			 
			if @race_engineer.save		
				#client_path="/assets/images/client/client_" + @race_engineer.id.to_s + ""
				#dir= File.join(Rails.root, "app", client_path)
				#Dir.mkdir(dir) unless File.exists?(dir)
						
				UserMailer.register_race_engineer_email(@race_engineer).deliver
						
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
		    @race_engineer=RaceEngineer.where(pk_engn_id: params[:id].to_i)	
			
			if @race_engineer.count <= 0
				render :json => { :status => "401", :message => "User not found, please try again."}
			    return	
			end
			@race_engineer=@race_engineer.first
			
			if  @race_engineer.status_code.to_s == "400"
				UserMailer.register_race_engineer_email(@race_engineer).deliver
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
			@race_engineer=RaceEngineer.where(:email => params[:race_engineer][:email].to_s)	
								
			if @race_engineer.count <= 0
				render :json => {:resp_code => "200", :message => "Email id is available"}				
			elsif @race_engineer.status_code == "403"			
				render :json => {:resp_code => "403", :message => "Email id is already taken. \n It's deleted account, do you want reactivate account ?"}				
			elsif @race_engineer.status_code == "402"
				render :json => {:resp_code => "403", :message => "Email id is already taken. \n It's de-activated account, do you want reactivate account ?"}				
			elsif @race_engineer.status_code == "400"	
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
		@race_engineer=RaceEngineer.find(params[:id].to_i)		
		render :action => "edit", :layout => "common_layout"
	end
	
	def update
		begin
			 @race_engineer=RaceEngineer.find(params[:id])	   
						
			 @race_engineer.last_updated_ip = request.remote_ip  			 
			 @race_engineer.race_engineer_name= params[:race_engineer][:race_engineer_name] || ""
			 @race_engineer.contact_person= params[:race_engineer][:contact_person] || ""			 
			 @race_engineer.phone= params[:race_engineer][:phone] || ""			
			 @race_engineer.address= params[:race_engineer][:address] || ""
			 @race_engineer.website= params[:race_engineer][:website] || ""
			 
			 if params[:race_engineer][:encrypt_pwd].blank? == false
			 	@race_engineer.encrypt_pwd= params[:race_engineer][:encrypt_pwd] || ""
			 end

			 if params[:race_engineer][:confirm_password].blank? == false	
			 	@race_engineer.encrypt_pwd_confirmation= params[:race_engineer][:confirm_password] || ""
			 end

			 if @race_engineer.valid? == false  
				render :action => 'edit', :layout => 'common_layout'
				return		    
			 end	
			 
			if @race_engineer.save					
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
		@race_engineer=RaceEngineer.get_selected_engn(params[:id].to_i)			
		render :action => "view", :layout => "common_layout"
	end
	
	def delete
		begin
			@race_engineer=RaceEngineer.find(params[:id])
			@race_engineer.status_code=403 # record delete : 403
			
			if @race_engineer.save!
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
			@race_engineer=RaceEngineer.find(params[:id])
			@race_engineer.status_code=402 # record delete : 403
			
			if @race_engineer.save!
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
			@race_engineer=RaceEngineer.find(params[:id])
			@race_engineer.status_code=401 # record delete : 403
			
			if @race_engineer.save!
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
