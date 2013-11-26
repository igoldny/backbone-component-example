window.Exemple =
  Application: {}
  Routers: {}
  Helpers: {}
  Mixins: {}
  Collections: {}
  Models: {}
  Views: {}
  init: ->
    window.ExempleApplication = new window.Exemple.Application
    Backbone.history.start({ pushState: history.pushState, hashChange: !history.pushState })

$(Exemple.init)
