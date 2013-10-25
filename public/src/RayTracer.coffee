class RayTracer
  constructor: (@pixelX, @pixelY, @scene) ->

  trace: () ->
    # 1. shoot a ray determined from the camera parameters and the pixel position in the image
    # 2. intersect the ray to scene elements and determine the closest one
    # 3. check if the intersection point is illuminated by each light source
    # 4. shade the intersection point using the meterial attributes and the lightings
    # 5. set the pixel color into the image buffer using the computed shading (for now set dummy color into the image buffer)
    rays = this.castRays(RayConfig.antialiasing)

    console.setRlog()

    traceRay = (ray) =>
      this.traceRec(ray, RayConfig.recDepth)

    colors = rays.map (ray) ->
      traceRay(ray)

    averageColorVector = colors.map((c) ->
      c.toVector()).reduce((previous, current) ->
      previous.add(current)).multiply(1 / colors.length)
    averageColorVector

  traceRec: (ray, times) ->
    color = new Color(0, 0, 0)

    intersection = @scene.firstIntersection(ray)

    return color unless intersection

    globalAmbient = @scene.globalAmbient
    globalAmbientColor = intersection.figure.reflectionProperties.ambientColor.multiply(globalAmbient)
    color = color.add(globalAmbientColor)

    if RayConfig.illumination
      for light in @scene.lights
        color = color.add(this.illuminate(intersection, ray, light))

    return color if times <= 0

    color = color.add(this.reflectAndRefract(intersection, ray, times)) if RayConfig.reflection
    color

  reflectAndRefract: (intersection, ray, times) ->
    f = intersection.figure
    [reflectedRay, refractedRay] = this.specularRays(intersection, ray)
    color = new Color(0, 0, 0)
    if reflectedRay?
      specularReflection = this.traceRec(reflectedRay, times - 1)
      specularReflection = specularReflection.multiplyColor(f.reflectionProperties.specularColor)
      color = color.add specularReflection.multiply(reflectedRay.power)
    if refractedRay?
      specularRefraction = this.traceRec(refractedRay, times - 1)
      specularRefraction = specularRefraction.multiplyColor(f.reflectionProperties.specularColor) unless ray.isInside() && RayConfig.strongRefraction
      color = color.add specularRefraction.multiply(refractedRay.power)
    color

  specularRays: (intersection, ray) ->
    # the norm n (unit vector)
    n = intersection.getNormal()
    # the point of intersection p
    p = intersection.getPoint()
    #n = obj.norm(pos) #.multiply(-1).toUnitVector()
    n = n.multiply(-1) if ray.isInside()
    # the view direction / input ray i (vector)
    i = p.subtract(ray.line.anchor).toUnitVector()

    n1 = ray.refraction
    n2 = if ray.isInside() then 1 else intersection.figure.reflectionProperties.refractionIndex

    # the angle theta θ = i*n
    i_dot_n = i.dot(n)
    cos_theta_i = -i_dot_n

    # === reflection ===

    # reflection ray r (unit vector)
    reflectionDirection = i.add(n.multiply(2 * cos_theta_i)).toUnitVector()

    # === refraction ===

    # Total reflection!
    if n2 == Infinity
      return [new Ray($L(p, reflectionDirection), n1, ray.power), null]

    ratio = n1 / n2
    sin_theta_t_2 = Math.square(ratio) * (1 - Math.square(cos_theta_i))

    if sin_theta_t_2 > 1
      # Total reflection!
      return [new Ray($L(p, reflectionDirection), n1, ray.power), null]

    cos_theta_t = Math.sqrt(1 - sin_theta_t_2)
    refractionDirection = i.multiply(ratio).add(n.multiply((ratio * cos_theta_i) - cos_theta_t)).toUnitVector()

    # Ok, both reflection and refraction exist => how is the ratio of the power? => frensel approximation
    # Note: we could also use the schlick's approximation which would be a little bit faster but less exact
    r1 = Math.square((n1 * cos_theta_i - n2 * cos_theta_t) / (n1 * cos_theta_i + n2 * cos_theta_t))
    r2 = Math.square((n2 * cos_theta_i - n1 * cos_theta_t) / (n2 * cos_theta_i + n1 * cos_theta_t))
    reflectionPowerRatio = (r1 + r2) / 2
    refractionPowerRatio = 1 - reflectionPowerRatio

    unless 0 <= reflectionPowerRatio <= 1 && 0 <= refractionPowerRatio <= 1
      # Total reflection!
      return [new Ray($L(p, reflectionDirection), n1, ray.power), null]

    unless 0 <= reflectionPowerRatio <= 1 && 0 <= refractionPowerRatio <= 1
      throw "Invalid state: reflectionPowerRatio: #{reflectionPowerRatio}, refractionPowerRatio: #{refractionPowerRatio}"

    return [new Ray($L(p, reflectionDirection), n1, ray.power * reflectionPowerRatio),
            new Ray($L(p, refractionDirection), n2, ray.power * refractionPowerRatio)]


  illuminate: (intersection, ray, light) ->
    f = intersection.figure
    p = intersection.getPoint()

    nv = intersection.getNormal()

    w = ray.line.direction
    wl = light.location.subtract(p).toUnitVector()
    wr = nv.multiply(2).multiply(w.dot(nv)).subtract(w).toUnitVector()

    # Shadow
    return new Color(0, 0, 0) if @scene.firstIntersection(new Ray($L(p, wl), ray.refraction, 1))

    ambient = light.intensity.ambient
    ambientColor = f.reflectionProperties.ambientColor.multiply(ambient)

    kd = f.reflectionProperties.diffuseColor
    E = light.intensity.diffuse * nv.dot(wl)
    diffuse = kd.multiply(E * light.intensity.diffuse)

    n = f.reflectionProperties.specularExponent
    ks = f.reflectionProperties.specularColor
    frac = Math.pow(wr.dot(wl), n) / nv.dot(wl)
    spepcularIntensity = frac * E
    spepcularIntensity = 0 if frac < 0
    specularHighlights = ks.multiply(spepcularIntensity)

    ambientColor.add(diffuse).add(specularHighlights)


  castRays: (antialiasing) ->
    camera = @scene.camera

    # so rays go through the middle of a pixel
    antialiasing_translation_mean = (1 + (1 / antialiasing)) / 2

    arr = []

    if antialiasing == 1
      pixelX = ((@pixelX + 0.5) - (camera.width / 2))
      pixelY = ((@pixelY + 0.5) - (camera.height / 2)) * -1
      arr.push this.calcRayForPixel(camera, pixelX, pixelY)
    else if RayConfig.antialiasingTechnique == 'grid'
      x = [1..antialiasing]
      for i in x
        for j in x
          # translate pixels, so that 0/0 is in the center of the image
          pixelX = ((@pixelX + i/antialiasing - antialiasing_translation_mean + 0.5) - (camera.width / 2))
          pixelY = ((@pixelY + j/antialiasing - antialiasing_translation_mean + 0.5) - (camera.height / 2)) * -1
          arr.push this.calcRayForPixel(camera, pixelX, pixelY)
    else if RayConfig.antialiasingTechnique == 'random'
      x = [1..(antialiasing*antialiasing)]
      z = antialiasing_translation_mean / 2
      for i in x
        # translate pixels, so that 0/0 is in the center of the image
        pixelX = ((@pixelX + Math.random(z) - antialiasing_translation_mean + 0.5) - (camera.width / 2))
        pixelY = ((@pixelY + Math.random(z) - antialiasing_translation_mean + 0.5) - (camera.height / 2)) * -1
        arr.push this.calcRayForPixel(camera, pixelX, pixelY)
    else if RayConfig.antialiasingTechnique == 'jittered'
      x = [1..antialiasing]
      antialiasing_translation_mean = antialiasing_translation_mean + (1 / antialiasing / 2)
      z = 1/antialiasing
      for i in x
        for j in x
          # translate pixels, so that 0/0 is in the center of the image
          pixelX = ((@pixelX + i/antialiasing + Math.random(z) - antialiasing_translation_mean + 0.5) - (camera.width / 2))
          pixelY = ((@pixelY + j/antialiasing + Math.random(z) - antialiasing_translation_mean + 0.5) - (camera.height / 2)) * -1
          arr.push this.calcRayForPixel(camera, pixelX, pixelY)


    arr

  calcRayForPixel: (camera, pixelX, pixelY) ->
    # calculate point in imagePane in 3D
    p = camera.imageCenter.add(camera.upDirection.multiply(pixelY / camera.height * camera.imagePaneHeight))
    p = p.add(camera.rightDirection.multiply(pixelX / camera.width * camera.imagePaneWidth))

    # vector from camera position to point in image pane
    direction = p.subtract(camera.position)

    # Assume that the camera is not inside an object (otherwise, the refraction index would not be 1)
    new Ray($L(camera.position, direction), 1, 1)


this.RayTracer = RayTracer
