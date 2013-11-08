class Light
  constructor: (@location, @color, @intensity, @radius, @direction) ->
    if @radius
      @upDirection = @direction.cross($V([1, 0, 0]))
      @rightDirection = @direction.cross(@upDirection)

  calculateShadowRatio: (p, wl, ray, scene) ->
    if @radius && ModuleId.D2
      # Area light
      return this.calculateAreaLight(p, wl, ray, scene)
    else
      return if scene.firstIntersection(new Ray($L(p, wl), ray.refraction, 1, ray.eye)) then 1 else 0


  calculateAreaLight: (p, wl, ray, scene) ->
    # Use jitter for monte carlo integration
    cellSize = @radius * 2 / RayConfig.areaLightShadowsAxis

    shadowIntensity = 0
    i = 0
    while i < RayConfig.areaLightShadows
      r = -RayConfig.areaLightShadowsAxis / 2
      while r < RayConfig.areaLightShadowsAxis / 2
        s = -RayConfig.areaLightShadowsAxis / 2
        while s < RayConfig.areaLightShadowsAxis / 2
          newP = null
          z = 0
          loop
            z++
            x = r * cellSize + cellSize * Math.random()
            y = s * cellSize + cellSize * Math.random()
            newP = @location.add(@rightDirection.multiply(x)).add(@upDirection.multiply(y))
            break if newP.distanceFrom(@location) <= @radius
            if z > 20
              newP = null
              break
          if newP
            wl = newP.subtract(p).toUnitVector();
            light_intersection = scene.firstIntersection(new Ray($L(p, wl), ray.refraction, 1, ray.eye))
            shadowIntensity += 1 / RayConfig.areaLightShadows if light_intersection
          i++
          s++
        r++
    shadowIntensity
