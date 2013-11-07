class NormalMap
  constructor: (_normalmap) ->
    @tga = readTGA(_normalmap)

  getNormal: (u, v) ->
    # exact pixel values
    u = u * @tga.header.width
    v = v * @tga.header.height

    # integer pixel values surrounding the exact value
    u1 = Math.floor(u)
    v1 = Math.floor(v)
    u2 = (u1 + 1)
    v2 = (v1 + 1)

    # fractional parts of u and v
    frac_u = u - Math.floor(u)
    frac_v = v - Math.floor(v)

    # weight factors of the surrounding pixels
    w1 = (1 - frac_u) * (1 - frac_v)
    w2 = frac_u * (1 - frac_v)
    w3 = (1 - frac_u) * frac_v
    w4 = frac_u * frac_v

    # weighted pixel colors of the surrounding pixels
    n1 = this.getPixelNormal(u1, v1).multiply(w1)
    n2 = this.getPixelNormal(u2, v1).multiply(w2)
    n3 = this.getPixelNormal(u1, v2).multiply(w3)
    n4 = this.getPixelNormal(u2, v2).multiply(w4)

    #/ add them together
    n1.add(n2).add(n3).add n4

  @earth: () ->
    new NormalMap("data/EarthNormal.tga")

  @moon: () ->
    new NormalMap("data/MoonNormal.tga")

  getPixelNormal: (u, v) ->
    id = 3 * (v * @tga.header.width + u)
    r = @tga.image[id + 2] / 255.0
    g = @tga.image[id + 1] / 255.0
    b = @tga.image[id + 0] / 255.0
    $V([2 * r - 1, 2 * g - 1, 2 * b - 1]).toUnitVector()

  noFilter: (u, v) ->
    fu = Math.floor(u * @tga.header.width)
    fv = Math.floor(v * @tga.header.height)
    this.getPixelNormal fu, fv
