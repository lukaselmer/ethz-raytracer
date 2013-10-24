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
      var i, intersectionPoint;
      i = object.intersects(ray);
      if (i && i < min && i > RayConfig.intersectionDelta) {
        min = i;
        intersectionPoint = ray.line.anchor.add(ray.line.direction.multiply(i));
        return ret = [intersectionPoint, object];
      }
    });
    return ret;
  };

  return Scene;

})();

/*
//@ sourceMappingURL=Scene.map
*/
