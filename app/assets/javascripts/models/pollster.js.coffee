Hummingbird.Pollster = Em.Object.extend
  timer: null
  start: ->
    _this = @
    @set 'timer', Ember.run.later(@, ->
      _this.onPoll()
      _this.start()
     , 60000)
  stop: -> 
     timer = @get('timer')
     Ember.run.cancel(timer)
  onPoll: ->
