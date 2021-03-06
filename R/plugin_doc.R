#' Plugin Interface
#' 
#' In order to facilitate encapsulate functionality that can be shared between 
#' `fiery` servers `fiery` implements a plugin interface. Indeed, the reason why
#' `fiery` is so minimal in functionality is because it is intended as a
#' foundation for separate plugins that can add convenience and power. This
#' approach allows `fiery` itself to remain unopinionated and flexible.
#' 
#' @section Using Plugins:
#' Plugins are added to a [`Fire`] object using the `attach()` method. Any
#' parameters passed along with the plugin to the `attach()` method will be
#' passed on to the plugins `on_attach()` method (see below).
#' 
#' ```
#' app$attach(plugin)
#' ```
#' 
#' @section Creating Plugins:
#' The `fiery` plugin specification is rather simple. A plugin is either a list
#' or environment (e.g. a [RefClass][methods::setRefClass] or [R6][R6::R6Class]
#' object) with the following elements:
#' 
#' \describe{
#'  \item{`on_attach(server, ...)`}{A function that will get called when the
#'  plugin is attached to the server. It is passed the server object as the 
#'  first argument along with any arguments passed to the `attach()` method.}
#'  \item{`name`}{A string giving the name of the plugin}
#'  \item{`require`}{**Optional** A character vector giving names of other
#'  plugins that must be attached for this plugin to work}
#' }
#' 
#' Apart from this, the list/environment can contain anything you desires. For
#' an example of a relatively complex plugin, have a look at the source code for
#' the [`routr`](https://github.com/thomasp85/routr) package.
#' 
#' @section Accessing Plugins:
#' When a plugin is attached to a `Fire` object, two things happens. First, the
#' `on_attach()` function in the plugin is called modifying the server in
#' different ways, then the plugin object is saved internally, so that it can 
#' later be retrieved. All plugins are accessible in the `plugins` field under
#' the name of the plugin. This is useful for plugins that modifies other 
#' plugins, or are dependent on functionality in other plugins. A minimal 
#' example of a plugin using another plugin could be:
#' 
#' ```
#' plugin <- list(
#'   on_attach = function(server) {
#'     router <- server$plugins$request_routr
#'     route <- Route$new()
#'     route$add_handler('all', '*', function(request, response, arg_list, ...) {
#'       message('Hello')
#'       TRUE
#'     })
#'     router$add_route(route, 1)
#'   },
#'   name = 'Hello_plugin',
#'   require = 'request_routr'
#' )
#' ```
#' 
#' The `Hello_plugin` depends on the routr plugin for its functionality as it
#' modifies the request router to always say hello when processing requests. If
#' the `reques_routr` plugin has not already been attached it is not possible to
#' use the `Hello_plugin` plugin.
#' 
#' It is also possible to have a soft dependency to another plugin, by not 
#' listing it in `require` and instead use the `has_plugin()` method in the
#' server to modify the behaviour of the plugin. We could rewrite the 
#' `Hello_plugin` to add the routr plugin by itself if missing:
#' 
#' ```
#' plugin <- list(
#'   on_attach = function(server) {
#'     if (!server$has_plugin('request_routr')) {
#'       server$attach(RouteStack$new())
#'     }
#'     router <- server$plugins$request_routr
#'     route <- Route$new()
#'     route$add_handler('all', '*', function(request, response, arg_list, ...) {
#'       message('Hello')
#'       TRUE
#'     })
#'     router$add_route(route, 1)
#'   },
#'   name = 'Hello_plugin2'
#' )
#' ```
#' 
#' @seealso [`Fire`] describes how to create a new server
#' 
#' [events] describes how the server event cycle works
#' 
#' @rdname plugin_doc
#' @name plugin_doc
#' @aliases plugins
#' 
NULL