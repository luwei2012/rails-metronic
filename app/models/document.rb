class Document < ActiveRecord::Base
  include ActiveModel::Validations
  validates_with Validator
  belongs_to :shop
  belongs_to :discount
  attr_accessor :file_upload
  include Backburner::Queue
  queue "encode-jobs" # defaults to 'user'
  queue_priority 500 # most urgent priority is 0
                      #document_type
  queue_respond_timeout 300
  IMG = 0
  VIDEO = 1
  FILE = 2

  ENCODE_NO = 0
  ENCODE_SUCCESS = 1
  ENCODE_FAILED = 2
  ENCODE_PROCESS = 3

  # 异步调用 Document.async.encode_video
  def self.encode_video(root_path, relative_path, document_id)
    file_path = root_path + relative_path
    ext = File.extname file_path
    folder_path = file_path[0, file_path.index(ext)]
    folder_relative_path = relative_path[0, relative_path.index(ext)]
    document = Document.find document_id
    unless File.exist? folder_path
      `mkdir -p #{folder_path}`
    end
    file_name = (document[:title].blank?) ? 'default' : document[:title][0, document[:title].index(ext)]
    image_thumb = "#{folder_path}"+ '/'+file_name+'.jpg'
    m3u8_path = "#{folder_path}" + '/'+file_name+'.m3u8'
    %x(ffmpeg -y -i #{file_path}  -y -f mjpeg -ss 8 -t 0.001 -vf scale="trunc(oh*a/2)*2:270" #{image_thumb})
    %x(ffmpeg -y -i #{file_path}  -hls_time 10 -hls_list_size 10000 -vcodec libx264 -acodec libfaac -crf 23 -vf scale="trunc(oh*a/2)*2:480" -deinterlace #{m3u8_path})
    if File.exist?(image_thumb) && File.exist?(m3u8_path)
      # 压缩完成更新数据库中视频的状态为完成

      document.status = Document::ENCODE_SUCCESS
      document.screenshot = folder_relative_path + '/'+file_name+'.jpg'
      document.original = folder_relative_path + '/'+file_name+'.m3u8'
      document.save
    else
      document.status = Document::ENCODE_FAILED
      document.save
      return false
    end

  end

  #  this method must be revoked before save, for the id field can not be nil
  def videos_upload

    file_extname = File.extname self.file_upload.original_filename
    new_file_name = "#{Time.now.strftime("%Y%m%d%H%M%S")}#{self[:employee_id]}#{file_extname}"
    folder_path = "/videos/#{Time.now.strftime("%Y") }/#{Time.now.strftime("%m") }/#{Time.now.strftime("%d") }/"
    url_path = folder_path + new_file_name
    full_folder_path = "#{Rails.root.to_s}/public#{folder_path}"
    new_file_path = "#{Rails.root.to_s}/public#{url_path}"
    unless File.exist? full_folder_path
      `mkdir -p #{full_folder_path}`
    end

    Dir.mkdir(full_folder_path) unless File.exists?(full_folder_path)

    if !self.file_upload.original_filename.empty?
      self.status = Document::ENCODE_PROCESS
      self.original = url_path
      #`touch #{new_file_path}`
      File.open(new_file_path, "wb") do |f|
        f.write(self.file_upload.read)
        f.close
      end
      self.save!
      # async encoding video files
      begin
        Backburner.enqueue Document, "#{Rails.root.to_s}/public", url_path, self.id
      rescue => ex
        puts 'async task fail'
        puts ex
        self.status = Document::ENCODE_FAILED
        self.save
      end
    end

  end

  def self.perform(root_path, relative_path, document_id)
    Document.encode_video(root_path, relative_path, document_id)
  end

  def del_uploads
    if self.original
      ext = File.extname self.original
      folder_prefix = self.original[0, self.original.index(ext)]
      full_folder_path = "#{Rails.root.to_s}/public#{folder_prefix}"
      `rm -rf #{full_folder_path}*`
    end

    if self.screenshot
      ext = File.extname self.screenshot
      folder_prefix = self.screenshot[0, self.screenshot.index(ext)]
      full_folder_path = "#{Rails.root.to_s}/public#{folder_prefix}"
      `rm -rf #{full_folder_path}*`
    end
  end

  def images_upload
    image_upload=self.file_upload
    file_extname = File.extname image_upload.original_filename
    file_name = image_upload.original_filename[0, image_upload.original_filename.index(file_extname)].gsub(/[' ','(',')']/, '_')
    new_file_name = "#{Time.now.strftime("%Y%m%d%H%M%S")}#{self[:user_id]}#{file_name}#{file_extname}"
    folder_path = "/image_uploads/#{Time.now.strftime("%Y") }/#{Time.now.strftime("%m")}/#{Time.now.strftime("%d") }/"
    url_path = folder_path + new_file_name
    full_folder_path = "#{Rails.root.to_s}/public#{folder_path}"
    new_file_path = "#{Rails.root.to_s}/public#{url_path}"
    unless File.exist? full_folder_path
      `mkdir -p #{full_folder_path}`
    end


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
    self.status = Document::ENCODE_SUCCESS
    self.original = url_path
    self.screenshot = small_url_thumbnail_path
    self.file_name = image_upload.original_filename
    self.upload_file_size = image_upload.size
    self.save
  end

  def to_jq_upload
    {
        'url' => self.original,
        'id' => self.id,
        'name' => self.file_name,
        'size' => self.upload_file_size,
        'thumbnail_url' => self.screenshot,
        'delete_url' => "/documents/#{self.id}",
        'delete_type' => 'DELETE'
    }
  end

  def destroy
    del_uploads
    with_transaction_returning_status { super }
  end

end
