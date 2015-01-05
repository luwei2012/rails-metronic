class Role < ActiveRecord::Base
  has_many :employee_roles, :dependent => :destroy
  has_many :employees, :through => :employee_roles
  validates :name, uniqueness: true
  validates :name, :duty, presence: true
end
