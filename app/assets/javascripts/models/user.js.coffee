Hummingbird.User = DS.Model.extend
  username: DS.attr('string')
  coverImageUrl: DS.attr('string')
  avatarTemplate: DS.attr('string')
  online: DS.attr('boolean')
  miniBio: DS.attr('string')
  ratingType: DS.attr('string')

  isFollowed: DS.attr('boolean')

  titleLanguagePreference: DS.attr('string')

  avatarUrl: (->
    @get("avatarTemplate").replace('{size}', 'thumb')
  ).property('avatarTemplate')

  userLink: (->
    "/users/" + @get('id')
  ).property('id')
