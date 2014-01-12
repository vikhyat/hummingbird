Hummingbird.LibraryEntry = DS.Model.extend
  anime: DS.belongsTo('anime')
  status: DS.attr('string')
  isFavorite: DS.attr('boolean')
  rating: DS.attr('number')
  episodesWatched: DS.attr('number')
  private: DS.attr('boolean')

  positiveRating: (-> @get('rating') >= 3.6).property('rating')
  negativeRating: (-> @get('rating') <= 2.4).property('rating')
  neutralRating: (-> @get('rating') > 2.4 and @get('rating') < 3.6).property('rating')
