class MultipleObjectsIntersection
  constructor: (@figure1, @figure2, @reflectionProperties) ->

  norm: (intersectionPoint, ray) ->
    i1 = @figure1.solutions(ray)
    i2 = @figure2.solutions(ray)

    [i11, i12] = i1
    [i11, i12] = [i12, i11] if i11 > i12
    [i21, i22] = i2
    [i21, i22] = [i22, i21] if i21 > i22

    f = if i21 < i11 then @figure1 else @figure2

    return f.norm(intersectionPoint, ray)

  solutions: (ray) ->
    i = this.intersection(ray)
    return null unless i
    [i.t1, i.t2]

  intersection: (ray) ->
    f1 = @figure1
    f2 = @figure2
    i1 = f1.solutions(ray)
    i2 = f2.solutions(ray)

    return null unless i1 && i2

    [i11, i12] = i1
    [i11, i12] = [i12, i11] if i11 > i12

    [i21, i22] = i2
    [i21, i22] = [i22, i21] if i21 > i22

    [f1, i1, i11, i12, f2, i2, i21, i22] = [f2, i2, i21, i22, f1, i1, i11, i12] if i21 < i11

    return null if i12 < i21

    new Intersection(ray, this, f2, i21, Math.min(i12, i22), @reflectionProperties)
