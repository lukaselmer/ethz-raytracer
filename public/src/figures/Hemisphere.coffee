class Hemisphere

  constructor: (@sphere, @plane) ->

  intersection: (ray) ->
    sphereIntersection = @sphere.intersection(ray)
    planeIntersection = @plane.intersection(ray)

    # just one intersection
    return null if sphereIntersection is null or planeIntersection is null

    # sphere before plane intersection -> miss
    return null if sphereIntersection.distance < planeIntersection.distance and sphereIntersection.distance2 < planeIntersection.distance

    # plane before sphere intersection -> intersection on sphere
    return sphereIntersection if sphereIntersection.distance > planeIntersection.distance and sphereIntersection.distance2 > planeIntersection.distance

    # plane between sphere intersections -> intersection on plane
    return planeIntersection if sphereIntersection.distance < planeIntersection.distance and sphereIntersection.distance2 > planeIntersection.distance

    # should never come here
    throw "Invalid state"


  ###intersection: (ray) ->
    si = @sphere.solutions(ray)
    pi = @plane.solutions(ray)

    # sphere intersection before plane intersection
    return null unless si && pi

    [si1, si2] = si
    [si1, si2] = [si2, si1] if si1 > si2

    [pi1, pi2] = pi
    [pi1, pi2] = [pi2, pi1] if pi1 > pi2

    # sphere intersection before plane intersection
    return null if si1 < pi1 && si2 < pi1

    # plane intersection before sphere intersection => sphere intersection
    if si1 > pi1 && si2 > pi1
      return @sphere.intersection(ray)

    # sphere intersection before plane intersection => plane intersection
    if si1 < pi1 && si2 > pi1
      return @plane.intersection(ray)

    throw "Invalid state"###

  solutions: (ray) ->
    i = this.intersection(ray)
    return null unless i
    [i.t1, i.t2]
