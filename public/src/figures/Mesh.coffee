class Mesh

  constructor: (@position, @scale) ->
    @V = new Array() # vertices
    @F = new Array() # triangles
    @N = new Array() # normals
    @triangles = new Array()
    @octree = new Octree(null, 0)

  getBounding: ->
    @bounding = BoundingBox.getBoundingFromObjects(@triangles) unless @bounding
    @bounding

  generateTriangles: ->
    i = 0
    while i < @F.length
      face = @F[i]
      triangle = new Triangle(@V[face.e(1)].multiply(@scale).add(@position),
        @V[face.e(2)].multiply(@scale).add(@position), @V[face.e(3)].multiply(@scale).add(@position), null)
      @triangles[i] = triangle
      i++

    if RayConfig.octree
      depth = Math.min(Math.ceil(Math.log(@triangles.length) / Math.log(8)), RayConfig.octreeMaxDepth)
      @octree = new Octree(this.getBounding(), depth)
      i = 0

      while i < @triangles.length
        @octree.insertObject @triangles[i]
        i++

  intersection: (ray) ->
    min_intersection = null
    objects = (if RayConfig.octree then @octree.getIntersectionObjects(ray) else @triangles)

    #console.rlog("triangle intersection tests (before): " + objects.length);
    objects = objects.filter((elem, pos) ->
      objects.indexOf(elem) is pos
    )

    #console.rlog("triangle intersection tests (after): " + objects.length);
    i = 0
    while i < objects.length
      intersection = objects[i].intersection(ray)
      if intersection
        if min_intersection == null || intersection.distance < min_intersection.distance
          min_intersection = intersection
          min_intersection.reflectionProperties = @reflectionProperties
          min_intersection.figure = this
      ++i
    min_intersection

  computeNormals: ->
    i = 0
    while i < @V.length
      @N[i] = $V([0, 0, 0])
      ++i

    i = 0
    while i < @F.length
      f = @F[i]
      t = @triangles[i]
      @N[f.e(1)] = @N[f.e(1)].add(t.getTriangleNormal().multiply(t.getArea()))
      @N[f.e(2)] = @N[f.e(2)].add(t.getTriangleNormal().multiply(t.getArea()))
      @N[f.e(3)] = @N[f.e(3)].add(t.getTriangleNormal().multiply(t.getArea()))
      i++

    i = 0
    while i < @V.length
      @N[i] = @N[i].toUnitVector()
      ++i

    i = 0
    while i < @triangles.length
      f = @F[i]
      t = @triangles[i]
      t.n1 = @N[f.e(1)]
      t.n2 = @N[f.e(2)]
      t.n3 = @N[f.e(3)]
      i++