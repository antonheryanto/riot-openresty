var riot = window.riot

function jQueryStore () {
  var base = '/api/',
    jQuery = window.jQuery

  this.get = function (api, arg, fn) {
    if (riot.cache[api]) return fn(riot.cache[api])
    riot.trigger('loading')
    return jQuery.get(base + api, arg, fn).done(function () {
      riot.trigger('loaded')
    }).fail(function () {
      riot.trigger('loaded')
    })
  }

  this.set = function (api, data, fn) {
    return jQuery.post(base + api, data, fn)
  }

  this.del = function (api, arg, fn) {
    if (typeof arg === 'function') {
      fn = arg
      arg = {}
    }
    arg.method = 'DELETE'
    return jQuery.get(base + api, arg, fn)
  }

}

function Auth () {
  this.login = function (data) {
    return riot.store.set('auth', data, function (r) {
      if (!r || !r.id) return
      riot.trigger('login', r)
    })
  }

  this.logout = function () {
    return riot.store.del('auth', function (r) {
      riot.trigger('logout')
    })
  }

  this.logged = function () {
    return riot.store.get('auth', function (r) {
      if (!r || !r.id) return
      riot.trigger('logged', r)
    })
  }

}

function App (conf) {
  conf = conf || {}
  conf.main = conf.main || '#main'
  riot.observable(riot)
  riot.cache = riot.cache || {}
  riot.store = conf.store || new jQueryStore()
  riot.auth = new Auth()

  this.load = function (tag, params) {
    var route = typeof tag === 'string' ? { tag: tag, params: params } : tag
    riot.trigger('before:load', this)
    this.tags = riot.mount(conf.main, route.tag, { route: route.params })
    riot.trigger('after:load', this)
  }

  this.parser = function (hash) {
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

    if (n === 1) return { tag: tag || 'home', params: params }

    params.id = parseInt(uri[1], 10) || undefined
    var action = !params.id ? uri[1] : (uri[2] || 'details')

    tag = tag + '-' + action
    return { tag: tag, params: params }
  }

  riot.route.parser(this.parser)
  riot.route(this.load)
  riot.mount('*')
}
