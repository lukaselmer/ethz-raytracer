class Triangle
  constructor: (@v1, @v2, @v3, @reflectionProperties) ->

  #boundingBox: ->
  #  this.getBoundingBox()

  getBoundingBox: ->
    return @boundingBox if @boundingBox
    min_x = Infinity
    min_y = Infinity
    min_z = Infinity
    max_x = -Infinity
    max_y = -Infinity
    max_z = -Infinity
    min_x = @v1.e(1) if @v1.e(1) < min_x
    min_x = @v2.e(1) if @v2.e(1) < min_x
    min_x = @v3.e(1) if @v3.e(1) < min_x
    max_x = @v1.e(1) if @v1.e(1) > max_x
    max_x = @v2.e(1) if @v2.e(1) > max_x
    max_x = @v3.e(1) if @v3.e(1) > max_x
    min_y = @v1.e(2) if @v1.e(2) < min_y
    min_y = @v2.e(2) if @v2.e(2) < min_y
    min_y = @v3.e(2) if @v3.e(2) < min_y
    max_y = @v1.e(2) if @v1.e(2) > max_y
    max_y = @v2.e(2) if @v2.e(2) > max_y
    max_y = @v3.e(2) if @v3.e(2) > max_y
    min_z = @v1.e(3) if @v1.e(3) < min_z
    min_z = @v2.e(3) if @v2.e(3) < min_z
    min_z = @v3.e(3) if @v3.e(3) < min_z
    max_z = @v1.e(3) if @v1.e(3) > max_z
    max_z = @v2.e(3) if @v2.e(3) > max_z
    max_z = @v3.e(3) if @v3.e(3) > max_z
    @boundingBox = new BoundingBox(max_x, min_x, max_y, min_y, max_z, min_z)
    @boundingBox

  getArea: ->
    return @area if @area

    AB = @v2.subtract(@v1)
    AC = @v3.subtract(@v1)
    cr = AB.cross(AC)
    @area = cr.distanceFrom($V([0, 0, 0])) / 2
    @area

  getTriangleNormal: ->
    return @triangleNormal if @triangleNormal

    e1 = @v1.subtract(@v2)
    e2 = @v1.subtract(@v3)
    @triangleNormal = e1.cross(e2).toUnitVector()
    @triangleNormal

  norm: (intersectionPoint) ->
    return this.getTriangleNormal() unless @n1 || @n2 || @n3
    t1 = new Triangle(intersectionPoint, @v2, @v3).getArea()
    t2 = new Triangle(intersectionPoint, @v1, @v3).getArea()
    t3 = new Triangle(intersectionPoint, @v1, @v2).getArea()

    normal = $V([0, 0, 0])
    normal = normal.add(@n1.multiply(t1))
    normal = normal.add(@n2.multiply(t2))
    normal = normal.add(@n3.multiply(t3))
    normal.toUnitVector()

  intersection: (ray) ->

    # ⟨Get triangle vertices in p1, p2, and p3 140⟩
    p1 = @v1
    p2 = @v2
    p3 = @v3

    # ⟨Compute s1 141⟩
    e1 = p2.subtract(p1)
    e2 = p3.subtract(p1)
    s1 = ray.line.direction.cross(e2)
    divisor = s1.dot(e1)
    return null if divisor is 0
    invDivisor = 1.0 / divisor

    # ⟨Compute first barycentric coordinate 142⟩
    d = ray.line.anchor.subtract(p1)
    b1 = d.dot(s1) * invDivisor
    return null if b1 < 0 or b1 > 1

    # ⟨Compute second barycentric coordinate 142⟩
    s2 = d.cross(e1)
    b2 = ray.line.direction.dot(s2) * invDivisor
    return null if b2 < 0 or b1 + b2 > 1

    # ⟨Compute t to intersection point 142⟩
    t = e2.dot(s2) * invDivisor


    #if (t < ray.mint || t > ray.maxt)
    #    return false;

    # ⟨Compute triangle partial derivatives 143⟩
    # ⟨Interpolate (u, v) triangle parametric coordinates 143⟩
    # ⟨Test intersection against alpha texture, if present 144⟩
    # ⟨Fill in Differential Geometry from triangle hit 145⟩
    # *tHit = t;
    # *rayEpsilon = 1e-3f * *tHit;
    # return true;
    i = new Intersection(ray, this, this, t, null, @reflectionProperties)
