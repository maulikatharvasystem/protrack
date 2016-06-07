class Api::UserController < Api::ApiController
    #include Protrack::Apiload
	#skip_before_filter :validate_request, :only => [:user_login]
	
	def coockies_user_login
		begin
			#logger.debug "Output: " + params.to_s
					
			@client=Client.where(pk_client_id: params[:client_id].to_i)		
			if (@client.count<=0)
				logger.debug "Client not found for client_id=" + params[:client_id].to_s
				coockies_render_error('e1011',params[:response_type].to_s)  
				return
			end			
			
			@device_users=DeviceUser.where(fk_client_id:  params[:client_id].to_i, email:  params[:email], password:  params[:password], :status_code => ['401','402']) 
			
			if (@device_users.count<=0)
				logger.debug "device_users not found for client_id=" + params[:client_id].to_s
				coockies_render_error('e1012',params[:response_type].to_s)  
				return
			else

				if @device_users[0][:status_code] == 403
					coockies_render_error('e2203',params[:response_type].to_s)  
					return false
				end

				if @device_users[0][:status_code] == 402
					coockies_render_error('e2204',params[:response_type].to_s)  
					return false
				end


				@device_users=@device_users.first
				session_id=Time.now.to_i
				
				@device_users[:sessionid]=session_id	
				
				@user_device=UserDevice.where(fk_client_id: params[:client_id].to_s, device_id: params[:device_id].to_s)
				#@device_users.last_fk_device_id = update_device(params[:client_id].to_s, params[:device_id].to_s, "")
				if @user_device.count >0
					@device_users.last_fk_device_id=@user_device.first.pk_device_id
				end
				
				if @device_users.save!
					data={}	
					data['user_id']=@device_users.id.to_s
					data['sessionid']=session_id	
					cookies[:user_id] = {
					  value: @device_users.id.to_s,
					  expires: 5.year.from_now
					}
					cookies[:session_id] = {
					  value: session_id.to_s,
					  expires: 5.year.from_now
					}

					cookies[:client_id] = {
					  value: @device_users.fk_client_id.to_s,
					  expires: 5.year.from_now
					}				
					#api_response({"responsecode" => "200", "data" => data}, params[:response_type])
					api_response({"success" => true}, params[:response_type])				
					return
				else
					#logger.debug "Client not found for client_id=" + params[:client_id].to_s
					coockies_render_error('e1012',params[:response_type].to_s)  
					return
				end
						
			end	
		rescue 	=> ex
			logger.error "erro: #{ex.class} , #{ex.message}"
		end	
	end
		
	def coockies_update_push_token 
		begin
			#logger.debug "Output: " + params.to_s
			#update_device(params[:client_id].to_s, params[:device_id].to_s, params[:token].to_s)
			#return
			
			device_id = update_device(params[:client_id].to_s, params[:device_id].to_s, params[:token].to_s)
			if device_id.to_i > 0	
				begin	
					ApnsController.register_device(params[:token].to_s)
				rescue 	=> ex
					logger.error "erro: #{ex.class} , #{ex.message}"
				end	
				
				api_response({"success" => true}, params[:response_type])				
				return
			else
				coockies_render_error('e1013',params[:response_type].to_s)  
				return
			end
			
			# @device_users=DeviceUser.where(fk_client_id:  params[:client_id].to_i, pk_user_id:  params[:user_id].to_i)			
			# if (@device_users.count<=0)
				# logger.debug "device_users not found for client_id=" + params[:client_id].to_s
				# coockies_render_error('e1012',params[:response_type].to_s)  
				# return
			# else
				# @device_users=@device_users.first				
				# @device_users.last_fk_device_id = update_device(params[:client_id].to_s, params[:device_id].to_s, params[:token].to_s)
				# if @device_users.save!						
					# api_response({"success" => true}, params[:response_type])				
					# return
				# else
					# logger.debug "Device not found for client_id=" + params[:client_id].to_s
					# coockies_render_error('e1013',params[:response_type].to_s)  
					# return
				# end
			# end
		rescue 	=> ex
			logger.error "erro: #{ex.class} , #{ex.message}"
		end	
	end	
	
	def coockies_user_logout 
		begin
			logger.debug "Output: " + params.to_s		
			
			cookies.delete :user_id
			cookies.delete :session_id
			cookies.delete :client_id	
		
			api_response({"success" => true}, params[:response_type])				
			return	
		rescue 	=> ex
			logger.error "erro: #{ex.class} , #{ex.message}"
		end	
	end
	
	def user_login
		logger.debug "Output: " + params.to_s
		
		@client=Client.where(pk_client_id: params[:client_id].to_i)		
		if (@client.count<=0)
			logger.debug "Client not found for client_id=" + params[:client_id].to_s
			render_error('e1011',params[:response_type].to_s)  
			return
		end	
		
		@user_device=UserDevice.where(fk_client_id:  params[:client_id].to_i, pk_device_id:  params[:device_id].to_i)		
		if (@user_device.count<=0)
			logger.debug "user_device not found for client_id=" + params[:client_id].to_s
			render_error('e1014', params[:response_type]) 
			return
		end	
		
		@device_users=DeviceUser.where(fk_client_id:  params[:client_id].to_i, email:  params[:email], password:  params[:password]) 
		
		if (@device_users.count<=0)
			logger.debug "device_users not found for client_id=" + params[:client_id].to_s
			render_error('e1012',params[:response_type].to_s)  
			return
		else
			@device_users=@device_users.first
			session_id=Time.now.to_i
			
			@device_users[:sessionid]=session_id
			if @device_users.save!
				data={}	
				data['user_id']=@device_users.id.to_s
				data['sessionid']=session_id			
				api_response({"responsecode" => "200", "data" => data}, params[:response_type])		
				return
			else
				logger.debug "Client not found for client_id=" + params[:client_id].to_s
				render_error('e1012',params[:response_type].to_s)  
				return
			end
					
		end	
	end
		
	def user_registeration
		begin
			logger.debug "User register: " + params.to_s
			
			@client=Client.where(pk_client_id: params[:client_id].to_i)
			
			#render :json => @client.count
			#return
			if (@client.count<=0)
				logger.debug "Client not found for client_id=" + params[:client_id].to_s
				render_error('e1011',params[:response_type].to_s)
				return
			end
			
			@user_device=UserDevice.where(fk_client_id:  params[:client_id].to_i, pk_device_id:  params[:device_id].to_i)		
			if (@user_device.count<=0)
				logger.debug "user_device not found for client_id=" + params[:client_id].to_s
				render_error('e1014', params[:response_type]) 
				return
			end			
			
			@device_users=DeviceUser.new
			@device_users[:email]=params[:email]
			@device_users[:first_name]=params[:first_name]
			@device_users[:last_name]=params[:last_name]
			@device_users[:phone]=params[:phone] || ''
			@device_users[:address]=params[:address] || ''
			@device_users[:dob]=params[:dob] || '1901-01-01'
			@device_users[:create_ip]=request.remote_ip 
			@device_users[:last_updated_ip]=request.remote_ip 
			@device_users[:password]=params[:password]
			@device_users[:fk_client_id]=params[:client_id]
			@device_users[:last_fk_device_id]=params[:device_id]
			@device_users[:status_code]=401
				
			#api_response({"responsecode" => "200", "data" => @device_users}, params[:response_type])	
			#return
			
			data={}			
			if @device_users.save!
				data['user_id']=@device_users.id.to_s
				data['last_updated']=@device_users.last_timestamp.to_s
				
				api_response({"responsecode" => "200", "data" => data}, params[:response_type])	
			else
				 render_error('e1010',params[:response_type].to_s,@device_users.errors.to_json) 
			end	
		rescue 	=> ex
			render_error('e1010',params[:response_type].to_s,"#{ex.message}") 
			logger.error "erro: #{ex.class} , #{ex.message}"
		end
	end
	
	def need_update		
		logger.debug "Output: " + params.to_s
		
		@client=Client.where(pk_client_id: params[:client_id].to_i)		
		if (@client.count<=0)
			logger.debug "Client not found for client_id=" + params[:client_id].to_s
			render_error('e1011', params[:response_type]) 
			return
		end	
					
		@device_users=DeviceUser.where(fk_client_id:  params[:client_id].to_i, sessionid:  params[:sessionid].to_i) 		
		if (@device_users.count<=0)
			logger.debug "Client not found for client_id=" + params[:client_id].to_s
			render_error('e1012', params[:response_type]) 
			return
		end	
		
		@user_device=UserDevice.where(fk_client_id:  params[:client_id].to_i, pk_device_id:  params[:device_id].to_i)		
		if (@user_device.count<=0)
			logger.debug "user_device not found for client_id=" + params[:client_id].to_s
			render_error('e1014', params[:response_type]) 
			return
		end	
			
		@device_users=@device_users.first
		
		data={}	
		if (@device_users[:last_timestamp].to_i > params[:last_updated].to_i)
			data['need_update']= "true"	
		else					
			data['need_update']= "false"			
		end	
		api_response({"responsecode" => "200", "data" => data}, params[:response_type])			
	end
   
    def update_device(client_id, device_id, device_token)
		begin
			logger.debug "Device registeration: " + params.to_s				
			@user_device=UserDevice.where(fk_client_id: client_id, device_id: device_id)										
			
			if (@user_device.count<=0)				
				@user_device=UserDevice.new
			else
				@user_device=@user_device.first
			end			
			
			@user_device[:platform_code]= "300"
			@user_device[:device_id]= device_id || ''
			if device_token.empty? == false			
				@user_device[:device_token]= device_token || ''	
			end
					
			@user_device[:create_ip]=request.remote_ip 
			@user_device[:last_updated_ip]=request.remote_ip 
					
			@user_device[:fk_client_id]=client_id
			@user_device[:status_code]=401
			
			
			if @user_device.save(validate: false)	
				return @user_device.pk_device_id.to_s
			else
				return "0"
			end	
			
			#render :json => @user_device	
			#return
		rescue 	=> ex			
			logger.error "erro: #{ex.class} , #{ex.message}"
			#render :json => ex.message
			#return
			return "0"
		end
	end
	
end
