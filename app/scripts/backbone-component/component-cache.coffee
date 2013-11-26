class Backbone.Cache
  CACHE_PREFIX: "key_"
  EXPIRATION: 5
  LOCALESTORGE_ENABLED: true

  findFromCache: (cacheKey) ->
    return unless localStorage
    cacheKey = @CACHE_PREFIX + cacheKey + "_#{locale}" if cacheKey
    JSON.parse(localStorage.getItem(cacheKey) || "{}") if cacheKey and @getExpirationDate(cacheKey)

  addKey: (key, data, ttl) ->
    return if ttl is 0
    data.ttl = @expirationDate(ttl).getTime() unless data and data.ttl
    @saveItem(key, data)

  saveItem: (key, data) ->
    return unless localStorage and localStorage.setItem
    try
      localStorage.setItem key, JSON.stringify(data)
    catch e
      @clearItems()

  clearItems: ->
    keys = _.keys localStorage
    itemsKeys = _.filter(keys, (key) => return key.indexOf(@CACHE_PREFIX) == 0)
    _.each(itemsKeys, (key) -> localStorage.removeItem(key))

  removeKey: (key) ->
    return unless localStorage and localStorage.removeItem
    localStorage.removeItem(key)

  getExpirationDate: (cacheKey) ->
    return unless @LOCALESTORGE_ENABLED
    return unless localStorage and localStorage.getItem
    data = JSON.parse(localStorage.getItem(cacheKey) || "{}")
    return localStorage.removeItem(cacheKey) if data and data.ttl and (new Date()) > (new Date(data.ttl))
    return data.ttl if data

  expirationDate: (ttl)->
    new Date((new Date()).setMinutes((new Date()).getMinutes() + (ttl || @EXPIRATION)))

  disableLocaleStroge: ->
    @LOCALESTORGE_ENABLED = false

  clear: ->
    @memoryStorage = {}
