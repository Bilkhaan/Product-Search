class Product < ApplicationRecord
  serialize :tags, Array
  searchkick word_start: [:title, :description]

  def search_data
    {
      title: title,
      description: description,
      country: country&.downcase,
      price: price,
      tags: tags.map { |tag| tag.downcase },
      created_at: created_at
    }
  end
end
