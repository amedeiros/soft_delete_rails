ENV['RAILS_ENV'] ||= 'test'
require 'pathname'
require 'active_record'
require 'active_support'
require 'database_cleaner'
require 'soft_delete_rails'
require 'test/unit'
require 'shoulda'
require 'turn/autorun'

module Rails
  def self.env
    'test'
  end
end

configuration = Pathname.new File.expand_path('configuration', File.dirname(__FILE__))
models        = Pathname.new File.expand_path('models', File.dirname(__FILE__))
Dir.glob(models.join('*.rb')).each do |file|
  autoload File.basename(file).chomp('.rb').camelcase.intern, file
end.each do |file|
  require file
end

# Setup ActiveRecord
ActiveRecord::Base.configurations = YAML.load_file configuration.join('database.yml')
ActiveRecord::Base.establish_connection
load configuration.join('schema.rb')
