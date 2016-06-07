require 'apn_on_rails'
class DashboardController < ApplicationController
	#skip_before_filter :require_login, :only => [:login, :attempt_login]

	def index1
		token="51c9dcf10a673332931e2373821d07ec24bb82903f5e133c48da4e18f408294f"
		#token="9efcd91e78866f8ef4d89da8e39ba626dab763d6679736de4eb5d56ef54f0a42" #Fitspo
		
		app = APN::App.all
		total_app= app.count
		if total_app <= 0
			app = APN::App.new
			app.apn_prod_cert = File.read('config/apple_push_notification_production.pem')
			app.apn_dev_cert = File.read('config/apple_push_notification_production.pem')
			#PremaFDA_Production_Push_Certificate.pem')darratorres
			app.save
		else
			app = app.last
		end		
		
		# render :json => app
		# return
		
		device = APN::Device.where(:token => token)
		total_device= device.count
	
		if total_device <= 0
			device = APN::Device.new
			device.token = token #self.device_token
			device.app_id=app.id
			device.save(validate: false)
		else
			device = device.first
		end
				
		 # render :json =>device
		 # return
				
		#notification = APN::Notification.all
		#total_notification= notification.count
		#if total_notification <= 0
			notification = APN::Notification.new
			notification.device = device
			notification.badge = 5
			notification.sound = true
			notification.alert = "Testing prema racing app push"
			notification.save	
		#else
		#		notification = notification.first
		#end
		
			#render :json => APN::configatron.apn.cert
		   #return
		
		 @test = APN::App.send_notifications

		 render :json => @test
		 return
		render :action => "index", :layout => "common_layout"
	end
	
	def index	
		render :action => "index", :layout => "common_layout"
	end
	
	def back_to_admin	
		session.delete(:proxy_client_id)
		session.delete(:proxy_client_name)
		redirect_to :action => "index"
	end
		
end
