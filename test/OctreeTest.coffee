describe "Octree", ->
  it "should have a constructor", ->
    new Octree()

  it "should be able to add spheres", ->
    s = new Sphere($V([0,0,0]), 1, null)
    o = new Octree()
    o.add(s)

  it "should get an instersection for staight line", ->
    t = new Octree()
    s1 = new Sphere($V([1,1,1]), 0.5, null)
    t.add(s1)
    s2 = new Sphere($V([1,1,2]), 0.5, null)
    t.add(s2)
    s3 = new Sphere($V([1,0,1]), 0.5, null)
    t.add(s3)

    i = t.getFirstFigure(new Ray($L([1,1,0], [0,0,1])))
    expect(i).not.toBeNull()
    expect(i instanceof Intersection).toBe(true)
    expect(i.figure).toBe(s1)

    i = t.getFirstFigure(new Ray($L([1,0,0], [0,0,1])))
    expect(i).not.toBeNull()
    expect(i instanceof Intersection).toBe(true)
    expect(i.figure).toBe(s3)

    i = t.getFirstFigure(new Ray($L([-1,1,2], [1,0,0])))
    expect(i).not.toBeNull()
    expect(i instanceof Intersection).toBe(true)
    expect(i.figure).toBe(s2)

    i = t.getFirstFigure(new Ray($L([-1,0,2], [1,0,0])))
    expect(i).toBeNull()

  it "should get an instersection for sloped line", ->
    t = new Octree()
    s1 = new Sphere($V([1,1,1]), 0.5, null)
    t.add(s1)
    s2 = new Sphere($V([1,1,2]), 0.5, null)
    t.add(s2)
    s3 = new Sphere($V([1,0,1]), 0.5, null)
    t.add(s3)

    i = t.getFirstFigure(new Ray($L([0,0,0], [1,1,1])))
    expect(i).not.toBeNull()
    expect(i instanceof Intersection).toBe(true)
    expect(i.figure).toBe(s1)

    i = t.getFirstFigure(new Ray($L([0,0,0], [1,1,2])))
    expect(i).not.toBeNull()
    expect(i instanceof Intersection).toBe(true)
    expect(i.figure).toBe(s2)

    i = t.getFirstFigure(new Ray($L([0,0,0], [1,0,1])))
    expect(i).not.toBeNull()
    expect(i instanceof Intersection).toBe(true)
    expect(i.figure).toBe(s3)

    i = t.getFirstFigure(new Ray($L([0,0,0], [1,1,0])))
    expect(i).toBeNull()

  it "should get an instersection for strange sloped line", ->
    t = new Octree()
    s1 = new Sphere($V([1,1,1]), 0.5, null)
    t.add(s1)
    s2 = new Sphere($V([1,1,2]), 0.5, null)
    t.add(s2)
    s3 = new Sphere($V([1,0,1]), 0.5, null)
    t.add(s3)

    i = t.getFirstFigure(new Ray($L([0.05,0.14,0], [1,1,1.1])))
    expect(i).not.toBeNull()
    expect(i instanceof Intersection).toBe(true)
    expect(i.figure).toBe(s1)

    i = t.getFirstFigure(new Ray($L([0.03,0.1,0.16], [0.9,1.1,2.1])))
    expect(i).not.toBeNull()
    expect(i instanceof Intersection).toBe(true)
    expect(i.figure).toBe(s2)

    i = t.getFirstFigure(new Ray($L([0.07,0.124,0.02], [1.1,0.1,1])))
    expect(i).not.toBeNull()
    expect(i instanceof Intersection).toBe(true)
    expect(i.figure).toBe(s3)

    i = t.getFirstFigure(new Ray($L([0.02,0,0.1], [1,1.1,0])))
    expect(i).toBeNull()

  it "should not get a figure", ->
    t = new Octree()
    t.add(new Sphere($V([1,1,1]), 0.5, null))
    r = new Ray($L([1,1,0], [0,0,1]))
    t.getFirstFigure(r)

