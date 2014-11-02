---
---

window.app = angular.module('theApp', ['restangular', 'ui.bootstrap', 'ngRoute'])

app.config ['$routeProvider', ($routeProvider)->
  $routeProvider.when '/home', {templateUrl: '/partial/home.html', controller: 'HomeCtrl' }
  $routeProvider.when '/courses', {templateUrl: '/partial/courses.html', controller: 'CoursesCtrl' }

  $routeProvider.otherwise { redirectTo: '/home'}
]

app.config ['RestangularProvider', '$httpProvider', (RestangularProvider, $httpProvider)->
  RestangularProvider.setBaseUrl('http://localhost:8000')
]
app.run(['$rootScope', '$location', 'AuthFactory'
  ($rootScope, $location, AuthFactory) ->
    routesThatDontRequireAuth = ['/home', '/courses'];

    routeClean = (route) ->
      return _.find(routesThatDontRequireAuth,
        (noAuthRoute) ->
          return _.str.startsWith(route, noAuthRoute)
        )

    $rootScope.$on '$routeChangeStart',
      (event, next, current) ->
        if (!routeClean($location.url()) && !AuthFactory.isLoggedIn())
          AuthFactory.friendlyRedirect = $location.path()
          $location.path('/home')
        window.updateActive $location.path()
        $rootScope.flash = undefined
])


window.updateActive = (path) ->
  $('.nav > li').each (i, e) ->
    route = $(this).attr 'route'
    if path.match(route) && route
      $(this).addClass 'active'
    else
      $(this).removeClass 'active'