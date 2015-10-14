var riot = window.riot,
    jQuery = window.jQuery

riot.app = function (conf) {
  var base = '/api/'

  conf = conf || {}
  riot.observable(riot)
  riot.cache = riot.cache || {}

  riot.get = function (api, arg, fn) {
    if (riot.cache[api]) return fn(riot.cache[api])
    riot.trigger('loading')
    return jQuery.get(base + api, arg, fn).done(function () {
      riot.trigger('loaded')
    }).fail(function () {
      riot.trigger('loaded')
    })
  }

  riot.set = function (api, data, fn) {
    return jQuery.post(base + api, data, fn)
  }

  riot.del = function(api, arg, fn) {
    arg = arg || {}
    arg.method = 'DELETE'
    return jQuery.get(base + api, arg, fn)
  }

  riot.login = function (data) {
    return riot.set('auth', data, function (r) {
      if (!r || !r.id) return
      riot.trigger('login', r)
    })
  }

  riot.logout = function () {
    return riot.get('auth/delete', function (r) {
      riot.trigger('logout')
    })
  }

  riot.logged = function () {
    return riot.get('auth', function (r) {
      if (!r || !r.id) return
      riot.trigger('logged', r)
    })
  }

  riot.load = function (route) {
    riot.trigger('load', route)
  }

  riot.parse_hash = function (hash) {
    var raw = hash.slice(2).split('?'),
      uri = raw[0].split('/'),
      qs = raw[1],
      tag = uri[0],
      params = {},
      n = uri.length

    if (qs) {
      qs.split('&').forEach(function (v) {
        var c = v.split('=')
        params[decodeURIComponent(c[0])] = decodeURIComponent(c[1])
      })
    }

    if (n === 1) return { tag: tag ? tag + '-index' : 'home', params: params }

    params.id = parseInt(uri[1], 10) || undefined
    var action = !params.id ? uri[1] : (uri[2] || 'details')

    tag = tag + '-' + action
    return { tag: tag, params: params }
  }

  riot.route.parser(riot.parse_hash)
  riot.route(riot.load)
  riot.mount('*', conf)
}
