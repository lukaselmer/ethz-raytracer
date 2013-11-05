# Idea: http://www.brandonpelfrey.com/blog/coding-a-simple-octree/

class OctreeNode
  constructor: (@boundingBox, @depth) ->
    @values = []
    @type = 'childWithoutData'

  addFigure: (figure) ->
    if @type == 'childWithoutData' || @depth <= 0 # Leaf node => assign value
      @values.push figure
      @type = 'childWithData'
    else if @type == 'internal' # Internal node
      this.insertFigure(figure)
    else # Currently, it's a childWithData => convert it to an internal node
      this.convertToInternalNode()

  convertToInternalNode: () ->
    @center = @boundingBox.center()
    @xPlane = new Plane(@center, $V([1, 0, 0]), null) # vertical plane
    @yPlane = new Plane(@center, $V([0, 1, 0]), null) # horizontal plane
    @zPlane = new Plane(@center, $V([0, 0, 1]), null) # ....? plane
    b = @boundingBox
    c = new BoundingBox(@center.e(1), @center.e(1), @center.e(2), @center.e(2), @center.e(3), @center.e(3))

    @children = [
      new BoundingBox(b.right, c.left, b.top, c.bottom, b.back, c.front), # right && top && back
      new BoundingBox(b.right, c.left, b.top, c.bottom, c.back, b.front), # right && top && front
      new BoundingBox(b.right, c.left, c.top, b.bottom, b.back, c.front), # right && bottom && back
      new BoundingBox(b.right, c.left, c.top, b.bottom, c.back, b.front), # right && bottom && front
      new BoundingBox(c.right, b.left, b.top, c.bottom, b.back, c.front), # left && top && back
      new BoundingBox(c.right, b.left, b.top, c.bottom, c.back, b.front), # left && top && front
      new BoundingBox(c.right, b.left, c.top, b.bottom, b.back, c.front), # left && bottom && back
      new BoundingBox(c.right, b.left, c.top, b.bottom, c.back, b.front), # left && bottom && front
    ]

    v = @values[0]
    @values = null

    this.addFigure(v)

  insertFigure: (figure) ->
    right = figure.isRight(@xPlane)
    left = figure.isLeft(@xPlane)
    top = figure.isTop(@yPlane)
    bottom = figure.isBottom(@yPlane)
    back = figure.isBack(@zPlane)
    front = figure.isFront(@zPlane)

    indices = []
    indices.push(0) if right && top && back
    indices.push(1) if right && top && front
    indices.push(2) if right && bottom && back
    indices.push(3) if right && bottom && front
    indices.push(4) if left && top && back
    indices.push(5) if left && top && front
    indices.push(6) if left && bottom && back
    indices.push(7) if left && bottom && front

    for i in indices
      @children[i].addFigure(figure)
