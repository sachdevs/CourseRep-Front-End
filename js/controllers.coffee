---
---

app.controller 'HomeCtrl',['$scope', ($scope)->
  $scope.hello = "HI GUYS"
]

app.controller 'CoursesCtrl',['$scope', 'ApiFactory', 'AuthFactory', '$sce', '$modal', ($scope, ApiFactory, AuthFactory, $sce, $modal)->
  $scope.authf = AuthFactory
  current_user = AuthFactory.current_user
  $scope.openLoginModal = () ->
    $modal.open {
      templateUrl: '/partial/login_modal.html'
      controller: 'LoginModalCtrl'
    }
  after_login = () ->
    ApiFactory.getCourses().then (courses)->
      $scope.courses = courses
      _.each($scope.courses, (course) ->
        course.topics = []
        _.each(course.topic_set, (set) ->
          topic_set_id = set.split('/')
          topic_set_id = topic_set_id[topic_set_id.length - 2]
          ApiFactory.getTopic(topic_set_id).then (topic) ->
            course.topics.push topic
            topic.resources = []
            _.each(topic.resource_set, (rset) ->
              resource_set_id = rset.split('/')
              resource_set_id = resource_set_id[resource_set_id.length - 2]
              ApiFactory.getResource(resource_set_id).then (resource) ->
                topic.resources.push resource
            )
          )
      )
    $scope.refreshVotes()
  if !current_user
    $scope.openLoginModal().result.then(after_login)
  else
    after_login()
  $scope.refreshVotes = () ->
    ApiFactory.getVotes().then (votes) ->
      votes = _.map(votes, (vote) ->
        voter = vote.voter.split('/')
        voter = voter[voter.length - 2] # Get voter id
        resource = vote.resource.split('/')
        resource = resource[resource.length - 2] # Get resource id
        return {
          id: vote.id
          value: vote.value
          voter: parseInt(voter)
          resource: parseInt(resource)
        }
      )
      $scope.votes = votes

  $scope.selectCourse = (course) ->
    $scope.selected_course = course
  $scope.selectTopic = (topic) ->
    $scope.selected_topic = topic
  $scope.trust = (stuff) ->
    $sce.trustAsHtml(stuff)
  $scope.getVote = (resource) ->
    val = _.find($scope.votes, (vote) -> vote.resource == resource.id)
    val && val.value
  $scope.open = (content) ->
    valid_url_regex = /^http[^<>]*/i
    if content.match valid_url_regex
      window.location.assign(content)
  $scope.openResourceModal = () ->
    modalInstance = $modal.open {
      templateUrl: '/partial/resource_modal.html'
      controller: 'ResourceModalCtrl'
    }

    modalInstance.result.then (res) ->
      res.topic_id = $scope.selected_topic.id
      res.author_id = AuthFactory.current_user.id
      ApiFactory.createResource(res.title, res.content, res.topic_id, res.author_id).then (resource) ->
        $scope.selected_topic.resources.push resource
  $scope.vote = (resource, value) ->
    existing_vote = _.find($scope.votes, (vote) -> vote.resource == resource.id)
    if existing_vote
      delta = value - existing_vote.value
      ApiFactory.updateVote(value, existing_vote.id, resource.id, AuthFactory.current_user.id).then (vote) ->
        $scope.refreshVotes()
        ApiFactory.updatePoints(resource, resource.points + delta).then (res) ->
          _.extend(_.find($scope.selected_topic.resources, (reso) -> reso.id == res.id), res)
    else
      ApiFactory.createVote(value, resource.id, AuthFactory.current_user.id).then (vote) ->
        $scope.refreshVotes()
        ApiFactory.updatePoints(resource, resource.points + value).then (res) ->
          _.extend(_.find($scope.selected_topic.resources, (reso) -> reso.id == res.id), res)
]

app.controller 'ResourceModalCtrl',['$scope', '$modalInstance', ($scope, $modalInstance)->
  $scope.resource = {}
  $scope.dismiss = () ->
    $modalInstance.dismiss()
  $scope.ok = (resource) ->
    $modalInstance.close($scope.resource)
]

app.controller 'LoginModalCtrl',['$scope', '$modalInstance', 'AuthFactory', ($scope, $modalInstance, AuthFactory)->
  $scope.login = (credentials) ->
    AuthFactory.login(credentials).then (user) ->
      if user
        $modalInstance.close()
      else
        alert user
    () ->
      alert 'An Error Occured'
]