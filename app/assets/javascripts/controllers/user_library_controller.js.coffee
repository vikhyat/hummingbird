Hummingbird.UserLibraryController = Ember.ArrayController.extend
  needs: "user"
  user: Ember.computed.alias('controllers.user')

  sectionNames: ["Currently Watching", "Plan to Watch", "Completed", "On Hold", "Dropped"]
  showSection: "Currently Watching"
  showAll: Ember.computed.equal('showSection', 'View All')

  sections: (->
    that = this
    @get('sectionNames').map (name) ->
      Ember.Object.create
        title: name
        content: []
        visible: (name == that.get('showSection')) or that.get('showAll')
        displayVisible: name == that.get('showSection')
  ).property('sectionNames')

  updateSectionVisibility: (->
    that = this
    @get('sections').forEach (section) ->
      name = section.get('title')
      section.setProperties
        visible: (name == that.get('showSection')) or that.get('showAll')
        displayVisible: name == that.get('showSection')
  ).observes('showSection')

  actions:
    showSection: (section) ->
      if typeof(section) == "string"
        @set 'showSection', section
      else
        @set 'showSection', section.get('title')























  #showSection: "Currently Watching"
  #
  #showAll: Ember.computed.equal('showSection', "View All")
  #showCurrentlyWatching: Ember.computed.equal('showSection', "Currently Watching")
  #showPlanToWatch: Ember.computed.equal('showSection', "Plan to Watch")
  #showCompleted: Ember.computed.equal('showSection', "Completed")
  #showOnHold: Ember.computed.equal('showSection', "On Hold")
  #showDropped: Ember.computed.equal('showSection', "Dropped")
  #
  #sections: (->
  #  that = this
  #  agg = {}
  #
  #  @get('sectionNames').forEach (section) ->
  #    agg[section] = []
  #
  #  @get('content').forEach (item) ->
  #    agg[item.get('status')].push item
  #
  #  result = []
  #
  #  @get('sectionNames').forEach (section) ->
  #    result.push Ember.Object.create
  #      title: section
  #      content: agg[section]
  #
  #  result
  #).property('content.@each.status', 'sectionNames')
  #
  #sectionsWithVisibility: (->
  #  result = @get('sections')
  #  showSection = @get('showSection')
  #
  #  result.forEach (x) ->
  #    section = x.get('title')
  #    x.set 'visible', (showSection == section) or (showSection == "View All")
  #
  #  result
  #).property('sections', 'showSection')
  #
