function LocalStore () {
  var store = window.localStorage,
    apis = {},
    data = [
      ['auth:anton.heryanto@gmail.com', 1],
      ['user', 1],
      ['user:1', {id: 1, name: 'Anton Heryanto', email: 'anton.heryanto@gmail.com'}]
    ]

  apis.user = {
    get: function (arg) {
      if (arg.id) return JSON.parse(store.getItem('user:' + arg.id))

      var n = parseInt(store.getItem('user'), 10),
        data = []
      for (var i = 1, j = 0; i <= n; i++) {
        var v = store.getItem('user:' + i)
        if (v) data[j++] = JSON.parse(v)
      }
      return data
    },
    set: function (data) {
      if (!data.id) {
        data.id = parseInt(store.getItem('user'), 10) + 1
        store.setItem('user', data.id)
      }
      store.setItem('user:' + data.id, JSON.stringify(data))
      return 'user:' + data.id
    },
    del: function (arg) {
      return arg.id && 'user:' + arg.id
    }
  }

  apis.auth = {
    get: function () {
      var id = store.getItem('auth')
      return id && JSON.parse(store.getItem('user:' + id))
    },
    set: function (data) {
      if (!data.name) return

      var id = store.getItem('auth:' + data.name)
      if (id) store.setItem('auth', id)

      return id && 'user:' + id
    },
    del: function () {
      return 'auth'
    }
  }

  this.get = function (api, arg, fn) {
    if (typeof arg === 'function') {
      fn = arg
      arg = {}
    }

    if (fn) fn(apis[api].get(arg))
  }

  this.set = function (api, data, fn) {
    var key = apis[api].set(data)
    console.log(key)
    if (!key) return

    fn(JSON.parse(store.getItem(key)))
  }

  this.del = function (api, arg, fn) {
    if (typeof arg === 'function') {
      fn = arg
      arg = {}
    }

    var key = apis[api].del(arg)
    if (!key) return

    if (fn) fn(store.removeItem(key))
  }

  if (store.length == 0) {
    data.forEach(function (d) {
      var k = d[0], v = d[1]
      v = typeof v === 'object' ? JSON.stringify(v) : v
      store.setItem(k, v)
    })
  }
}


