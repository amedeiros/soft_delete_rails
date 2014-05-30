module SoftDeleteRails
  class Scopes
    def self.default(model)
      model.class_eval { default_scope { where(deleted_at: nil) } }
    end

    def self.deleted(model)
      model.class_eval { scope :deleted, -> { unscoped.where('deleted_at IS NOT NULL') } }
    end
  end
end