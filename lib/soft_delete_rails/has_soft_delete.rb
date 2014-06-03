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

        # Set scopes
        SoftDeleteRails::Scopes.default(self) unless options[:default_scope] == false
        SoftDeleteRails::Scopes.deleted(self)
      end
    end

    module InstanceMethods
      def destroy(force=nil)
        if force == :force
          if super()
            hard_destroy_dependent_records
            return !self.persisted?
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
          return self.reload # return self reloaded
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
            records = Array.wrap(send(key).try(:deleted)) if key.to_s.singularize.camelize.constantize.column_names.include?('deleted_at')
            records = Array.wrap(send(key)) if records.blank?
            records.to_a.each do |record|
              record.revive if record.respond_to?(:revive)
            end
          end
        end
      end

      # Perform a hard destroy on the dependent records
      def hard_destroy_dependent_records
        reflections.each do |key, relation|
          if relation.options[:dependent] == :destroy
            records = send(key).try(:unscope, where: :deleted_at) if key.to_s.singularize.camelize.constantize.column_names.include?('deleted_at')
            records = Array.wrap(send(key)) if records.blank?
            records.each do |record|
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