class RayTracer
  constructor: (@color, @pixelX, @pixelY, @scene) ->

  trace: () ->
    # 1. shoot a ray determined from the camera parameters and the pixel position in the image
    # 2. intersect the ray to scene elements and determine the closest one
    # 3. check if the intersection point is illuminated by each light source
    # 4. shade the intersection point using the meterial attributes and the lightings
    # 5. set the pixel color into the image buffer using the computed shading (for now set dummy color into the image buffer)
    rays = this.castRays(RayConfig.antialiasing)

    console.setRlog()

    traceRay = (ray) =>
      this.traceRec(ray, new Color(0, 0, 0), RayConfig.recDepth)

    colors = rays.map (ray) ->
      traceRay(ray)

    averageColorVector = colors.map((c) ->
      c.toVector()).reduce((previous, current) ->
      previous.add(current)).multiply(1 / colors.length)
    @color.setElements(averageColorVector.elements)

  traceRec: (ray, color, times) ->
    intersection = @scene.firstIntersection(ray)

    if intersection
      pos = intersection[0]
      obj = intersection[1]

      globalAmbient = @scene.globalAmbient
      globalAmbientColor = obj.reflectionProperties.ambientColor.multiply(globalAmbient)
      color = color.add(globalAmbientColor)

      if RayConfig.illumination
        for light in @scene.lights
          color = color.add(this.illuminate(pos, obj, ray, light))

      return color if times <= 0

      color = color.add(this.reflectAndRefract(pos, obj, ray, times)) if RayConfig.reflection
    color

  reflectAndRefract: (pos, obj, ray, times) ->
    [reflectedRay, refractedRay] = this.specularRays(pos, obj, ray)
    color = new Color(0, 0, 0)
    if reflectedRay?
      specularReflection = this.traceRec(reflectedRay, new Color(0, 0, 0), times - 1)
      specularReflection = specularReflection.multiplyColor(obj.reflectionProperties.specularColor)
      color = color.add specularReflection.multiply(reflectedRay.power)
    if refractedRay?
      specularRefraction = this.traceRec(refractedRay, new Color(0, 0, 0), times - 1)
      if ray.refraction != 1
        specularRefraction = specularRefraction.multiplyColor(obj.reflectionProperties.specularColor)
      color = color.add specularRefraction.multiply(refractedRay.power) #* 0.5
    color

  #nv = obj.norm(pos)
  #w = ray.line.direction
  #wr = nv.multiply(2 * w.dot(nv)).subtract(w).toUnitVector().multiply(-1)
  #ks = obj.reflectionProperties.specularColor

  #specularReflection = this.traceRec(new Ray($L(pos, wr), ray.rafraction, 1), new Color(0, 0, 0), times - 1)
  #specularReflection = specularReflection.multiplyColor(ks)
  #specularReflection

  specularRays: (pos, obj, ray) ->
    inside = ray.refraction isnt 1

    # normal of intersection-point
    nv = obj.norm(pos)
    nv = nv.multiply(-1) if inside

    # view-direction
    w = ray.line.anchor.subtract(pos).toUnitVector()

    # angle between view-direction and normal
    w_dot_nv = w.dot(nv)

    # ray-reflection-direction: wr = 2n(w*n) - w
    wr = nv.multiply(2 * w_dot_nv).subtract(w).toUnitVector()

    # refraction
    refractedRay = null
    n1 = ray.refraction
    n2 = (if inside then 1 else obj.reflectionProperties.refractionIndex)
    ref = n1 / n2
    reflectPower = 0
    refractPower = 0
    unless n2 is Infinity
      first = w.subtract(nv.multiply(w_dot_nv)).multiply(-ref)
      underRoot = 1 - (ref * ref) * (1 - (w_dot_nv * w_dot_nv))

      if underRoot < 0 && !inside
        throw "underRoot < 0 && !inside"

      if underRoot >= 0
        # ray-refraction-direction
        wt = first.subtract(nv.multiply(Math.sqrt(underRoot))).toUnitVector()

        # fresnel equation
        cos1 = wr.dot(nv) # Math.cos(w_dot_n);
        cos2 = wt.dot(nv.multiply(-1)) # Math.cos(wr_dot_n);
        p_reflect = (n2 * cos1 - n1 * cos2) / (n2 * cos1 + n1 * cos2)
        p_refract = (n1 * cos1 - n2 * cos2) / (n1 * cos1 + n2 * cos2)
        reflectPower = ((p_reflect * p_reflect) + (p_refract * p_refract)) * ray.power #* 0.5
        refractPower = (1 - reflectPower) * ray.power #* 0.5

        refractedRay = new Ray($L(pos, wt), n2, refractPower)
      else
        reflectPower = ray.power

    reflectedRay = new Ray($L(pos, wr), ray.refraction, reflectPower)
    [reflectedRay, refractedRay]


  illuminate: (pos, obj, ray, light) ->
    nv = obj.norm(pos)

    w = ray.line.direction
    wl = light.location.subtract(pos).toUnitVector()
    wr = nv.multiply(2).multiply(w.dot(nv)).subtract(w).toUnitVector()

    return new Color(0, 0, 0) if @scene.intersections(new Ray($L(pos, wl), ray.refraction, 1)).length > 0

    ambient = light.intensity.ambient
    ambientColor = obj.reflectionProperties.ambientColor.multiply(ambient)

    kd = obj.reflectionProperties.diffuseColor
    E = light.intensity.diffuse * nv.dot(wl)
    diffuse = kd.multiply(E * light.intensity.diffuse)

    n = obj.reflectionProperties.specularExponent
    ks = obj.reflectionProperties.specularColor
    frac = Math.pow(wr.dot(wl), n) / nv.dot(wl)
    spepcularIntensity = frac * E
    spepcularIntensity = 0 if frac < 0
    specularHighlights = ks.multiply(spepcularIntensity)

    ambientColor.add(diffuse).add(specularHighlights)


  castRays: (antialiasing) ->
    camera = @scene.camera
    w = camera.width * antialiasing
    h = camera.height * antialiasing

    [1..antialiasing].map (i) =>
      [1..antialiasing].map (j) =>
        centerPixelX = (@pixelX * antialiasing + (i - 1) + 0.5 - w / 2) / h * camera.imagePaneHeight # + 0.5 for the center of the pixel
        centerPixelY = (-@pixelY * antialiasing - (j - 1) - 0.5 + h / 2) / w * camera.imagePaneWidth # - 0.5 for the center of the pixel

        rayDirection = camera.imageCenter.add(camera.upDirection.multiply(centerPixelX)).add(
          camera.rightDirection.multiply(centerPixelY)).subtract(camera.position)

        # Assume that the camera is not inside an object (otherwise, the refraction index would not be 1)
        new Ray($L(camera.position, rayDirection), 1, 1)
    .reduce((a, b) ->
        a.concat(b))
