ActiveRecord::Schema.define do
  create_table :groups, force: true do |t|
    t.datetime  :deleted_at
    t.string    :name
    t.timestamps
  end

  create_table :accounts, force: true do |t|
    t.datetime :deleted_at
    t.string   :name
    t.timestamps
  end

  create_table :users, force: true do |t|
    t.datetime   :deleted_at
    t.belongs_to :group
    t.timestamps
  end

  create_table :phone_numbers, force: true do |t|
    t.belongs_to :user
    t.timestamps
  end

  create_table :addresses, force: true do |t|
    t.belongs_to :user
    t.datetime :deleted_at
    t.timestamps
  end
end