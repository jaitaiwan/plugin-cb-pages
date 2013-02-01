###
# @name cb-pages
# @author Daniel J Holmes
# @description loads pages based on url
###

Plugin = require '../../library/Plugin.main'
IO = require '../../coffeeblog/log'
coffeeblog = require '../../coffeeblog/coffeeblog'
Database = coffeeblog.singleton().database
config = require '../../config'

class Pages extends Plugin
	routes:[
		{
			address: '/:page'
			method: 'get'
			callback: (request, response, template, next) =>
				Database.get {postType:"page",name:request.params.page}, {}, (err, datas) ->
					if err then IO.log "Failed to load page from memory"
					if datas.length is 0
						next()
					for data in datas
						if data.name is request.params.page
							try
								view = require "../../templates/#{config.template}/views/page"
								template.changeContent view data
							catch e
								IO.warn "Template does not have a page view"
								IO.debug e
								template.changeContent data.contents
							response.send template.render()
							template.newContext()
							return true
						else return next()
				, "posts"
		}
	]

module.exports = Pages