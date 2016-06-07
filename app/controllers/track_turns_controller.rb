require 'net/http'
require 'uri'

class TrackTurnsController < ApplicationController
	skip_before_filter :require_login, :only => [:create_ajax, :dot_position_save_ajax]
	
	def index
		client_id=session[:client_id] || 0
		admin_id=session[:admin_id] || 0
		if (admin_id.to_i > 0 )
			client_id = session[:proxy_client_id] || 0 						
		end
		
		@client_track=ClientTrack.get_selected_tracks(client_id.to_i, params[:id])
		@track_turn_notes=TrackTurnNote.get_selected_track_turns(client_id.to_i, params[:id])	
		@track_image={}
	    	
		file_name= @client_track.track_image.to_s
		file_name= file_name.gsub('assets','assets/images')
		image_path = File.join(Rails.root, "app", file_name)			
		image = MiniMagick::Image.open(image_path)
		@track_image['width'] = image[:width]
		@track_image['height'] =  image[:height]
		
		@new_turn=TrackTurnNote.new
		@new_turn.fk_client_id=client_id
		@new_turn.fk_track_id=params[:id]
		render :action => "index", :layout => "common_layout"
	end
	
	def add		
		render :action => "add", :layout => "common_layout"
	end	
	
	def create_ajax 
		begin		
			#logger.error params	 
 
			#render :json => { :resp_code => "400", :message => params.to_s }
			#return
			
			client_id=session[:client_id] || 0	
			admin_id=session[:admin_id] || 0
			if (admin_id.to_i > 0 )
				client_id = session[:proxy_client_id] || 0 						
			end
		
			@track_turn_note=TrackTurnNote.new		
			
			@track_turn_note.fk_client_id=params[:track_turn_note][:fk_client_id]
	     	@track_turn_note.fk_track_id=params[:track_turn_note][:fk_track_id]
		    @track_turn_note.status_code = "402"
			
			@track_turn_note.x_pos = params[:track_turn_note][:x_pos]			
			@track_turn_note.y_pos = params[:track_turn_note][:y_pos]	
			
			@track_turn_note.last_updated_ip = request.remote_ip
			@track_turn_note.create_ip = request.remote_ip
			
			@track_turn_note.fk_plactype_id = params[:track_turn_note][:fk_plactype_id]
			@track_turn_note.tn_step_id = params[:track_turn_note][:tn_step_id]
			@track_turn_note.tn_name = params[:track_turn_note][:tn_name]
			@track_turn_note.tn_video = params[:track_turn_note][:tn_video]
			@track_turn_note.tn_data = params[:track_turn_note][:tn_data]
			@track_turn_note.tn_type = params[:track_turn_note][:tn_type]
			@track_turn_note.tn_strategy = params[:track_turn_note][:tn_strategy]
			
			@track_turn_note.tn_marker = params[:track_turn_note][:tn_marker]
			@track_turn_note.tn_note = params[:track_turn_note][:tn_note]
			
			@track_turn_note.sort_no =TrackTurnNote.get_turn_last_sort_no(params[:track_turn_note][:fk_client_id],params[:track_turn_note][:fk_track_id])
			#render :json => @track_turn_note
			#return
			
			if (params[:track_turn_note][:tn_picture].blank? == false)
				image_filename_=params[:track_turn_note][:tn_picture].original_filename.to_s 		
				img_name=image_filename_.split('/').last
				img_extn=img_name.split('.').last
				newfilename = "#{(Time.now.to_i.to_s + Time.now.usec.to_s).ljust(16, '0')}"
				newfilename = newfilename + '.' + img_extn
				
				image_path="/assets/images/client/client_" + @track_turn_note.fk_client_id.to_s + "/turn_pictures/"						
				save_file_url(params[:track_turn_note][:tn_picture],newfilename, image_path)			
				public_url_image_path="/assets/client/client_" + @track_turn_note.fk_client_id.to_s + "/turn_pictures/"				
				@track_turn_note.tn_picture= public_url_image_path + newfilename			
			end			
			
			#render :json => {:resp_code => "200", :message => @track_turn_note.tn_picture}			
			#return
	
			if @track_turn_note.valid? == false   		
				error_messages=""
				if @track_turn_note.errors.full_messages.length >0
					@track_turn_note.errors.full_messages.each do |msg|
						if error_messages.empty? == false
							error_messages =  error_messages + ", \n "
						else
							error_messages =  error_messages + " \n "
						end
						error_messages =  error_messages +  msg
					end
				end
				render :json => {:resp_code => "401", :message => "Errors: " + error_messages}
				#render :json => {:resp_code => "401", :message => "Track turn data is not valid. Please try again." + @track_turn_note.errors.to_json}
				return
			end
	
			if @track_turn_note.save!
				if (params[:track_turn_note][:turn_info_image].blank? == false)
					params[:track_turn_note][:turn_info_image].each do |turn_info_image|	
						begin
							@track_turn_image=TrackTurnImage.new
							
							image_filename= turn_info_image.original_filename.to_s 		
							image_name=image_filename.split('/').last
							image_extn=image_name.split('.').last
							newfilename = "#{(Time.now.to_i.to_s + Time.now.usec.to_s).ljust(16, '0')}"
							newfilename = newfilename + '.' + image_extn
													
							image_path="/assets/images/client/client_" + @track_turn_note.fk_client_id.to_s + "/turn_pictures/info_turn_images/"						
							save_file_url(turn_info_image,newfilename, image_path)							
							public_url_image_path="/assets/client/client_" + @track_turn_note.fk_client_id.to_s + "/turn_pictures/info_turn_images/"					
														
							@track_turn_image.turn_image= public_url_image_path + newfilename	
							@track_turn_image.fk_tn_id= @track_turn_note.id	
							@track_turn_image.status_code= 401	
							@track_turn_image.image_code= 201							
							@track_turn_image.save
						rescue							
							#Error Comment
						end								
					end	
				end
				
				begin
					alert_message= "New coach tip added on " + @track_turn_note.tn_name.to_s + " turn"
					#server_base=Protrack::Configuration['domain_url'];										
					#data = { "alert_message" => alert_message, "client_id" => @track_turn_note.fk_client_id.to_s }
										
					#uri = URI(server_base + "apns/send_group_notification_params");
					#res = Net::HTTP.post_form(uri, data)
									
					Thread.new do
						ApnsController::send_group_notification(alert_message, @track_turn_note.fk_client_id)
					end
					#ApnsController::send_group_notification(alert_message, @track_turn_note.fk_client_id)
				rescue 	=> ex
					logger.error "erro: #{ex.class} , #{ex.message}"
				end	
				
				render :json => {:resp_code => "200", :message => "Track turn data is sucessfully saved.",
				:id => @track_turn_note.id, :turn_name =>  @track_turn_note.tn_name, 
				:step_id => @track_turn_note.tn_step_id}
				return
			else
				render :json => {:resp_code => "402", :message => "Track turn data is not valid. Please try again."}
				return
			end
				
		rescue => ex
		    logger.error "erro: #{ex.class} , #{ex.message}"		
			render :json => {:resp_code => "403", :message => "Track turn data is not valid. Please try again. error: #{ex.message}"}
			return
		end			
		render :json => {:resp_code => "404", :message => "Track turn data is not valid. Please try again."}
	end	
		
	def edit		
		client_id=session[:client_id] || 0		
		admin_id=session[:admin_id] || 0
		if (admin_id.to_i > 0 )
			client_id = session[:proxy_client_id] || 0 						
		end
		
		@track_turn_note=TrackTurnNote.get_turn_info(client_id.to_i, params[:id])
		@turn_info_image=TrackTurnImage.where("image_code in(201) and status_code=401 and fk_tn_id=" + @track_turn_note.id.to_s)				
			
		render :action => "edit", :layout => "common_layout"
	end
	
	def delete_turn_image_ajax
		begin
			@turn_info_image=TrackTurnImage.find(params[:id])
			
			if @turn_info_image.nil? == true
				render :json => {:resp_code => "411", :message => "Turn image data is not valid. Please try again." + @turn_info_image.errors.to_json}
				return
			end
			
			@turn_info_image.status_code=403
			
			if @turn_info_image.valid? == false   				
				render :json => {:resp_code => "412", :message => "Turn image data is not valid. Please try again." + @turn_info_image.errors.to_json}
				return
			end
	
			if @turn_info_image.save!
				render :json => {:resp_code => "200", :message => "Turn image data is sucessfully processed."}
				return
			else
				render :json => {:resp_code => "413", :message => "Turn image data is not valid. Please try again."}
				return
			end				
		rescue => ex
		    logger.error "erro: #{ex.class} , #{ex.message}"		
			render :json => {:resp_code => "414", :message => "Turn image data is not valid. Please try again. error: #{ex.message}"}
			return
		end			
		render :json => {:resp_code => "415", :message => "Turn image have problem. Please try again."}	
	end	
	
	def update 
		@turn_info_image=TrackTurnImage.where("image_code in(201) and status_code=401 and fk_tn_id=" + params[:id].to_s)				
		begin						
			client_id=session[:client_id] || 0		
			admin_id=session[:admin_id] || 0
			if (admin_id.to_i > 0 )
				client_id = session[:proxy_client_id] || 0 						
			end
			

			@track_turn_note=TrackTurnNote.find(params[:id])

			@original_coach_tip = @track_turn_note.tn_data			
			
			@track_turn_note.last_updated_ip = request.remote_ip
			
			@track_turn_note.fk_plactype_id = params[:track_turn_note][:fk_plactype_id]
			@track_turn_note.tn_step_id = params[:track_turn_note][:tn_step_id]
			@track_turn_note.tn_name = params[:track_turn_note][:tn_name]
			@track_turn_note.tn_video = params[:track_turn_note][:tn_video]
			@track_turn_note.tn_data = params[:track_turn_note][:tn_data]
			@track_turn_note.tn_type = params[:track_turn_note][:tn_type]
			@track_turn_note.tn_strategy = params[:track_turn_note][:tn_strategy]
			
			@track_turn_note.tn_marker = params[:track_turn_note][:tn_marker]
			@track_turn_note.tn_note = params[:track_turn_note][:tn_note]
					
			if (params[:track_turn_note][:tn_picture].blank? == false)
				image_filename_=params[:track_turn_note][:tn_picture].original_filename.to_s 		
				img_name=image_filename_.split('/').last
				img_extn=img_name.split('.').last
				newfilename = "#{(Time.now.to_i.to_s + Time.now.usec.to_s).ljust(16, '0')}"
				newfilename = newfilename + '.' + img_extn
				
				image_path="/assets/images/client/client_" + @track_turn_note.fk_client_id.to_s + "/turn_pictures/"						
				save_file_url(params[:track_turn_note][:tn_picture],newfilename, image_path)			
				public_url_image_path="/assets/client/client_" + @track_turn_note.fk_client_id.to_s + "/turn_pictures/"				
				@track_turn_note.tn_picture= public_url_image_path + newfilename			
			end			
		
			if @track_turn_note.valid? == false 
				render :action => "edit", :id => params[:id]
				return
			end
	
			if @track_turn_note.save!
				if (params[:track_turn_note][:turn_info_image].blank? == false)
					params[:track_turn_note][:turn_info_image].each do |turn_info_image|	
						begin
							@track_turn_image=TrackTurnImage.new
							
							image_filename= turn_info_image.original_filename.to_s 		
							image_name=image_filename.split('/').last
							image_extn=image_name.split('.').last
							newfilename = "#{(Time.now.to_i.to_s + Time.now.usec.to_s).ljust(16, '0')}"
							newfilename = newfilename + '.' + image_extn
													
							image_path="/assets/images/client/client_" + @track_turn_note.fk_client_id.to_s + "/turn_pictures/info_turn_images/"						
							save_file_url(turn_info_image,newfilename, image_path)							
							public_url_image_path="/assets/client/client_" + @track_turn_note.fk_client_id.to_s + "/turn_pictures/info_turn_images/"					
														
							@track_turn_image.turn_image= public_url_image_path + newfilename	
							@track_turn_image.fk_tn_id= @track_turn_note.id	
							@track_turn_image.status_code= 401	
							@track_turn_image.image_code= 201							
							@track_turn_image.save
						rescue							
							#Error Comment
						end								
					end	
				end
				
				begin

					if @track_turn_note.tn_data != @original_coach_tip
						alert_message= "Update Coach Tip on Turn " + @track_turn_note.tn_name.to_s;
						#server_base=Protrack::Configuration['domain_url'];										
						#data = { "alert_message" => alert_message, "client_id" => @track_turn_note.fk_client_id.to_s }
											
						#uri = URI(server_base + "apns/send_group_notification_params");
						#res = Net::HTTP.post_form(uri, data)
						
						Thread.new do
							ApnsController::send_group_notification(alert_message, @track_turn_note.fk_client_id, @track_turn_note.id)
						end
					end

					#ApnsController::send_group_notification(alert_message, @track_turn_note.fk_client_id)
				rescue 	=> ex
					logger.error "erro: #{ex.class} , #{ex.message}"
				end	
								
				render_error :error_code => 'e372'  ## Display error message email/password does not match..       
				redirect_to(:action => 'index', :id => params[:track_turn_note][:fk_track_id])
				return	
			else
				#render_error :error_code => 'e310'  ## Display error message email/password does not match..       
				render :action => "edit", :id => params[:id]
				return
			end				
		rescue => ex
		    logger.error "erro: #{ex.class} , #{ex.message}"
			render_error :error_code => 'e371'  ## Display error message email/password does not match..       
			render :action => "edit", :id => params[:id]
			return
		end			
		@turn_info_image=TrackTurnImage.where("image_code in(201) and status_code=401 and fk_tn_id=" + @track_turn_note.id.to_s)				
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
	
	def delete
		begin
			@track_turn_note=TrackTurnNote.find(params[:id])	
			@track_turn_note.status_code=403 # record delete : 403
			
			if @track_turn_note.valid? == false   				
				#render :action => "index", :id => params[:track_id]		
				redirect_to(:action => 'index', :id => params[:track_id])
				return
			end	
			
			if @track_turn_note.save!
				render_error :error_code => 'e374'  ## Display error message email/password does not match..       
				redirect_to(:action => 'index', :id => params[:track_id])
				return	
			else
				render_error :error_code => 'e371'  ## Display error message email/password does not match..       
				render :action => "index", :id => params[:track_id]		
				return
			end
		rescue
			render_error :error_code => 'e371'  ## Display error message email/password does not match..       
			render :action => "index", :id => params[:track_id]		
			return
		end			
		render :action => "index", :id => params[:track_id]
	end
	
	def sort
		client_id=session[:client_id] || 0		
		admin_id=session[:admin_id] || 0
		if (admin_id.to_i > 0 )
			client_id = session[:proxy_client_id] || 0 						
		end
		
		record_per_page=Protrack::Configuration['pagesize']
		
		@track_turn_notes = TrackTurnNote.get_track_turns_paginate(client_id.to_i, params[:id], record_per_page, params[:page])	
		
		#render :json => @track_turn_notes
		#return
		
		render :action => "sort", :layout => "common_layout"
	end
	
	def sort_save_ajax
		begin
			client_id=session[:client_id] || 0		
			admin_id=session[:admin_id] || 0
			if (admin_id.to_i > 0 )
				client_id = session[:proxy_client_id] || 0 						
			end
		
			@track_turn_note=TrackTurnNote.find(params[:id])			
			@track_turn_note.last_updated_ip = request.remote_ip			
			@track_turn_note.sort_no = params[:sort_no]		
			
			if @track_turn_note.valid? == false   				
				render :json => {:resp_code => "401", :message => "Track turn data is not valid. Please try again." + @track_turn_note.errors.to_json}
				return
			end
	
			if @track_turn_note.save!
				render :json => {:resp_code => "200", :message => "Track turn data is sucessfully saved.",
				:id => @track_turn_note.id, :step_id =>  @track_turn_note.tn_step_id, 
				:sort_no => @track_turn_note.sort_no}
				return
			else
				render :json => {:resp_code => "402", :message => "Track turn data is not valid. Please try again."}
				return
			end
				
		rescue => ex
		    logger.error "erro: #{ex.class} , #{ex.message}"		
			render :json => {:resp_code => "403", :message => "Track turn data is not valid. Please try again. error: #{ex.message}"}
			return
		end			
		render :json => {:resp_code => "404", :message => "Track turn data is not valid. Please try again."}
	end
		
	def set_turns_active
		begin
			client_id=session[:client_id] || 0		
			admin_id=session[:admin_id] || 0	
			if (admin_id.to_i > 0 )
				client_id = session[:proxy_client_id] || 0 						
			end
			
			@track_turn_notes=TrackTurnNote.find(params[:id])	
			@track_turn_notes.status_code = 401	
			@track_turn_notes.last_updated_ip = request.remote_ip
				
			if @track_turn_notes.valid? == false   				
				render :action => "index", :id => params[:track_id]		
				return
			end	
	
			if @track_turn_notes.save!
				render_error :error_code => 'e372'  ## Display error message email/password does not match..       
				redirect_to(:action => 'index', :id => params[:track_id])
				return	
			else
				render_error :error_code => 'e371'  ## Display error message email/password does not match..       
				redirect_to(:action => 'index', :id => params[:track_id])
				return
			end
		rescue
			render_error :error_code => 'e371'  ## Display error message email/password does not match..       
			redirect_to(:action => 'index', :id => params[:track_id])
			return
		end			
		render :action => "index", :id => params[:track_id]
	end
	
	def set_turns_deactive
		begin	
			#render :json => params[:id]
			#return
			
			client_id=session[:client_id] || 0		
			admin_id=session[:admin_id] || 0
			if (admin_id.to_i > 0 )
				client_id = session[:proxy_client_id] || 0 						
			end
		
			@track_turn_notes=TrackTurnNote.find(params[:id])	
			@track_turn_notes.status_code = 402
			@track_turn_notes.last_updated_ip = request.remote_ip
						
			if @track_turn_notes.valid? == false   				
				render :action => "index", :id => params[:track_id]		
				return				
			end
	
			if @track_turn_notes.save!
				render_error :error_code => 'e372'  ## Display error message email/password does not match..       
				redirect_to(:action => 'index', :id => params[:track_id])
				return	
			else
				#render_error :error_code => 'e371'  ## Display error message email/password does not match..       
				redirect_to(:action => 'index', :id => params[:track_id])
				return
			end
		
		rescue => ex
		    logger.error "erro: #{ex.class} , #{ex.message}"
			render_error :error_code => 'e371'  ## Display error message email/password does not match..       
			redirect_to(:action => 'index', :id => params[:track_id])
			return
		end			
		render :action => "index", :id => params[:track_id]
	end
		
	def dot_position_save_ajax
		begin					
			@track_turn_note=TrackTurnNote.find(params[:turn_id])			
			@track_turn_note.last_updated_ip = request.remote_ip			
			@track_turn_note.x_pos = params[:x_pos]		
			@track_turn_note.y_pos = params[:y_pos]	
			
			if @track_turn_note.valid? == false   				
				render :json => {:resp_code => "401", :message => "Track turn data is not valid. Please try again." + @track_turn_note.errors.to_json}
				return
			end
	
			if @track_turn_note.save!
				render :json => {:resp_code => "200", :message => "Track turn data is sucessfully saved."}
				return
			else
				render :json => {:resp_code => "402", :message => "Track turn data is not valid. Please try again."}
				return
			end
				
		rescue => ex
		    logger.error "erro: #{ex.class} , #{ex.message}"		
			render :json => {:resp_code => "403", :message => "Track turn data is not valid. Please try again. error: #{ex.message}"}
			return
		end			
		render :json => {:resp_code => "404", :message => "Track turn data is not valid. Please try again."}
	end
	
	#handle_asynchronously :update
end
