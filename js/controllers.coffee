---
---

app.controller 'HomeCtrl',['$scope', ($scope)->
  $scope.hello = "HI GUYS"
]

app.controller 'CoursesCtrl',['$scope', 'ApiFactory', 'AuthFactory', '$sce', '$modal', ($scope, ApiFactory, AuthFactory, $sce, $modal)->
  $scope.authf = AuthFactory
  AuthFactory.login({username: 'penis', password: 'vagina'})
  ApiFactory.getCourses().then (courses)->
    $scope.courses = courses
    _.each($scope.courses, (course) ->
      _.each(course.topic_set, (set) ->
        topic_set_id = set.split('/')
        topic_set_id = topic_set_id[topic_set_id.length - 2]
        ApiFactory.getTopics(topic_set_id).then (topics) ->
          course.topics = topics
          _.each(course.topics, (topic) ->
            _.each(topic.resource_set, (rset) ->
              resource_set_id = rset.split('/')
              resource_set_id = resource_set_id[resource_set_id.length - 2]
              ApiFactory.getResources(resource_set_id).then (resources) ->
                topic.resources = resources
            )
          )
        )
    )

  $scope.selectCourse = (course) ->
    $scope.selected_course = course
  $scope.selectTopic = (topic) ->
    $scope.selected_topic = topic
  $scope.trust = (stuff) ->
    $sce.trustAsHtml(stuff)
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
  $scope.upVote = (resource) ->
    
]

app.controller 'ResourceModalCtrl',['$scope', '$modalInstance', ($scope, $modalInstance)->
  $scope.resource = {}
  $scope.dismiss = () ->
    $modalInstance.dismiss()
  $scope.ok = (resource) ->
    $modalInstance.close($scope.resource)
]