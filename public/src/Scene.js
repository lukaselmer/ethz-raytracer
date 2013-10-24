// Generated by CoffeeScript 1.6.3
var Scene;

Scene = (function() {
  function Scene(camera, globalAmbient) {
    this.camera = camera;
    this.globalAmbient = globalAmbient;
    this.objects = [];
    this.lights = [];
  }

  Scene.prototype.addLight = function(light) {
    return this.lights.push(light);
  };

  Scene.prototype.addObject = function(object) {
    return this.objects.push(object);
  };

  Scene.prototype.firstIntersection = function(ray) {
    var min, ret;
    min = Infinity;
    ret = null;
    this.objects.forEach(function(object) {
      var i, intersectionPoint, normal, _ref;
      _ref = object.intersection(ray), i = _ref[0], intersectionPoint = _ref[1], normal = _ref[2];
      if (i && i < min && i > RayConfig.intersectionDelta) {
        min = i;
        return ret = [intersectionPoint, normal, object];
      }
    });
    return ret;
  };

  return Scene;

})();

/*
//@ sourceMappingURL=Scene.map
*/
