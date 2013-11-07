class BoundingBoxOld
  constructor: (@right, @left, @top, @bottom, @back, @front) ->

  update: (other) ->
    @right = Math.max(@right, other.right)
    @left = Math.min(@left, other.left)

    @top = Math.max(@top, other.top)
    @bottom = Math.min(@bottom, other.bottom)

    @back = Math.max(@back, other.back)
    @front = Math.min(@front, other.front)

  center: () ->
    v1 = $V([@right, @top, @back])
    v2 = $V([@left, @bottom, @front])
    v1.add(v2).multiply(0.5)
