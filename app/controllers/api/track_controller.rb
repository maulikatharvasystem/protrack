require 'set'

class Api::TrackController < Api::ApiController
    #include Protrack::Apiload
		
	#2.D
	def coockies_get_track 
		begin
			#logger.debug "get_track: " + params.to_s		
			
			##########Start-Track data###########
     		@client_track=ClientTrack.find_by_sql("select CT.pk_track_id as server_id, " +
			 "display_id as short_name, track_name as name, CT.description," +
			 "CT.track_image as scheme_image, " +
			 "CT.track_image as scheme_image_height, " +
			 "CT.track_image as scheme_image_width, " +
			 " ifnull(GROUP_CONCAT(CTI.track_image SEPARATOR  ','),'') as extra_images, " +
			 " ifnull(GROUP_CONCAT(CTI2.track_image SEPARATOR  ','),'') as track_overview_images, " +			
			 " med_track_info_image as preview_scheme_image, " +	
			 " track_info_image as track_info_image " +				
			" from client_tracks  CT " +
			" left outer join product_prices  PP on PP.pk_product_id=CT.fk_product_id	" +
			" left outer join client_track_images CTI on CTI.fk_track_id=CT.pk_track_id and CTI.image_code in(0,101) and CTI.status_code = 401	" +	
			" left outer join client_track_images CTI2 on CTI2.fk_track_id=CT.pk_track_id and CTI2.image_code=102  and CTI2.status_code = 401	" +				
			" where CT.status_code=401 and CT.fk_client_id=" +  params[:client_id].to_s  + " group by CT.pk_track_id ")
			
			if (@client_track.count<=0)
				#logger.debug "Client Track not found for fk_client_id=" + params[:client_id].to_s
				coockies_render_error('e1015', params[:response_type]) 
				return
			end		

			image_server_ip=Protrack::Configuration['image_server_ip']							
			@client_track.each_with_index  do |client_track, index|								
				@client_track[index].extra_images= client_track.extra_images.split(",")
				@client_track[index].track_overview_images= client_track.track_overview_images.split(",")

				@client_track[index].track_overview_images=@client_track[index].track_overview_images.uniq
				@client_track[index].extra_images.each_with_index  do |description_images, index1|
					@client_track[index].extra_images[index1]= image_server_ip + "" + description_images
				end
				@client_track[index].track_overview_images.each_with_index  do |info_images, index1|
					@client_track[index].track_overview_images[index1]= image_server_ip + "" + info_images
				end
				@client_track[index].preview_scheme_image= image_server_ip + "" + @client_track[index].preview_scheme_image
				if @client_track[index].preview_scheme_image.empty? == false
					@client_track[index].preview_scheme_image= image_server_ip + "" + @client_track[index].preview_scheme_image
				end
				if @client_track[index].track_info_image.empty? == false
					@client_track[index].track_info_image= image_server_ip + "" + @client_track[index].track_info_image
				end

				@client_track[index].scheme_image= image_server_ip + "" + @client_track[index].scheme_image
				if @client_track[index].scheme_image.empty? == false

					temp_image1 = @client_track[index].scheme_image

          @client_track[index].scheme_image= image_server_ip + "" + temp_image1

          temp_image = temp_image1

          temp_image.sub! '/assets/', '/assets/images/'

          source_image_path= File.join(Rails.root, "app", temp_image.split('/')[3..-1])
          image = MiniMagick::Image.open(source_image_path)

          @client_track[index].scheme_image_width= image[:width]
          @client_track[index].scheme_image_height= image[:height]

        end



				@track_turn_notes=TrackTurnNote.find_by_sql("select TTN.pk_tn_id as server_id" +
				" ,TPT.plac_name as place_type ,TTN.sort_no as sort_number ,TTN.tn_name as name" +
				"  ,TTN.x_pos as x_position ,TTN.y_pos as y_position ,TTN.tn_picture as scheme_image" +
				" ,TTN.tn_video as youtube_video" +
				" ,ifnull(GROUP_CONCAT(TTI.turn_image SEPARATOR  ','),'') as info_images " +
				" , (case when  UTN.pk_utn_id is null then TTN.tn_type else UTN.tn_type end) as corner_type " +
				" ,(case when  UTN.pk_utn_id is null then TTN.tn_strategy else UTN.tn_strategy end) as corner_strategy" +
				" , (case when  UTN.pk_utn_id is null then TTN.tn_marker else UTN.tn_marker end) as corner_markers	" +
				" , (case when  UTN.pk_utn_id is null then TTN.tn_note else UTN.tn_note end) as notes " +
				" , TTN.tn_data as coach_tip" +
				" , (case when  UTN.pk_utn_id is null then '' else UTN.tn_picture end) as my_line_image  " +
				" from track_turn_notes  TTN " +
				" left outer join track_placement_types TPT on TPT.pk_plactype_id=TTN.fk_plactype_id" +
				" left outer join client_tracks CT on CT.pk_track_id=TTN.fk_track_id" +
				" left outer join track_turn_images TTI on TTI.fk_tn_id=TTN.pk_tn_id and TTI.image_code=201	and TTI.status_code = 401 " +
				" left outer join user_turn_notes UTN on UTN.fk_tn_id=TTN.pk_tn_id " +
					"  and UTN.fk_user_id=" + params[:user_id].to_s  +
				"  and UTN.fk_client_id=" + params[:client_id].to_s  +
				" and UTN.status_code=401	" +
				" where  TTN.status_code=401 and  TTN.fk_client_id=" +  params[:client_id].to_s +
				" and  fk_track_id=" +  client_track.server_id.to_s + "  group by TTN.pk_tn_id");

				@track_turn_notes.each_with_index  do |track_turn_notes, index1|
					@turns=Hash.new;
					@notes=Hash.new;
					@notes['coach_tip']=track_turn_notes.coach_tip;
					@notes['corner_type']=track_turn_notes.corner_type;
					@notes['corner_strategy']=track_turn_notes.corner_strategy;
					@notes['corner_markers']=track_turn_notes.corner_markers;
					@notes['notes']=track_turn_notes.notes;

					@notes['my_line_image']=track_turn_notes.my_line_image;
					if @notes['my_line_image'].empty? == false
						@notes['my_line_image']= image_server_ip + "" + @notes['my_line_image'];
					end

					#@notes['notes']=@notes;
					@track_turn_notes[index1]['note']=@notes

					@turns['server_id']=track_turn_notes.server_id
					@turns['place_type']=track_turn_notes.place_type
					@turns['sort_number']=track_turn_notes.sort_number
					@turns['name']=track_turn_notes.name
					@turns['x_position']=track_turn_notes.x_position
					@turns['y_position']=track_turn_notes.y_position

					@turns['scheme_image']=track_turn_notes.scheme_image
					if @turns['scheme_image'].empty? == false
						@turns['scheme_image']= image_server_ip + "" + @turns['scheme_image'];
					end

					@turns['youtube_video']=track_turn_notes.youtube_video
					@turns['note']=@notes

					@turns['info_images']=track_turn_notes.info_images.split(",")
					@turns['info_images'].each_with_index  do |info_images, index2|
						@turns['info_images'][index2]= image_server_ip + "" + info_images
					end

					@track_turn_notes[index1]=@turns
				end
				@client_track[index]['turns']=@track_turn_notes;
			end
			track={}
			track=@client_track
			##########End-Track data###########
			##########Start-Race Reprt data###########
			race_reports=Array.new
			@user_report=UserReport.where(fk_user_id: params[:user_id].to_i, fk_client_id: params[:client_id].to_i, status_code: "401")

			if (@user_report.count>0)
				#logger.debug "user_report not found for client_id=" + params[:client_id].to_s
				@user_report.each do |user_report|
					_user_report=Hash.new
					_user_report["server_id"] = user_report.id
					#_user_report["name"] = user_report.name.to_s
					_user_report["circuit"] = user_report.circuit.to_s
					_user_report["engineer_name"] = user_report.engineer_name.to_s
					_user_report["event"] = user_report.event.to_s
					_user_report["report_time"] = user_report.report_time.to_s
					_user_report["championship"] = user_report.championship.to_s
					_user_report["user_type"] = user_report.user_type.to_s

					fields=Array.new
					@user_report_field=UserReportField.where(fk_report_id: user_report.id.to_i)
					@user_report_field.each do |user_report_field|
						_user_report_field=Hash.new
						_user_report_field[:key]=user_report_field[:key] 
						_user_report_field[:name]=user_report_field[:name] 
						_user_report_field[:value]=user_report_field[:value] 
						_user_report_field[:need_rating]= user_report_field[:need_rating] 
						_user_report_field[:rating]= user_report_field[:rating]
						
						fields.push(_user_report_field)
					end
					_user_report["fields"]=fields 
					#count_report=race_reports.length
					race_reports.push(_user_report)					
				end
			end		
			##########End-Race Reprt data###########

			##########Start-manage URLS data###########
				manage_urls = ManageUrl.first
				_manage_urls_field = Hash.new
				_manage_urls_field[:regulation_pdf]= (manage_urls ? manage_urls[:regulation_pdf] : '')
				_manage_urls_field[:media_pdf]= (manage_urls ? manage_urls[:media_pdf] : '')
				_manage_urls_field[:car_manual_pdf]= (manage_urls ? manage_urls[:car_manual_pdf] : '')
				_manage_urls_field[:fb_url]= (manage_urls ? manage_urls[:fb_url] : '')
				_manage_urls_field[:twitter_url]= (manage_urls ? manage_urls[:twitter_url] : '')
				_manage_urls_field[:prema_url]= (manage_urls ? manage_urls[:prema_url] : '')
				_manage_urls_field[:formula_url]= (manage_urls ? manage_urls[:formula_url] : '')
			##########End-manage URLs data###########

			##########Start-telemetry_sessions data###########
			telemetry_sessions=Array.new			
			@track_session=TrackSession.find_by_sql("select pk_session_id as server_id " +
			 " ,name as name " +
			 " ,ifnull(GROUP_CONCAT(session_image SEPARATOR  ','),'') as images " +	
			" ,session_date, ifnull(race_engineer_name, '') as  driver_name, championship, engineer_name, circuit, event " +
			" from track_sessions  TS " +
			" left outer join race_engineers RE on TS.fk_engn_id=RE.pk_engn_id  " +
			" left outer join track_session_images TSI on TSI.fk_session_id=TS.pk_session_id and TSI.image_code in(301)	and TSI.status_code = 401 " +	
			"where TS.status_code=401 and TS.fk_driver_id = " + params[:user_id].to_s + " and TS.fk_client_id=" +  params[:client_id].to_s  + " group by pk_session_id ")
			
			

			

			@track_session.each  do |track_session|	
					@session=Hash.new;
					@session['server_id']=track_session.server_id
					@session['name']=track_session.name
					@session['images']=track_session.images.split(",")
					@session['images'].each_with_index  do |images, index2|		
						@session['images'][index2]= image_server_ip + "" + images
					end 
					session_date = track_session.session_date.to_time.to_i || 0
					@session['date']=session_date
					@session['driver']=track_session.driver_name
					@session['championship']=track_session.championship
					@session['engineer']=track_session.engineer_name
					@session['circuit']=track_session.circuit
					@session['event']=track_session.event
					
					telemetry_sessions.push(@session)
			end
				
			##########End-telemetry_sessions data###########

				api_response({'success' => true, 'tracks' => track,
											'race_reports' => race_reports, 'manage_urls' => _manage_urls_field, 'telemetry_sessions' => telemetry_sessions}, params[:response_type])
		rescue 	=> ex
			coockies_render_error('e1015',params[:response_type].to_s,"#{ex.message}") 
			#logger.error "erro: #{ex.class} , #{ex.message}"
		end
	end
	
	#2.D
	def coockies_update_turns 
		begin
			#logger.debug "coockies_update_turns: " + params.to_s
			@track_turn_note=TrackTurnNote.where(pk_tn_id: params[:id].to_s)	
			if (@track_turn_note.count <=0)
				#logger.debug "Turn not found for pk_tn_id=" + params[:id].to_s
				coockies_render_error('e1016', params[:response_type]) 
				return
			end
			@track_turn_note=@track_turn_note[0]			
			@user_turn_note=UserTurnNote.where(fk_user_id: params[:user_id].to_i, fk_tn_id: params[:id].to_i, fk_client_id: params[:client_id].to_i)				
			
			if (@user_turn_note.count <=0)
				@user_turn_note=UserTurnNote.new					
				@user_turn_note[:fk_tn_id]=params[:id] || "0"
				@user_turn_note[:fk_client_id]=params[:client_id] || "0"	
				@user_turn_note[:fk_user_id]=params[:user_id] || "0"				
				@user_turn_note[:tn_picture]= ""
				@user_turn_note[:status_code]= "401"
			else
				@user_turn_note=@user_turn_note[0]['pk_utn_id'].to_i
				@user_turn_note = UserTurnNote.find(@user_turn_note)
			end	
		    
			@user_turn_note[:tn_type]= params[:corner_type] || @user_turn_note[:tn_type]	
			@user_turn_note[:tip]= params[:coach_tip] || @user_turn_note[:tip]	
			@user_turn_note[:tn_strategy]=params[:corner_strategy] || @user_turn_note[:tn_strategy]
			@user_turn_note[:tn_marker]=params[:corner_markers] || @user_turn_note[:tn_marker]
			@user_turn_note[:tn_note]= params[:notes] || @user_turn_note[:tn_note]		
		
			if @user_turn_note.valid? == false 
				coockies_render_error('e2201', params[:response_type],@user_turn_note.errors.messages) 
				return
			end
			
			if (params[:my_line_image_file].blank? == false)
					#params[:my_line_image_file].each do |my_line_image_file|	
						begin							
							image_filename= params[:my_line_image_file].original_filename.to_s 		
							image_name=image_filename.split('/').last
							image_extn=image_name.split('.').last
							newfilename = "#{(Time.now.to_i.to_s + Time.now.usec.to_s).ljust(16, '0')}"
							newfilename = newfilename + '.' + image_extn
										
							image_path="/assets/images/client/client_" + params[:client_id].to_s + "/" + params[:user_id].to_s + "/turn_images/"						
							save_file_url(params[:my_line_image_file],newfilename, image_path)	
													
							public_url_image_path="/assets/client/client_" + params[:client_id].to_s + "/" + params[:user_id].to_s + "/turn_images/"				
							@user_turn_note[:tn_picture]=public_url_image_path + newfilename
						rescue	=> ex						
							#Error Comment
							render :json =>  "erro: #{ex.class} , #{ex.message}"
							return
						end								
					#end				
				end
			
			if @user_turn_note.save!
				#track_turn_note saved
			else
				coockies_render_error('e2202', params[:response_type]) 
				return
			end
			
			image_server_ip=Protrack::Configuration['image_server_ip']
			
			data={};
			data['coach_tip']=@user_turn_note.tip;
			data['corner_type']=@user_turn_note.tn_type;
			data['corner_strategy']=@user_turn_note.tn_strategy;
			data['corner_markers']=@user_turn_note.tn_marker;
			data['notes']=@user_turn_note.tn_note;	
				
			data['my_line_image']= @user_turn_note.tn_picture;	
			if data['my_line_image'].empty? == false	
				data['my_line_image']= image_server_ip + "" + data['my_line_image'];					
			end 		  
			api_response({"success" => true, "note" => data}, params[:response_type])
		rescue 	=> ex
			coockies_render_error('e2202',params[:response_type].to_s,"#{ex.message}") 
			#logger.error "erro: #{ex.class} , #{ex.message}"
		end
	end
	
	def save_file_url(params_name,filename, path) 
		begin
			dir= File.join(Rails.root, "app", path)
			
			image_path_dir=""
			if File.exists?(dir) == false
				path_split=path.split("/")
				path_split.each do |_path_split|
					if image_path_dir.empty? == false
						image_path_dir = image_path_dir + "/"
					end
					image_path_dir = image_path_dir + _path_split
					
					dir=File.join(Rails.root, "app", image_path_dir)
					if File.exists?(dir) == false
						Dir.mkdir(dir) unless File.exists?(dir)	
					end
				end
			end
			dir= File.join(Rails.root, "app", path)
			Dir.mkdir(dir) unless File.exists?(dir)
			
			path = File.join(Rails.root, "app", path, filename)
			# write the file
			File.open(path, "wb") { |f| f.write(params_name.read) }  
		rescue => ex
			logger.info "erro: #{ex.class} , #{ex.message}"
			#render :json =>  "erro: #{ex.class} , #{ex.message}"
			#return
		end
	end
	
	def get_track
		begin
			logger.debug "get_track: " + params.to_s		
			
			@client=Client.where(pk_client_id: params[:client_id].to_i)				
			if (@client.count<=0)
				logger.debug "Client not found for client_id=" + params[:client_id].to_s
				render_error('e1011', params[:response_type]) 
				return
			end
			
			@user_device=UserDevice.where(fk_client_id: params[:client_id].to_i, pk_device_id: params[:device_id].to_i)				
			if (@user_device.count<=0)
				logger.debug "Device not found for fk_client_id=" + params[:client_id].to_s
				render_error('e1014', params[:response_type]) 
				return
			end		
			
			@client_track=ClientTrack.find_by_sql("select pk_track_id as track_id, CT.fk_client_id as client_id," +
			" display_id as display_id, track_name as track_name, track_tip as track_tip, CT.description," +
			" CT.track_image as track_image, ifnull(GROUP_CONCAT(CTI.track_image SEPARATOR  ','),'') as extra_images, " +
			" ifnull(GROUP_CONCAT(CTI2.track_image SEPARATOR  ','),'') as track_overview_images, " +
			" track_info_image as track_info_image, " +
			" small_track_image as small_track_image, small_track_info_image as small_track_info_image, " + 
			" med_track_image as med_track_image, med_track_info_image as med_track_info_image, " +
			" ios_product_id as product_id, ios_price as price, no_turns as no_turns " +
		   " from client_tracks  CT " +
		   " left outer join product_prices  PP on PP.pk_product_id=CT.fk_product_id " +
		   " left outer join client_track_images CTI on CT.pk_track_id=CTI.fk_track_id  and CTI.image_code in(0,101) and CTI.status_code = 401 " +  
		   " left outer join client_track_images CTI2 on CTI2.fk_track_id=CT.pk_track_id and CTI2.image_code=102  and CTI2.status_code = 401 " +		   
		   " where CT.status_code=401 and CT.fk_client_id=" +  params[:client_id].to_s  + " group by CT.pk_track_id ")
		
			if (@client_track.count<=0)
				logger.debug "Client Track not found for fk_client_id=" + params[:client_id].to_s
				render_error('e1015', params[:response_type]) 
				return
			end		
								
			@client_track.each_with_index  do |client_track, index|
				@client_track[index].extra_images= client_track.extra_images.split(",")
				@client_track[index].extra_images= client_track.extra_images.uniq

				@client_track[index].track_overview_images= client_track.track_overview_images.split(",")
				@client_track[index].track_overview_images= client_track.track_overview_images.uniq
				
			end
			
			image_server_ip=Protrack::Configuration['image_server_ip']
			
			data={}
			data=@client_track
			api_response({ "responsecode" => "200", "server_ip" => image_server_ip, "data" => data},params[:response_type])	
			
		rescue 	=> ex
			render_error('e1015',params[:response_type].to_s,"#{ex.message}") 
			logger.error "erro: #{ex.class} , #{ex.message}"
		end
	end
	
    #3.D	
	def register_purchased_track
		begin
			#logger.debug "get_track_info: " + params.to_s		
			
			@client=Client.where(pk_client_id: params[:client_id].to_i)				
			if (@client.count<=0)
				logger.debug "Client not found for client_id=" + params[:client_id].to_s
				render_error('e1011', params[:response_type]) 
				return
			end
			
			@user_device=UserDevice.where(fk_client_id: params[:client_id].to_i, pk_device_id: params[:device_id].to_i)				
			if (@user_device.count<=0)
				logger.debug "Device not found for fk_client_id=" + params[:client_id].to_s
				render_error('e1014', params[:response_type]) 
				return
			end		
			
			@client_track=ClientTrack.where(fk_client_id: params[:client_id].to_i, pk_track_id: params[:track_id].to_i)				
			if (@client_track.count<=0)
				logger.debug "Track not found for pk_track_id=" + params[:track_id].to_s
				render_error('e1015', params[:response_type]) 
				return
			end		
			@client_track=@client_track.first				
			@product_price=ProductPrice.where(pk_product_id: @client_track[:fk_product_id])			
				
			if (@product_price.count<=0)
				logger.debug "Product not found for pk_product_id=" + @client_track[:fk_product_id].to_s
				render_error('e1018', params[:response_type]) 
				return
			end	
			@product_price=@product_price.first			
			
			#params[:receipt_data]="ewoJInNpZ25hdHVyZSIgPSAiQXBMek1neit0Y3M0VmN3YTF1RmFHT0FmUllmYW1uQ1hNTHhib3NMOU5MdEEvWm5BanA2SHdoaUR4TTVSMytSdTJCR3N3ODB3TXFiS1VkNk5SYkpmQlZXUXU1M1U0TmNVYysvMXNmajFOVVFySzNBY0dpeHZtVGpBQk0yRi9xWE5UQ3VHZGdleENiYVkzcWJQV1NUeG1Pb0g3QlRQbkhDbTE2a1BtQ3JBUFBYc0FBQURWekNDQTFNd2dnSTdvQU1DQVFJQ0NHVVVrVTNaV0FTMU1BMEdDU3FHU0liM0RRRUJCUVVBTUg4eEN6QUpCZ05WQkFZVEFsVlRNUk13RVFZRFZRUUtEQXBCY0hCc1pTQkpibU11TVNZd0pBWURWUVFMREIxQmNIQnNaU0JEWlhKMGFXWnBZMkYwYVc5dUlFRjFkR2h2Y21sMGVURXpNREVHQTFVRUF3d3FRWEJ3YkdVZ2FWUjFibVZ6SUZOMGIzSmxJRU5sY25ScFptbGpZWFJwYjI0Z1FYVjBhRzl5YVhSNU1CNFhEVEE1TURZeE5USXlNRFUxTmxvWERURTBNRFl4TkRJeU1EVTFObG93WkRFak1DRUdBMVVFQXd3YVVIVnlZMmhoYzJWU1pXTmxhWEIwUTJWeWRHbG1hV05oZEdVeEd6QVpCZ05WQkFzTUVrRndjR3hsSUdsVWRXNWxjeUJUZEc5eVpURVRNQkVHQTFVRUNnd0tRWEJ3YkdVZ1NXNWpMakVMTUFrR0ExVUVCaE1DVlZNd2daOHdEUVlKS29aSWh2Y05BUUVCQlFBRGdZMEFNSUdKQW9HQkFNclJqRjJjdDRJclNkaVRDaGFJMGc4cHd2L2NtSHM4cC9Sd1YvcnQvOTFYS1ZoTmw0WElCaW1LalFRTmZnSHNEczZ5anUrK0RyS0pFN3VLc3BoTWRkS1lmRkU1ckdYc0FkQkVqQndSSXhleFRldngzSExFRkdBdDFtb0t4NTA5ZGh4dGlJZERnSnYyWWFWczQ5QjB1SnZOZHk2U01xTk5MSHNETHpEUzlvWkhBZ01CQUFHamNqQndNQXdHQTFVZEV3RUIvd1FDTUFBd0h3WURWUjBqQkJnd0ZvQVVOaDNvNHAyQzBnRVl0VEpyRHRkREM1RllRem93RGdZRFZSMFBBUUgvQkFRREFnZUFNQjBHQTFVZERnUVdCQlNwZzRQeUdVakZQaEpYQ0JUTXphTittVjhrOVRBUUJnb3Foa2lHOTJOa0JnVUJCQUlGQURBTkJna3Foa2lHOXcwQkFRVUZBQU9DQVFFQUVhU2JQanRtTjRDL0lCM1FFcEszMlJ4YWNDRFhkVlhBZVZSZVM1RmFaeGMrdDg4cFFQOTNCaUF4dmRXLzNlVFNNR1k1RmJlQVlMM2V0cVA1Z204d3JGb2pYMGlreVZSU3RRKy9BUTBLRWp0cUIwN2tMczlRVWU4Y3pSOFVHZmRNMUV1bVYvVWd2RGQ0TndOWXhMUU1nNFdUUWZna1FRVnk4R1had1ZIZ2JFL1VDNlk3MDUzcEdYQms1MU5QTTN3b3hoZDNnU1JMdlhqK2xvSHNTdGNURXFlOXBCRHBtRzUrc2s0dHcrR0szR01lRU41LytlMVFUOW5wL0tsMW5qK2FCdzdDMHhzeTBiRm5hQWQxY1NTNnhkb3J5L0NVdk02Z3RLc21uT09kcVRlc2JwMGJzOHNuNldxczBDOWRnY3hSSHVPTVoydG04bnBMVW03YXJnT1N6UT09IjsKCSJwdXJjaGFzZS1pbmZvIiA9ICJld29KSW05eWFXZHBibUZzTFhCMWNtTm9ZWE5sTFdSaGRHVXRjSE4wSWlBOUlDSXlNREV6TFRBM0xURTBJREExT2pFek9qVXdJRUZ0WlhKcFkyRXZURzl6WDBGdVoyVnNaWE1pT3dvSkluQjFjbU5vWVhObExXUmhkR1V0YlhNaUlEMGdJakV6TnpNNE1EUXdNekEwT1RnaU93b0pJblZ1YVhGMVpTMXBaR1Z1ZEdsbWFXVnlJaUE5SUNKaU5HSTNObU00WVRNM056Wm1ORGd5TW1ZelpUZ3dPVEJrTlRsa04yVTFNVGcyWVRnek16Y3dJanNLQ1NKdmNtbG5hVzVoYkMxMGNtRnVjMkZqZEdsdmJpMXBaQ0lnUFNBaU1qUXdNREF3TURRM05qVTFNelEwSWpzS0NTSmlkbkp6SWlBOUlDSXhMakFpT3dvSkltRndjQzFwZEdWdExXbGtJaUE5SUNJMU56Z3dNekF4T1RjaU93b0pJblJ5WVc1ellXTjBhVzl1TFdsa0lpQTlJQ0l5TkRBd01EQXdORGMyTlRVek5EUWlPd29KSW5GMVlXNTBhWFI1SWlBOUlDSXhJanNLQ1NKdmNtbG5hVzVoYkMxd2RYSmphR0Z6WlMxa1lYUmxMVzF6SWlBOUlDSXhNemN6T0RBME1ETXdORGs0SWpzS0NTSjFibWx4ZFdVdGRtVnVaRzl5TFdsa1pXNTBhV1pwWlhJaUlEMGdJalJCTVRjd1JUazBMVGxDUlVNdE5EaEdOUzA1UTBVNExVSTNSREExUlRZd1F6RkVSU0k3Q2draWFYUmxiUzFwWkNJZ1BTQWlOVGM0TURNeU56VXdJanNLQ1NKMlpYSnphVzl1TFdWNGRHVnlibUZzTFdsa1pXNTBhV1pwWlhJaUlEMGdJakV5TURFek56azBJanNLQ1NKd2NtOWtkV04wTFdsa0lpQTlJQ0pKVjBOZlJsSkZSVjlUVlVKVFExSkpVRlJKVDA1Zk1TSTdDZ2tpY0hWeVkyaGhjMlV0WkdGMFpTSWdQU0FpTWpBeE15MHdOeTB4TkNBeE1qb3hNem8xTUNCRmRHTXZSMDFVSWpzS0NTSnZjbWxuYVc1aGJDMXdkWEpqYUdGelpTMWtZWFJsSWlBOUlDSXlNREV6TFRBM0xURTBJREV5T2pFek9qVXdJRVYwWXk5SFRWUWlPd29KSW1KcFpDSWdQU0FpWTI5dExtbDNZeTV1WlhkemMzUmhibVJ0WVdkaGVtbHVaU0k3Q2draWNIVnlZMmhoYzJVdFpHRjBaUzF3YzNRaUlEMGdJakl3TVRNdE1EY3RNVFFnTURVNk1UTTZOVEFnUVcxbGNtbGpZUzlNYjNOZlFXNW5aV3hsY3lJN0NuMD0iOwoJInBvZCIgPSAiMjQiOwoJInNpZ25pbmctc3RhdHVzIiA9ICIwIjsKfQ=="
					
			val_reciept_data=verify_reciept(params[:receipt_data])
					
			if  val_reciept_data.empty? == true
				logger.debug "reciept validate false"
				render_error('e1017', params[:response_type]) 
				return
			end
			
			@transaction=Transaction.new
			@transaction[:fk_client_id]=params[:client_id]
			@transaction[:fk_track_id]=params[:track_id]			
			@transaction[:fk_device_id]=params[:device_id]
			@transaction[:gateway]=params[:gateway]
			@transaction[:latest_receipt]=params['receipt_data']
			
			@transaction[:platform_code]=@client_track[:platform_code]
			
			@transaction[:start_date]=val_reciept_data['purchase_date']
			#@transaction[:end_date]=val_reciept_data['']			
			@transaction[:bid]=val_reciept_data['bid']
			@transaction[:bvrs]=val_reciept_data['bvrs']
			#@transaction[:expires_date]=val_reciept_data['']
			@transaction[:item_id]=val_reciept_data['item_id']				
			@transaction[:product_id]=val_reciept_data['product_id']
			@transaction[:original_purchase_date]=val_reciept_data['original_purchase_date']
			@transaction[:original_transaction_id]=val_reciept_data['original_transaction_id']
			@transaction[:purchase_date]=val_reciept_data['purchase_date']
			@transaction[:quantity]=val_reciept_data['quantity']
			@transaction[:transaction_id]=val_reciept_data['transaction_id']
			#@transaction[:order_id]=val_reciept_data['']		
			@transaction[:purchase_state]=0
			@transaction[:price]=@product_price[:ios_price]
						
			@transaction[:create_ip]=request.remote_ip 				
			@transaction[:status_code]=401
			
			image_server_ip=Protrack::Configuration['image_server_ip']
			data={}				
			if @transaction.save!							
				data['track_id']=@transaction[:fk_track_id].to_s
				data['client_id']=@transaction[:fk_client_id].to_s
				data['display_id']=@client_track[:display_id].to_s
				data['track_name']=@client_track[:track_name].to_s
				data['track_tip']=@client_track[:track_tip].to_s
				data['description']=@client_track[:description].to_s
				data['track_image']= @client_track[:track_image].to_s
				data['track_info_image']= @client_track[:track_info_image].to_s
				
				data['small_track_image']= @client_track[:small_track_image].to_s
				data['small_track_info_image']= @client_track[:small_track_info_image].to_s
				
				data['med_track_image']= @client_track[:med_track_image].to_s
				data['med_track_image']= @client_track[:med_track_image].to_s
							 
				data['product_id']=@transaction[:product_id].to_s
				data['price']=@transaction[:price].to_s
				data['no_turns']=@client_track[:no_turns].to_s
				data['transaction_id']=@transaction.id.to_s
				
				str=""							
				@client_track_image=ClientTrackImage.where(fk_track_id: @client_track.id.to_i)			
				if @client_track_image.count > 0	
					@client_track_image.each do |client_track_image|
						str= "," + client_track_image.track_image.to_s
					end
					str.slice!(0)
					data["extra_images"]= str.split(",")
				else
					data["extra_images"]=""
				end
					
				api_response({"responsecode" => "200", "server_ip" => image_server_ip, "data" => data}, params[:response_type])	
			else
				 render_error('e1017',params[:response_type].to_s,@device_users.errors.to_json) 
			end			
		rescue 	=> ex
			render_error('e1017',params[:response_type].to_s,"#{ex.message}") 
			logger.error "erro: #{ex.class} , #{ex.message}"
		end
	end
	
	#4.D
	def get_purchased_track_tn_detail
		begin
			logger.debug "get_purchased_track_tn_detail: " + params.to_s		
			
			@client=Client.where(pk_client_id: params[:client_id].to_i)				
			if (@client.count<=0)
				logger.debug "Client not found for client_id=" + params[:client_id].to_s
				render_error('e1011', params[:response_type]) 
				return
			end
			
			@user_device=UserDevice.where(fk_client_id: params[:client_id].to_i, pk_device_id: params[:device_id].to_i)				
			if (@user_device.count<=0)
				logger.debug "Device not found for fk_client_id=" + params[:client_id].to_s
				render_error('e1014', params[:response_type]) 
				return
			end	

			@client_track=ClientTrack.where(fk_client_id: params[:client_id].to_i, pk_track_id: params[:track_id].to_i)				
			if (@client_track.count<=0)
				logger.debug "Track not found for pk_track_id=" + params[:track_id].to_s
				render_error('e1015', params[:response_type]) 
				return
			end				
				
			
			# @track_turn_notes=TrackTurnNote.find_by_sql("select pk_tn_id as tn_id, fk_track_id as track_id, 
			# fk_client_id as client_id, 
			# plac_name as place_type, tn_step_id as  step_id, tn_name as name, tn_data as data, 
			# tn_video as video, tn_type as types, tn_strategy as strategy, tn_marker as marker, 
			# tn_picture as picture, tn_note as note, x_pos as x_position, y_pos as y_position  			
			# from track_turn_notes  TTN		
			# left outer join track_placement_types TPT on TPT.pk_plactype_id=TTN.fk_plactype_id
			# where TTN.fk_client_id=" +  params[:client_id].to_s +			
			# "  and TTN.fk_track_id in(select fk_track_id from transactions where " +
			# " pk_trans_id in(" +  params[:transaction_id].to_s + 
			# ") and  fk_track_id =" +  params[:track_id].to_s + ") ")
			
			image_server_ip=Protrack::Configuration['image_server_ip']

			@track_turn_notes=TrackTurnNote.find_by_sql("select pk_tn_id as tn_id, fk_track_id as track_id, 
			fk_client_id as client_id, 
			plac_name as place_type, tn_step_id as  step_id, tn_name as name, tn_data as data, 
			tn_video as video, tn_type as types, tn_strategy as strategy, tn_marker as marker, 
			tn_picture as picture, tn_note as note, x_pos as x_position, y_pos as y_position,
			sort_no as sort_no"+" ,ifnull(GROUP_CONCAT(TTI.turn_image SEPARATOR  ','),'') as info_images " + "
			from track_turn_notes  TTN		
			left outer join track_placement_types TPT on TPT.pk_plactype_id=TTN.fk_plactype_id
			"+" left outer join track_turn_images TTI on TTI.fk_tn_id=TTN.pk_tn_id and TTI.image_code=201	and TTI.status_code = 401 " + "	
			where  TTN.status_code=401 and  TTN.fk_client_id=" +  params[:client_id].to_s +			
			"  and  fk_track_id =" +  params[:track_id].to_s + " group by TTN.pk_tn_id")
			
			if (@track_turn_notes.count<=0)
				logger.debug "Client Track turn/notes not found for pk_track_id=" + params[:track_id].to_s
				render_error('e1016', params[:response_type]) 
				return
			end		
			
			@track_turn_notes.each_with_index  do |track_turn_notes, index|
				@track_turn_notes[index].info_images= track_turn_notes.info_images.split(",")
				@track_turn_notes[index].info_images= track_turn_notes.info_images.uniq				
			end

			data={}
			data=@track_turn_notes
			api_response({ "responsecode" => "200", "server_ip" => image_server_ip, "data" => data},params[:response_type])	
			
		rescue 	=> ex
			render_error('e1016',params[:response_type].to_s,"#{ex.message}") 
			logger.error "error: #{ex.class} , #{ex.message}"
		end
	end
	
	#5.D
	def restore_purchased_track
		begin
			logger.debug "restore_purchased_track: " + params.to_s		
			
			@client=Client.where(pk_client_id: params[:client_id].to_i)				
			if (@client.count<=0)
				logger.debug "Client not found for client_id=" + params[:client_id].to_s
				render_error('e1011', params[:response_type]) 
				return
			end
			
			@user_device=UserDevice.where(fk_client_id: params[:client_id].to_i, pk_device_id: params[:device_id].to_i)				
			if (@user_device.count<=0)
				logger.debug "Device not found for fk_client_id=" + params[:client_id].to_s
				render_error('e1014', params[:response_type]) 
				return
			end		
			
			image_server_ip=Protrack::Configuration['image_server_ip']
			@client_track=ClientTrack.find_by_sql("select pk_track_id as track_id, CT.fk_client_id as client_id,
			 display_id as display_id, track_name as track_name, track_tip as track_tip,CT.description,
			 CT.track_image as track_image, ifnull(GROUP_CONCAT(CTI.track_image SEPARATOR  ','),'') as extra_images,
			 "+" ifnull(GROUP_CONCAT(CTI2.track_image SEPARATOR  ','),'') as track_overview_images, " + "
			  track_info_image as track_info_image, 
			 small_track_image as small_track_image, small_track_info_image as small_track_info_image, 
			 med_track_image as med_track_image, med_track_info_image as med_track_info_image, 
			 ios_product_id as product_id, 	ios_price as price, no_turns as no_turns
			from client_tracks  CT
			left outer join product_prices  PP on PP.pk_product_id=CT.fk_product_id		
			left outer join client_track_images CTI on CTI .fk_track_id=CT.pk_track_id" +  
		   " left outer join client_track_images CTI2 on CTI2.fk_track_id=CT.pk_track_id and CTI2.image_code=102  and CTI2.status_code = 401 " +		   
		   " where CT.status_code=401 and   CT.fk_client_id=" +  params[:client_id].to_s +
			"  and CT.pk_track_id in(select fk_track_id from transactions where " +
			" transaction_id in(" +  params[:transaction_id].to_s + ") ) group by CT.pk_track_id")
			
			if (@client_track.count<=0)
				logger.debug "Client Track not found for fk_client_id=" + params[:client_id].to_s
				render_error('e1039', params[:response_type]) 
				return
			end		
			
			@client_track.each_with_index  do |client_track, index|
				@client_track[index].extra_images= client_track.extra_images.split(",")
				@client_track[index].extra_images= client_track.extra_images.uniq

				@client_track[index].track_overview_images= client_track.track_overview_images.split(",")
				@client_track[index].track_overview_images= client_track.track_overview_images.uniq

			end
			
			data={}
			data=@client_track
			api_response({ "responsecode" => "200", "server_ip" => image_server_ip, "data" => data},params[:response_type])	
			
		rescue 	=> ex
			render_error('e1015',params[:response_type].to_s,"#{ex.message}") 
			logger.error "erro: #{ex.class} , #{ex.message}"
		end
	end
	
	#6.D
	def restore_purchased_track_tn_detail
		begin
			logger.debug "get_purchased_track_tn_detail: " + params.to_s		
			
			@client=Client.where(pk_client_id: params[:client_id].to_i)				
			if (@client.count<=0)
				logger.debug "Client not found for client_id=" + params[:client_id].to_s
				render_error('e1011', params[:response_type]) 
				return
			end
			
			@user_device=UserDevice.where(fk_client_id: params[:client_id].to_i, pk_device_id: params[:device_id].to_i)				
			if (@user_device.count<=0)
				logger.debug "Device not found for fk_client_id=" + params[:client_id].to_s
				render_error('e1014', params[:response_type]) 
				return
			end	
		
		    image_server_ip=Protrack::Configuration['image_server_ip']
			@track_turn_notes=TrackTurnNote.find_by_sql("select pk_tn_id as tn_id, fk_track_id as track_id, 
			fk_client_id as client_id, 
			plac_name as place_type, tn_step_id as  step_id, tn_name as name, tn_data as data, 
			tn_video as video, tn_type as types, tn_strategy as strategy, tn_marker as marker, 
			tn_picture as picture, tn_note as note , sort_no as sort_no
			"+" ,ifnull(GROUP_CONCAT(TTI.turn_image SEPARATOR  ','),'') as info_images " + " 			
			from track_turn_notes  TTN		
			left outer join track_placement_types TPT on TPT.pk_plactype_id=TTN.fk_plactype_id
			"+" left outer join track_turn_images TTI on TTI.fk_tn_id=TTN.pk_tn_id and TTI.image_code=201	and TTI.status_code = 401 " + "
			where TTN.status_code=401 and   TTN.fk_client_id=" +  params[:client_id].to_s +
			"  and TTN.fk_track_id in(select fk_track_id from transactions where " +
			" transaction_id in(" +  params[:transaction_id].to_s + ") ) ")
			
			if (@track_turn_notes.count<=0)
				logger.debug "Client Track turn/notes not found for pk_track_id=" + params[:track_id].to_s
				render_error('e1039', params[:response_type]) 
				return
			end		
			
			@track_turn_notes.each_with_index  do |track_turn_notes, index|
				@track_turn_notes[index].info_images= track_turn_notes.info_images.split(",")
				@track_turn_notes[index].info_images= track_turn_notes.info_images.uniq				
			end

			data={}
			data=@track_turn_notes
			api_response({ "responsecode" => "200", "server_ip" => image_server_ip, "data" => data},params[:response_type])	
			
		rescue 	=> ex
			render_error('e1016',params[:response_type].to_s,"#{ex.message}") 
			logger.error "error: #{ex.class} , #{ex.message}"
		end
	end

	def add_note
		@client_track = ClientTrack.find(params[:id])
		@client_track.update_attributes(note: params[:note]) if params[:note]
		render json: { note: @client_track.note, track: @client_track }, status: :ok
	rescue => e
		render json: { message: "Track is not found" }, status: :bad_request
	end
	
end
