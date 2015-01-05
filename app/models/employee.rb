class Employee < ActiveRecord::Base
  has_secure_password
  belongs_to :shop
  has_many :employee_roles, :dependent => :destroy
  has_many :roles, :through => :employee_roles
  validates :email, presence: true
  # validates :auth_token, uniqueness: true
  validates :email, uniqueness: true
  before_create { generate_token(:auth_token) }

  def generate_token(column)
    begin
      self[column]=SecureRandom.urlsafe_base64
    end while Employee.exists?(column => self[column])
  end

  def send_password_reset(request)
    generate_token(:password_reset_token)
    self.password_reset_sent_at = Time.zone.now
    save!
    UserMailer.password_reset(self,request).deliver
  end
end
