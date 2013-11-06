describe "Texture", ->
  it "should have a earth and moon", ->
    base = "http://localhost:63342/ethz-raytracer/public/" #https://raytracer-eth.renuo.ch/
    window.waitingForData = 0

    earth = Texture.earth(base)
    moon = Texture.moon(base)

    waitsFor (->
      window.waitingForData == 0
    ), "Unable to load tgas", 2000

    runs ->
      expect(earth.tga.header.width).toEqual 2048
      expect(moon.tga.header.width).toEqual 2048
      