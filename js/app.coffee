---
---

App = Ember.Application.create()

App.Router.map () ->
  # routes go here

App.IndexRoute = Ember.Route.extend {
  model: () ->
    ['red', 'yellow', 'blue']
}
