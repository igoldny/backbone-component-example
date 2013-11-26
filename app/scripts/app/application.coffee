class Exemple.Application extends Backbone.Application
  namespace: 'Exemple'

  postInitialize: ->
    console.log 'postInitialize'

  postAjaxError: ->
    console.log 'postAjaxError'

  preRoute: (page, args) ->
    console.log 'preRoute', page

  postRoute: (page) ->
    console.log 'postRoute', page
    $('#main .page').removeClass('active')
    page.el.addClass('active')
