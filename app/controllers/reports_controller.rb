class ReportsController < ApplicationController

	def transaction_history
		record_per_page=Protrack::Configuration['pagesize']
	
		client_id=session[:client_id] || 0		
		admin_id=session[:admin_id] || 0			
		if (admin_id.to_i > 0 )
			client_id = session[:proxy_client_id] || 0 						
		end

		@transaction=Transaction.get_transaction(client_id.to_i,record_per_page,params[:page])
					
		render :action => "transaction_history", :layout => "common_layout"
	end	
	
	def view_transaction	
		client_id=session[:client_id] || 0	
		admin_id=session[:admin_id] || 0	
		if (admin_id.to_i > 0 )
			client_id = session[:proxy_client_id] || 0 						
		end
		
		@transaction=Transaction.get_selected_transaction(client_id, params[:id])
		if @transaction.nil? == true
			render_error :error_code => 'e375'
			redirect_to :action => 'transaction_history'
			return	
		end
		
		render :action => "view_transaction", :layout => "common_layout"
	end
	
	
	def restore_apps_history
		record_per_page=Protrack::Configuration['pagesize']
	
		client_id=session[:client_id] || 0		
		admin_id=session[:admin_id] || 0	
		if (admin_id.to_i > 0 )
			client_id = session[:proxy_client_id] || 0 						
		end
		
		@user_restore_app_info=UserRestoreAppInfo.get_restore_apps(client_id.to_i,record_per_page,params[:page])
							
		render :action => "restore_apps_history", :layout => "common_layout"
	end	
		
	def view_restore_app	
		client_id=session[:client_id] || 0		
		admin_id=session[:admin_id] || 0	
		if (admin_id.to_i > 0 )
			client_id = session[:proxy_client_id] || 0 						
		end
		
		@user_restore_app_info=UserRestoreAppInfo.get_selected_restore_app(client_id, params[:id])
		if @user_restore_app_info.nil? == true
			render_error :error_code => 'e375'
			redirect_to :action => 'restore_apps_history'
			return	
		end
		
		render :action => "view_restore_app", :layout => "common_layout"
	end
	
end