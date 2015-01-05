class DocumentsController < ApplicationController
  layout 'admin'
  before_filter :check_login
  before_filter :set_document, :only => [:show, :edit, :update, :destroy]

  def index
    discount_id = params[:discount_id]
    if !discount_id.blank?
      @documents = Discount.find(discount_id).documents
    end
    respond_to do |format|
      format.json {
        if @documents.blank?
          head :no_content
        else
          result = {:files => @documents.map { |upload| upload.to_jq_upload }}
          render :json => result.to_json
        end
      }
      format.any { head :no_content }
    end

  end

  # GET /documents/1
  # GET /documents/1.json
  def show
    respond_to do |format|
      format.any { head :no_content }
    end
  end

  # GET /documents/new
  def new
    respond_to do |format|
      format.any { head :no_content }
    end
  end


  # POST /documents
  # POST /documents.json
  def create
    @document = Document.new(document_params)
    @document[:employee_id] = session[:user_id]
    if @document.file_upload.nil?
      flash.now[:msg] = '请选择上文件'
    end
    begin
      Document.transaction do
        @document.save
        #document_type
        #IMG = 0
        #VIDEO = 1
        #FILE = 2
        if IMAGE_REGEXP.match(@document.file_upload.original_filename)
          @document[:document_type]=DOCUMENT_VALUE_KEY[:image]
          @document.images_upload
        elsif VIDEO_REGEXP.match(@document.file_upload.original_filename)
          @document[:document_type]=DOCUMENT_VALUE_KEY[:video]
          @document.videos_upload
        else
          raise '不支持的類型!!'
        end
      end
    rescue
      @document.del_uploads()
    end
  end

  def image_upload
    if params[:files].class == Array
      file_upload = params[:files].first
    else
      file_upload = params[:files]
    end
    old_photo = params[:old_shop_photo]

    if !old_photo.blank?
      document = Document.find(old_photo)
      document.destroy
    end
    files = []
    image_upload=file_upload
    file_extname = File.extname image_upload.original_filename
    file_name = image_upload.original_filename[0, image_upload.original_filename.index(file_extname)].gsub(/[' ','(',')']/, '_')
    new_file_name = "#{Time.now.strftime("%Y%m%d%H%M%S")}#{session[:user_id]}#{file_name}#{file_extname}"
    folder_path = "/image_uploads/#{Time.now.strftime("%Y") }/#{Time.now.strftime("%m")}/#{Time.now.strftime("%d") }/"
    url_path = folder_path + new_file_name
    full_folder_path = "#{Rails.root.to_s}/public#{folder_path}"
    new_file_path = "#{Rails.root.to_s}/public#{url_path}"
    unless File.exist? full_folder_path
      `mkdir -p #{full_folder_path}`
    end

    Dir.mkdir(full_folder_path) unless File.exists?(full_folder_path)

    if !image_upload.original_filename.empty?
      File.open(new_file_path, "wb") do |f|
        f.write(image_upload.read)
        f.close
      end
    end

    #转换格式生成缩略图
    #小图路径
    small_url_thumbnail_path = url_path.gsub(file_extname, "-S#{file_extname}")
    small_thumbnail_path = new_file_path.gsub(file_extname, "-S#{file_extname}")
    %x(convert -resize #{THUMBNAIL_SIZE.small_width}x#{THUMBNAIL_SIZE.small_height} #{new_file_path} #{small_thumbnail_path})
    document = Document.new
    document.status = Document::ENCODE_SUCCESS
    document.original = url_path
    document.screenshot = small_url_thumbnail_path
    document.file_name = file_upload.original_filename
    document.upload_file_size = file_upload.size
    begin
      Document.transaction do
        document.save!
      end
      files << {'url' => document.original,
                'id' => document.id,
                'name' => image_upload.original_filename,
                'size' => file_upload.size,
                'thumbnail_url' => document.screenshot,
                'delete_url' => document_path(document),
                'delete_type' => 'DELETE'}
    rescue
      document.del_uploads
      files<< {
          'name' => image_upload.original_filename,
          'size' => file_upload.size,
          'error' => 'custom_failure'}
    end


    res = {:files => files}
    respond_to do |format|
      format.html {#(html response is for browsers using iframe sollution)
        render :json => res.to_json,
               :content_type => 'text/html',
               :layout => false
      }
      format.json {
        render :json => res.to_json
      }
      format.any { head :no_content }
    end
  end

  # 验证照片是否存在
  def validate
    photo = params[:photo]
    if photo.blank?
      flag = false
    else
      document = Document.find(photo)
      if document.blank?
        flag = false
      else
        flag = true
      end
    end
    respond_to do |format|
      format.json { render :json => flag }
      format.any { head :no_content }
    end

  end

  # DELETE /documents/1
  # DELETE /documents/1.json
  def destroy
    begin
      @document.destroy
      flag = true
    rescue
      error_message = ''
      @document.errors[:error_message].each do |error|
        if error == @document.errors[:error_message].last
          error_message += error.to_s
        else
          error_message += error.to_s + ','
        end
      end
      flash.now[:error] = error_message
      flag = false
    end
    respond_to do |format|
      format.json { render :json => flag }
      format.any { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_document
    begin
      @document = Document.find(params[:id])
    rescue
      error_message = ''
      @document.errors[:error_message].each do |error|
        if error == @document.errors[:error_message].last
          error_message += error.to_s
        else
          error_message += error.to_s + ','
        end
      end
      flash.now[:error] = error_message
      return false
    end

  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def document_params
    params.require(:document).permit(:document_type, :screenshot, :original, :employee_id, :shop_id, :brand_shop_id, :brand_discount, :status, :file_name)
  end
end
