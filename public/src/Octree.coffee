class Octree
  constructor: () ->
    @maxDepth = RayConfig.octreeMaxDepth
    @figures = []
    @built = false
    @type = 'child'

  add: (figure) ->
    @figures.push(figure)
    @built = false

  calculateBoundingBox: () ->
    @boundingBox = new BoundingBox(0, 0, 0, 0, 0, 0)

    for figure in @figures
      @boundingBox.update(figure.boundingBox())

  build: () ->
    this.calculateBoundingBox()
    @octreeNode = new OctreeNode()
    @built = true

  getFirstFigure: (ray) ->
    this.build() unless @built

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
