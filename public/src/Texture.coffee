class Texture
  constructor: (tgaPath, @specularExponent, @refractionIndex) ->
    @tga = readTGA(tgaPath)

  getPixelColor: (u, v) ->
    u = Math.floor(u * @tga.header.width)
    v = Math.floor(v * @tga.header.height)
    id = 3 * (v * @tga.header.width + u)
    r = @tga.image[id + 2] / 255.0
    g = @tga.image[id + 1] / 255.0
    b = @tga.image[id + 0] / 255.0
    new Color(r, g, b)

  @earth: (prefix) ->
    d = "data/Earth.tga"
    s = if prefix then prefix + d else d
    new Texture(s, 32.0, Infinity)

  @moon: (prefix) ->
    d = "data/Earth.tga"
    s = if prefix then prefix + d else d
    new Texture(s, 16.0, Infinity)