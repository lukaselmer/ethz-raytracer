class RayTracer
  constructor: (@color, @pixelX, @pixelY, @scene) ->

  trace: () ->
    # 1. shoot a ray determined from the camera parameters and the pixel position in the image
    # 2. intersect the ray to scene elements and determine the closest one
    # 3. check if the intersection point is illuminated by each light source
    # 4. shade the intersection point using the meterial attributes and the lightings
    # 5. set the pixel color into the image buffer using the computed shading (for now set dummy color into the image buffer)
    ray = this.castRay()
    c = new Color(0, 0, 0)
    c = this.traceRec(ray, c, RayConfig.recDepth)
    @color.setElements(c.toArray())

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

      color = color.add(this.reflect(pos, obj, ray, times)) if RayConfig.reflection
    color

  reflect: (pos, obj, ray, times) ->
    nv = obj.norm(pos)
    w = ray.line.direction
    wr = nv.multiply(2 * w.dot(nv)).subtract(w).toUnitVector().multiply(-1)
    ks = obj.reflectionProperties.specularColor

    specularReflection = this.traceRec(new Ray($L(pos, wr), 1, 1), new Color(0, 0, 0), times - 1)
    specularReflection = specularReflection.multiplyColor(ks)
    specularReflection


  illuminate: (pos, obj, ray, light) ->
    nv = obj.norm(pos)

    w = ray.line.direction
    wl = light.location.subtract(pos).toUnitVector()
    wr = nv.multiply(2).multiply(w.dot(nv)).subtract(w).toUnitVector()

    return new Color(0, 0, 0) if @scene.intersections(new Ray($L(pos, wl), 1, 1)).length > 0

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


  castRay: () ->
    camera = @scene.camera

    centerPixelX = (@pixelX + 0.5 - camera.width / 2) / camera.height * camera.imagePaneHeight # + 0.5 for the center of the pixel
    centerPixelY = (-@pixelY - 0.5 + camera.height / 2) / camera.width * camera.imagePaneWidth # - 0.5 for the center of the pixel

    rayDirection = camera.imageCenter.add(camera.upDirection.multiply(centerPixelX)).add(
      camera.rightDirection.multiply(centerPixelY)).subtract(camera.position)

    new Ray($L(camera.position, rayDirection), 1, 1)
