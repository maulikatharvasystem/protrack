class Api::DeviceController < Api::ApiController
    #include Protrack::Apiload
	
	#1
	def device_registeration
		begin
			logger.debug "Device registeration: " + params.to_s		
			
			@client=Client.where(pk_client_id: params[:client_id].to_i)				
			if (@client.count<=0)
				logger.debug "Client not found for client_id=" + params[:client_id].to_s
				render_error('e1011', params[:response_type]) 
				return
			end
						
			@user_device=UserDevice.where(fk_client_id: params[:client_id].to_i, device_token: params[:device_token].to_s)				
			
			if (@user_device.count<=0)				
				@user_device=UserDevice.new
			else
				@user_device=@user_device.first
			end			
			
			@user_device[:platform_code]=params[:platform_code]
			@user_device[:app_name]=params[:app_name] || ''
			@user_device[:app_version]=params[:app_version] || ''
			@user_device[:device_token]=params[:device_token]
			@user_device[:device_name]=params[:device_name] || ''
			@user_device[:device_model]=params[:device_model] || ''
			@user_device[:device_version]=params[:device_version] || ''
			@user_device[:push_badge]=params[:push_badge] || '0'
			@user_device[:push_alert]=params[:push_alert] || '0'
			@user_device[:push_sound]=params[:push_sound] || ''
			@user_device[:devlopment]=params[:devlopment] || '0'
			@user_device[:lang_code]=params[:lang_code] || ''
			@user_device[:country_code]=params[:country_code] || ''
			@user_device[:os_version]=params[:os_version] || ''
					
			@user_device[:create_ip]=request.remote_ip 
			@user_device[:last_updated_ip]=request.remote_ip 
					
			@user_device[:fk_client_id]=params[:client_id]		
			@user_device[:status_code]=401
								
			data={}
			
			if @user_device.save!
				data['device_id']=@user_device.id.to_s
				data['last_updated']=@user_device.last_timestamp.to_s
							
				api_response({"responsecode" => "200", "data" => data},params[:response_type])	
			else
				 render_error('e1013',params[:response_type].to_s,@user_device.errors.to_json) 
			end	
		rescue 	=> ex
			render_error('e1013',params[:response_type].to_s,"#{ex.message}") 
			logger.error "erro: #{ex.class} , #{ex.message}"
		end
	end
	
	
	
end
