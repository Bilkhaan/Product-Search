require 'rails_helper'

describe Product, search: true do
  it "Cross check search count by title" do
    Product.create!(title: "Alien Suede Dad Hat", description: "Navy Blue Suede Dad Cap", price: 300, country: 'Canada')
    Product.create!(title: "Alien Suede Dad Hat Black", description: "Black Suede Dad Cap", price: 200, country: 'Canada')
    Product.create!(title: "Cotton shirt", description: "Navy Blue cotton shirt", price: 300, country: 'Germany')
    Product.search_index.refresh

    params = { title: 'Alien Suede' }
    products = Products::SearchService.new.apply_search(params)
    expect(products.size).to eq(2)
  end

  it "Cross check search count by country" do
    Product.create!(title: "Alien Suede Dad Hat", description: "Navy Blue Suede Dad Cap", price: 300, country: 'Canada')
    Product.create!(title: "Alien Suede Dad Hat Black", description: "Black Suede Dad Cap", price: 200, country: 'Canada')
    Product.create!(title: "Cotton shirt", description: "Navy Blue cotton shirt", price: 300, country: 'Germany')
    Product.search_index.refresh

    params = { country: 'Canada' }
    products = Products::SearchService.new.apply_search(params)
    expect(products.size).to eq(2)
  end

  it "Sort by relevance" do
    Product.create!(title: "Dad Hat Black", description: "Alien Suede Black Suede Dad Cap", price: 200, country: 'Canada')
    Product.create!(title: "Alien Suede Dad Hat", description: "Navy Blue Suede Dad Cap", price: 300, country: 'Canada')
    Product.create!(title: "Cotton shirt", description: "Alien Suede cotton shirt", price: 300, country: 'Germany')
    Product.search_index.refresh

    params = { title: 'Alien Suede', sort: 'relevance' }
    products = Products::SearchService.new.apply_search(params)
    expect(products.first.title).to eq('Alien Suede Dad Hat')
  end

  it "Sort by newest" do
    Product.create!(title: "Dad Hat Black", description: "Alien Suede Black Suede Cap", country: 'Canada')
    sleep(0.5)
    Product.create!(title: "Alien Suede Dad Hat", description: "Navy Blue Suede Cap", country: 'Canada')
    Product.search_index.refresh

    params = { sort: 'newest' }
    products = Products::SearchService.new.apply_search(params)
    expect(products.first.title).to eq('Alien Suede Dad Hat')
  end

  it "Sort by lowest price" do
    Product.create!(title: "Dad Hat Black", description: "Alien Suede Black Suede Cap", country: 'Canada', price: 10)
    Product.create!(title: "Dad Hat White", description: "Alien Suede white Suede Cap", country: 'Canada', price: 30)
    Product.create!(title: "Alien Suede Dad Hat", description: "Navy Blue Suede Cap", country: 'Canada', price: 20)
    Product.search_index.refresh

    params = { sort: 'lowest_price' }
    products = Products::SearchService.new.apply_search(params)
    expect(products.first.price).to eq(10)
  end

  it "Sort by highest price" do
    Product.create!(title: "Dad Hat Black", country: 'Canada', price: 10)
    Product.create!(title: "Dad Hat White", country: 'Canada', price: 30)
    Product.create!(title: "Alien Suede Dad Hat", country: 'Canada', price: 20)
    Product.search_index.refresh

    params = { sort: 'highest_price' }
    products = Products::SearchService.new.apply_search(params)
    expect(products.first.price).to eq(30)
  end

  it "Filter by equal price" do
    Product.create!(title: "Dad Hat Black", country: 'Canada', price: 10)
    Product.create!(title: "Dad Hat White", country: 'Canada', price: 30)
    Product.search_index.refresh

    params = { price: 30, price_variant: 'equal_to' }
    products = Products::SearchService.new.apply_search(params)
    expect(products.first.price).to eq(30)
  end

  it "Filter by less than price" do
    Product.create!(title: "Dad Hat Black", country: 'Canada', price: 10)
    Product.create!(title: "Dad Hat White", country: 'Canada', price: 30)
    Product.search_index.refresh

    params = { price: 20, price_variant: 'less_than' }
    products = Products::SearchService.new.apply_search(params)
    expect(products.first.price).to eq(10)
  end

  it "Filter by greater than price" do
    Product.create!(title: "Dad Hat Black", country: 'Canada', price: 10)
    Product.create!(title: "Dad Hat White", country: 'Canada', price: 30)
    Product.search_index.refresh

    params = { price: 20, price_variant: 'greater_than' }
    products = Products::SearchService.new.apply_search(params)
    expect(products.first.price).to eq(30)
  end

  it "Filter by greater than price wrong case" do
    Product.create!(title: "Dad Hat Black", country: 'Canada', price: 10)
    Product.create!(title: "Dad Hat White", country: 'Canada', price: 30)
    Product.search_index.refresh

    params = { price: 20, price_variant: 'greater_than' }
    products = Products::SearchService.new.apply_search(params)
    expect(products.first.price).not_to eq(10)
  end

  it "search by country success case" do
    Rails.application.load_seed
    Product.search_index.refresh

    params = { title: 'shirt', country: 'United States' }
    products = Products::SearchService.new.apply_search(params)
    expect(products.map(&:country).uniq).to eq(['United States'])
  end

  it "search by country failed case" do
    Rails.application.load_seed
    Product.search_index.refresh

    params = { title: 'shirt', country: 'United States' }
    products = Products::SearchService.new.apply_search(params)
    expect(products.map(&:country).uniq).not_to include('Canada')
  end
end


