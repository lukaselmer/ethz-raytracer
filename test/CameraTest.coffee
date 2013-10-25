describe "Camera", ->
  it "center should be 0,0,9", ->
    fieldOfView = 40 / 180 * Math.PI
    c = new Camera($V([0, 0, 10]), $V([0, 0, -1]), $V([0, 1, 0]), 1, fieldOfView, RayConfig.width, RayConfig.height)
    expect(c.center.elements).toEqual([0, 0, 9])
    c = new Camera($V([0, 0, 9]), $V([0, 0, -1]), $V([0, 1, 0]), 1, fieldOfView, RayConfig.width, RayConfig.height)
    expect(c.center.elements).toEqual([0, 0, 8])
    c = new Camera($V([0, 0, 9]), $V([0, 0, 1]), $V([0, 1, 0]), 1, fieldOfView, RayConfig.width, RayConfig.height)
    expect(c.center.elements).toEqual([0, 0, 10])

