Hummingbird.AnimeController = Ember.ObjectController.extend
  activeTab: "Genres"
  language: null

  showGenres: (-> @get('activeTab') == "Genres").property('activeTab')
  showFranchise: (-> @get('activeTab') == "Franchise").property('activeTab')
  showQuotes: (-> @get('activeTab') == "Quotes").property('activeTab')
  showStudios: (-> @get('activeTab') == "Studios").property('activeTab')
  showCast: (-> @get('activeTab') == "Cast").property('activeTab')

  filteredCast: (->
    @get('model.featuredCastings').filterBy 'language', @get('language')
  ).property('model.featuredCastings', 'language')

  trailerPreviewImage: (->
    "http://img.youtube.com/vi/" + @get('model.youtubeVideoId') + "/hqdefault.jpg"
  ).property('model.youtubeVideoId')

  trailerLink: (->
    "http://www.youtube.com/watch?v=" + @get('model.youtubeVideoId')
  ).property('model.youtubeVideoId')

  # Legacy -- remove after Ember transition is complete.
  fullQuotesURL: (-> "/anime/" + @get('model.id') + "/quotes").property('model.id')
  fullReviewsURL: (-> "/anime/" + @get('model.id') + "/reviews").property('model.id')
  newReviewURL: (-> "/anime/" + @get('model.id') + "/reviews/new").property('model.id')
  # End Legacy

  actions:
    setLanguage: (language) ->
      @set 'language', language
      @send 'switchTo', 'Cast'

    switchTo: (newTab) ->
      @set 'activeTab', newTab
      if newTab == "Franchise"
        @get 'model.franchise'

    toggleFavorite: ->
      if @get('model.isFavorite')
        @set('model.isFavorite', false)
      else
        @set('model.isFavorite', true)
      @get('model').save()

    toggleQuoteFavorite: (quote) ->
      if quote.get('isFavorite')
        quote.set('isFavorite', false)
      else
        quote.set('isFavorite', true)
      quote.save()
