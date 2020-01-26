module Products
  class ProductService
    def find_by attr
      Product.find_by(attr)
    end
  end
end
