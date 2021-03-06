###
Rest Sessions

The MIT License (MIT)

Copyright © 2014 Patrick Liess, http://www.tcs.de

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
###
config = require "./config.json"
RedisSessions = require "redis-sessions"
rs = new RedisSessions({host: config.redishost, port: config.redisport})
_ = require "lodash"
express = require "express"
morgan = require "morgan"
bodyParser = require "body-parser"
app = express()
app.use(morgan('dev'))
app.use(bodyParser.json({limit:60000}))

_respond = (res, err, resp) ->
	res.header('Content-Type', "application/json")
	res.removeHeader("X-Powered-By")
	if err
		res.status(500).send(err)
		return
	res.send(resp)
	return

app.get '/:app/activity', (req, res) ->
	rs.activity {app: req.params.app, dt: req.param("dt")}, _.partial(_respond, res)
	return

app.put '/:app/create/:id', (req, res) ->
	params = {app: req.params.app, id: req.params.id, ttl: req.param('ttl'), ip: req.param('ip')}
	if _.keys(req.body).length
		params = _.extend(params, {d: req.body})
	rs.create params, _.partial(_respond, res)
	return

app.get '/:app/get/:token', (req, res) ->
	rs.get {app: req.params.app, token: req.params.token},  _.partial(_respond, res)
	return

app.post '/:app/set/:token', (req, res) ->
	rs.set {app: req.params.app, token: req.params.token, d: req.body},  _.partial(_respond, res)
	return

app.get '/:app/soapp', (req, res) ->
	rs.soapp {app: req.params.app, dt: req.param("dt")},  _.partial(_respond, res)
	return

app.get '/:app/soid/:id', (req, res) ->
	rs.soid {app: req.params.app, id: req.params.id},  _.partial(_respond, res)
	return

app.delete '/:app/kill/:token', (req, res) ->
	rs.kill {app: req.params.app, token: req.params.token},  _.partial(_respond, res)
	return

app.delete '/:app/killsoid/:id', (req, res) ->
	rs.killsoid {app: req.params.app, id: req.params.id},  _.partial(_respond, res)
	return

app.delete '/:app/killall', (req, res) ->
	rs.killall {app: req.params.app},  _.partial(_respond, res)
	return

module.exports = app
