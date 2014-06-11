module ActiveRelation
  module CreateUpdateDestroy
    def create! (fields = {}, options = {})
      ids = if fields.is_a?(Array)
        attributes = fields.map { |f| attributes_for_fields(f) }
        active_record.transaction do
          attributes.map do |attribute|
            record = active_record.new
            assign_attributes(record, attributes)
            record.save!
            record[primary_key]
          end
        end
      else
        attributes = attributes_for_fields(fields)
        # Wrap in a transaction anyway since models may instantiate children
        active_record.transaction do
          record = active_record.new
          # Workaround for legacy models with mass assignment security
          attributes.each do |attribute, v|
            if v.is_a?(Array)
              v.each do |model|
                f = model.serializable_hash
                a = model.class.attributes_for_fields(f)

                r = record.public_send(attribute).build
                assign_attributes(r, a)
              end
            elsif v.is_a?(ActiveRelation::Model)
              f = v.serializable_hash
              a = v.class.attributes_for_fields(f)

              r = record.public_send(:"build_#{attribute}")
              assign_attributes(r, a)
            else
              assign_attribute(record, attribute, v)
            end
          end
          record.save!
          record[primary_key]
        end
      end
      find(ids, options)
    end

    def update! (ids, fields = {}, options = {})
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

    protected
    def assign_attributes (record, attributes)
      # Workaround for legacy models with mass assignment security
      attributes.each do |attribute, value|
        assign_attribute(record, attribute, value)
      end
    end

    def assign_attribute (record, attribute, value)
      if value.is_a?(ActiveRelation::Model)
        f = value.serializable_hash
        a = value.class.attributes_for_fields(f)
        r = record.public_send(:"build_#{attribute}")
        assign_attributes(r, a)
      else
        record.public_send(:"#{attribute}=", value)
      end
    end
  end
end
