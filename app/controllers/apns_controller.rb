require 'apn_on_rails'
class ApnsController < ApplicationController	
	skip_before_filter :require_login, :only => [:send_group_notification_params]
	
	def self.register_cert
		begin
			apns_dev_cert_path=Protrack::Configuration['apns_dev_cert_path']
			apns_prod_cert_path=Protrack::Configuration['apns_prod_cert_path']

			app = APN::App.all
			total_app= app.count
			
			if total_app <= 0
				app = APN::App.new				
			else
				app = app.first				
			end	
			
			app.apn_prod_cert = File.read(apns_dev_cert_path)
			app.apn_dev_cert = File.read(apns_prod_cert_path)
			app.save
			return true
		rescue 	=> ex			
			logger.error "erro: #{ex.class} , #{ex.message}"
		end		
		return false
	end
	
	def self.register_device(token)
		begin
			app = APN::App.first				
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
			return device
		rescue 	=> ex
			logger.error "erro: #{ex.class} , #{ex.message}"
		end		
	end
	
	def self.register_group(group_name)
		begin
			app = APN::App.first	
			group = APN::Group.where(:name => group_name)
			total_group= group.count
		
			if total_group <= 0
				group = APN::Group.new
				group.name = group_name
				group.app_id = app.id
				group.save(validate: false)			
			else
				group = group.first	
			end
			return group
		rescue 	=> ex
			logger.error "erro: #{ex.class} , #{ex.message}"
		end	 		
	end
	
	def self.send_device_notification(token, alert_message)
		begin
			app = APN::App.first
			device=register_device(token);
			
			notification = APN::Notification.new
			notification.device = device
			notification.badge = 5
			notification.sound = true
			notification.alert = alert_message
			notification.save	

			APN::App.send_notifications		
			return true			
		rescue 	=> ex
			logger.error "erro: #{ex.class} , #{ex.message}"
		end	
		return false
	end
	
	def self.send_group_notification(alert_message, client_id, turn_id )
		begin
			app = APN::App.first
			devices = APN::Device.all
			devices = APN::Device.where(" token in (select device_token from user_devices where fk_client_id=" + client_id.to_s + ")")
			group = register_group('client_' + client_id.to_s)				
			group.devices = devices		
						
			notification = APN::GroupNotification.new
			notification.group = group
			notification.alert = alert_message
			notification.sound = true

			notification.custom_properties = {"userInfo" => {"type" => "didChangeTurnInfo", "serverID" => turn_id } }

			notification.save(validate: false)		
	
			APN::App.send_group_notifications
			APN::App.process_devices
			
			return true
		rescue 	=> ex
			logger.error "erro: #{ex.class} , #{ex.message}"
		end	
		return false
	end
	
	def send_group_notification_params()
		#ret =
		ApnsController::send_group_notification(params[:alert_message], params[:client_id])
		#render :json => ret
		#return
	end
	
	def index	
		# app = APN::App.first
		# devices = APN::Device.where(" token in (select device_token from user_devices where fk_client_id=2)")
		
		  # render :json =>devices
		  # return
	 
		token="1726e0b019fda4c032b0f9fbbfd3c0f610f70a55cab39c959e4c78cdef1721a2"
		app = APN::App.all
		total_app= app.count
		if total_app <= 0
			app = APN::App.new
			app.apn_prod_cert = File.read(Protrack::Configuration['apns_dev_cert_path'])
			app.apn_dev_cert = File.read(Protrack::Configuration['apns_prod_cert_path'])
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
	
end