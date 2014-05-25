require 'active_record/errors'

module ActiveRelation
  module CreateUpdateDestroy
    def create! (fields = {})
      if fields.is_a?(Array)
        attributes = fields.map { |f| attributes_for_fields(f) }
        ids        = active_record.transaction do
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
        ids        = active_record.transaction do
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
        ids        = active_record.transaction do
          attributes.map.with_index do |attribute, i|
            id = ids[i]
            r  = active_record.find(id)
            # Workaround for legacy models with mass assignment security
            attribute.each { |a, v| r.public_send(:"#{a}=", v) }
            r.save!
            r[primary_key]
          end
        end
      else
        attributes = attributes_for_fields(fields)
        ids        = active_record.transaction do
          r = active_record.find(ids)
          # Workaround for legacy models with mass assignment security
          attributes.each { |a, v| r.public_send(:"#{a}=", v) }
          r.save!
          r[primary_key]
        end
      end
      find(ids)
    end

    def destroy! (ids)
      before  = where(primary_key, ids).count
      records = active_record.transaction do
        records = active_record.destroy(ids)
        after   = reset.where(primary_key, ids).count
        raise ActiveRecord::RecordNotSaved unless after == 0
        records
      end
      before
    end

    def attributes_for_fields (fields)
      available = self.attributes
      fields.reduce({}) do |a, (f, v)|
        raise ActiveRelation::FieldNotDefined unless available.include?(f)
        unless (attribute = attributes[f])
          raise ActiveRelation::AttributeNotDefined
        end
        a[attribute] = v
        a
      end
    end
  end
end
