module Products
  class SearchService
    def apply_search params
      search_options = {
        page: params[:page],
        per_page: PER_PAGE
      }

      query = params[:title].present? ? params[:title] : '*'
      search_options = generate_search_filters(search_options, params)
      Product.search query, search_options
    end

    def generate_search_filters search_options, params
      case params[:sort]
      when 'relevance'
        search_options[:fields] = ["title^2", "description"]
      when 'newest'
        search_options[:order] = { created_at: :desc }
      when 'lowest_price'
        search_options[:order] = { price: :asc }
      when 'highest_price'
        search_options[:order] = { price: :desc }
      end

      where_clause = generate_where_clause(params)
      search_options[:where] = where_clause
      search_options[:match] = :word_start

      search_options
    end

    def set_price_filters params
      price_filter = {}
      price_filter[:gt] = params[:price] if params[:price_variant] == 'greater_than'
      price_filter[:lt] = params[:price] if params[:price_variant] == 'less_than'
      price_filter = params[:price] if params[:price_variant] == 'equal_to'

      price_filter
    end

    def generate_where_clause params
      where_clause = {}
      where_clause = { price: set_price_filters(params) } if params[:price].present?
      where_clause = where_clause.merge!({ country: {like: "%#{params[:country].downcase}%"} }) if params[:country].present?

      if params[:tags].present?
        tags = params[:tags].split(',').map { |tag| tag.strip.downcase }
        where_clause = where_clause.merge!({ tags: tags })
      end

      where_clause
    end
  end
end
