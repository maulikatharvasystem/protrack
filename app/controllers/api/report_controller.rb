require 'set'

class Api::ReportController < Api::ApiController
    #include Protrack::Apiload

	#1.A
	def coockies_post_report 
		begin
			#render :json => params
			#return
			#logger.debug "coockies_post_report: " + params.to_s							
			@user_report=UserReport.new	

			@user_report[:fk_client_id]=params[:client_id] || "0"	
			@user_report[:fk_user_id]=params[:user_id] || "0"
				
			#@user_report[:name]=params[:name] || ""
			@user_report[:circuit]=params[:circuit] || ""
			@user_report[:engineer_name]=params[:engineer_name] || ""	
			@user_report[:event]=params[:event] || ""	
			@user_report[:report_time]=params[:report_time] || ""	
			@user_report[:championship]=params[:championship] || ""				
			@user_report[:status_code]= "401"
			
			if @user_report.valid? == false 			
				coockies_render_error('e2101', params[:response_type],@user_report.errors.messages) 
				return
			end
			
			if @user_report.save!
				#track_turn_note saved
			else
				coockies_render_error('e2102', params[:response_type]) 
				return
			end
			
			# if params[:fields].count <=0			
				# coockies_render_error('e1011', params[:response_type]) 
				# return
			# end			
			
			if params[:fields].nil? == false && params[:fields].count >0
				@user_report_field=UserReportField.where(fk_report_id: @user_report.id.to_i)
				@user_report_field.destroy_all	
				
				begin
					params[:fields].each do |fields|
						@user_report_field=UserReportField.new	

						@user_report_field[:fk_client_id]=params[:client_id] || "0"	
						@user_report_field[:fk_user_id]=params[:user_id] || "0"
						@user_report_field[:fk_report_id]=@user_report.id || "0"
						
						@user_report_field[:key]=fields[:key] || ""
						@user_report_field[:name]=fields[:name] || ""	
						@user_report_field[:value]=fields[:value] || ""	
						@user_report_field[:need_rating]= fields[:need_rating] || true	
						@user_report_field[:rating]= fields[:rating] || "0"										
						
						if @user_report_field.save!
							logger.error " @user_report_field: #{ @user_report_field.id.to_s}"
						end					
					end
				rescue 	=> ex	
					#logger.error "erro: #{ex.class} , #{ex.message}"
					#render :json =>  "erro: #{ex.class} , #{ex.message}"
					#return	
				end
			end
							  
			api_response({"success" => true, "server_id" => @user_report.id.to_i}, params[:response_type])
		rescue 	=> ex
			coockies_render_error('e2102',params[:response_type].to_s,"#{ex.message}") 
			#logger.error "erro: #{ex.class} , #{ex.message}"
		end
	end
		
	#2.A
	def coockies_patch_report 
		begin
			#logger.debug "coockies_post_report: " + params.to_s	
			@user_report=UserReport.where(pk_report_id: params[:id].to_i, status_code: "401")				
			if (@user_report.count<=0)
				logger.debug "user_report not found for client_id=" + params[:client_id].to_s
				coockies_render_error('e2103', params[:response_type]) 
				return
			end		
			
			@user_report=@user_report[0]		
				
			@user_report[:circuit]=params[:circuit] || @user_report.circuit
			@user_report[:engineer_name]=params[:engineer_name] || @user_report.engineer_name
			#@user_report[:name]=params[:name] || @user_report.name	
			@user_report[:event]=params[:event] || @user_report.event
			@user_report[:report_time]=params[:report_time] || @user_report.report_time	
			@user_report[:championship]=params[:championship] || @user_report.championship			
			
			if @user_report.valid? == false 
				coockies_render_error('e2101', params[:response_type],@user_report.errors.messages)  
				return
			end
			
			if @user_report.save!
				#track_turn_note saved
			else
				coockies_render_error('e2102', params[:response_type]) 
				return
			end
			
			@user_report_field=UserReportField.where(fk_report_id: @user_report.id.to_i)
			@user_report_field.destroy_all	
			
			begin
				params[:fields].each do |fields|
					@user_report_field=UserReportField.new	

					@user_report_field[:fk_client_id]=params[:client_id] || "0"	
					@user_report_field[:fk_user_id]=params[:user_id] || "0"
					@user_report_field[:fk_report_id]=@user_report.id || "0"
					
					@user_report_field[:key]=fields[:key] || ""
					@user_report_field[:name]=fields[:name] || ""	
					@user_report_field[:value]=fields[:value] || ""	
					@user_report_field[:need_rating]= fields[:need_rating] || true	
					@user_report_field[:rating]= fields[:rating] || "0"										
					
					if @user_report_field.save!
						logger.error " @user_report_field: #{ @user_report_field.id.to_s}"
					end					
				end
			rescue 	=> ex	
				#logger.error "erro: #{ex.class} , #{ex.message}"
				#render :json =>  "erro: #{ex.class} , #{ex.message}"
				#return	
			end
							  
			api_response({"success" => true}, params[:response_type])
		rescue 	=> ex
			coockies_render_error('e2102',params[:response_type].to_s,"#{ex.message}") 
			#logger.error "erro: #{ex.class} , #{ex.message}"
		end
	end
	
	#3.A
	def coockies_delete_report 
		begin
			#logger.debug "coockies_delete_report: " + params.to_s		
			
			@user_report=UserReport.where(pk_report_id: params[:id].to_i)				
			if (@user_report.count<=0)
				#logger.debug "user_report not found for client_id=" + params[:client_id].to_s
				coockies_render_error('e2103', params[:response_type]) 
				return
			end					
			
			#@user_report=@user_report[0]
			#@user_report.status_code="403"
			@user_report_field=UserReportField.where(fk_report_id: params[:id].to_i)
			if @user_report_field.destroy_all	
				@user_report.destroy_all							
				#track_turn_note saved
			else
				coockies_render_error('e2102', params[:response_type]) 
				return
			end
		
			api_response({"success" => true}, params[:response_type])
		rescue 	=> ex
			coockies_render_error('e2102',params[:response_type].to_s) 
			#logger.error "erro: #{ex.class} , #{ex.message}"
		end
	end
	
	
end
