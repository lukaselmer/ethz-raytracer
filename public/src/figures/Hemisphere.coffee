class Hemisphere

  constructor: (@sphere, @plane) ->

  intersection: (ray) ->
    s = @sphere.intersection(ray)
    p = @plane.intersection(ray)

    # one intersection
    return null unless s && p

    s1 = s.distance
    s2 = s.distance2
    p1 = p.distance

    # sphere intersection before plane intersection
    return null if s1 < p1 && s2 < p1

    # plane intersection before sphere intersection
    return s if s1 > p1 && s2 > p1

    # plane intersection between sphere intersections
    return p if s1 < p1 && s2 > p1

    throw "Invalid state: s1: #{s2}, s1: #{s2}, p1: #{p1}"

  solutions: (ray) ->
    i = this.intersection(ray)
    return null unless i
    [i.t1, i.t2]
