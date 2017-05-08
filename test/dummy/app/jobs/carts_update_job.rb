class CartsUpdateJob < DiscoApp::ShopJob

  def perform(_shop, cart_data)
    Cart.synchronise(@shop, cart_data)
  end

end
