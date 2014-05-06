Hummingbird.Paginated = Ember.Mixin.create({
  // Return an empty array immediately from the model hook.
  model: function() {
    this.set('cursor', null);
    return [];
  },

  // Wrapper around fetchPage which needs to be implemented by the route.
  // Keeps track of whether we are currently fetching a page, and saves the cursor
  // returned by the server.
  fetchPageProxy: function(cursor) {
    var self = this;
    this.set('currentlyFetchingPage', true);

    return this.fetchPage(cursor).then(function(objects) {
      self.set('cursor', objects.get('meta.cursor'));

      Ember.run.next(function() { self.set('currentlyFetchingPage', false); });

      if (objects.get('length') == 0) { self.setCanLoadMore(false); }
      else { self.setCanLoadMore(true); }

      return objects;
    });
  },

  // Set canLoadMore on the controller while setting it up.
  setupController: function(controller, model) {
    this.setCanLoadMore(true);
    controller.set('canLoadMore', this.get('canLoadMore'));
    controller.set('model', model);
  },

  // Set `canLoadMore` on the route and, if possible, on the controller.
  setCanLoadMore: function(canLoadMore) {
    this.set('canLoadMore', canLoadMore);
    if (this.controller) { this.controller.set('canLoadMore', canLoadMore); }
  },

  actions: {
    loadNextPage: function() {
      var that = this;
      if (this.get('canLoadMore') && !this.get('currentlyFetchingPage')) {
        this.fetchPageProxy(this.get('cursor')).then(function(objects) {
          that.controller.get('content').addObjects(objects);
        });
      }
    },
    // changed this function around so the name is wrong. this function adds new objects to the front of the content array for display
    reloadFirstPage: function(){
      var _this = this;
      if (this.get('canLoadMore') && !this.get('currentlyFetchingPage')){
        this.fetchPageProxy().then(function(objects){ 
          content = _this.controller.get('content');
          newobjects = objects.filter(function(n){
            return content.indexOf(n) === -1;
          });
          _this.controller.get('content').unshiftObjects(newobjects);
       
        });
      }
    }
  }
});
