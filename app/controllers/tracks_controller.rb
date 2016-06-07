class TracksController < ApplicationController
	skip_before_filter :require_login, :only => [:delete_track_extra_image_ajax]

	def index
		record_per_page=Protrack::Configuration['pagesize']
						
		client_id=session[:client_id] || 0	
		admin_id=session[:admin_id] || 0
				
		if (admin_id.to_i > 0 )
			client_id = params[:id] || session[:proxy_client_id] || 0 	
			session[:proxy_client_id] = client_id	
			session[:proxy_client_name] = Client.find(client_id).client_name				
		end
		
		@client_track=ClientTrack.get_client_tracks(client_id.to_i,record_per_page,params[:page])							
		render :action => "index", :layout => "common_layout"
	end
	
	def add		
		client_id=session[:client_id] || 0
		admin_id=session[:admin_id] || 0
		if (admin_id.to_i > 0 )
			client_id = session[:proxy_client_id] || 0 						
		end
		
		@client_track=ClientTrack.new
		@client_track.fk_client_id=client_id
		
		render :action => "add", :layout => "common_layout"
	end	
	
	def create_ajax
		begin
			#render :json => params
			#return				
										
			small_thumb_image_width=Protrack::Configuration['small_thumb_image_width'].to_s			
			small_thumb_image_height=Protrack::Configuration['small_thumb_image_height'].to_s				
			med_thumb_image_width=Protrack::Configuration['med_thumb_image_width'].to_s	
			med_thumb_image_height=Protrack::Configuration['med_thumb_image_height'].to_s	
		
			@client_track=ClientTrack.new	
			@client_track.fk_client_id=params[:client_track][:fk_client_id]				
						
			@client_track.display_id=params[:client_track][:display_id]
			@client_track.track_name=params[:client_track][:track_name]
			@client_track.track_tip=params[:client_track][:track_tip]
			@client_track.no_turns=params[:client_track][:no_turns]
			@client_track.fk_product_id=params[:client_track][:fk_product_id] 
			@client_track.description=params[:client_track][:description] 
			@client_track.status_code=401
			@client_track.create_ip=request.remote_ip 	
			@client_track.last_updated_ip=request.remote_ip
		  @client_track.platform_code=300
			@client_track.timing_url=params[:client_track][:timing_url]
			@client_track.media_url=params[:client_track][:media_url]
			@client_track.weather_url=params[:client_track][:weather_url]
			@client_track.lap_video_url=params[:client_track][:lap_video_url]
			@client_track.note=params[:client_track][:note]

			#@client_track.fk_product_id=params[:price]
			
			client_path="/assets/images/client/client_" + @client_track.fk_client_id.to_s + ""
			dir= File.join(Rails.root, "app", client_path)
			Dir.mkdir(dir) unless File.exists?(dir)
			
			if (params[:client_track][:track_image].blank? == false)
				track_image_filename_=params[:client_track][:track_image].original_filename.to_s 		
				track_img_name=track_image_filename_.split('/').last
				track_img_extn=track_img_name.split('.').last
				track_newfilename = "#{(Time.now.to_i.to_s + Time.now.usec.to_s).ljust(16, '0')}"
				track_newfilename = track_newfilename + '.' + track_img_extn
				
				image_path="/assets/images/client/client_" + @client_track.fk_client_id.to_s + "/track_images/"						
				save_file_url(params[:client_track][:track_image],track_newfilename, image_path)
							
				small_image_path="/assets/images/client/client_" + @client_track.fk_client_id.to_s + "/track_images/small_track_images/"						
				save_thumb_file_url(image_path,track_newfilename, small_image_path, small_thumb_image_width, small_thumb_image_height)
				
				medium_image_path="/assets/images/client/client_" + @client_track.fk_client_id.to_s + "/track_images/med_track_images/"						
				save_thumb_file_url(image_path,track_newfilename, medium_image_path, med_thumb_image_width, med_thumb_image_height)
					
				public_url_image_path="/assets/client/client_" + @client_track.fk_client_id.to_s + "/track_images/"	
				public_url_small_image_path="/assets/client/client_" + @client_track.fk_client_id.to_s + "/track_images/small_track_images/"
				public_url_med_image_path="/assets/client/client_" + @client_track.fk_client_id.to_s + "/track_images/med_track_images/"
				
				@client_track.track_image= public_url_image_path + track_newfilename
				@client_track.small_track_image= public_url_small_image_path + track_newfilename
				@client_track.med_track_image= public_url_med_image_path + track_newfilename
			end
			if params[:client_track][:schedule_pdf_url]
				track_image_filename_=params[:client_track][:schedule_pdf_url].original_filename.to_s
				track_img_name=track_image_filename_.split('/').last
				track_img_extn=track_img_name.split('.').last
				if @client_track.track_name.nil?
					track_newfilename = "Schedule_pdf_#{(Time.now.strftime('%y%m%d'))}}"
				else
					track_newfilename = "Schedule_pdf_#{(Time.now.strftime('%y%m%d'))}_#{@client_track.track_name.split(' ').join('_') }"
				end
				track_newfilename = track_newfilename + '.' + track_img_extn
				schedule_pdf_path="/assets/images/client/client_" + @client_track.fk_client_id.to_s + "/schedule_pdf/"
				save_file_url(params[:client_track][:schedule_pdf_path],track_newfilename, schedule_pdf_path)
				public_url_image_path="/assets/client/client_" + @client_track.fk_client_id.to_s + "/schedule_pdf/"

				@client_track.schedule_pdf_url= public_url_image_path + track_newfilename

			end


			if (params[:client_track][:track_info_image].blank? == false)
				track_info_image_filename_=params[:client_track][:track_info_image].original_filename.to_s 		
				track_info_img_name=track_info_image_filename_.split('/').last
				track_info_img_extn=track_info_img_name.split('.').last
				track_info_newfilename = "#{(Time.now.to_i.to_s + Time.now.usec.to_s).ljust(16, '0')}"
				track_info_newfilename = track_info_newfilename + '.' + track_info_img_extn
			
				info_image_path="/assets/images/client/client_" + @client_track.fk_client_id.to_s + "/track_info_images/"						
				save_file_url(params[:client_track][:track_info_image],track_info_newfilename, info_image_path)
							
				small_info_image_path="/assets/images/client/client_" + @client_track.fk_client_id.to_s + "/track_info_images/small_track_info_images/"						
				save_thumb_file_url(info_image_path, track_info_newfilename, small_info_image_path, small_thumb_image_width, small_thumb_image_height)
				
				medium_info_image_path="/assets/images/client/client_" + @client_track.fk_client_id.to_s + "/track_info_images/med_track_info_images/"						
				save_thumb_file_url(info_image_path, track_info_newfilename, medium_info_image_path, med_thumb_image_width, med_thumb_image_height)
					
				public_url_info_image_path="/assets/client/client_" + @client_track.fk_client_id.to_s + "/track_info_images/"	
				public_url_small_info_image_path="/assets/client/client_" + @client_track.fk_client_id.to_s + "/track_info_images/small_track_info_images/"
				public_url_med_info_image_path="/assets/client/client_" + @client_track.fk_client_id.to_s + "/track_info_images/med_track_info_images/"
				
				@client_track.track_info_image= public_url_info_image_path + track_info_newfilename
				@client_track.small_track_info_image= public_url_small_info_image_path + track_info_newfilename
				@client_track.med_track_info_image= public_url_med_info_image_path + track_info_newfilename					
			end
					
           # render :json => @client_track.valid
		   #return	
			
			if @client_track.valid? == false
				error_messages=""
				if @client_track.errors.full_messages.length >0
					@client_track.errors.full_messages.each do |msg|
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
					
			if @client_track.save!		
				if (params[:client_track][:extra_image].blank? == false)
					params[:client_track][:extra_image].each do |extra_image|	
						begin
							@client_track_image=ClientTrackImage.new
							
							image_filename= extra_image.original_filename.to_s 		
							image_name=image_filename.split('/').last
							image_extn=image_name.split('.').last
							newfilename = "#{(Time.now.to_i.to_s + Time.now.usec.to_s).ljust(16, '0')}"
							newfilename = newfilename + '.' + image_extn
							
							#render :json => newfilename
							#return
							
							image_path="/assets/images/client/client_" + @client_track.fk_client_id.to_s + "/track_images/extra_track_images/"						
							save_file_url(extra_image,newfilename, image_path)							
							public_url_image_path="/assets/client/client_" + @client_track.fk_client_id.to_s + "/track_images/extra_track_images/"					
							
							#render :json => public_url_image_path
							#return
							
							@client_track_image.track_image= public_url_image_path + newfilename	
							@client_track_image.fk_track_id= @client_track.id	
							@client_track_image.status_code= 401
							#render :json => @client_track_image
							#return
							@client_track_image.save
						rescue							
							#Error Comment
						end								
					end				
				end	

				if (params[:client_track][:track_overview_page_image].blank? == false)
					params[:client_track][:track_overview_page_image].each do |track_overview_page_image|	
						begin
							@client_track_image=ClientTrackImage.new
							
							image_filename= track_overview_page_image.original_filename.to_s 		
							image_name=image_filename.split('/').last
							image_extn=image_name.split('.').last
							newfilename = "#{(Time.now.to_i.to_s + Time.now.usec.to_s).ljust(16, '0')}"
							newfilename = newfilename + '.' + image_extn
													
							image_path="/assets/images/client/client_" + @client_track.fk_client_id.to_s + "/track_images/info_track_images/"						
							save_file_url(track_overview_page_image,newfilename, image_path)							
							public_url_image_path="/assets/client/client_" + @client_track.fk_client_id.to_s + "/track_images/info_track_images/"					
														
							@client_track_image.track_image= public_url_image_path + newfilename	
							@client_track_image.fk_track_id= @client_track.id	
							@client_track_image.status_code= 401	
							@client_track_image.image_code= 102							
							@client_track_image.save
						rescue							
							#Error Comment
						end								
					end	
				end
				
				# begin
					# alert_message= "New coach tip added on " + @client_track.track_name.to_s + " track"
					# ApnsController::send_group_notification(alert_message, @client_track.fk_client_id)
				# rescue 	=> ex
					# logger.error "erro: #{ex.class} , #{ex.message}"
				# end	
			
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
			#render :json => params
			#return
									
			small_thumb_image_width=Protrack::Configuration['small_thumb_image_width'].to_s			
			small_thumb_image_height=Protrack::Configuration['small_thumb_image_height'].to_s				
			med_thumb_image_width=Protrack::Configuration['med_thumb_image_width'].to_s	
			med_thumb_image_height=Protrack::Configuration['med_thumb_image_height'].to_s	
		
			@client_track=ClientTrack.new	
			@client_track.fk_client_id=params[:client_track][:fk_client_id]				
						
			@client_track.display_id=params[:client_track][:display_id]
			@client_track.track_name=params[:client_track][:track_name]
			@client_track.track_tip=params[:client_track][:track_tip]
			@client_track.no_turns=params[:client_track][:no_turns]
			@client_track.fk_product_id=params[:client_track][:fk_product_id]
			@client_track.description=params[:client_track][:description] 
			@client_track.status_code=401
			@client_track.create_ip=request.remote_ip 	
			@client_track.last_updated_ip=request.remote_ip
		    @client_track.platform_code=300
			#@client_track.fk_product_id=params[:price]
			
			client_path="/assets/images/client/client_" + @client_track.fk_client_id.to_s + ""
			dir= File.join(Rails.root, "app", client_path)
			Dir.mkdir(dir) unless File.exists?(dir)
			
			if (params[:client_track][:track_image].blank? == false)
				track_image_filename_=params[:client_track][:track_image].original_filename.to_s 		
				track_img_name=track_image_filename_.split('/').last
				track_img_extn=track_img_name.split('.').last
				track_newfilename = "#{(Time.now.to_i.to_s + Time.now.usec.to_s).ljust(16, '0')}"
				track_newfilename = track_newfilename + '.' + track_img_extn
				
				image_path="/assets/images/client/client_" + @client_track.fk_client_id.to_s + "/track_images/"						
				save_file_url(params[:client_track][:track_image],track_newfilename, image_path)
							
				small_image_path="/assets/images/client/client_" + @client_track.fk_client_id.to_s + "/track_images/small_track_images/"						
				save_thumb_file_url(image_path,track_newfilename, small_image_path, small_thumb_image_width, small_thumb_image_height)
				
				medium_image_path="/assets/images/client/client_" + @client_track.fk_client_id.to_s + "/track_images/med_track_images/"						
				save_thumb_file_url(image_path,track_newfilename, medium_image_path, med_thumb_image_width, med_thumb_image_height)
					
				public_url_image_path="/assets/client/client_" + @client_track.fk_client_id.to_s + "/track_images/"	
				public_url_small_image_path="/assets/client/client_" + @client_track.fk_client_id.to_s + "/track_images/small_track_images/"
				public_url_med_image_path="/assets/client/client_" + @client_track.fk_client_id.to_s + "/track_images/med_track_images/"
				
				@client_track.track_image= public_url_image_path + track_newfilename
				@client_track.small_track_image= public_url_small_image_path + track_newfilename
				@client_track.med_track_image= public_url_med_image_path + track_newfilename
			end
					
			if (params[:client_track][:track_info_image].blank? == false)
				track_info_image_filename_=params[:client_track][:track_info_image].original_filename.to_s 		
				track_info_img_name=track_info_image_filename_.split('/').last
				track_info_img_extn=track_info_img_name.split('.').last
				track_info_newfilename = "#{(Time.now.to_i.to_s + Time.now.usec.to_s).ljust(16, '0')}"
				track_info_newfilename = track_info_newfilename + '.' + track_info_img_extn
			
				info_image_path="/assets/images/client/client_" + @client_track.fk_client_id.to_s + "/track_info_images/"						
				save_file_url(params[:client_track][:track_info_image],track_info_newfilename, info_image_path)
							
				small_info_image_path="/assets/images/client/client_" + @client_track.fk_client_id.to_s + "/track_info_images/small_track_info_images/"						
				save_thumb_file_url(info_image_path, track_info_newfilename, small_info_image_path, small_thumb_image_width, small_thumb_image_height)
				
				medium_info_image_path="/assets/images/client/client_" + @client_track.fk_client_id.to_s + "/track_info_images/med_track_info_images/"						
				save_thumb_file_url(info_image_path, track_info_newfilename, medium_info_image_path, med_thumb_image_width, med_thumb_image_height)
					
				public_url_info_image_path="/assets/client/client_" + @client_track.fk_client_id.to_s + "/track_info_images/"	
				public_url_small_info_image_path="/assets/client/client_" + @client_track.fk_client_id.to_s + "/track_info_images/small_track_info_images/"
				public_url_med_info_image_path="/assets/client/client_" + @client_track.fk_client_id.to_s + "/track_info_images/med_track_info_images/"
				
				@client_track.track_info_image= public_url_info_image_path + track_info_newfilename
				@client_track.small_track_info_image= public_url_small_info_image_path + track_info_newfilename
				@client_track.med_track_info_image= public_url_med_info_image_path + track_info_newfilename					
			end
					
			if @client_track.valid? == false
				render :action => "add"
				return
			end
					
			if @client_track.save!		
				if (params[:client_track][:extra_image].blank? == false)
					params[:client_track][:extra_image].each do |extra_image|	
						begin
							@client_track_image=ClientTrackImage.new
							
							image_filename= extra_image.original_filename.to_s 		
							image_name=image_filename.split('/').last
							image_extn=image_name.split('.').last
							newfilename = "#{(Time.now.to_i.to_s + Time.now.usec.to_s).ljust(16, '0')}"
							newfilename = newfilename + '.' + image_extn
							
							#render :json => newfilename
							#return
							
							image_path="/assets/images/client/client_" + @client_track.fk_client_id.to_s + "/track_images/extra_track_images/"						
							save_file_url(extra_image,newfilename, image_path)							
							public_url_image_path="/assets/client/client_" + @client_track.fk_client_id.to_s + "/track_images/extra_track_images/"					
							
							#render :json => public_url_image_path
							#return
							
							@client_track_image.track_image= public_url_image_path + newfilename	
							@client_track_image.fk_track_id= @client_track.id	
							@client_track_image.status_code= 401
							#render :json => @client_track_image
							#return
							@client_track_image.save
						rescue							
							#Error Comment
						end								
					end				
				end	
				
				if (params[:client_track][:track_overview_page_image].blank? == false)
					params[:client_track][:track_overview_page_image].each do |track_overview_page_image|	
						begin
							@client_track_image=ClientTrackImage.new
							
							image_filename= track_overview_page_image.original_filename.to_s 		
							image_name=image_filename.split('/').last
							image_extn=image_name.split('.').last
							newfilename = "#{(Time.now.to_i.to_s + Time.now.usec.to_s).ljust(16, '0')}"
							newfilename = newfilename + '.' + image_extn
													
							image_path="/assets/images/client/client_" + @client_track.fk_client_id.to_s + "/track_images/info_track_images/"						
							save_file_url(track_overview_page_image,newfilename, image_path)							
							public_url_image_path="/assets/client/client_" + @client_track.fk_client_id.to_s + "/track_images/info_track_images/"					
														
							@client_track_image.track_image= public_url_image_path + newfilename	
							@client_track_image.fk_track_id= @client_track.id	
							@client_track_image.status_code= 401	
							@client_track_image.image_code= 102							
							@client_track_image.save
						rescue							
							#Error Comment
						end								
					end	
				end
				
				# begin
					# alert_message= "New coach tip added on " + @client_track.track_name.to_s + " track"
					# ApnsController::send_group_notification(alert_message, @client_track.fk_client_id)
				# rescue 	=> ex
					# logger.error "erro: #{ex.class} , #{ex.message}"
				# end
				
								
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
		client_id = session[:client_id] ||  0		
		admin_id=session[:admin_id] || 0
			
		if (admin_id.to_i > 0 )
			client_id = session[:proxy_client_id] || 0 						
		end
		
		@client_track=ClientTrack.get_selected_tracks(client_id.to_i, params[:id])
	
		if @client_track.nil? == true
			render_error :error_code => 'e375'
			redirect_to :action => 'index'
			return	
		end
		
		@client_track_image=ClientTrackImage.where("image_code in(0,101) and status_code=401 and fk_track_id=" + @client_track.id.to_s)	
		@client_track_info_image=ClientTrackImage.where("image_code in(102) and status_code=401 and fk_track_id=" + @client_track.id.to_s)				
		
		render :action => "edit", :layout => "common_layout"
	end
	
	def delete_track_extra_image_ajax
		begin
			@client_track_image=ClientTrackImage.find(params[:id])
			
			if @client_track_image.nil? == true
				render :json => {:resp_code => "411", :message => "Track extra image data is not valid. Please try again." + @track_turn_note.errors.to_json}
				return
			end
			
			@client_track_image.status_code=403
			
			if @client_track_image.valid? == false   				
				render :json => {:resp_code => "412", :message => "Track extra image data is not valid. Please try again." + @track_turn_note.errors.to_json}
				return
			end
	
			if @client_track_image.save!
				render :json => {:resp_code => "200", :message => "Track extra image data is sucessfully saved."}
				return
			else
				render :json => {:resp_code => "413", :message => "Track extra image data is not valid. Please try again."}
				return
			end				
		rescue => ex
		    logger.error "erro: #{ex.class} , #{ex.message}"		
			render :json => {:resp_code => "414", :message => "Track extra image data is not valid. Please try again. error: #{ex.message}"}
			return
		end			
		render :json => {:resp_code => "415", :message => "Track extra image have problem. Please try again."}	
	end
	
	def view				
    	client_id=session[:client_id] || 0
		admin_id=session[:admin_id] || 0
		if (admin_id.to_i > 0 )
			client_id = session[:proxy_client_id] || 0 						
		end
		
		@client_track=ClientTrack.get_selected_tracks(client_id.to_i, params[:id].to_i)
		if @client_track.nil? == true
			render_error :error_code => 'e375'
			redirect_to :action => 'index'
			return	
		end
		
		#@client_track_image=ClientTrackImage.where("status_code=401 and fk_track_id=" + @client_track.id.to_s)
		@client_track_image=ClientTrackImage.where("image_code in(0,101) and status_code=401 and fk_track_id=" + @client_track.id.to_s)	
		@client_track_info_image=ClientTrackImage.where("image_code in(102) and status_code=401 and fk_track_id=" + @client_track.id.to_s)				
		
		render :action => "view", :layout => "common_layout"
	end
		
	def update_ajax
		begin
			#render :json => params
			#return
				
			small_thumb_image_width=Protrack::Configuration['small_thumb_image_width'].to_s			
			small_thumb_image_height=Protrack::Configuration['small_thumb_image_height'].to_s				
			med_thumb_image_width=Protrack::Configuration['med_thumb_image_width'].to_s	
			med_thumb_image_height=Protrack::Configuration['med_thumb_image_height'].to_s	
		
			@client_track=ClientTrack.find(params[:id])
			
			@client_track.display_id=params[:client_track][:display_id]
			@client_track.track_name=params[:client_track][:track_name]
			@client_track.track_tip=params[:client_track][:track_tip]
			@client_track.no_turns=params[:client_track][:no_turns]
			@client_track.fk_product_id=params[:client_track][:fk_product_id]
			@client_track.last_updated_ip=request.remote_ip
			@client_track.description=params[:client_track][:description]
			@client_track.timing_url=params[:client_track][:timing_url]
			@client_track.media_url=params[:client_track][:media_url]
			@client_track.weather_url=params[:client_track][:weather_url]
			@client_track.lap_video_url=params[:client_track][:lap_video_url]
			# @client_track.schedule_pdf_url=params[:client_track][:schedule_pdf_url]
			@client_track.note=params[:client_track][:note]
		
			#@client_track.fk_product_id=params[:price]
			client_path="/assets/images/client/client_" + @client_track.fk_client_id.to_s + ""
			dir= File.join(Rails.root, "app", client_path)
			Dir.mkdir(dir) unless File.exists?(dir)
			
			if (params[:client_track][:track_image].blank? == false)
				track_image_filename_=params[:client_track][:track_image].original_filename.to_s 		
				track_img_name=track_image_filename_.split('/').last
				track_img_extn=track_img_name.split('.').last
				track_newfilename = "#{(Time.now.to_i.to_s + Time.now.usec.to_s).ljust(16, '0')}"
				track_newfilename = track_newfilename + '.' + track_img_extn
				
				image_path="/assets/images/client/client_" + @client_track.fk_client_id.to_s + "/track_images/"						
				save_file_url(params[:client_track][:track_image],track_newfilename, image_path)
							
				small_image_path="/assets/images/client/client_" + @client_track.fk_client_id.to_s + "/track_images/small_track_images/"						
				save_thumb_file_url(image_path,track_newfilename, small_image_path, small_thumb_image_width, small_thumb_image_height)
				
				medium_image_path="/assets/images/client/client_" + @client_track.fk_client_id.to_s + "/track_images/med_track_images/"						
				save_thumb_file_url(image_path,track_newfilename, medium_image_path, med_thumb_image_width, med_thumb_image_height)
					
				public_url_image_path="/assets/client/client_" + @client_track.fk_client_id.to_s + "/track_images/"	
				public_url_small_image_path="/assets/client/client_" + @client_track.fk_client_id.to_s + "/track_images/small_track_images/"
				public_url_med_image_path="/assets/client/client_" + @client_track.fk_client_id.to_s + "/track_images/med_track_images/"
				
				@client_track.track_image= public_url_image_path + track_newfilename
				@client_track.small_track_image= public_url_small_image_path + track_newfilename
				@client_track.med_track_image= public_url_med_image_path + track_newfilename
			end

			unless params[:client_track][:schedule_pdf_url].nil?
				track_image_filename_=params[:client_track][:schedule_pdf_url].original_filename.to_s
				track_img_name=track_image_filename_.split('/').last
				track_img_extn=track_img_name.split('.').last
				if @client_track.track_name.nil?
					track_newfilename = "Schedule_pdf_#{(Time.now.strftime('%y%m%d'))}}"
				else
					track_newfilename = "Schedule_pdf_#{(Time.now.strftime('%y%m%d'))}_#{@client_track.track_name.split(' ').join('_') }"
				end
				track_newfilename = track_newfilename + '.' + track_img_extn
				schedule_pdf_path="/assets/images/client/client_" + @client_track.fk_client_id.to_s + "/schedule_pdf/"
				save_file_url(params[:client_track][:schedule_pdf_url],track_newfilename, schedule_pdf_path)
				public_url_image_path="/assets/client/client_" + @client_track.fk_client_id.to_s + "/schedule_pdf/"

				@client_track.schedule_pdf_url= public_url_image_path + track_newfilename

			end
					
			 if (params[:client_track][:track_info_image].blank? == false)
				track_info_image_filename_=params[:client_track][:track_info_image].original_filename.to_s 		
				track_info_img_name=track_info_image_filename_.split('/').last
				track_info_img_extn=track_info_img_name.split('.').last
				track_info_newfilename = "#{(Time.now.to_i.to_s + Time.now.usec.to_s).ljust(16, '0')}"
				track_info_newfilename = track_info_newfilename + '.' + track_info_img_extn
			
				info_image_path="/assets/images/client/client_" + @client_track.fk_client_id.to_s + "/track_info_images/"						
				save_file_url(params[:client_track][:track_info_image],track_info_newfilename, info_image_path)
							
				small_info_image_path="/assets/images/client/client_" + @client_track.fk_client_id.to_s + "/track_info_images/small_track_info_images/"						
				save_thumb_file_url(info_image_path, track_info_newfilename, small_info_image_path, small_thumb_image_width, small_thumb_image_height)
				
				medium_info_image_path="/assets/images/client/client_" + @client_track.fk_client_id.to_s + "/track_info_images/med_track_info_images/"						
				save_thumb_file_url(info_image_path, track_info_newfilename, medium_info_image_path, med_thumb_image_width, med_thumb_image_height)
					
				public_url_info_image_path="/assets/client/client_" + @client_track.fk_client_id.to_s + "/track_info_images/"	
				public_url_small_info_image_path="/assets/client/client_" + @client_track.fk_client_id.to_s + "/track_info_images/small_track_info_images/"
				public_url_med_info_image_path="/assets/client/client_" + @client_track.fk_client_id.to_s + "/track_info_images/med_track_info_images/"
				
				@client_track.track_info_image= public_url_info_image_path + track_info_newfilename
				@client_track.small_track_info_image= public_url_small_info_image_path + track_info_newfilename
				@client_track.med_track_info_image= public_url_med_info_image_path + track_info_newfilename					
			 end
						
			if @client_track.valid? == false  				
				error_messages=""
				if @client_track.errors.full_messages.length >0
					@client_track.errors.full_messages.each do |msg|
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
			 				
			if @client_track.save!
				if (params[:client_track][:extra_image].blank? == false)
					params[:client_track][:extra_image].each do |extra_image|	
						begin
							@client_track_image=ClientTrackImage.new
							
							image_filename= extra_image.original_filename.to_s 		
							image_name=image_filename.split('/').last
							image_extn=image_name.split('.').last
							newfilename = "#{(Time.now.to_i.to_s + Time.now.usec.to_s).ljust(16, '0')}"
							newfilename = newfilename + '.' + image_extn
													
							image_path="/assets/images/client/client_" + @client_track.fk_client_id.to_s + "/track_images/extra_track_images/"						
							save_file_url(extra_image,newfilename, image_path)							
							public_url_image_path="/assets/client/client_" + @client_track.fk_client_id.to_s + "/track_images/extra_track_images/"					
														
							@client_track_image.track_image= public_url_image_path + newfilename	
							@client_track_image.fk_track_id= @client_track.id	
							@client_track_image.status_code= 401
							@client_track_image.image_code= 101		
							@client_track_image.save
						rescue							
							#Error Comment
						end								
					end	
				end
				if (params[:client_track][:track_overview_page_image].blank? == false)
					params[:client_track][:track_overview_page_image].each do |track_overview_page_image|	
						begin
							@client_track_image=ClientTrackImage.new
							
							image_filename= track_overview_page_image.original_filename.to_s 		
							image_name=image_filename.split('/').last
							image_extn=image_name.split('.').last
							newfilename = "#{(Time.now.to_i.to_s + Time.now.usec.to_s).ljust(16, '0')}"
							newfilename = newfilename + '.' + image_extn
													
							image_path="/assets/images/client/client_" + @client_track.fk_client_id.to_s + "/track_images/info_track_images/"						
							save_file_url(track_overview_page_image,newfilename, image_path)							
							public_url_image_path="/assets/client/client_" + @client_track.fk_client_id.to_s + "/track_images/info_track_images/"					
														
							@client_track_image.track_image= public_url_image_path + newfilename	
							@client_track_image.fk_track_id= @client_track.id	
							@client_track_image.status_code= 401	
							@client_track_image.image_code= 102							
							@client_track_image.save
						rescue							
							#Error Comment
						end								
					end	
				end
				
				# begin
					# alert_message= "Update coach tip on " + @client_track.track_name.to_s + " track"
					# ApnsController::send_group_notification(alert_message, @client_track.fk_client_id)
				# rescue 	=> ex
					# #render :json => "erro: #{ex.class} , #{ex.message}"
					# #return
					# logger.error "erro: #{ex.class} , #{ex.message}"
				# end
				
				render :json => {:resp_code => "200", :message => "Track is successfully updated."}				
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
	
	def update
		begin
			#render :json => params
			#return
				
			small_thumb_image_width=Protrack::Configuration['small_thumb_image_width'].to_s			
			small_thumb_image_height=Protrack::Configuration['small_thumb_image_height'].to_s				
			med_thumb_image_width=Protrack::Configuration['med_thumb_image_width'].to_s	
			med_thumb_image_height=Protrack::Configuration['med_thumb_image_height'].to_s	
		
			@client_track=ClientTrack.find(params[:id])
			
			@client_track.display_id=params[:client_track][:display_id]
			@client_track.track_name=params[:client_track][:track_name]
			@client_track.track_tip=params[:client_track][:track_tip]
			@client_track.no_turns=params[:client_track][:no_turns]
			@client_track.fk_product_id=params[:client_track][:fk_product_id]
			@client_track.last_updated_ip=request.remote_ip
			@client_track.description=params[:client_track][:description] 
		
			#@client_track.fk_product_id=params[:price]
			client_path="/assets/images/client/client_" + @client_track.fk_client_id.to_s + ""
			dir= File.join(Rails.root, "app", client_path)
			Dir.mkdir(dir) unless File.exists?(dir)
			
			if (params[:client_track][:track_image].blank? == false)
				track_image_filename_=params[:client_track][:track_image].original_filename.to_s 		
				track_img_name=track_image_filename_.split('/').last
				track_img_extn=track_img_name.split('.').last
				track_newfilename = "#{(Time.now.to_i.to_s + Time.now.usec.to_s).ljust(16, '0')}"
				track_newfilename = track_newfilename + '.' + track_img_extn
				
				image_path="/assets/images/client/client_" + @client_track.fk_client_id.to_s + "/track_images/"						
				save_file_url(params[:client_track][:track_image],track_newfilename, image_path)
							
				small_image_path="/assets/images/client/client_" + @client_track.fk_client_id.to_s + "/track_images/small_track_images/"						
				save_thumb_file_url(image_path,track_newfilename, small_image_path, small_thumb_image_width, small_thumb_image_height)
				
				medium_image_path="/assets/images/client/client_" + @client_track.fk_client_id.to_s + "/track_images/med_track_images/"						
				save_thumb_file_url(image_path,track_newfilename, medium_image_path, med_thumb_image_width, med_thumb_image_height)
					
				public_url_image_path="/assets/client/client_" + @client_track.fk_client_id.to_s + "/track_images/"	
				public_url_small_image_path="/assets/client/client_" + @client_track.fk_client_id.to_s + "/track_images/small_track_images/"
				public_url_med_image_path="/assets/client/client_" + @client_track.fk_client_id.to_s + "/track_images/med_track_images/"
				
				@client_track.track_image= public_url_image_path + track_newfilename
				@client_track.small_track_image= public_url_small_image_path + track_newfilename
				@client_track.med_track_image= public_url_med_image_path + track_newfilename
			end
					
			if (params[:client_track][:track_info_image].blank? == false)
				track_info_image_filename_=params[:client_track][:track_info_image].original_filename.to_s 		
				track_info_img_name=track_info_image_filename_.split('/').last
				track_info_img_extn=track_info_img_name.split('.').last
				track_info_newfilename = "#{(Time.now.to_i.to_s + Time.now.usec.to_s).ljust(16, '0')}"
				track_info_newfilename = track_info_newfilename + '.' + track_info_img_extn
			
				info_image_path="/assets/images/client/client_" + @client_track.fk_client_id.to_s + "/track_info_images/"						
				save_file_url(params[:client_track][:track_info_image],track_info_newfilename, info_image_path)
							
				small_info_image_path="/assets/images/client/client_" + @client_track.fk_client_id.to_s + "/track_info_images/small_track_info_images/"						
				save_thumb_file_url(info_image_path, track_info_newfilename, small_info_image_path, small_thumb_image_width, small_thumb_image_height)
				
				medium_info_image_path="/assets/images/client/client_" + @client_track.fk_client_id.to_s + "/track_info_images/med_track_info_images/"						
				save_thumb_file_url(info_image_path, track_info_newfilename, medium_info_image_path, med_thumb_image_width, med_thumb_image_height)
					
				public_url_info_image_path="/assets/client/client_" + @client_track.fk_client_id.to_s + "/track_info_images/"	
				public_url_small_info_image_path="/assets/client/client_" + @client_track.fk_client_id.to_s + "/track_info_images/small_track_info_images/"
				public_url_med_info_image_path="/assets/client/client_" + @client_track.fk_client_id.to_s + "/track_info_images/med_track_info_images/"
				
				@client_track.track_info_image= public_url_info_image_path + track_info_newfilename
				@client_track.small_track_info_image= public_url_small_info_image_path + track_info_newfilename
				@client_track.med_track_info_image= public_url_med_info_image_path + track_info_newfilename					
			end
			
			#render :json => @client_track.valid?
			#return
			
			if @client_track.valid? == false  
				#@client_track.product_id=params[:client_track][:product_id]
				#@client_track_image=ClientTrackImage.where("status_code=401 and fk_track_id=" + @client_track.id.to_s)		
				
				@client_track_image=ClientTrackImage.where("image_code in(0,101) and status_code=401 and fk_track_id=" + @client_track.id.to_s)	
				@client_track_info_image=ClientTrackImage.where("image_code in(102) and status_code=401 and fk_track_id=" + @client_track.id.to_s)				
		
				render :action => 'edit', :id => params[:id]
				return		    
			 end	
			 				
			if @client_track.save!
				if (params[:client_track][:extra_image].blank? == false)
					params[:client_track][:extra_image].each do |extra_image|	
						begin
							@client_track_image=ClientTrackImage.new
							
							image_filename= extra_image.original_filename.to_s 		
							image_name=image_filename.split('/').last
							image_extn=image_name.split('.').last
							newfilename = "#{(Time.now.to_i.to_s + Time.now.usec.to_s).ljust(16, '0')}"
							newfilename = newfilename + '.' + image_extn
							
							image_path="/assets/images/client/client_" + @client_track.fk_client_id.to_s + "/track_images/extra_track_images/"						
							save_file_url(extra_image,newfilename, image_path)							
							public_url_image_path="/assets/client/client_" + @client_track.fk_client_id.to_s + "/track_images/extra_track_images/"					
														
							@client_track_image.track_image= public_url_image_path + newfilename	
							@client_track_image.fk_track_id= @client_track.id	
							@client_track_image.status_code= 401
							@client_track_image.image_code= 101											
							@client_track_image.save
						rescue							
							#Error Comment
						end								
					end	
				end
				
				if (params[:client_track][:track_overview_page_image].blank? == false)
					params[:client_track][:track_overview_page_image].each do |track_overview_page_image|	
						begin
							@client_track_image=ClientTrackImage.new
							
							image_filename= track_overview_page_image.original_filename.to_s 		
							image_name=image_filename.split('/').last
							image_extn=image_name.split('.').last
							newfilename = "#{(Time.now.to_i.to_s + Time.now.usec.to_s).ljust(16, '0')}"
							newfilename = newfilename + '.' + image_extn
													
							image_path="/assets/images/client/client_" + @client_track.fk_client_id.to_s + "/track_images/info_track_images/"						
							save_file_url(track_overview_page_image,newfilename, image_path)							
							public_url_image_path="/assets/client/client_" + @client_track.fk_client_id.to_s + "/track_images/info_track_images/"					
														
							@client_track_image.track_image= public_url_image_path + newfilename	
							@client_track_image.fk_track_id= @client_track.id	
							@client_track_image.status_code= 401	
							@client_track_image.image_code= 102							
							@client_track_image.save
						rescue							
							#Error Comment
						end								
					end	
				end
				
				# begin
					# alert_message= "Update coach tip on " + @client_track.track_name.to_s + " track"
					# ApnsController::send_group_notification(alert_message, @client_track.fk_client_id)
				# rescue 	=> ex
					# logger.error "erro: #{ex.class} , #{ex.message}"
				# end
				
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
			@client_track=ClientTrack.find(params[:id])
			
			if @client_track.nil? == true
				render_error :error_code => 'e375'
				redirect_to :action => 'index'
				return	
			end
		
			@client_track.status_code=403 # record delete : 403
			
			if @client_track.save!
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
