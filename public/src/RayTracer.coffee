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
      specularRefraction = specularRefraction.multiplyColor(obj.reflectionProperties.specularColor) #unless ray.isInside()
      color = color.add specularRefraction.multiply(refractedRay.power)
    color

  #nv = obj.norm(pos)
  #w = ray.line.direction
  #wr = nv.multiply(2 * w.dot(nv)).subtract(w).toUnitVector().multiply(-1)
  #ks = obj.reflectionProperties.specularColor

  #specularReflection = this.traceRec(new Ray($L(pos, wr), ray.rafraction, 1), new Color(0, 0, 0), times - 1)
  #specularReflection = specularReflection.multiplyColor(ks)
  #specularReflection

  specularRays: (pos, obj, ray) ->
    # the norm n (unit vector)
    n = obj.norm(pos) #.multiply(-1).toUnitVector()
    n = n.multiply(-1) if ray.isInside()
    # the view direction / input ray i (vector)
    i = pos.subtract(ray.line.anchor).toUnitVector()

    n1 = ray.refraction
    n2 = if ray.isInside() then 1 else obj.reflectionProperties.refractionIndex

    # the angle theta θ = i*n
    i_dot_n = i.dot(n)
    cos_theta_i = -i_dot_n
    #cos_theta_i = -cos_theta_i if ray.isInside()

    # === reflection ===

    # reflection ray r (unit vector)
    reflectionDirection = i.add(n.multiply(2 * cos_theta_i)).toUnitVector()

    # === refraction ===

    # Total reflection!
    if n2 == Infinity
      return [new Ray($L(pos, reflectionDirection), n1, ray.power), null]

    ratio = n1 / n2
    sin_theta_t_2 = Math.square(ratio) * (1 - Math.square(cos_theta_i))

    if sin_theta_t_2 > 1
      # Total reflection!
      return [new Ray($L(pos, reflectionDirection), n1, ray.power), null]

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
      return [new Ray($L(pos, reflectionDirection), n1, ray.power), null]

    throw "Invalid state: reflectionPowerRatio: #{reflectionPowerRatio}, refractionPowerRatio: #{refractionPowerRatio}" unless 0 <= reflectionPowerRatio <= 1 && 0 <= refractionPowerRatio <= 1

    return [new Ray($L(pos, reflectionDirection), n1, ray.power * reflectionPowerRatio),
            new Ray($L(pos, refractionDirection), n2, ray.power * refractionPowerRatio)] # * 0.5 : why here * 0.5

  ###
    # normal of intersection-point
    #n = obj.norm(pos)
    n = n.multiply(-1) if ray.isInside()

    # view-direction
    w = ray.line.anchor.subtract(pos).toUnitVector()

    # angle between view-direction and normal
    w_dot_nv = w.dot(n)

    # ray-reflection-direction: wr = 2n(w*n) - w
    wr = n.multiply(2 * w_dot_nv).subtract(w).toUnitVector()

    # refraction
    refractedRay = null
    n1 = ray.refraction
    n2 = (if ray.isInside() then 1 else obj.reflectionProperties.refractionIndex)
    ref = n1 / n2
    reflectPower = 0
    refractPower = 0
    unless n2 is Infinity
      first = w.subtract(n.multiply(w_dot_nv)).multiply(-ref)
      underRoot = 1 - (ref * ref) * (1 - (w_dot_nv * w_dot_nv))

      if underRoot < 0 && !ray.isInside()
        throw "underRoot < 0 && !ray.isInside()"

      if underRoot >= 0
        # ray-refraction-direction
        wt = first.subtract(n.multiply(Math.sqrt(underRoot))).toUnitVector()

        # fresnel equation
        cos1 = wr.dot(n) # Math.cos(w_dot_n);
        cos2 = wt.dot(n.multiply(-1)) # Math.cos(wr_dot_n);
        p_reflect = (n2 * cos1 - n1 * cos2) / (n2 * cos1 + n1 * cos2)
        p_refract = (n1 * cos1 - n2 * cos2) / (n1 * cos1 + n2 * cos2)
        reflectPower = ((p_reflect * p_reflect) + (p_refract * p_refract)) * ray.power #* 0.5
        refractPower = (1 - reflectPower) * ray.power #* 0.5

        refractedRay = new Ray($L(pos, wt), n2, refractPower)
      else
        reflectPower = ray.power

    reflectedRay = new Ray($L(pos, wr), ray.refraction, reflectPower)
    [reflectedRay, refractedRay]
  ###

  illuminate: (pos, obj, ray, light) ->
    nv = obj.norm(pos)

    w = ray.line.direction
    wl = light.location.subtract(pos).toUnitVector()
    wr = nv.multiply(2).multiply(w.dot(nv)).subtract(w).toUnitVector()

    # Shadow
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


    camera = @scene.camera
    w = camera.width * antialiasing
    h = camera.height * antialiasing

    # so rays go through the middle of a pixel
    antialiasing_translation_mean = (1 + antialiasing) / 2

    [1..antialiasing].map (i) =>
      [1..antialiasing].map (j) =>
        # translate pixels, so that 0/0 is in the center of the image
        pixelX = ((@pixelX + i/antialiasing - antialiasing_translation_mean + 0.5) - (camera.width / 2))
        pixelY = ((@pixelY + j/antialiasing - antialiasing_translation_mean + 0.5) - (camera.height / 2)) * -1

        # calculate point in imagePane in 3D
        p = camera.imageCenter.add(camera.upDirection.multiply(pixelY / camera.height * camera.imagePaneHeight))
        p = p.add(camera.rightDirection.multiply(pixelX / camera.width * camera.imagePaneWidth))

        # vector from camera position to point in image pane
        direction = p.subtract(camera.position).toUnitVector()

        # Assume that the camera is not inside an object (otherwise, the refraction index would not be 1)
        new Ray($L(camera.position, direction), 1, 1)
    .reduce((a, b) ->
        a.concat(b))




this.RayTracer = RayTracer
