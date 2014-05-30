class Account < ActiveRecord::Base
  validates :name, presence: true
  has_soft_delete default_scope: false, validate: false
end