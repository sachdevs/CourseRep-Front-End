---
---

window.urlbase = 'http://localhost:8000'

myServices = angular.module 'theApp'

myServices.factory 'ApiFactory', ['Restangular', (Restangular) ->
  {
    getCourses: () ->
      Restangular.all('courses/').getList()
    getCourse: (course_id) ->
      Restangular.one('courses', course_id).get()
    getTopics: (course_id) ->
      Restangular.all('topics/', course_id).getList()
    getTopic: (course_id, topic_id) ->
      Restangular.one('courses', course_id).one('topics', topic_id).get()
    getResources: (topic_id) ->
      Restangular.all('resources/', topic_id).getList()
    getResource: (resource_id) ->
      Restangular.one('resources', resource_id).get()
    createResource: (content, topic_id, author_id) ->
      Restangular.all('resources').customPOST({
        content: content
        topic: window.urlbase + '/topics/' + topic_id + '/'
        author: window.urlbase + '/users/' + author_id + '/'
      })
  }
]

myServices.factory 'AuthFactory', ['Restangular', '$window', '$q', (Restangular, $window, $q) ->
  {
    login: (credentials) -> # credentials: {username, password}
      deferred = $q.defer()
      obj = {'Authorization': 'Basic ' + btoa(credentials.username + ':' + credentials.password)}
      Restangular.setDefaultHeaders(obj)

      response = Restangular.all('users/').getList().then((scc) ->
        this._isLoggedIn = true
        deferred.resolve(true)
      , (err) ->
        this.errors = [err]
        deferred.reject(this.errors)
      )
      return deferred.promise
    ,
    logout: () ->
      authf = this
      authf._isLoggedIn = false
      Restangular.setDefaultHeaders({'Authorization': ''})
    ,
    isLoggedIn: () ->
      this._isLoggedIn ||= $window.sessionStorage.getItem 'current_user'
    ,
    currentUser: () ->
      this.current_user ||= angular.fromJson($window.sessionStorage.getItem('current_user'))
    ,
    relationshipHolder: () ->
      this.relationship_holder ||= Restangular.one('relationship_holders').get()
    ,
    currentOrganization: () ->
      this.current_organization ||= angular.fromJson($window.sessionStorage.getItem('current_organization'))
    testLogin: () ->
      deferred = $q.defer()
      authf = this
      Restangular.one('users/sign_in').get().then (response) ->
        if response.success
          authf._isLoggedIn = true
          authf.current_user = response.current_user
          authf.current_organization = response.current_organization
          $window.sessionStorage.setItem 'current_user', JSON.stringify(authf.current_user)
          $window.sessionStorage.setItem 'current_organization', JSON.stringify(authf.current_organization)
          deferred.resolve(authf.current_user)
        else
          deferred.reject(authf.errors)
      return deferred.promise
  }
]