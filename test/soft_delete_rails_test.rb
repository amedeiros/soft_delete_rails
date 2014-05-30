require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class SoftDeleteRailsTest < ActiveSupport::TestCase
  context SoftDeleteRails do
    setup do
      DatabaseCleaner.strategy = :truncation
      DatabaseCleaner.start
    end

    teardown do
      DatabaseCleaner.clean
    end

    context 'soft deletion' do
      should 'should set the deleted_at' do
        user = User.create
        assert_difference 'User.count', -1 do
          user.destroy
          assert user.deleted_at.present?
          assert user.soft_deleted?
        end
      end

      context 'dependents' do
        should 'soft delete dependent records' do
          group = Group.create(name: 'test')
          user  = User.create(group: group)
          assert_difference ['Group.count', 'User.count'], -1 do
            assert group.destroy
            assert group.soft_deleted?
            assert user.reload.soft_deleted?
          end
        end
      end
    end

    context 'revive' do
      should 'revive a record' do
        user = User.create
        # Soft destroy the record
        assert user.destroy
        assert user.soft_deleted?

        # Revive the record
        assert user.revive
        refute user.soft_deleted?
      end

      context 'dependents' do
        should 'revive dependent records' do
          group = Group.create(name: 'test')
          user  = User.create(group: group)

          # Soft Destroy the group first
          assert group.destroy
          assert group.soft_deleted?
          assert user.reload.soft_deleted?

          # Revive the group and its relations
          assert group.revive
          refute group.soft_deleted?
          refute group.reload.soft_deleted?
        end
      end
    end

    context 'hard deletion' do
      should 'hard delete a record' do
        user = User.create
        assert_difference 'User.unscoped.count', -1 do
          assert user.destroy(:force)
        end
      end

      context 'dependents' do
        should 'hard delete dependent records' do
          group = Group.create(name: 'test')
          User.create(group: group)
          assert_difference ['Group.unscoped.count', 'User.unscoped.count'], -1 do
            assert group.destroy(:force)
          end
        end
      end
    end

    context 'scopes' do
      context 'default' do
        should 'have the default scope' do
          assert_equal User.all.to_sql, User.where(deleted_at: nil).to_sql
        end

        should 'not have the default scope' do
          assert_not_equal Account.all.to_sql, Account.where(deleted_at: nil).to_sql
        end
      end

      context 'deleted' do
        should 'have the deleted scope' do
          assert_equal User.all.deleted.to_sql, User.unscoped.where('deleted_at IS NOT NULL').to_sql
        end
      end
    end

    context 'validations' do
      should 'raise ActiveRecord::RecordInvalid for an invalid record' do
        group = Group.create(name: 'test')
        error = assert_raises ActiveRecord::RecordInvalid do
          group.name = nil
          group.destroy
        end
        assert_equal 'Validation failed: Name can\'t be blank', error.message, error.message.inspect
      end

      should 'not raise ActiveRecord::RecordInvalid for an invalid record' do
        account = Account.create(name: 'test')
        assert_nothing_raised do
          account.name = nil
          assert account.destroy
        end
      end
    end
  end
end