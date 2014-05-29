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
                attributes.each { |a, v| r.public_send(:"#{a}=", v) }
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
  end
end
