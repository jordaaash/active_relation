module ActiveRelation
  module CreateUpdateDestroy
    def create! (fields = {})
      ids = if fields.is_a?(Array)
        attributes = fields.map { |f| attributes_for_fields(f) }
        active_record.transaction do
          attributes.map do |attribute|
            r = active_record.new
            # Workaround for legacy models with mass assignment security
            attribute.each { |a, v| r.public_send(:"#{a}=", v) }
            r.save!
            r[primary_key]
          end
        end
      else
        attributes = attributes_for_fields(fields)
        # Wrap in a transaction anyway since models may instantiate children
        active_record.transaction do
          r = active_record.new
          # Workaround for legacy models with mass assignment security
          attributes.each do |a, v|
            if v.is_a?(Array)
              v.each do |model|
                f     = model.serializable_hash
                value = model.class.attributes_for_fields(f)
                r.public_send(a).build(value)
              end
            elsif v.is_a?(ActiveRelation::Model)
              f = v.serializable_hash
              r.public_send(:"build_#{a}", f)
            else
              r.public_send(:"#{a}=", v)
            end
          end
          r.save!
          r[primary_key]
        end
      end
      find(ids)
    end

    def update! (ids, fields = {})
      if fields.is_a?(Array)
        attributes = fields.map { |f| attributes_for_fields(f) }
        active_record.transaction do
          attributes.map.with_index do |attribute, i|
            id = ids[i]
            r  = active_record.find(id)
            # Workaround for legacy models with mass assignment security
            attribute.each { |a, v| r.public_send(:"#{a}=", v) }
            r.save!
          end
        end
      else
        attributes = attributes_for_fields(fields)
        # Wrap in a transaction anyway since models may instantiate children
        active_record.transaction do
          r = active_record.find(ids)
          # Workaround for legacy models with mass assignment security
          attributes.each { |a, v| r.public_send(:"#{a}=", v) }
          r.save!
        end
      end
      find(ids)
    end

    def destroy! (ids)
      before = where(primary_key, ids).count
      active_record.transaction do
        active_record.destroy(ids)
        after = where(primary_key, ids).count
        # Roll back transaction if all models weren't destroyed atomically
        raise ActiveRecord::RecordNotSaved unless after == 0
      end
      before
    end

    def assign_attributes

    end
  end
end
