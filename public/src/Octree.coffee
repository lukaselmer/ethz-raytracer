class Octree
  constructor: () ->
    @figures = []

  add: (figure) ->
    @figures.push(figure)

  getFirstFigure: (ray) ->
    min = Infinity
    ret = null
    for figure in @figures
      i = figure.intersection(ray)
      continue unless i

      dist = i.distance
      if dist != null && dist < min
        ret = i
        min = dist
    ret