 require 'net/http'        
 require 'net/https'
 require 'uri'
  
class Api::ApiController < ActionController::Base
    include Protrack::Apiload	
	# before_filter :validate_data
	# before_filter :validate_request, :only => [:coockies_post_report, :coockies_patch_report, :coockies_delete_report, :coockies_update_turns, :coockies_user_logout, :coockies_get_track]
	
	#validation request	
	def validate_request 
		val_required='required'
		data_val_required='data_required'
		user_id="";
		client_id="";
		session_id="";
		
		if(cookies[:user_id])
			user_id= cookies[:user_id].to_s
		end
		
		if(cookies[:client_id])
			client_id= cookies[:client_id].to_s
		end
		
		if(cookies[:session_id])
			session_id= cookies[:session_id].to_s
		end
		
		if client_id.empty? == true || session_id.empty? == true
			logger.debug "Client not found for client_id=" + client_id
			coockies_render_error('e1011',params[:response_type].to_s)  
			return false
		end
		
		@client=Client.where(pk_client_id: client_id)		
		if (@client.count<=0)
			logger.debug "Client not found for client_id=" + client_id
			coockies_render_error('e1011',params[:response_type].to_s)  
			return false
		end			
		
		@device_users=DeviceUser.where(fk_client_id: client_id, pk_user_id: user_id, sessionid: session_id) 
		
		if (@device_users.count<=0)	
			logger.debug "device_users not found for client_id=" + client_id+ " and session_id=" + session_id + " "
			coockies_render_error('e1012',params[:response_type].to_s)  
			return false
		else
			if @device_users[0][:status_code] == 403
				coockies_render_error('e2203',params[:response_type].to_s)  
				return false
			end

			if @device_users[0][:status_code] == 402
				coockies_render_error('e2204',params[:response_type].to_s)  
				return false
			end
		end
	
		params[:user_id]=user_id
		params[:client_id]=client_id
		params[:session_id]=session_id
		
		return true
	end
	
	def validate_data		
		val_required='required'
		data_val_required='data_required'
		coockies="coockies"
		#render :json => Protrack::Apiload[params[:action]]
		#return
				
		if all_required(params, Protrack::Apiload[params[:action]][val_required]) ==false
			if Protrack::Apiload[params[:action]][coockies].nil? == false
				coockies_render_error('e1005','json',@api_errmsg.join(',') + ' fields are missing')
			else
				render_error('e1005','json',@api_errmsg.join(',') + ' fields are missing')
			end
			return false
		end
		
		if data_required(params[:data], Protrack::Apiload[params[:action]][data_val_required]) ==false
			if Protrack::Apiload[params[:action]][coockies].nil? == false
				coockies_render_error('e1005','json',@api_errmsg.join(',') + ' fields are missing')
			else
				render_error('e1005','json',@api_errmsg.join(',') + ' fields are missing')
			end
			return false
		end
		
		return true
	end
	
	#generate error message from local file code
    def render_error(error_code=nil,error_format='json',error_summary=nil)
      if params[:response_type]=="2" 
        error_format='xml'
      end
      if params[:response_type].nil? == true
		error_format='json'
	  end
	  
      if error_summary.nil?
        error_desc = t(error_code+'.errorcode').to_s + ": " + t(error_code+'.errordescription')
        logger.debug "API Error: #{error_desc}"
      else
        logger.debug "API Error: #{error_summary}"
      end  
      
      case error_format
      when 'json'
        if error_summary.nil?
          render :json => {responsecode: t(error_code+'.errorcode'),errormessage: t(error_code+'.errordescription')}
		else
          render :json => {responsecode: t(error_code+'.errorcode'),errormessage: error_summary}
		 end  
      when 'xml'
        if error_summary.nil?
          render :xml => {responsecode: t(error_code+'.errorcode'),errormessage: t(error_code+'.errordescription')}
		else
          render :xml => {responsecode: t(error_code+'.errorcode'),errormessage: error_summary}
		end
      end
    end
	
	#generate error message from local file code for cookies
    def coockies_render_error(error_code=nil,error_format='json',error_summary=nil)
      if params[:response_type]=="2" 
        error_format='xml'
      end
      if params[:response_type].nil? == true
		error_format='json'
	  end
	  
      if error_summary.nil?
        error_desc = t(error_code+'.errorcode').to_s + ": " + t(error_code+'.errordescription')
        logger.debug "API Error: #{error_desc}"
      else
        logger.debug "API Error: #{error_summary}"
      end  
      
      case error_format
      when 'json'
        if error_summary.nil?
         render :json => {:success => false, :error => { :code => t(error_code+'.errorcode'), :description => t(error_code+'.errordescription')}}
        else
      	  render :json => {:success => false, :error => { :code => t(error_code+'.errorcode'), :description => error_summary}}
        end  
      when 'xml'
        if error_summary.nil?
           render :xml => {:success => false, :error => { :code => t(error_code+'.errorcode'), :description => t(error_code+'.errordescription')}}     
        else
           render :xml => {:success => false, :error => { :code => t(error_code+'.errorcode'), :description => error_summary}}
        end
      end
    end
  
	 #find out required parameter required for api request and assign value
	def all_required(data, fields)		
		if fields.nil? == true
			return true
		end
		@api_errmsg = Array.new
		fields = fields.split(',')
		flag = true
		fields.each do |name|
			if data[name].nil?
			  @api_errmsg.push(name)
			  flag = false
			end
		end
		if flag == true
		   return true
		end
		return false
	end
	
	def data_required(data_json, fields)
		if (fields.nil? == true || fields.empty? == true)
			return true
		end	
		
		if (data_json.nil? == true || data_json.empty? == true)
			return false
		end	
	    data=JSON.parse(data_json)
		#logger.debug data[0]
	
		@api_errmsg = Array.new
		fields = fields.split(',')
		flag = true
		array_index=0
		data.each do |dt|
			#logger.debug "DATA" + dt.to_s 
			fields.each do |name|
				if dt[name].nil?
				  @api_errmsg.push("[" + array_index.to_s + "][" + name + "]")
				  flag = false
				end
			end
			array_index = array_index + 1
		end
		
		if flag == true
		   return true
		end
		return false
	end
	
	def api_response(data,response_type)
	
     #logger.debug "Output: #{data.inspect}"
      
     #if !data.has_key?('responsecode')
     #  data['responsecode']='200'
     #end 
  
     if response_type == '2'
        render :xml => data.to_xml(:dasherize => false)
     else
        render :json => data
     end
   end
	
	def verify_reciept(receipt_data)
	  b64_receipt=receipt_data
	 # b64_receipt=Base64.encode64(receipt_data)
	 # logger.debug "verify_reciept status: " + b64_receipt.to_s 	
      url = URI.parse("https://buy.itunes.apple.com/verifyReceipt")
     # url = URI.parse("https://sandbox.itunes.apple.com/verifyReceipt")
  
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      valid = false
	  val_reciept_data={}
      json_request = {'receipt-data' => b64_receipt, 'password' => '74123d88a3904c478bd6381ff152b828'}.to_json
      resp, resp_body = http.post(url.path, json_request.to_s, {'Content-Type' => 'application/x-www-form-urlencoded'})

	 # logger.debug "verify_reciept status: " + resp.code.to_s 	
      if resp.code == '200'
        json_resp = JSON.parse(resp_body)
		#logger.debug "get_track_info resp_body: " + resp_body	
        if json_resp['status'] == 0
		  logger.debug "get_track_info success: " + json_resp['status'].to_s	
		  val_reciept_data=json_resp['receipt']
         # valid = true
        end
      end
      #valid
	  val_reciept_data
    end 
	
	def ver_rec(receipt_data)
		# This core reads an file called receipt (see an example bellow)
		params_json = "{ \"receipt-data\": \"#{receipt_data}\"  }"
		 
		# Use net/http to post to apple sandbox server
		#URI("https://sandbox.itunes.apple.com") #for production
		uri = "https://buy.itunes.apple.com" 
		Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
			response = http.post('/verifyReceipt', params_json)
			# Puts the result! (see an example below - result.json)
			#puts response.body
			logger.debug "ver_rec: " + response.body
		end
	end
 
end