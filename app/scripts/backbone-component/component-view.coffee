class Backbone.ViewBase extends Backbone.View
  firstPageLoad: false
  renderOnce: false

  initialize: (options) ->
    this.bindings()
    this.initOptions(options)
    this.postInitialize(options)
    _.bindAll this

  initOptions: (options) ->
    @page = options.page
    @args = options.args

  postElementSet: ->
    this.$el.addClass('render-once') if @renderOnce

  getTemplate: (obj)->
    output = ''
    try
      output = JST[this.template](obj) if @template && JST
    catch error
      console.log error if console
      console.log this.template if console
    output

  getHtml: (obj) ->
    output = ''
    data = obj || @getRenderData()
    if _.isArray(data)
      output += @getTemplate(item) for item in data
    else
      output = @getTemplate(data) || ''
    @postGetHtml(output)

  templateContainer: ->
    return this.$el.find(@filter) if @filter
    this.$el

  buildHtml: ->
    @templateContainer().html(this.getHtml())

  buildBaseHtml: ->
    this.$el.html(JST[this.templatePrefix + this.template_base]()) if @template_base && JST

  render: ->
    @preRender()
    @buildBaseHtml()
    @buildHtml()
    @postRender()
    return this

  load: (view, data) ->
    @renderData(view, data)
    @render() if @template
    return view

  getRenderData: ->
    return @hash if @hash
    return @model.toJSON() if @model
    return @collection.toJSON() if @collection
    return {}

  renderData: (view, data) ->
    @hash = data if view.hash
    @hash = data.collection if view.hash and data.collection
    @model = new FTBPro.Models[view.model](data) if view.model
    @collection = new FTBPro.Collections[view.collection](data.collection) if view.collection
    @postRenderData(view, data)

  cleanup: ->
    @preDispose()
    @dispose()
    this.$el.empty()
    return this

  dispose: ->
    @undelegateEvents()
    @hash = {} if @hash
    @stopListening()
    @model.off(null, null, this) if @model
    @collection.off(null, null, this) if @collection
    return this

  postGetHtml: (html) -> html
  allowed: -> true
  getCacheKey: -> null
  postInitialize: -> null
  preDispose: -> null
  preRender: -> null
  postRender: -> null
  postRenderData: -> null
  bindings: -> null
  getRequest: -> null
