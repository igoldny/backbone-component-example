class Exemple.Views.Welcome extends Backbone.ViewBase
  template: 'welcome'

  postInitialize: ->
    console.log 'postInitialize ' + @template

  preRender: ->
    console.log 'preRender ' + @template

  postRenderData: ->
    console.log 'postRenderData ' + @template

  postRender: ->
    console.log 'postRender ' + @template

  preDispose: ->
    console.log 'preDispose ' + @template
