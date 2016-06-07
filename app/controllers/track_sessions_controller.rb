class TrackSessionsController < ApplicationController
	skip_before_filter :require_login, :only => [:delete_track_session_image_ajax]
	
	def index
		record_per_page=Protrack::Configuration['pagesize']
						
		client_id=session[:client_id] || 0	
		admin_id=session[:admin_id] || 0
		engn_id=session[:engn_id] || 0
				
		if (admin_id.to_i > 0 )
			client_id = params[:id] || session[:proxy_client_id] || 0 	
			session[:proxy_client_id] = client_id	
			session[:proxy_client_name] = Client.find(client_id).client_name				
		end
		
		@track_session=TrackSession.get_track_sessions(engn_id.to_i,client_id.to_i,record_per_page,params[:page])
		  # render :json => @track_session
		  # return					
		  render :action => "index", :layout => "common_layout"
	end
	
	def add		
		client_id=session[:client_id] || 0
		admin_id=session[:admin_id] || 0
		engn_id=session[:engn_id] || 0
		
		if (admin_id.to_i > 0 )
			client_id = session[:proxy_client_id] || 0 						
		end
		
		@track_session=TrackSession.new		
		@track_session.fk_engn_id=engn_id
		@track_session.fk_client_id= 0
		@track_session.engineer_name= session[:user_name].to_s		
		
		if engn_id.to_i > 0
			@race_engineer=RaceEngineer.where(:pk_engn_id => engn_id)	
			if @race_engineer.count >0 
				@race_engineer=@race_engineer.first
				@track_session.fk_client_id=@race_engineer.fk_client_id
			end				
		end		
		@track_session.session_date=  Date.today.to_s
		#@device_user=DeviceUser.get_device_user_list(1)		
		#render :json => @device_user
		#return
		
		render :action => "add", :layout => "common_layout"
	end	
	
	def create_ajax
		begin
			#render :json => params
			#return
			@track_session=TrackSession.new(params[:track_session])
			fk_client_id= RaceEngineer.find(params[:track_session][:fk_engn_id]).fk_client_id			
			@track_session.fk_client_id=fk_client_id 
			@track_session.engineer_name = session[:user_name].to_s || ""
			@track_session.status_code=401
			@track_session.create_ip=request.remote_ip
			@track_session.last_updated_ip=request.remote_ip

			if @track_session.valid? == false
				error_messages=""
				if @track_session.errors.full_messages.length >0
					@track_session.errors.full_messages.each do |msg|
						if error_messages.empty? == false
							error_messages =  error_messages + ", \n "
						else
							error_messages =  error_messages + " \n "
						end
						error_messages =  error_messages +  msg
					end
				end
				render :json => {:resp_code => "401", :message => "Errors: " + error_messages}
				return
			end
			if @track_session.save!
				if (params[:track_session][:session_image].blank? == false)
					params[:track_session][:session_image].each do |session_image|
						begin
							@track_session_image=TrackSessionImage.new
							
							image_filename= session_image.original_filename.to_s 		
							image_name=image_filename.split('/').last
							image_extn=image_name.split('.').last
							newfilename = "#{(Time.now.to_i.to_s + Time.now.usec.to_s).ljust(16, '0')}"
							newfilename = newfilename + '.' + image_extn
													
							image_path="/assets/images/client/client_" + @track_session.fk_client_id.to_s + "/session_image/"						
							save_file_url(session_image,newfilename, image_path)							
							public_url_image_path="/assets/client/client_" + @track_session.fk_client_id.to_s + "/session_image/"					
							
							
							@track_session_image.session_image= public_url_image_path + newfilename	
							@track_session_image.fk_session_id= @track_session.id	
							@track_session_image.status_code= 401
							@track_session_image.image_code= 301
							#render :json => @client_track_image
							#return
							@track_session_image.save
						rescue							
							#Error Comment
						end								
					end				
				end
				unless params[:track_session][:engineer_report].blank?
					params[:track_session][:engineer_report].each do |session_report|
						@track_session_report=TrackSessionReport.new

					image_filename= session_report.original_filename.to_s
					image_name=image_filename.split('/').last
					image_extn=image_name.split('.').last
					newfilename = "#{(Time.now.to_i.to_s + Time.now.usec.to_s).ljust(16, '0')}"
					newfilename = newfilename + '.' + image_extn

					report_path="/assets/images/client/client_" + @track_session.fk_client_id.to_s + "/session_report/"
					save_file_url(session_report,newfilename, report_path)
					public_url_image_path="/assets/client/client_" + @track_session.fk_client_id.to_s + "/session_report/"


					@track_session_report.session_report= public_url_image_path + newfilename
					@track_session_report.fk_session_id= @track_session.id
					@track_session_report.status_code= 401
					@track_session_report.report_code= 301
					#render :json => @client_track_image
					#return
					@track_session_report.save
						end
				end
					render :json => {:resp_code => "200", :message => "Track is successfully created."}				
					return					
				else
					render :json => {:resp_code => "402", :message => "Track is not valid. Please try again "}				
					return
				end
		rescue => ex
			logger.error "erro: #{ex.class} , #{ex.message}"
			render :json => {:resp_code => "403", :message => "Track is not valid. Please try again "}				
			return
		end			
		render :json => {:resp_code => "404", :message => "Track is not valid. Please try again "}				
	end
		
	def create
		begin			
			@track_session=TrackSession.new	
			fk_client_id= RaceEngineer.find(params[:track_session][:fk_engn_id]).fk_client_id			
			@track_session.fk_client_id=fk_client_id 			
			@track_session.fk_engn_id=params[:track_session][:fk_engn_id]				
						
			@track_session.name=params[:track_session][:name]
									
			@track_session.session_date=params[:track_session][:session_date] 
			@track_session.fk_driver_id=params[:track_session][:fk_driver_id] 
			@track_session.engineer_name=session[:user_name].to_s || ""
			@track_session.championship=params[:track_session][:championship] || ""
			@track_session.circuit=params[:track_session][:circuit] || ""
			@track_session.event=params[:track_session][:event] || ""
			
			@track_session.status_code=401
			@track_session.create_ip=request.remote_ip 	
			@track_session.last_updated_ip=request.remote_ip
								
			if @track_session.valid? == false
				render :action => "add"
				return
			end
					
			if @track_session.save!		
				if (params[:track_session][:session_image].blank? == false)
					params[:track_session][:session_image].each do |session_image|	
						begin
							@track_session_image=TrackSessionImage.new
							
							image_filename= session_image.original_filename.to_s 		
							image_name=image_filename.split('/').last
							image_extn=image_name.split('.').last
							newfilename = "#{(Time.now.to_i.to_s + Time.now.usec.to_s).ljust(16, '0')}"
							newfilename = newfilename + '.' + image_extn
							
							#render :json => newfilename
							#return
							
							image_path="/assets/images/client/client_" + @track_session.fk_client_id.to_s + "/session_image/"						
							save_file_url(session_image,newfilename, image_path)							
							public_url_image_path="/assets/client/client_" + @track_session.fk_client_id.to_s + "/session_image/"					
							
							#render :json => public_url_image_path
							#return
							
							@track_session_image.session_image= public_url_image_path + newfilename	
							@track_session_image.fk_session_id= @track_session.id	
							@track_session_image.status_code= 401
							@track_session_image.image_code= 301
							@track_session_image.save
						rescue							
							#Error Comment
						end								
					end				
				end		
					render_error :error_code => 'e350'  ## Display error message email/password does not match..       
					redirect_to(:action => 'index')
					return	
				else
					#	 :error_code => 'e310'  ## Display error message email/password does not match..       
					render :action => "add"
					return
				end
		rescue
			render_error :error_code => 'e349'  ## Display error message email/password does not match..       
			render :action => "add"
			return
		end			
		render :action => "add"
	end
	
	def edit
				
		client_id=session[:client_id] || 0
		admin_id=session[:admin_id] || 0
		engn_id=session[:engn_id] || 0
			
		if (admin_id.to_i > 0 )
			client_id = session[:proxy_client_id] || 0 						
		end
		
		@track_session=TrackSession.get_selected_track_sessions(engn_id.to_i,client_id.to_i, params[:id])
	
		if @track_session.nil? == true
			render_error :error_code => 'e375'
			redirect_to :action => 'index'
			return	
		end
		
		@track_session_image=TrackSessionImage.where("image_code in(301) and status_code=401 and fk_session_id=" + @track_session.id.to_s)	
		
		render :action => "edit", :layout => "common_layout"
	end
	
	def delete_track_session_image_ajax
		begin
			@track_session_image=TrackSessionImage.find(params[:id])
			
			if @track_session_image.nil? == true
				render :json => {:resp_code => "411", :message => "Track session image data is not valid. Please try again." + @track_turn_note.errors.to_json}
				return
			end
			
			@track_session_image.status_code=403
			
			if @track_session_image.valid? == false   				
				render :json => {:resp_code => "412", :message => "Track session image data is not valid. Please try again." + @track_turn_note.errors.to_json}
				return
			end
	
			if @track_session_image.save!
				render :json => {:resp_code => "200", :message => "Track session image data is sucessfully saved."}
				return
			else
				render :json => {:resp_code => "413", :message => "Track session image data is not valid. Please try again."}
				return
			end				
		rescue => ex
		    logger.error "erro: #{ex.class} , #{ex.message}"		
			render :json => {:resp_code => "414", :message => "Track session image data is not valid. Please try again. error: #{ex.message}"}
			return
		end			
		render :json => {:resp_code => "415", :message => "Track session image have problem. Please try again."}	
	end
	
	def view				
    	client_id=session[:client_id] || 0
		admin_id=session[:admin_id] || 0
		engn_id=session[:engn_id] || 0
		
		if (admin_id.to_i > 0 )
			client_id = session[:proxy_client_id] || 0 						
		end
		
		@track_session=TrackSession.get_selected_track_sessions(engn_id.to_i,client_id.to_i, params[:id].to_i)	
		
		if @track_session.nil? == true
			render_error :error_code => 'e375'
			redirect_to :action => 'index'
			return	
		end
			
		@track_session_image=TrackSessionImage.where("image_code in(301) and status_code=401 and fk_session_id=" + @track_session.id.to_s)	
		
		render :action => "view", :layout => "common_layout"
	end
		
	def update_ajax
		
		begin		
			@track_session=TrackSession.find(params[:id])
			
			fk_client_id= RaceEngineer.find(params[:track_session][:fk_engn_id]).fk_client_id			
			@track_session.fk_client_id=fk_client_id 
			@track_session.name=params[:track_session][:name] 		
			
			@track_session.session_date=params[:track_session][:session_date] 
			@track_session.fk_driver_id=params[:track_session][:fk_driver_id] 
			#@track_session.engineer_name=params[:track_session][:engineer_name] || ""
			@track_session.championship=params[:track_session][:championship] || ""
			@track_session.circuit=params[:track_session][:circuit] || ""
			@track_session.event=params[:track_session][:event] || ""
			
			@track_session.last_updated_ip=request.remote_ip
						
			if @track_session.valid? == false  				
				error_messages=""
				if @track_session.errors.full_messages.length >0
					@track_session.errors.full_messages.each do |msg|
						if error_messages.empty? == false
							error_messages =  error_messages + ", \n "
						else
							error_messages =  error_messages + " \n "
						end
						error_messages =  error_messages +  msg
					end
				end
				render :json => {:resp_code => "401", :message => "Errors: " + error_messages}				
				return	    
			 end	
			 				
			if @track_session.save!				
				if (params[:track_session][:session_image].blank? == false)
					params[:track_session][:session_image].each do |session_image|	
						begin
							@track_session_image=TrackSessionImage.new
							
							image_filename= session_image.original_filename.to_s 		
							image_name=image_filename.split('/').last
							image_extn=image_name.split('.').last
							newfilename = "#{(Time.now.to_i.to_s + Time.now.usec.to_s).ljust(16, '0')}"
							newfilename = newfilename + '.' + image_extn
							
							#render :json => newfilename
							#return
							
							image_path="/assets/images/client/client_" + @track_session.fk_client_id.to_s + "/session_image/"						
							save_file_url(session_image,newfilename, image_path)							
							public_url_image_path="/assets/client/client_" + @track_session.fk_client_id.to_s + "/session_image/"					
							
							#render :json => public_url_image_path
							#return
							
							@track_session_image.session_image= public_url_image_path + newfilename	
							@track_session_image.fk_session_id= @track_session.id	
							@track_session_image.status_code= 401
							@track_session_image.image_code= 301
							@track_session_image.save
						rescue							
							#Error Comment
						end								
					end				
				end		
				
				render :json => {:resp_code => "200", :message => "Track Session is successfully updated."}				
				return					
			else
				render :json => {:resp_code => "402", :message => "Track Session is not valid. Please try again "}				
				return
			end
		rescue => ex
			logger.error "erro: #{ex.class} , #{ex.message}"
			render :json => {:resp_code => "403", :message => "Track Session is not valid. Please try again "}				
			return
		end			
		render :json => {:resp_code => "404", :message => "Track Session is not valid. Please try again "}	
	end
	
	def update
		
		begin		
			@track_session=TrackSession.find(params[:id])
			
			fk_client_id= RaceEngineer.find(params[:track_session][:fk_engn_id]).fk_client_id
			@track_session.fk_client_id=fk_client_id
			@track_session.name=params[:track_session][:name] 		
			
			@track_session.session_date=params[:track_session][:session_date] 
			@track_session.fk_driver_id=params[:track_session][:fk_driver_id] 
			#@track_session.engineer_name=params[:track_session][:engineer_name] || ""
			@track_session.championship=params[:track_session][:championship] || ""
			@track_session.circuit=params[:track_session][:circuit] || ""
			@track_session.event=params[:track_session][:event] || ""
			
			@track_session.last_updated_ip=request.remote_ip 
		
			if @track_session.valid? == false  				
				@track_session_image=TrackSessionImage.where("image_code in(301) and status_code=401 and fk_engn_id=" + @track_session.id.to_s)	
		
				render :action => 'edit', :id => params[:id]
				return		    
			 end	
			 				
			if @track_session.save!
				if (params[:track_session][:session_image].blank? == false)
					params[:track_session][:session_image].each do |session_image|	
						begin
							@track_session_image=TrackSessionImage.new
							
							image_filename= session_image.original_filename.to_s 		
							image_name=image_filename.split('/').last
							image_extn=image_name.split('.').last
							newfilename = "#{(Time.now.to_i.to_s + Time.now.usec.to_s).ljust(16, '0')}"
							newfilename = newfilename + '.' + image_extn
							
							#render :json => newfilename
							#return
							
							image_path="/assets/images/client/client_" + @track_session.fk_client_id.to_s + "/session_image/"						
							save_file_url(session_image,newfilename, image_path)							
							public_url_image_path="/assets/client/client_" + @track_session.fk_client_id.to_s + "/session_image/"					
							
							#render :json => public_url_image_path
							#return
							
							@track_session_image.session_image= public_url_image_path + newfilename	
							@track_session_image.fk_session_id= @track_session.id	
							@track_session_image.status_code= 401
							@track_session_image.image_code= 301
							@track_session_image.save
						rescue							
							#Error Comment
						end								
					end				
				end		
				render_error :error_code => 'e351'  ## Display error message email/password does not match..       
				redirect_to(:action => 'index')
				return	
			else
				#render_error :error_code => 'e310'  ## Display error message email/password does not match..       
				render :action => 'edit', :id => params[:id]
				return
			end
		rescue => ex
			logger.error "erro: #{ex.class} , #{ex.message}"
			render_error :error_code => 'e349'  ## Display error message email/password does not match..       
			render :action => 'edit', :id => params[:id]
			return
		end			
		render :action => "edit", :id => params[:id]
	end
	
	def save_file_url(params_name,filename, path) 
		begin
			dir= File.join(Rails.root, "app", path)
			Dir.mkdir(dir) unless File.exists?(dir)
			
			path = File.join(Rails.root, "app", path, filename)
			# write the file
			File.open(path, "wb") { |f| f.write(params_name.read) }  
		rescue => ex
			logger.info "erro: #{ex.class} , #{ex.message}"
		end
	end
	
	def save_thumb_file_url(source_image_path,filename, path, width, height) 
		begin
			dir= File.join(Rails.root, "app", path)
			Dir.mkdir(dir) unless File.exists?(dir)
			
			path = File.join(Rails.root, "app", path, filename)
			# write the file
			source_image_path= File.join(Rails.root, "app", source_image_path, filename)
			
			image = MiniMagick::Image.open(source_image_path)
			image.resize width + "x" + height
			image.write  path
		rescue => ex
			logger.info "thumb error : #{ex.class} , #{ex.message}"
		end
	end
	
	def delete
		begin
			@track_session=TrackSession.find(params[:id])
			
			if @track_session.nil? == true
				render_error :error_code => 'e375'
				redirect_to :action => 'index'
				return	
			end
		
			@track_session.status_code=403 # record delete : 403
			
			if @track_session.save!
				render_error :error_code => 'e348'  ## Display error message email/password does not match..       
				redirect_to(:action => 'index')
				return	
			else
				render_error :error_code => 'e310'  ## Display error message email/password does not match..       
				redirect_to(:action => 'view')
				return
			end
		rescue
			render_error :error_code => 'e349'  ## Display error message email/password does not match..       
			redirect_to(:action => 'view')
			return
		end			
		render :action => "view"
	end
end