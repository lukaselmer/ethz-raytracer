// Generated by CoffeeScript 1.6.3
var Cylinder;

Cylinder = (function() {
  function Cylinder(axis_line, fixed_x, fixed_y, fixed_z, radius_x, radius_y, radius_z, reflectionProperties) {
    this.axis_line = axis_line;
    this.fixed_x = fixed_x;
    this.fixed_y = fixed_y;
    this.fixed_z = fixed_z;
    this.radius_x = radius_x;
    this.radius_y = radius_y;
    this.radius_z = radius_z;
    this.reflectionProperties = reflectionProperties;
    this.radius_x_2 = Math.square(this.radius_x);
    this.radius_y_2 = Math.square(this.radius_y);
    this.radius_z_2 = Math.square(this.radius_z);
  }

  Cylinder.prototype.norm = function(intersectionPoint) {
    var intersection, n;
    intersection = $V([(this.fixed_x ? 0 : (intersectionPoint.e(1)) / this.radius_x_2), (this.fixed_y ? 0 : (intersectionPoint.e(2)) / this.radius_y_2), (this.fixed_z ? 0 : (intersectionPoint.e(3)) / this.radius_z_2)]);
    n = intersection.subtract(this.axis_line);
    return n.toUnitVector();
  };

  Cylinder.prototype.intersects = function(ray) {
    var a, b, c, dir, oc, root, t1, t2, under_root;
    oc = ray.line.anchor.subtract(this.axis_line);
    dir = ray.line.direction.toUnitVector();
    a = (this.fixed_x ? 0 : (dir.e(1) * dir.e(1)) / this.radius_x_2) + (this.fixed_y ? 0 : dir.e(2) * dir.e(2) / this.radius_y_2) + (this.fixed_z ? 0 : dir.e(3) * dir.e(3) / this.radius_z_2);
    b = (this.fixed_x ? 0 : (2 * oc.e(1) * dir.e(1)) / this.radius_x_2) + (this.fixed_y ? 0 : (2 * oc.e(2) * dir.e(2)) / this.radius_y_2) + (this.fixed_z ? 0 : (2 * oc.e(3) * dir.e(3)) / this.radius_z_2);
    c = (this.fixed_x ? 0 : (oc.e(1) * oc.e(1)) / this.radius_x_2) + (this.fixed_y ? 0 : (oc.e(2) * oc.e(2)) / this.radius_y_2) + (this.fixed_z ? 0 : (oc.e(3) * oc.e(3)) / this.radius_z_2) - 1;
    under_root = Math.square(b) - (4 * a * c);
    if (under_root < 0 || a === 0 || b === 0 || c === 0) {
      return null;
    }
    root = Math.sqrt(under_root);
    t1 = (-b + root) / (2 * a);
    t2 = (-b - root) / (2 * a);
    if (t1 < RayConfig.intersectionDelta) {
      return t2;
    }
    if (t2 < RayConfig.intersectionDelta) {
      return t1;
    }
    return Math.min(t1, t2);
  };

  return Cylinder;

})();
