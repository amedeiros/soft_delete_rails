class Address < ActiveRecord::Base
  belongs_to :user
  has_soft_delete
end