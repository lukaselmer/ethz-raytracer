class Hemisphere

  constructor: (@sphere, @plane) ->

  norm: (intersectionPoint, ray) ->
    si = @sphere.solutions(ray)
    pi = @plane.solutions(ray)

    return null unless si && pi

    [si1, si2] = si
    [si1, si2] = [si2, si1] if si1 > si2

    [pi1, pi2] = pi
    [pi1, pi2] = [pi2, pi1] if pi1 > pi2

    return null if si1 < pi1 && si2 < pi1

    if si1 > pi1 && si2 > pi1
      @reflectionProperties = @sphere.reflectionProperties
      return @sphere.norm(intersectionPoint, ray)

    if si1 < pi1 && si2 > pi1
      @reflectionProperties = @plane.reflectionProperties
      return @plane.norm(intersectionPoint, ray)

    throw "Invalid state"

  solutions: (ray) ->
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
      @reflectionProperties = @sphere.reflectionProperties
      return si

    # sphere intersection before plane intersection => plane intersection
    if si1 < pi1 && si2 > pi1
      @reflectionProperties = @plane.reflectionProperties
      return pi

    throw "Invalid state"
