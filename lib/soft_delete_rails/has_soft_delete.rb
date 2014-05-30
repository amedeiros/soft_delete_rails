module SoftDeleteRails
  module Model
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def has_soft_delete(options = {})
        # Lazy load the instance methods
        send :include, InstanceMethods

        class_attribute :delete_options
        self.delete_options = options

        # Set default scope
        SoftDeleteRails::Scopes.default(self) unless options[:default_scope] == false
        SoftDeleteRails::Scopes.deleted(self)
      end
    end

    module InstanceMethods
      def destroy(force=nil)
        if force == :force
          if super()
            destroy_dependent_records
          end
        else
          run_callbacks(:destroy) do
            soft_deleted? || new_record? ? save : update_deleted_at(Time.current)
          end
        end
      end

      def revive
        if soft_deleted?
          update_deleted_at(nil)
          revive_dependent_records
        end
      end

      def soft_deleted?
        deleted_at.present?
      end

      private

      def update_deleted_at(value)
        self.deleted_at = value
        if self.class.delete_options[:validate] == false
          save(validate: false)
        else
          save!
        end
      end

      def revive_dependent_records
        reflections.each do |key, relation|
          if relation.options[:dependent] == :destroy
            Array.wrap(self.send(key).deleted).collect(&:revive) rescue nil
          end
        end
      end

      def destroy_dependent_records
        reflections.each do |key, relation|
          if relation.options[:dependent] == :destroy
            Array.wrap(self.send(key).unscoped).each do |record|
              if record.respond_to?(:soft_deleted?)
                record.destroy(:force)
              else
                record.destroy
              end
            end
          end
        end
      end

      def reflections
        self.class.reflections
      end
    end
  end
end