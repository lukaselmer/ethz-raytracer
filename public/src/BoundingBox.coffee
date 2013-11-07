class BoundingBox
  constructor: (@x_max, @x_min, @y_max, @y_min, @z_max, @z_min) ->
    @x_width = @x_max - @x_min
    @y_width = @y_max - @y_min
    @z_width = @z_max - @z_min


  contains: (bounding) ->
    return false  if bounding.x_min > @x_max or bounding.x_max < @x_min
    return false  if bounding.y_min > @y_max or bounding.y_max < @y_min
    return false  if bounding.z_min > @z_max or bounding.z_max < @z_min
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

  @getBoundingFromObjects: (objects) ->
    x_min = Infinity
    y_min = Infinity
    z_min = Infinity
    x_max = -Infinity
    y_max = -Infinity
    z_max = -Infinity
    i = 0




    while i < objects.length
      bounding = objects[i].getBounding()
      x_min = bounding.x_min if bounding.x_min < x_min
      y_min = bounding.y_min if bounding.y_min < y_min
      z_min = bounding.z_min if bounding.z_min < z_min
      x_max = bounding.x_max if bounding.x_max > x_max
      y_max = bounding.y_max if bounding.y_max > y_max
      z_max = bounding.z_max if bounding.z_max > z_max
      i++
    new BoundingBox(x_max, x_min, y_max, y_min, z_max, z_min)