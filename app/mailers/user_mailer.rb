class UserMailer < ActionMailer::Base
  default :from => "do-not-reply@protrack.com"
  
  def register_email(user,user_type)   
    # @url  = "http://example.com/login"   
    domain_url=Protrack::Configuration['domain_url']
	
	user_name=""	
	if user[:client_name].nil? == true
		user_name=user.admin_name 
	 else
		user_name=user.client_name
	end	
	 
    mail(:to => user.email, :subject =>  "Welcome to protrack ", :body => "Please click on link to activate your account on `protrack' : #{domain_url}emails/userverified?uid=#{user.id.to_s}&uval=#{user.encrypt_pwd}&ut=#{user_type}")
  end  
  
  def register_device_user_email(user)   
    # @url  = "http://example.com/login"   
    domain_url=Protrack::Configuration['domain_url']
	
	user_name=""	
	if user[:first_name].nil? == false &&  user[:last_name].nil? == false
		user_name= user.first_name + " " +  user.last_name
	 else
		user_name=user.email
	end	
	 
    mail(:to => user.email, :subject =>  "Welcome to protrack ", :body => "Please click on link to activate your account on `protrack' : #{domain_url}emails/device_userverified?uid=#{user.id.to_s}&uval=#{user.sessionid}")
  end  
      
  def register_race_engineer_email(user)   
    # @url  = "http://example.com/login"   
    domain_url=Protrack::Configuration['domain_url']
	
	user_name=""	
	if user[:race_engineer_name].nil? == false 
		user_name= user.race_engineer_name
	 else
		user_name=user.email
	end	
	  
    mail(:to => user.email, :subject =>  "Welcome to protrack ", :body => "Please click on link to activate your account on `protrack' : #{domain_url}emails/race_engineer_userverified?uid=#{user.id.to_s}&uval=#{user.encrypt_pwd}")
  end  
  
  def forgot_pwd_email(user, user_type)  
	begin
	 domain_url=Protrack::Configuration['domain_url']
	 user_name=""
	
	if user[:client_name].nil? == true
		user_name=user.admin_name 
	 else
		user_name=user.client_name
	 end	
	 
     subject="Reset your password"
     body=" <html> " + 
          " <head> " + 
          " <meta http-equiv=\"Content-Type\" content=\"text/html; charset=iso-8859-1\" /> " +
          " </head> " +
          " <body bgcolor=\"#ffffff\" link=\"#0099cc\" alink=\"#0099cc\" vlink=\"#0099cc\" leftmargin=\"0\" topmargin=\"0\" style=\"text-align: left;\"> " +
          " <div style=\"width: 100%; margin: 30px 0;\"><center>" +
          " <table cellpadding=\"0\" cellspacing=\"0\" border=\"0\" width=\"98%\">" +
          " <tr>" +
          " <td style=\"padding: 15px; font-family: Helvetica, Arial, sans-serif; font-size: 16px; line-height: 1.3em; text-align: left;\">" +
          " <p>" +
          " Protrack " +
          " </p>" +
          " </td>" +
          " </tr>" +
          " <tr>" +
          " <td style=\"padding: 15px; padding-top: 10px; padding-bottom: 40px; font-family: Helvetica, Arial, sans-serif; font-size: 16px; line-height: 1.3em; text-align: left;\" valign=\"top\">" +     
          " <h1 style=\"font-family: Helvetica, Arial, sans-serif; color: #222222; font-size: 28px; line-height: normal; letter-spacing: -1px;\">" +
          " Reset your Protrack password" +
          " </h1>" +
          " <p>Hi #{user_name} ,</p>" +
          " <p>Can't remember your password? Don't worry about it &mdash; it happens.</p>" +
          " <p>Your email is: <strong>#{user.email}</strong></p>" +
          " <p><b>Just click this link to reset your password:</b><br />" +
          " <a href=\"#{domain_url}emails/saveforgotpwd?uid=#{user.id.to_s}&uval=#{user.reset_pswd_token}&ut=#{user_type}\">#{domain_url}emails/saveforgotpwd?uid=#{user.id.to_s}&uval=#{user.reset_pswd_token}&ut=#{user_type}</a></p>" +
          " <hr style=\"margin-top: 30px; border:none; border-top: 1px solid #ccc;\" />" +
          " <p style=\"font-size: 13px; line-height: 1.3em;\"><b>Didn't ask to reset your password?</b><br />If you didn't ask for your password, it's likely that another" +
          " user entered your username or email address by mistake while" +
          " trying to reset their password. If that's the case, you don't" +
          " need to take any further action and can safely disregard this email." +
          " </p>" +
          " </td>" +
          " </tr>" +
          " </table>" +
          " </center>" +
          " </div>" +
          " </body>" +
          " </html>"     

      mail(:to => user.email, :subject => subject, :body => body,  :content_type => 'text/html') 
	rescue => ex
		logger.info "Mail error : #{ex.class} , #{ex.message}"		
	end
  end
 
end 