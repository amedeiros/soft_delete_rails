class Group < ActiveRecord::Base
  has_many :users, dependent: :destroy
  validates :name, presence: :true
  has_soft_delete
end