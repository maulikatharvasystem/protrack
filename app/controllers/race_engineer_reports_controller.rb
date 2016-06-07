class RaceEngineerReportsController < ApplicationController
  skip_before_filter :require_login, :only => [:update]
  require 'fileutils'

  def index
    record_per_page=Protrack::Configuration['pagesize']
    if params[:id]
      @race_engineer_reports = RaceEngineerReport.where('circuit = ? ', params[:id]).paginate(:per_page => record_per_page, :page => params[:page])
    else
      @race_engineer_reports = RaceEngineerReport.paginate(:per_page => record_per_page, :page => params[:page])
    end
  end

  def new
    race_engineer = RaceEngineer.find(session[:engn_id])
    @race_engineer_report = RaceEngineerReport.new() do |race_report|
      race_report.race_engineer_id = race_engineer.id if race_engineer
      race_report.client_id = race_engineer.fk_client_id if race_engineer
      race_report.engineer_name = session[:user_name].to_s
      race_report.report_date = Date.today.to_s
    end
  end

  def create
    abort params.inspect
  end

  def create_ajax
    # begin
      # abort params.inspect
      @race_engineer_report = RaceEngineerReport.new(params[:race_engineer_report])
      @race_engineer_report.engineer_name = session[:user_name].to_s
      @race_engineer_report.create_ip=request.remote_ip
      @race_engineer_report.last_updated_ip=request.remote_ip
      @race_engineer_report.status_code=401

      unless params[:race_engineer_report][:report_info].nil?
        track_image_filename_=params[:race_engineer_report][:report_info].original_filename.to_s
        track_img_name=track_image_filename_.split('/').last
        track_img_extn=track_img_name.split('.').last
        if @race_engineer_report.race_engineer.race_engineer_name.nil?
          track_newfilename = "Report_info_pdf_#{(Time.now.strftime('%y%m%d'))}}"
        else
          track_newfilename = "Report_info_pdf_#{(Time.now.strftime('%y%m%d'))}_#{@race_engineer_report.race_engineer.race_engineer_name.split(' ').join('_') }"
        end
        track_newfilename = track_newfilename + '.' + track_img_extn
        report_info_pdf_path="/assets/images/client/client_" + @race_engineer_report.client_id.to_s + "/report_info_pdf/"
        save_file_url(params[:race_engineer_report][:report_info],track_newfilename, report_info_pdf_path)
        public_url_image_path="/assets/client/client_" + @race_engineer_report.client_id.to_s + "/report_info_pdf/"

        @race_engineer_report.report_info= public_url_image_path + track_newfilename

      end

      if @race_engineer_report.valid?
        if @race_engineer_report.save!
          render :json => {:resp_code => "200", :message => I18n.t(:race_report_created)}
          return
        else
          render :json => {:resp_code => "402", :message => I18n.t(:race_report_invalid)}
          return
        end
      else
        error_messages=""
        if @race_engineer_report.errors.full_messages.length >0
          @race_engineer_report.errors.full_messages.each do |msg|
            if error_messages.empty? == false
              error_messages =  error_messages + ", \n "
            else
              error_messages =  error_messages + " \n "
            end
            error_messages =  error_messages +  msg
          end
        end
        render :json => {:resp_code => "401", :message => error_messages}
        return
      end
    # rescue => ex
      logger.error "erro: #{ex.class} , #{ex.message}"
      render :json => {:resp_code => "403", :message => I18n.t(:race_report_invalid)}
      return
    # end
    render :json => {:resp_code => "404", :message => I18n.t(:race_report_invalid)}
  end


  def edit
   @race_engineer_report =  RaceEngineerReport.find(params[:id])
  end
  def update
   @race_engineer_report = RaceEngineerReport.find(params[:id])

   unless params[:race_engineer_report][:report_info].nil?
     track_image_filename_=params[:race_engineer_report][:report_info].original_filename.to_s
     track_img_name=track_image_filename_.split('/').last
     track_img_extn=track_img_name.split('.').last
     if @race_engineer_report.race_engineer.race_engineer_name.nil?
       track_newfilename = "Report_info_pdf_#{(Time.now.strftime('%y%m%d'))}}"
     else
       track_newfilename = "Report_info_pdf_#{(Time.now.strftime('%y%m%d'))}_#{@race_engineer_report.race_engineer.race_engineer_name.split(' ').join('_') }"
     end
     track_newfilename = track_newfilename + '.' + track_img_extn
     report_info_pdf_path="/assets/images/client/client_" + @race_engineer_report.client_id.to_s + "/report_info_pdf/"
     save_file_url(params[:race_engineer_report][:report_info],track_newfilename, report_info_pdf_path)
     public_url_image_path="/assets/client/client_" + @race_engineer_report.client_id.to_s + "/report_info_pdf/"

     params[:race_engineer_report][:report_info]= @race_engineer_report_path =  public_url_image_path + track_newfilename
   end

   @race_engineer_report.update_attributes(params[:race_engineer_report], report_info: @race_engineer_report_path)

   redirect_to :action => 'index'
  end

  def show
    @race_engineer_report =  RaceEngineerReport.find(params[:id])
  end

  def destroy
    RaceEngineerReport.destroy(params[:id])
    redirect_to :action => 'index'
  end

  def save_file_url(params_name,filename, path)
    begin
      dir= File.join(Rails.root, "app", path)
      FileUtils::mkdir_p dir unless File.exists?(dir)

      path = File.join(Rails.root, "app", path, filename)
      # write the file
      File.open(path, "wb") { |f| f.write(params_name.read) }
    rescue => ex
      logger.info "erro: #{ex.class} , #{ex.message}"
    end
  end

end
