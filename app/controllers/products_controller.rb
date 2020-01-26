class ProductsController < ApplicationController

  def index
    @searched_params = search_params
    @products = Products::SearchService.new.apply_search(@searched_params)
  end

  private

  def search_params
    params.permit(:sort, :title, :price, :price_variant, :country, :tags)
  end

end
