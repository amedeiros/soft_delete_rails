class User < ActiveRecord::Base
  belongs_to :group
  has_one :phone_number, dependent: :destroy
  has_one :address, dependent: :destroy
  has_soft_delete
end