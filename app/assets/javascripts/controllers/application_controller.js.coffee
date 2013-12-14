Hummingbird.ApplicationController = Ember.Controller.extend
  routeChanged: (->

    # Track the last visited URL for redirection on sign in.
    unless window.location.href.match('/sign-in')
      window.lastVisitedURL = window.location.href

    # Track Google Analytics page view.
    if window._gaq
      if @afterFirstHit
        Em.run.schedule 'afterRender', -> _gaq.push(['_trackPageview'])
      else
        @afterFirstHit = true

    # Scroll to the top of the page.
    Ember.run.next ->
      window.scrollTo(0, 0)

  ).observes('currentPath')

  actions:
    signOut: ->
      Hummingbird.Session.signOut()
      window.location.href = window.location.href
