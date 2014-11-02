---
---

window.urlbase = 'http://localhost:8000'

myServices = angular.module 'theApp'

myServices.factory 'ApiFactory', ['Restangular', (Restangular) ->
  {
    getVotes: () ->
      Restangular.all('votes/').getList()
    getCourses: () ->
      Restangular.all('courses/').getList()
    getCourse: (course_id) ->
      Restangular.one('courses', course_id).one('').get()
    getTopics: (course_id) ->
      Restangular.all('topics/', course_id).getList()
    getTopic: (topic_id) ->
      Restangular.one('topics', topic_id).one('').get()
    getResources: () ->
      Restangular.all('resources/').getList()
    getResource: (resource_id) ->
      Restangular.one('resources', resource_id).one('').get()
    createResource: (title, content, topic_id, author_id) ->
      Restangular.all('resources/').customPOST({
        title: title
        content: content
        topic: window.urlbase + '/topics/' + topic_id + '/'
        author: window.urlbase + '/users/' + author_id + '/'
        viewcount: 0,
        points: 1
      })
    createVote: (value, resource_id, user_id) ->
      Restangular.all('votes/').customPOST({
        value: value
        resource: window.urlbase + '/resources/' + resource_id + '/'
        voter: window.urlbase + '/users/' + user_id + '/'
      })
    updateVote: (value, vote_id, resource_id, user_id) ->
      Restangular.one('votes', vote_id).all('').customPUT({
        value: value
        resource: window.urlbase + '/resources/' + resource_id + '/'
        voter: window.urlbase + '/users/' + user_id + '/'
      })
    updatePoints: (resource, points) ->
      Restangular.one('resources/' + resource.id + '/').customPUT({
        points: points
        author: resource.author
        content: resource.content
        title: resource.title
        topic: resource.topic
        viewcount: resource.viewcount
      })
  }
]

myServices.factory 'AuthFactory', ['Restangular', '$window', '$q', (Restangular, $window, $q) ->
  {
    login: (credentials) -> # credentials: {username, password}
      deferred = $q.defer()
      obj = {'Authorization': 'Basic ' + btoa(credentials.username + ':' + credentials.password)}
      Restangular.setDefaultHeaders(obj)
      authf = this

      response = Restangular.all('users/').getList().then((scc) ->
        authf._isLoggedIn = true
        authf.current_user = _.find(scc, (user) -> user.username == credentials.username)
        deferred.resolve(true)
      , (err) ->
        authf.errors = [err]
        deferred.reject(authf.errors)
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