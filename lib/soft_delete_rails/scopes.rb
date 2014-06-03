module SoftDeleteRails
  class Scopes
    def self.default(model)
      model.class_eval { default_scope { where(deleted_at: nil) } }
    end

    def self.deleted(model)
      model.class_eval { scope :deleted, -> { unscope(where: :deleted_at).where.not(deleted_at: nil) } }
    end
  end
end