class BoundingBox
  constructor: (@x_max, @x_min, @y_max, @y_min, @z_max, @z_min) ->
    @x_width = @x_max - @x_min
    @y_width = @y_max - @y_min
    @z_width = @z_max - @z_min


  contains: (boundingBox) ->
    return false  if boundingBox.x_min > @x_max or boundingBox.x_max < @x_min
    return false  if boundingBox.y_min > @y_max or boundingBox.y_max < @y_min
    return false  if boundingBox.z_min > @z_max or boundingBox.z_max < @z_min
    true

  intersects: (ray) ->
    o = ray.line.anchor
    d = ray.line.direction
    t_x1 = (@x_min - o.e(1)) / d.e(1)
    t_y1 = (@y_min - o.e(2)) / d.e(2)
    t_z1 = (@z_min - o.e(3)) / d.e(3)
    t_x2 = (@x_max - o.e(1)) / d.e(1)
    t_y2 = (@y_max - o.e(2)) / d.e(2)
    t_z2 = (@z_max - o.e(3)) / d.e(3)
    t_x_min = Math.min(t_x1, t_x2)
    t_x_max = Math.max(t_x1, t_x2)
    t_y_min = Math.min(t_y1, t_y2)
    t_y_max = Math.max(t_y1, t_y2)
    t_z_min = Math.min(t_z1, t_z2)
    t_z_max = Math.max(t_z1, t_z2)
    t_min = Math.max(t_x_min, t_y_min, t_z_min)
    t_max = Math.min(t_x_max, t_y_max, t_z_max)

    # intersection if t_min < t_max
    t_min < t_max

  @getBoundingBoxFromObjects: (objects) ->
    x_min = Infinity
    y_min = Infinity
    z_min = Infinity
    x_max = -Infinity
    y_max = -Infinity
    z_max = -Infinity
    i = 0

    while i < objects.length
      boundingBox = objects[i].getBoundingBox()
      x_min = boundingBox.x_min if boundingBox.x_min < x_min
      y_min = boundingBox.y_min if boundingBox.y_min < y_min
      z_min = boundingBox.z_min if boundingBox.z_min < z_min
      x_max = boundingBox.x_max if boundingBox.x_max > x_max
      y_max = boundingBox.y_max if boundingBox.y_max > y_max
      z_max = boundingBox.z_max if boundingBox.z_max > z_max
      i++
    new BoundingBox(x_max, x_min, y_max, y_min, z_max, z_min)