# Soft Delete Rails

Soft deletion for rails. Includes default scoping and skipping validations. Features soft deletion of dependent records as well as reviving of dependent records.
Supports ActiveRecord >= 4.1.0

## Installation

Add this line to your application's Gemfile:

    gem 'soft_delete_rails'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install soft_delete_rails

## Requirements
Datetime column deleted_at
    
    class CreateUsers < ActiveRecord::Migration
      def up
        create_table :users, do |t|
          t.datetime :deleted_at
          t.timestamps
        end
      end
    end

## Scopes
Default scope (optional)

    where(deleted_at: nil)
Deleted scope (non-optional)

    unscope(where: :deleted_at).where.not(deleted_at: nil)

## Options    
Default usage includes the default scope and running model validations

    class User < ActiveRecord::Base
      has_soft_delete
    end
    
Without default scope
    
    class User < ActiveRecord::Base
      has_soft_delete default_scope: false
    end
    
Without validations. Will not run the model validations on soft delete or revive

    class User < ActiveRecord::Base
      has_soft_delete validate: false
    end

Without default scope and validations
    
    class User < ActiveRecord::Base
      has_soft_delete default_scope: false, validate: false
    end
        
## Dependent
Requires both models to have has_soft_delete and deleted_at column

    class User < ActiveRecord::Base
      belongs_to :group
      has_soft_delete
    end
    
    # Will soft delete and revive the user records
    class Group < ActiveRecord::Base
      has_many :users, dependent: :destroy
      has_soft_delete
    end
    
## Destroy

    group = Group.last

    # Will soft delete the record and any dependent records with has_soft_delete
    group.destroy

    # Will hard delete the record from the database and any dependent records
    group.destroy(:force)
   

## Revive

    group = Group.deleted.last

    # Will revive the record and any dependent records with has_soft_delete
    group.revive


## Author
Andrew Medeiros, amedeiros0920@gmail.com, @_AndrewMedeiros
    
## Contributing

1. Fork it ( https://github.com/amedeiros/soft_delete_rails/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
