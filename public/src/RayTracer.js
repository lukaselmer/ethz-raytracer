// Generated by CoffeeScript 1.6.3
var RayTracer;

RayTracer = (function() {
  function RayTracer(color, pixelX, pixelY, scene) {
    this.color = color;
    this.pixelX = pixelX;
    this.pixelY = pixelY;
    this.scene = scene;
  }

  RayTracer.prototype.trace = function() {
    var averageColorVector, colors, rays, traceRay,
      _this = this;
    rays = this.castRays(RayConfig.antialiasing);
    console.setRlog();
    traceRay = function(ray) {
      return _this.traceRec(ray, new Color(0, 0, 0), RayConfig.recDepth);
    };
    colors = rays.map(function(ray) {
      return traceRay(ray);
    });
    averageColorVector = colors.map(function(c) {
      return c.toVector();
    }).reduce(function(previous, current) {
      return previous.add(current);
    }).multiply(1 / colors.length);
    return this.color.setElements(averageColorVector.elements);
  };

  RayTracer.prototype.traceRec = function(ray, color, times) {
    var globalAmbient, globalAmbientColor, intersection, light, obj, pos, _i, _len, _ref;
    intersection = this.scene.firstIntersection(ray);
    if (intersection) {
      pos = intersection[0];
      obj = intersection[1];
      globalAmbient = this.scene.globalAmbient;
      globalAmbientColor = obj.reflectionProperties.ambientColor.multiply(globalAmbient);
      color = color.add(globalAmbientColor);
      if (RayConfig.illumination) {
        _ref = this.scene.lights;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          light = _ref[_i];
          color = color.add(this.illuminate(pos, obj, ray, light));
        }
      }
      if (times <= 0) {
        return color;
      }
      if (RayConfig.reflection) {
        color = color.add(this.reflectAndRefract(pos, obj, ray, times));
      }
    }
    return color;
  };

  RayTracer.prototype.reflectAndRefract = function(pos, obj, ray, times) {
    var color, reflectedRay, refractedRay, specularReflection, specularRefraction, _ref;
    _ref = this.specularRays(pos, obj, ray), reflectedRay = _ref[0], refractedRay = _ref[1];
    color = new Color(0, 0, 0);
    if (reflectedRay != null) {
      specularReflection = this.traceRec(reflectedRay, new Color(0, 0, 0), times - 1);
      specularReflection = specularReflection.multiplyColor(obj.reflectionProperties.specularColor);
      color = color.add(specularReflection.multiply(reflectedRay.power));
    }
    if (refractedRay != null) {
      specularRefraction = this.traceRec(refractedRay, new Color(0, 0, 0), times - 1);
      if (ray.refraction !== 1) {
        specularRefraction = specularRefraction.multiplyColor(obj.reflectionProperties.specularColor);
      }
      color = color.add(specularRefraction.multiply(refractedRay.power));
    }
    return color;
  };

  RayTracer.prototype.specularRays = function(pos, obj, ray) {
    var cos_theta_i, cos_theta_t, i, i_dot_n, n, n1, n2, r1, r2, ratio, reflectionDirection, reflectionPowerRatio, refractionDirection, refractionPowerRatio, sin_theta_t_2, theta_i;
    n = obj.norm(pos);
    i = ray.line.anchor.subtract(pos);
    n1 = ray.refraction;
    n2 = obj.reflectionProperties.refractionIndex;
    i_dot_n = i.dot(n);
    cos_theta_i = -i_dot_n;
    theta_i = Math.abs(i_dot_n);
    reflectionDirection = i.subtract(n.multiply(2 * (i.dot(n))));
    if (n2 === Infinity) {
      return [new Ray($L(pos, reflectionDirection), n1, ray.power), null];
    }
    ratio = n1 / n2;
    sin_theta_t_2 = Math.square(ratio) * (1 - Math.square(cos_theta_i));
    if (sin_theta_t_2 > 1) {
      return [new Ray($L(pos, reflectionDirection), n1, ray.power), null];
    }
    cos_theta_t = Math.sqrt(1 - sin_theta_t_2);
    refractionDirection = pos.multiply(ratio).add(n.multiply((ratio * cos_theta_i) - cos_theta_t));
    r1 = Math.square((n1 * cos_theta_i - n2 * cos_theta_t) / (n1 * cos_theta_i + n2 * cos_theta_t));
    r2 = Math.square((n2 * cos_theta_i - n1 * cos_theta_t) / (n2 * cos_theta_i + n1 * cos_theta_t));
    reflectionPowerRatio = (r1 + r2) / 2;
    refractionPowerRatio = 1 - reflectionPowerRatio;
    if (!((0 <= reflectionPowerRatio && reflectionPowerRatio <= 1) && (0 <= refractionPowerRatio && refractionPowerRatio <= 1))) {
      return [new Ray($L(pos, reflectionDirection), n1, ray.power), null];
    }
    if (!((0 <= reflectionPowerRatio && reflectionPowerRatio <= 1) && (0 <= refractionPowerRatio && refractionPowerRatio <= 1))) {
      throw "Invalid state: reflectionPowerRatio: " + reflectionPowerRatio + ", refractionPowerRatio: " + refractionPowerRatio;
    }
    return [new Ray($L(pos, reflectionDirection), n1, ray.power * reflectionPowerRatio), new Ray($L(pos, refractionDirection), n2, ray.power * refractionPowerRatio)];
  };

  /*
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
  */


  RayTracer.prototype.illuminate = function(pos, obj, ray, light) {
    var E, ambient, ambientColor, diffuse, frac, kd, ks, n, nv, specularHighlights, spepcularIntensity, w, wl, wr;
    nv = obj.norm(pos);
    w = ray.line.direction;
    wl = light.location.subtract(pos).toUnitVector();
    wr = nv.multiply(2).multiply(w.dot(nv)).subtract(w).toUnitVector();
    if (this.scene.intersections(new Ray($L(pos, wl), ray.refraction, 1)).length > 0) {
      return new Color(0, 0, 0);
    }
    ambient = light.intensity.ambient;
    ambientColor = obj.reflectionProperties.ambientColor.multiply(ambient);
    kd = obj.reflectionProperties.diffuseColor;
    E = light.intensity.diffuse * nv.dot(wl);
    diffuse = kd.multiply(E * light.intensity.diffuse);
    n = obj.reflectionProperties.specularExponent;
    ks = obj.reflectionProperties.specularColor;
    frac = Math.pow(wr.dot(wl), n) / nv.dot(wl);
    spepcularIntensity = frac * E;
    if (frac < 0) {
      spepcularIntensity = 0;
    }
    specularHighlights = ks.multiply(spepcularIntensity);
    return ambientColor.add(diffuse).add(specularHighlights);
  };

  RayTracer.prototype.castRays = function(antialiasing) {
    var camera, h, w, _i, _results,
      _this = this;
    camera = this.scene.camera;
    w = camera.width * antialiasing;
    h = camera.height * antialiasing;
    return (function() {
      _results = [];
      for (var _i = 1; 1 <= antialiasing ? _i <= antialiasing : _i >= antialiasing; 1 <= antialiasing ? _i++ : _i--){ _results.push(_i); }
      return _results;
    }).apply(this).map(function(i) {
      var _i, _results;
      return (function() {
        _results = [];
        for (var _i = 1; 1 <= antialiasing ? _i <= antialiasing : _i >= antialiasing; 1 <= antialiasing ? _i++ : _i--){ _results.push(_i); }
        return _results;
      }).apply(this).map(function(j) {
        var centerPixelX, centerPixelY, rayDirection;
        centerPixelX = (_this.pixelX * antialiasing + (i - 1) + 0.5 - w / 2) / h * camera.imagePaneHeight;
        centerPixelY = (-_this.pixelY * antialiasing - (j - 1) - 0.5 + h / 2) / w * camera.imagePaneWidth;
        rayDirection = camera.imageCenter.add(camera.upDirection.multiply(centerPixelX)).add(camera.rightDirection.multiply(centerPixelY)).subtract(camera.position);
        return new Ray($L(camera.position, rayDirection), 1, 1);
      });
    }).reduce(function(a, b) {
      return a.concat(b);
    });
  };

  return RayTracer;

})();
