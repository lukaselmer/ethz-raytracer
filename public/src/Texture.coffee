class Texture
  constructor: (tgaPath, @specularExponent, @refractionIndex) ->
    @tga = readTGA(tgaPath)

  getPixelColor: (u, v) ->
    # exact pixel values
    u = u * @tga.header.width
    v = v * @tga.header.height

    # integer pixel values surrounding the exact value
    u1 = Math.floor(u)
    v1 = Math.floor(v)
    u2 = Math.min((u1 + 1), @tga.header.width - 1)
    v2 = Math.min((v1 + 1), @tga.header.height - 1)

    # fractional parts of u and v
    frac_u = u - Math.floor(u)
    frac_v = v - Math.floor(v)

    # weight factors of the surrounding pixels
    w1 = (1 - frac_u) * (1 - frac_v)
    w2 = frac_u * (1 - frac_v)
    w3 = (1 - frac_u) * frac_v
    w4 = frac_u * frac_v

    # weighted pixel colors of the surrounding pixels
    c1 = this.getPixelColorSingle(u1, v1).multiply(w1)
    c2 = this.getPixelColorSingle(u2, v1).multiply(w2)
    c3 = this.getPixelColorSingle(u1, v2).multiply(w3)
    c4 = this.getPixelColorSingle(u2, v2).multiply(w4)

    # add them together
    c1.add(c2).add(c3).add c4

  @earth: (prefix) ->
    d = "data/Earth.tga"
    s = if prefix then prefix + d else d
    new Texture(s, 32.0, Infinity)

  @moon: (prefix) ->
    d = "data/Moon.tga"
    s = if prefix then prefix + d else d
    new Texture(s, 16.0, Infinity)

  getPixelColorSingle: (u, v) ->
    id = 3 * (v * @tga.header.width + u)
    r = @tga.image[id + 2] / 255.0
    g = @tga.image[id + 1] / 255.0
    b = @tga.image[id + 0] / 255.0
    new Color(r, g, b)

  noFilter: (u, v) ->
    fu = Math.floor(u * @tga.header.width)
    fv = Math.floor(v * @tga.header.height)
    this.getPixelColorSingle fu, fv
