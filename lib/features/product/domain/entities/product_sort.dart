/// Sort options supported by the `/products` endpoint's `sort` query param.
enum ProductSort { recent, oldest, priceLow, priceHigh, topPicks }

extension ProductSortX on ProductSort {
  /// Value sent to the API.
  String get apiValue {
    switch (this) {
      case ProductSort.recent:
        return 'recent';
      case ProductSort.oldest:
        return 'oldest';
      case ProductSort.priceLow:
        return 'price_low';
      case ProductSort.priceHigh:
        return 'price_high';
      case ProductSort.topPicks:
        return 'top_picks';
    }
  }

  /// Human label shown in the sort menu.
  String get label {
    switch (this) {
      case ProductSort.recent:
        return 'Newest first';
      case ProductSort.oldest:
        return 'Oldest first';
      case ProductSort.priceLow:
        return 'Price: Low to High';
      case ProductSort.priceHigh:
        return 'Price: High to Low';
      case ProductSort.topPicks:
        return 'Top picks';
    }
  }
}
