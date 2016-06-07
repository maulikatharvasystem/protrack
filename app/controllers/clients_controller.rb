class ClientsController < ApplicationController
	skip_before_filter :require_login, :only => [:send_reactivation_link]
	before_filter :is_admin_part
	
	def index
		record_per_page=Protrack::Configuration['pagesize']
	
		#client_id=session[:client_id] || 0	
		admin_id=session[:admin_id] || 0			
				
		@client=Client.get_client_list(admin_id,record_per_page,params[:page])							
		render :action => "index", :layout => "common_layout"
	end
	
	def index_flash_clear
		flash[:message]=nil
		redirect_to :action => 'index'
	end
	
	def add			
		@client=Client.new		
		render :action => "add", :layout => "common_layout"
	end	
	
	# create-----------------
	def create	
		begin
			 @client=Client.new	   
			
			 @client.create_ip = request.remote_ip  
			 @client.last_updated_ip = request.remote_ip  
			 @client.status_code= 401
			 @client.fk_user_type_id= 3
			 
			 @client.client_name= params[:client][:client_name] || ""
			 @client.contact_person= params[:client][:contact_person] || ""
			 @client.email= params[:client][:email] || ""
			 @client.phone= params[:client][:phone] || ""
			 @client.website= params[:client][:website] || ""
			 @client.address= params[:client][:address] || ""
			 
			 @client.encrypt_pwd= params[:client][:encrypt_pwd] || ""
			 @client.encrypt_pwd_confirmation= params[:client][:confirm_password] || ""
						 
			 if @client.valid? == false  
				render :action => 'add', :layout => 'common_layout'
				return		    
			 end	
			 
			 # render :json => @client
			 #return
			 
			if @client.save		
				client_path="/assets/images/client/client_" + @client.id.to_s + ""
				dir= File.join(Rails.root, "app", client_path)
				Dir.mkdir(dir) unless File.exists?(dir)
						
				UserMailer.register_email(@client, "2").deliver
						
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
		    @client=Client.where(pk_client_id: params[:id].to_i)	
			
			if @client.count <= 0
				render :json => { :status => "401", :message => "User not found, please try again."}
			    return	
			end
			@client=@client.first
			
			if  @client.status_code.to_s == "400"
				UserMailer.register_email(@client, "2").deliver
				render :json => { :status => "200", :message => "Reactivation account link is successfully sent to " + @client.email}
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
			@client=Client.where(:email => params[:client][:email].to_s)	
					
			
			if @client.count <= 0
				render :json => {:resp_code => "200", :message => "Email id is available"}				
			elsif @client.status_code == "403"			
				render :json => {:resp_code => "403", :message => "Email id is already taken. \n It's deleted account, do you want reactivate account ?"}				
			elsif @client.status_code == "402"
				render :json => {:resp_code => "403", :message => "Email id is already taken. \n It's de-activated account, do you want reactivate account ?"}				
			elsif @client.status_code == "400"	
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
		@client=Client.find(params[:id].to_i)		
		render :action => "edit", :layout => "common_layout"
	end
	
	def update
		begin
			 @client=Client.find(params[:id])	   
						
			 @client.last_updated_ip = request.remote_ip  			 
			 @client.client_name= params[:client][:client_name] || ""
			 @client.contact_person= params[:client][:contact_person] || ""			
			 @client.phone= params[:client][:phone] || ""
			 @client.website= params[:client][:website] || ""
			 @client.address= params[:client][:address] || ""
						 
			 if @client.valid? == false  
				render :action => 'edit', :layout => 'common_layout'
				return		    
			 end	
			 
			 # render :json => @client
			 #return
			 
			if @client.save					
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
		@client=Client.get_selected_client(params[:id].to_i)			
		render :action => "view", :layout => "common_layout"
	end
	
	def delete
		begin
			@client=Client.find(params[:id])
			@client.status_code=403 # record delete : 403
			
			if @client.save!
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
			@client=Client.find(params[:id])
			@client.status_code=402 # record delete : 403
			
			if @client.save!
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
			@client=Client.find(params[:id])
			@client.status_code=401 # record delete : 403
			
			if @client.save!
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
