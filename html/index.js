var riot = window.riot,
    jQuery = window.jQuery

riot.app = function (conf) {
  var base = '/api/'

  riot.observable(riot)
  riot.conf = riot.conf || {}
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

  riot.load = function (tag, id, action) {
    riot.trigger('load', tag, id, action)
  }

  riot.route.parser(function (hash) {
    return hash.slice(2).split('/')
  })

  riot.route(riot.load)

  riot.mount('*')
}
