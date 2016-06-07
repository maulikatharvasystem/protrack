# Renders an error response
module Protrack
  module Messages
      def render_error(arg)
        @error_code = arg[:error_code]
            flash[:message] = render_to_string :template => 'common/error', :layout => false
      end 
  end
end