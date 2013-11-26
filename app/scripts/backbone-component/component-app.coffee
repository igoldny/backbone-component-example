class Backbone.Application extends Backbone.Router
  routes: {}
  layouts: {}
  activeViews: []
  PIPE_URL: ''

  initialize: (options) ->
    @renderLayout()
    $(document).ajaxError @ajaxError
    @cache = new Backbone.Cache
    @bindLinks()
    @postInitialize()

  ajaxError: (ajax, jqXHR, textStatus, errorThrown) =>
    return unless jqXHR.getAllResponseHeaders()
    return if textStatus and textStatus.url is currentUser.CONNECT_URL
    @postAjaxError() if jqXHR.status

  renderLayout: ->
    _.map @registerLayouts(), (page) =>
      _.each page.urls, (url) =>
        @route url, page.name, =>
          @preRoute(page, arguments)
          @renderWithModels(page, @aggregateRequests(page, arguments))

  renderWithModels: (page, requests) ->
    return @postRoute(page) if _.isEmpty(requests)

    $.ajax
      url: @PIPE_URL + location.pathname
      data: requests
    .success (data) =>
      @renderViewsWithData(page, data)
      @postRoute(page)
    return this

  renderViewsWithData: (page, data)->
    _.each @layouts[page.name].views, (component) =>
        @loadComponentWithData(component, data)

  loadComponentWithData: (component, data) ->
    return unless component
    viewData = data[component.hash || component.model || component.collection]
    component.view.load component, viewData if viewData
    @cache.addKey(viewData.cache_key, viewData, component.view.ttl) if viewData

  aggregateRequests: (page, args) ->
    requests = {}
    options =
      page: page
      args: args

    _.each @activeViews, (component) =>
      @cleanComponent(component)

    @layouts[page.name].views = _.map @layouts[page.name].views, (component) =>
      @preLoadComponent options, component, (key, value) => requests[key] = value

    @activeViews = @layouts[page.name].views

    requests

  cleanComponent: (component) ->
    component.view.cleanup() if component.view and not component.el.hasClass('render-once')

  preLoadComponent: (options, component, callback) ->
    return component if component.el.hasClass('render-once')
    request = component.collection or component.model or component.hash
    throw new Error("component #{component.name} not found") unless window[@namespace].Views[component.name]
    component.view = new window[@namespace].Views[component.name] @getOptions(options)
    component.view.setElement component.el
    component.view.postElementSet()
    return component unless component.view.allowed()
    component.view.load(component) unless request
    responseFromCache = @cache.findFromCache component.view.getCacheKey.apply(this, options.args)
    return component.view.load(component, responseFromCache) if responseFromCache
    callback(request, component.view.getRequest.apply(this, options.args)) if request
    component

  getOptions: (options) ->
    args: options.args
    page: options.page

  registerLayouts: =>
    $('#main').find('[data-page]').each (i, page) =>
      $page = $(page)
      views = []
      pageName = $page.data('page')

      @layouts[pageName] =
        el: $page
        name: pageName
        type: $page.data('type')
        modal: $page.data('modal')
        urls: $page.data('urls').split(',')
        views: []

      $page.find('[data-view]').each (i, view) =>
        $view = $(view)
        name = $view.data('view')
        hash = $view.data('hash')
        model = $view.data('model')
        collection = $view.data('collection')
        views.push
          el: $view
          name: name
          hash: hash
          model: model
          collection: collection
        @layouts[pageName].views = views
    @layouts

  bindLinks: ->
    $(document.body).on "click", "a", (event) ->
      href = $(event.currentTarget).attr('href')
      return unless href
      passThrough = $(this).hasClass('pass')
      if !passThrough && !event.altKey && !event.ctrlKey && !event.metaKey && !event.shiftKey
        event.preventDefault()
        url = href.replace(/^\//,'').replace('\#\!\/','')
        ExempleApplication.navigate url, trigger: !$(this).hasClass('silent')
        window.scrollTo(0, 0)
        return false

  postInitialize: -> null
  postAjaxError: -> null
  preRoute: -> null
  postRoute: -> null
