// Generated by CoffeeScript 1.6.3
var Plane;

Plane = (function() {
  function Plane(point, normal, reflectionProperties) {
    this.point = point;
    this.normal = normal;
    this.reflectionProperties = reflectionProperties;
    this.normal = this.normal.toUnitVector();
  }

  Plane.prototype.norm = function(intersectionPoint, ray) {
    return this.normal;
  };

  Plane.prototype.intersection = function(ray) {
    var cos, d;
    cos = ray.line.direction.dot(this.normal);
    if (cos === 0) {
      return null;
    }
    d = this.point.subtract(ray.line.anchor).dot(this.normal) / cos;
    if (d < RayConfig.intersectionDelta) {
      return null;
    }
    return new Intersection(ray, this, this, d, 0, this.reflectionProperties);
  };

  Plane.prototype.solutions = function(ray) {
    var i;
    i = this.intersection(ray);
    if (!i) {
      return null;
    }
    return [i.t1, i.t2];
  };

  return Plane;

})();
