module ActiveRelation
  module CreateUpdateDestroy
    def create! (fields = {}, options = {})
      ids = if fields.is_a?(Array)
        active_record.transaction do
          fields.map do |f|
            record = active_record.new
            save!(record, f)
          end
        end
      else
        record = active_record.new
        active_record.transaction do
          save!(record, fields)
        end
      end
      find(ids, options)
    end

    def update! (ids, fields = {}, options = {})
      ids = if ids.is_a?(Array)
        results = find(ids, fields: [primary_key])
        results.map(&primary_key)
      else
        result = if ids.is_a?(Hash)
          find_by!(ids, fields: [primary_key])
        else
          find(ids, fields: [primary_key])
        end
        result[primary_key]
      end
      records = active_record.find(ids)
      if fields.is_a?(Array)
        raise ArgumentError unless ids.is_a?(Array) && ids.size == fields.size
        active_record.transaction do
          records.zip(fields).map do |r, f|
            save!(r, f)
          end
        end
      else
        raise ArgumentError if ids.is_a?(Array)
        active_record.transaction do
          save!(records, fields)
        end
      end
      find(ids, options)
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
    def save! (record, fields)
      assign_attributes_from_fields(record, fields)
      record.save!
      record[primary_key]
    end

    def assign_attributes (record, attributes)
      # Workaround for legacy models with mass assignment security
      attributes.each do |attribute, value|
        assign_attribute(record, attribute, value)
      end
    end

    def assign_attribute (record, attribute, value)
      if value.is_a?(Array)
        value.each do |model|
          associated = record.public_send(attribute).build
          assign_attributes_from_model(associated, model)
        end
      elsif value.is_a?(Model)
        associated = record.public_send(:"build_#{attribute}")
        assign_attributes_from_model(associated, value)
      else
        record.public_send(:"#{attribute}=", value)
      end
    end

    def assign_attributes_from_fields (record, fields)
      attributes = attributes_for_field_values(fields)
      assign_attributes(record, attributes)
    end

    def assign_attributes_from_model (record, model)
      attributes = attributes_for_model(model)
      assign_attributes(record, attributes)
      if record[model.class.primary_key]
        record.instance_variable_set(:@new_record, false)
      end
    end

    def attributes_for_model (model)
      fields = model.serializable_hash
      model.class.attributes_for_field_values(fields)
    end
  end
end
