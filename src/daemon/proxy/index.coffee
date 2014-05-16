http      = require 'http'
url       = require 'url'
httpProxy = require 'http-proxy'
chalk     = require 'chalk'
apps      = require '../apps/'
render    = require '../../render'
config    = require '../../config'

log = (str) ->
  console.log chalk.yellow('[proxy]'), str

getName = (req) ->
  req.headers.host.split('.').slice(-2, -1).pop()

module.exports =

  start: ->
    http  = http.createServer()
    proxy = httpProxy.createProxyServer()

    http.on 'request', (req, res) ->
      name = getName req
      app  = apps.findByName name
      if app
        proxy.web req, res, target: "http://localhost:#{app.env.PORT}"
      else
        res.end render 'html/app_not_found.html.eco'

    proxy.on 'error', (err, req, res) ->
      if err.code is 'ECONNREFUSED'
        name = getName req
        app  = apps.findByName name
        res.end render 'html/econnrefused.html.eco', app: app
      else
        res.end "Unknown error: #{err.code}"

    http.listen config.proxyPort, ->
      log "Listening on port #{config.proxyPort}"