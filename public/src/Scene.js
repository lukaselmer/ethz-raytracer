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

  Scene.prototype.intersections = function(ray) {
    var object, _i, _len, _ref, _results;
    _ref = this.objects;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      object = _ref[_i];
      if (object.intersects(ray)) {
        _results.push(object);
      }
    }
    return _results;
  };

  Scene.prototype.firstIntersection = function(ray) {
    var min, ret;
    min = Infinity;
    ret = null;
    this.objects.forEach(function(object) {
      var i, intersectionPoint;
      i = object.intersects(ray);
      if (i && i < min) {
        min = i;
        intersectionPoint = ray.line.anchor.add(ray.line.direction.multiply(i));
        return ret = [intersectionPoint, object];
      }
    });
    return ret;
  };

  return Scene;

})();
