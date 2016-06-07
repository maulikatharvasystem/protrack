class Api::UserFileController < Api::ApiController
    #include Protrack::Apiload

	def save_file
		data={}				
		data['success']= "false"	
		begin
			logger.debug "save_file: " + params.to_s
			
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
							
			if (@device_users[:last_timestamp].to_i >= params[:last_updated].to_i)
				data['success']= "false"				
				api_response({"responsecode" => "401", "data" => data}, params[:response_type])	
				return
			end
							
			if (params[:zip_file].blank? == false)
				file_name=params[:zip_file].original_filename.to_s 	

				org_file_name=file_name.split('/').last
				file_extn=org_file_name.split('.').last
				newfilename = "file_" + @device_users.fk_client_id.to_s 
				newfilename = newfilename + '.' + file_extn				
								
				file_path="/assets/images/client/client_" + @device_users.fk_client_id.to_s + "/file/"						
				save_file_url(params[:zip_file], newfilename, file_path)						
				
				@device_users.last_updated_ip=request.remote_ip
				@device_users.file_name=newfilename
				@device_users.last_timestamp=params[:last_updated]
				@device_users.save
			end						
								
			data['success']= "true"				
			api_response({"responsecode" => "200", "data" => data}, params[:response_type])		
		rescue 	=> ex
			api_response({"responsecode" => "401", "data" => data}, params[:response_type])
			logger.error "erro: #{ex.class} , #{ex.message}"
		end
	end
	
	def save_file_url(params_name,filename, org_path) 
		begin
			dir= File.join(Rails.root, "app", org_path)
			Dir.mkdir(dir) unless File.exists?(dir)
			path = File.join(Rails.root, "app", org_path, filename)
						
			if File.exist?(path)				
				org_file_name=filename.split('/').last
				file_extn=org_file_name.split('.').last
				newfilename = org_file_name.split('.').first + "_" + "#{(Time.now.to_i.to_s + Time.now.usec.to_s).ljust(16, '0')}"
				newfilename = newfilename + '.' + file_extn
				newfilepath = File.join(Rails.root, "app", org_path, newfilename)				
				File.rename(path,newfilepath)
			end
			# write the file
			
			File.open(path, "wb") { |f| f.write(params_name.read) }  
		rescue => ex
			logger.info "erro: #{ex.class} , #{ex.message}"
		end
	end
		
	def load_file			
		begin
			logger.debug "load_file: " + params.to_s
			
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
					
			filename = @device_users[:file_name]
			file_path="/assets/images/client/client_" + @device_users.fk_client_id.to_s + "/file/"
			path = File.join(Rails.root, "app", file_path, filename)
						
			image_server_ip=Protrack::Configuration['image_server_ip']
			if File.exist?(path)
				public_url= image_server_ip + "/assets/client/client_" + @device_users.fk_client_id.to_s + "/file/" + filename
				data['file_url']= public_url
			else
				data['file_url']= ""	
			end	
			 data['last_updated']=@device_users.last_timestamp.to_s
					
			api_response({"responsecode" => "200", "data" => data}, params[:response_type])		
		rescue 	=> ex
			api_response({"responsecode" => "401", "data" => data}, params[:response_type])
			logger.error "erro: #{ex.class} , #{ex.message}"
		end
	end
	
end
