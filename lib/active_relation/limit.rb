module ActiveRelation
  module Limit
    def paginate (rows, page)
      if rows > 0
        offset(rows * page) if page > 0
        limit(rows)
      end
      self
    end

    def limit (limit)
      query.take(limit)
      self
    end

    def offset (offset)
      query.skip(offset)
      self
    end
  end
end
