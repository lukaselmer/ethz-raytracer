class MultipleObjectsIntersection
  constructor: (@figure1, @figure2, @reflectionProperties) ->

  norm: (intersectionPoint, ray) ->
    i1 = @figure1.solutions(ray)
    i2 = @figure2.solutions(ray)

    [i11, i12] = i1
    [i11, i12] = [i12, i11] if i11 > i12
    [i21, i22] = i2
    [i21, i22] = [i22, i21] if i21 > i22

    return if i21 < i11 then @figure1.norm(intersectionPoint) else @figure2.norm(intersectionPoint)

  solutions: (ray) ->
    i1 = @figure1.solutions(ray)
    i2 = @figure2.solutions(ray)

    return null unless i1 && i2

    [i11, i12] = i1
    [i11, i12] = [i12, i11] if i11 > i12

    [i21, i22] = i2
    [i21, i22] = [i22, i21] if i21 > i22

    [i1, i11, i12, i2, i21, i22] = [i2, i21, i22, i1, i11, i12] if i21 < i11

    return null if i12 < i21

    [i21, Math.min(i12, i21)]
