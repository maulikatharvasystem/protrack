class UserRestoreAppInfo < ActiveRecord::Base
  # attr_accessible :title, :body
  
     
  def self.get_restore_apps(client_id, per_page, page_no)
	#where_cond = " where RT.status_code in(401,402) "\
	where_cond = ""
	
	if client_id > 0		
		where_cond= where_cond + " where RT.fk_client_id=" +  client_id.to_s  + " "	
	end
	
	@user_restore_app_info=UserRestoreAppInfo.paginate_by_sql("SELECT pk_user_restore_id , track_name, RT.create_at  " +
		" FROM client_tracks CT " +
		" LEFT OUTER JOIN user_restore_app_infos RT ON RT.str_fk_track_id LIKE concat( '%', CT.pk_track_id, '%' ) " +		
		where_cond + " order by pk_user_restore_id desc ", :per_page => per_page , :page => page_no)
		
	return @user_restore_app_info
  end
  
  def self.get_selected_restore_app(client_id, restore_id)
	where_cond= " where RT.pk_user_restore_id=" +  restore_id.to_s  + " "
	
	if client_id.to_i > 0		
		where_cond= where_cond + " and RT.fk_client_id=" +  client_id.to_s  + " "	
	end
	
	@user_restore_app_info=UserRestoreAppInfo.find_by_sql("SELECT pk_user_restore_id as id,track_name, RT.create_at  " +
		" FROM client_tracks CT " +
		" LEFT OUTER JOIN user_restore_app_infos RT ON RT.str_fk_track_id LIKE concat( '%', CT.pk_track_id, '%' ) " +		
		where_cond + " ")	
		
	return @user_restore_app_info.first
  end
  
end
