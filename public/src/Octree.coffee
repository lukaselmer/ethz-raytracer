# Concept from: http://www.brandonpelfrey.com/blog/coding-a-simple-octree/

class Octree
  constructor: (@boundingBox, @depth) ->
    #@maxDepth = RayConfig.octreeMaxDepth
    @data = null
    @children = new Array()

  isLeaf: ->
    @children.length is 0

  makeChildren: ->
    x = 0
    while x <= 1
      y = 0
      while y <= 1
        z = 0
        while z <= 1
          new_b = new BoundingBox(@boundingBox.x_max - (1 - x) * @boundingBox.x_width / 2,
            @boundingBox.x_min + x * @boundingBox.x_width / 2,
            @boundingBox.y_max - (1 - y) * @boundingBox.y_width / 2,
            @boundingBox.y_min + y * @boundingBox.y_width / 2,
            @boundingBox.z_max - (1 - z) * @boundingBox.z_width / 2,
            @boundingBox.z_min + z * @boundingBox.z_width / 2)
          @children.push new Octree(new_b, @depth - 1)
          z++
        y++
      x++

  insertObject: (object) ->
    if @depth <= 0
      @data = new Array() if @data == null
      @data.push object
      return

    # The node is a leaf (no children/not split) and has no data assigned.
    if this.isLeaf() && @data == null

      # This is the easiest! We’ve ended up in a small region of space
      # with no data currently assigned and no children,
      # so we will simply assign this data point
      # to this leaf node and we’re done!
      @data = object
      return

    # The node is a leaf (no children/not split),
    # but it already has a point assigned.
    if @isLeaf() && @data != null

      # This is slightly more complicated.
      # We are at a leaf but there’s something already here.
      # Since we only store one point in a leaf, we will actually
      # need to remember what was here already, split this node
      # into eight children, and then re-insert the old point and
      # our new point into the new children.
      # Note: it’s entirely possible that this will happen several
      # times during insert if these two points are really close
      # to each other. (On the order of the logarithm of the space
      # separating them.)
      this.makeChildren()
      tmp = @data
      @data = null
      this.insertObject tmp

    # The node is an interior node to the tree (has 8 children).
    unless this.isLeaf()

      # Since we never store data in an interior node
      # of the tree in this article, we will find out
      # which of the eight children the data point
      # lies in and then make a recursive call to
      # insert into that child.
      objBoundingBox = object.getBoundingBox()
      i = 0

      while i < @children.length
        @children[i].insertObject object  if @children[i].boundingBox.contains(objBoundingBox)
        i++
      return

  getIntersectionObjects: (ray) ->
    if this.isLeaf()
      return @data if @data != null && @depth <= 0
      return [@data] if @data != null
      return []
    objects = new Array()
    i = 0

    while i < 8
      objects = objects.concat(@children[i].getIntersectionObjects(ray)) if @children[i].boundingBox.intersects(ray)
      i++
    objects