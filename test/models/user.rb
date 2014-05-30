class User < ActiveRecord::Base
  belongs_to :group
  has_soft_delete
end