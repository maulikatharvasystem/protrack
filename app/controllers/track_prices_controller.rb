class TrackPricesController < ApplicationController
	
	def index
		record_per_page=Protrack::Configuration['pagesize']
		
		client_id=session[:client_id] || 0
		admin_id=session[:admin_id] || 0
		if (admin_id.to_i > 0 )
			client_id = session[:proxy_client_id] || 0 						
		end
		
		@track_price=ProductPrice.get_track_price_page(client_id.to_i, record_per_page, params[:page])			
		
		#render :json => @track_price
		#return 		
		render :action => "index", :layout => "common_layout"
	end
	
	def add
		client_id=session[:client_id] || 0
		admin_id=session[:admin_id] || 0
		if (admin_id.to_i > 0 )
			client_id = session[:proxy_client_id] || 0 						
		end
		
		@track_price=ProductPrice.new
		@track_price.fk_client_id=client_id
		
		render :action => "add", :layout => "common_layout"
	end	
		
	def create
		begin
			#render :json => params
			#return			
			
			@track_price=ProductPrice.new	
			@track_price.fk_client_id=params[:product_price][:fk_client_id]				
						
			@track_price.ios_product_id=params[:product_price][:ios_product_id].to_s.strip
			@track_price.ios_price=params[:product_price][:ios_price]
			@track_price.android_product_id=params[:product_price][:android_product_id].to_s.strip		
			@track_price.android_price=params[:product_price][:android_price]	
			@track_price.description=params[:product_price][:description]							
					
			@track_price.status_code=401
			@track_price.create_ip=request.remote_ip 	
			@track_price.last_updated_ip=request.remote_ip
		  						
			if @track_price.valid? == false  				
				render :action => 'add'
				return		    
			end	
			 
			if @track_price.save!
				render_error :error_code => 'e356'  ## Display error message email/password does not match..       
				redirect_to(:action => 'index')
				return	
			else
				#render_error :error_code => 'e354'  ## Display error message email/password does not match..       
				render :action => "add"
				return
			end
		rescue
			render_error :error_code => 'e354'  ## Display error message email/password does not match..       
			render :action => "add"
			return
		end			
		render :action => "add"
	end
		
	def edit
		client_id=session[:client_id] || 0
		admin_id=session[:admin_id] || 0
		if (admin_id.to_i > 0 )
			client_id = session[:proxy_client_id] || 0 						
		end
		
		@track_price=ProductPrice.get_selected_track_price(client_id.to_i, params[:id])	
		
		if @track_price.nil? == true
			render_error :error_code => 'e375'
			redirect_to :action => 'index'
			return	
		end
		#render :json => @track_price
		#return
		
		render :action => "edit", :layout => "common_layout"
	end	
	
	def update
		begin
			#render :json => params
			#return			
			@track_price=ProductPrice.find(params[:id])
			
			#@track_price.fk_client_id=params[:track_price][:fk_client_id]
			@track_price.ios_product_id=params[:product_price][:ios_product_id].to_s.strip
			@track_price.ios_price=params[:product_price][:ios_price]
			@track_price.android_product_id=params[:product_price][:android_product_id].to_s.strip		
			@track_price.android_price=params[:product_price][:android_price]	
			@track_price.description=params[:product_price][:description]							
			@track_price.last_updated_ip=request.remote_ip	
						
			#render :json => @product_price
			#return	

			if @track_price.valid? == false  				
				render :action => 'edit', :id => params[:id]
				return		    
			end				 			
			
			if @track_price.save!
				render_error :error_code => 'e355'  ## Display error message email/password does not match..       
				redirect_to(:action => 'index')
				return	
			else
				#render_error :error_code => 'e354'  ## Display error message email/password does not match..       
				render :action => 'edit', :id => params[:id]
				return
			end
		rescue
			render_error :error_code => 'e354'  ## Display error message email/password does not match..       
			render :action => "edit", :id => params[:id]
			return
		end			
		render :action => "edit", :id => params[:id]
	end
		
	def view				
    	client_id=session[:client_id] || 0
		admin_id=session[:admin_id] || 0
		if (admin_id.to_i > 0 )
			client_id = session[:proxy_client_id] || 0 						
		end
		
		@track_price=ProductPrice.get_selected_track_price(client_id.to_i, params[:id])	
		if @track_price.nil? == true
			render_error :error_code => 'e375'
			redirect_to :action => 'index'
			return	
		end
		
		render :action => "view", :layout => "common_layout"
	end
	
	def delete
		begin
			@track_price=ProductPrice.find(params[:id])
			@track_price.status_code=403 # record delete : 403
			 
			if @track_price.save!
				render_error :error_code => 'e357'  ## Display error message email/password does not match..       
				redirect_to :action => 'index'
				return	
			else
				render_error :error_code => 'e354'  ## Display error message email/password does not match..       
				redirect_to :action => 'view', :id => params[:id]
				return
			end
		rescue => ex
			logger.info "Delete track price error : #{ex.class} , #{ex.message}"
			
			render_error :error_code => 'e354'  ## Display error message email/password does not match..       
			redirect_to :action => 'view', :id => params[:id]
			return
		end			
		render :action => "view", :id => params[:id]
	end
	
end
