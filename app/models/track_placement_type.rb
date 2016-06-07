class TrackPlacementType < ActiveRecord::Base
  belongs_to :track__turn_note
     
  def self.get_track_placement_type()
	where_cond = " where status_code in(401) "
		
	@track_placement_type=TrackPlacementType.find_by_sql("select pk_plactype_id, plac_name from track_placement_types  " +		
		where_cond + " ")		
	return @track_placement_type
  end
  
end
