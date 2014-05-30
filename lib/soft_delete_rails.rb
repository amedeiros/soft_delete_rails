require 'soft_delete_rails/version'
require 'soft_delete_rails/scopes'
require 'soft_delete_rails/has_soft_delete'

# Include our model mixin
ActiveRecord::Base.send(:include, SoftDeleteRails::Model)