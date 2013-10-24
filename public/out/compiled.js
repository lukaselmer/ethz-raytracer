(function() {
  var Camera, Color, Cylinder, Ellipsoid, Light, LightIntensity, Ray, RayTracer, ReflectionProperty, Scene, SceneLoader, Sphere, SphereSphereIntersection;

  Camera = (function() {
    function Camera(position, direction, upDirection, distance, fieldOfView, width, height) {
      this.position = position;
      this.direction = direction;
      this.upDirection = upDirection;
      this.distance = distance;
      this.fieldOfView = fieldOfView;
      this.width = width;
      this.height = height;
      this.calibrateCamera();
    }

    Camera.prototype.calibrateCamera = function() {
      this.direction = this.direction.toUnitVector();
      this.rightDirection = this.direction.cross(this.upDirection);
      this.imagePaneHeight = 2 * Math.tan(this.fieldOfView / 2) * this.distance;
      this.imagePaneWidth = this.imagePaneHeight / this.height * this.width;
      return this.imageCenter = this.position.add(this.direction.multiply(this.distance));
    };

    Camera.prototype.getCenter = function() {
      return this.imageCenter;
    };

    return Camera;

  })();

  Color = (function() {
    Color.random = function() {
      return new Color(Math.random(), Math.random(), Math.random());
    };

    function Color(r, g, b) {
      if (r instanceof Vector) {
        g = r.elements[1];
        b = r.elements[2];
        r = r.elements[0];
      }
      if (r < 0) {
        r = 0;
      }
      if (g < 0) {
        g = 0;
      }
      if (b < 0) {
        b = 0;
      }
      if (r > 1) {
        r = 1;
      }
      if (g > 1) {
        g = 1;
      }
      if (b > 1) {
        b = 1;
      }
      this.val = $V([r, g, b]);
    }

    Color.prototype.add = function(color) {
      return new Color(this.val.add(color.val));
    };

    Color.prototype.multiply = function(scale) {
      return new Color(this.val.multiply(scale));
    };

    Color.prototype.multiplyColor = function(color) {
      return new Color(this.val.elements[0] * color.val.elements[0], this.val.elements[1] * color.val.elements[1], this.val.elements[2] * color.val.elements[2]);
    };

    Color.prototype.toArray = function() {
      return this.val.dup().elements;
    };

    Color.prototype.toVector = function() {
      return this.val.dup();
    };

    return Color;

  })();

  Cylinder = (function() {
    function Cylinder(axis_line, fixed_x, fixed_y, fixed_z, radius_x, radius_y, radius_z, reflectionProperties) {
      this.axis_line = axis_line;
      this.fixed_x = fixed_x;
      this.fixed_y = fixed_y;
      this.fixed_z = fixed_z;
      this.radius_x = radius_x;
      this.radius_y = radius_y;
      this.radius_z = radius_z;
      this.reflectionProperties = reflectionProperties;
      this.radius_x_2 = Math.square(this.radius_x);
      this.radius_y_2 = Math.square(this.radius_y);
      this.radius_z_2 = Math.square(this.radius_z);
    }

    Cylinder.prototype.norm = function(intersectionPoint) {
      var intersection, n;
      intersection = $V([(this.fixed_x ? 0 : (intersectionPoint.e(1)) / this.radius_x_2), (this.fixed_y ? 0 : (intersectionPoint.e(2)) / this.radius_y_2), (this.fixed_z ? 0 : (intersectionPoint.e(3)) / this.radius_z_2)]);
      n = intersection.subtract(this.axis_line);
      return n.toUnitVector();
    };

    Cylinder.prototype.intersects = function(ray) {
      var a, b, c, dir, oc, root, t1, t2, under_root;
      oc = ray.line.anchor.subtract(this.axis_line);
      dir = ray.line.direction.toUnitVector();
      a = (this.fixed_x ? 0 : (dir.e(1) * dir.e(1)) / this.radius_x_2) + (this.fixed_y ? 0 : dir.e(2) * dir.e(2) / this.radius_y_2) + (this.fixed_z ? 0 : dir.e(3) * dir.e(3) / this.radius_z_2);
      b = (this.fixed_x ? 0 : (2 * oc.e(1) * dir.e(1)) / this.radius_x_2) + (this.fixed_y ? 0 : (2 * oc.e(2) * dir.e(2)) / this.radius_y_2) + (this.fixed_z ? 0 : (2 * oc.e(3) * dir.e(3)) / this.radius_z_2);
      c = (this.fixed_x ? 0 : (oc.e(1) * oc.e(1)) / this.radius_x_2) + (this.fixed_y ? 0 : (oc.e(2) * oc.e(2)) / this.radius_y_2) + (this.fixed_z ? 0 : (oc.e(3) * oc.e(3)) / this.radius_z_2) - 1;
      under_root = Math.square(b) - (4 * a * c);
      if (under_root < 0 || a === 0 || b === 0 || c === 0) {
        return null;
      }
      root = Math.sqrt(under_root);
      t1 = (-b + root) / (2 * a);
      t2 = (-b - root) / (2 * a);
      if (t1 < RayConfig.intersectionDelta) {
        return t2;
      }
      if (t2 < RayConfig.intersectionDelta) {
        return t1;
      }
      return Math.min(t1, t2);
    };

    Cylinder.prototype.intersection = function(ray) {
      var i, intersectionPoint, normal;
      i = this.intersects(ray);
      if (!i) {
        return false;
      }
      intersectionPoint = ray.line.anchor.add(ray.line.direction.multiply(i));
      normal = this.norm(intersectionPoint);
      return [i, intersectionPoint, normal];
    };

    return Cylinder;

  })();

  Ellipsoid = (function() {
    function Ellipsoid(center, radius_x, radius_y, radius_z, reflectionProperties) {
      this.center = center;
      this.radius_x = radius_x;
      this.radius_y = radius_y;
      this.radius_z = radius_z;
      this.reflectionProperties = reflectionProperties;
      this.radius_x_2 = Math.square(this.radius_x);
      this.radius_y_2 = Math.square(this.radius_y);
      this.radius_z_2 = Math.square(this.radius_z);
    }

    Ellipsoid.prototype.norm = function(intersectionPoint) {
      var n, t;
      n = intersectionPoint.subtract(this.center);
      t = $M([[2 / this.radius_x_2, 0, 0], [0, 2 / this.radius_y_2, 0], [0, 0, 2 / this.radius_z_2]]);
      n = t.multiply(n);
      return n.toUnitVector();
    };

    Ellipsoid.prototype.intersects = function(ray) {
      var a, b, c, dir, oc, root, t1, t2, under_root;
      oc = ray.line.anchor.subtract(this.center);
      dir = ray.line.direction.toUnitVector();
      a = ((dir.e(1) * dir.e(1)) / this.radius_x_2) + ((dir.e(2) * dir.e(2)) / this.radius_y_2) + ((dir.e(3) * dir.e(3)) / this.radius_z_2);
      b = ((2 * oc.e(1) * dir.e(1)) / this.radius_x_2) + ((2 * oc.e(2) * dir.e(2)) / this.radius_y_2) + ((2 * oc.e(3) * dir.e(3)) / this.radius_z_2);
      c = ((oc.e(1) * oc.e(1)) / this.radius_x_2) + ((oc.e(2) * oc.e(2)) / this.radius_y_2) + ((oc.e(3) * oc.e(3)) / this.radius_z_2) - 1;
      under_root = (b * b) - (4 * a * c);
      if (under_root < 0 || a === 0 || b === 0) {
        return null;
      }
      root = Math.sqrt(under_root);
      t1 = (-b + root) / (2 * a);
      t2 = (-b - root) / (2 * a);
      if (t1 < RayConfig.intersectionDelta) {
        return t2;
      }
      if (t2 < RayConfig.intersectionDelta) {
        return t1;
      }
      return Math.min(t1, t2);
    };

    Ellipsoid.prototype.intersection = function(ray) {
      var i, intersectionPoint, normal;
      i = this.intersects(ray);
      if (!i) {
        return false;
      }
      intersectionPoint = ray.line.anchor.add(ray.line.direction.multiply(i));
      normal = this.norm(intersectionPoint);
      return [i, intersectionPoint, normal];
    };

    return Ellipsoid;

  })();

  Light = (function() {
    function Light(location, color, intensity) {
      this.location = location;
      this.color = color;
      this.intensity = intensity;
    }

    return Light;

  })();

  LightIntensity = (function() {
    function LightIntensity(ambient, diffuse, specular) {
      this.ambient = ambient;
      this.diffuse = diffuse;
      this.specular = specular;
    }

    return LightIntensity;

  })();

  Ray = (function() {
    function Ray(line, refraction, power) {
      this.line = line;
      this.refraction = refraction;
      this.power = power;
    }

    Ray.prototype.isInside = function() {
      return this.refraction !== 1;
    };

    return Ray;

  })();

  this.ModuleId = {
    B1: undefined,
    B2: undefined,
    B3: undefined,
    B4: undefined,
    C1: undefined,
    C2: undefined,
    C3: undefined,
    D1: undefined,
    D2: undefined,
    ALT: undefined,
    SP1: undefined
  };

  if ((typeof document !== "undefined" && document !== null) && (typeof $ !== "undefined" && $ !== null)) {
    $(document).ready(function() {
      var checkbox, k, label, query, v, _results;
      if (document.location.toString().indexOf("?") !== -1) {
        query = document.location.toString().replace(/^.*?\?/, "").replace("#", "").split("&");
        query.forEach(function(q) {
          var k, tmp, v;
          tmp = q.split("=");
          k = tmp[0];
          v = tmp[1];
          if (v === undefined || v === "1" || v === "true") {
            v = true;
          } else {
            v = false;
          }
          return ModuleId[k] = v;
        });
      }
      _results = [];
      for (k in ModuleId) {
        v = ModuleId[k];
        checkbox = document.createElement("input");
        checkbox.type = "checkbox";
        checkbox.value = 1;
        checkbox.name = k;
        checkbox.id = k;
        if (v) {
          checkbox.setAttribute("checked", "checked");
        }
        label = document.createElement("label");
        label.setAttribute("class", "btn btn-primary" + (v ? " active" : ""));
        label.appendChild(checkbox);
        $(label).data("option", k);
        label.innerHTML += k;
        _results.push($("#renderOptions").append(label));
      }
      return _results;
    });
  }

  this.initRayConfig = function() {
    return this.RayConfig = {
      width: 800,
      height: 600,
      illumination: true,
      reflection: ModuleId.B1,
      refraction: ModuleId.B1,
      antialiasing: ModuleId.B2 ? 4 : 1,
      recDepth: 5,
      intersectionDelta: 0.000001
    };
  };

  initRayConfig();

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
      var globalAmbient, globalAmbientColor, intersection, light, normal, obj, pos, _i, _len, _ref;
      intersection = this.scene.firstIntersection(ray);
      if (!intersection) {
        return color;
      }
      pos = intersection[0], normal = intersection[1], obj = intersection[2];
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
        return color.add(this.reflectAndRefract(pos, obj, normal, ray, times));
      }
    };

    RayTracer.prototype.reflectAndRefract = function(pos, obj, normal, ray, times) {
      var color, reflectedRay, refractedRay, specularReflection, specularRefraction, _ref;
      _ref = this.specularRays(pos, obj, normal, ray), reflectedRay = _ref[0], refractedRay = _ref[1];
      color = new Color(0, 0, 0);
      if (reflectedRay != null) {
        specularReflection = this.traceRec(reflectedRay, new Color(0, 0, 0), times - 1);
        specularReflection = specularReflection.multiplyColor(obj.reflectionProperties.specularColor);
        color = color.add(specularReflection.multiply(reflectedRay.power));
      }
      if (refractedRay != null) {
        specularRefraction = this.traceRec(refractedRay, new Color(0, 0, 0), times - 1);
        specularRefraction = specularRefraction.multiplyColor(obj.reflectionProperties.specularColor);
        color = color.add(specularRefraction.multiply(refractedRay.power));
      }
      return color;
    };

    RayTracer.prototype.specularRays = function(pos, obj, norm, ray) {
      var cos_theta_i, cos_theta_t, i, i_dot_n, n, n1, n2, r1, r2, ratio, reflectionDirection, reflectionPowerRatio, refractionDirection, refractionPowerRatio, sin_theta_t_2;
      n = norm;
      if (ray.isInside()) {
        n = n.multiply(-1);
      }
      i = pos.subtract(ray.line.anchor).toUnitVector();
      n1 = ray.refraction;
      n2 = ray.isInside() ? 1 : obj.reflectionProperties.refractionIndex;
      i_dot_n = i.dot(n);
      cos_theta_i = -i_dot_n;
      reflectionDirection = i.add(n.multiply(2 * cos_theta_i)).toUnitVector();
      if (n2 === Infinity) {
        return [new Ray($L(pos, reflectionDirection), n1, ray.power), null];
      }
      ratio = n1 / n2;
      sin_theta_t_2 = Math.square(ratio) * (1 - Math.square(cos_theta_i));
      if (sin_theta_t_2 > 1) {
        return [new Ray($L(pos, reflectionDirection), n1, ray.power), null];
      }
      cos_theta_t = Math.sqrt(1 - sin_theta_t_2);
      refractionDirection = i.multiply(ratio).add(n.multiply((ratio * cos_theta_i) - cos_theta_t)).toUnitVector();
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
      if (this.scene.firstIntersection(new Ray($L(pos, wl), ray.refraction, 1))) {
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
      var antialiasing_translation_mean, camera, h, w, _i, _results,
        _this = this;
      camera = this.scene.camera;
      camera = this.scene.camera;
      w = camera.width * antialiasing;
      h = camera.height * antialiasing;
      antialiasing_translation_mean = (1 + antialiasing) / 2;
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
          var direction, p, pixelX, pixelY;
          pixelX = (_this.pixelX + i / antialiasing - antialiasing_translation_mean + 0.5) - (camera.width / 2);
          pixelY = ((_this.pixelY + j / antialiasing - antialiasing_translation_mean + 0.5) - (camera.height / 2)) * -1;
          p = camera.imageCenter.add(camera.upDirection.multiply(pixelY / camera.height * camera.imagePaneHeight));
          p = p.add(camera.rightDirection.multiply(pixelX / camera.width * camera.imagePaneWidth));
          direction = p.subtract(camera.position).toUnitVector();
          return new Ray($L(camera.position, direction), 1, 1);
        });
      }).reduce(function(a, b) {
        return a.concat(b);
      });
    };

    return RayTracer;

  })();

  this.RayTracer = RayTracer;

  ReflectionProperty = (function() {
    function ReflectionProperty(ambientColor, diffuseColor, specularColor, specularExponent, refractionIndex) {
      this.ambientColor = ambientColor;
      this.diffuseColor = diffuseColor;
      this.specularColor = specularColor;
      this.specularExponent = specularExponent;
      this.refractionIndex = refractionIndex;
    }

    return ReflectionProperty;

  })();

  Scene = (function() {
    function Scene(camera, globalAmbient) {
      this.camera = camera;
      this.globalAmbient = globalAmbient;
      this.objects = [];
      this.lights = [];
    }

    Scene.prototype.addLight = function(light) {
      return this.lights.push(light);
    };

    Scene.prototype.addObject = function(object) {
      return this.objects.push(object);
    };

    Scene.prototype.firstIntersection = function(ray) {
      var min, ret;
      min = Infinity;
      ret = null;
      this.objects.forEach(function(object) {
        var i, intersectionPoint, normal, _ref;
        _ref = object.intersection(ray), i = _ref[0], intersectionPoint = _ref[1], normal = _ref[2];
        if (i && i < min && i > RayConfig.intersectionDelta) {
          min = i;
          return ret = [intersectionPoint, normal, object];
        }
      });
      return ret;
    };

    return Scene;

  })();

  SceneLoader = (function() {
    function SceneLoader() {
      this.scene = this.loadDefaults();
    }

    SceneLoader.prototype.loadDefaults = function() {
      var camera, fieldOfView, scene;
      fieldOfView = 40 / 180 * Math.PI;
      camera = new Camera($V([0, 0, 10]), $V([0, 0, -1]), $V([0, 1, 0]), 1, fieldOfView, RayConfig.width, RayConfig.height);
      scene = new Scene(camera, 0.2);
      scene.addLight(new Light($V([10, 10, 10]), new Color(1, 1, 1), new LightIntensity(0, 1, 1)));
      return scene;
    };

    SceneLoader.prototype.loadScene = function() {
      var scene;
      scene = this.scene;
      if (ModuleId.ALT) {
        this.loadAlternative(scene);
      } else if (ModuleId.B3) {
        this.loadB3(scene);
      } else if (ModuleId.B4) {
        this.loadB4(scene);
      } else {
        this.loadOriginal(scene);
      }
      return scene;
    };

    /* new ReflectionProperty(ambientColor, diffuseColor, specularColor, specularExponent, refractionIndex*/


    SceneLoader.prototype.loadOriginal = function(scene) {
      scene.addObject(new Sphere($V([0, 0, 0]), 2, new ReflectionProperty(new Color(0.75, 0, 0), new Color(1, 0, 0), new Color(1, 1, 1), 32, Infinity)));
      return scene.addObject(new Sphere($V([1.25, 1.25, 3]), 0.5, new ReflectionProperty(new Color(0, 0, 0.75), new Color(0, 0, 1), new Color(0.5, 0.5, 1), 16, 1.5)));
    };

    SceneLoader.prototype.loadB3 = function(scene) {
      scene.addObject(new Cylinder($V([0, 0, 0]), false, true, false, 2, 0, 1, new ReflectionProperty(new Color(0.75, 0, 0), new Color(1, 0, 0), new Color(1, 1, 1), 32, Infinity)));
      scene.addObject(new Ellipsoid($V([1.25, 1.25, 3]), 0.25, 0.75, 0.5, new ReflectionProperty(new Color(0, 0, 0.75), new Color(0, 0, 1), new Color(0.5, 0.5, 1), 16.0, 1.5)));
      if (ModuleId.SP1) {
        scene.addObject(new Sphere($V([2.25, 1.25, 3]), 0.5, new ReflectionProperty(new Color(0, 0, 0.75), new Color(0, 0, 1), new Color(0.5, 0.5, 1), 16, 1.5)));
        scene.addObject(new Sphere($V([-1.25, -1.25, 3]), 0.5, new ReflectionProperty(new Color(0, 0, 0.75), new Color(0, 0, 1), new Color(0.5, 0.5, 1), 16, 1.5)));
        return scene.addObject(new Sphere($V([0, 0, 3]), 0.5, new ReflectionProperty(new Color(1, 0, 0.75), new Color(0, 0, 1), new Color(0.5, 0.5, 1), 16, 1.5)));
      }
    };

    SceneLoader.prototype.loadB4 = function(scene) {
      var sphere1, sphere2;
      sphere1 = new Sphere($V([1.25, 1.25, 3]), 0.5, null);
      sphere2 = new Sphere($V([0.25, 1.25, 3]), 1, null);
      scene.addObject(new SphereSphereIntersection(sphere1, sphere2, new ReflectionProperty(new Color(0, 0, 0.75), new Color(0, 0, 1), new Color(0.5, 0.5, 1), 16, Infinity)));
      sphere1 = new Sphere($V([0.5, 0, 3]), 0.6, null);
      sphere2 = new Sphere($V([-0.5, 0, 3]), 0.6, null);
      sphere1 = new Sphere($V([0, 0, 3]), 0.6, null);
      sphere2 = new Sphere($V([0, 0, 4]), 0.6, null);
      return scene.addObject(new SphereSphereIntersection(sphere1, sphere2, new ReflectionProperty(new Color(0, 0, 0.75), new Color(0, 0, 1), new Color(0.5, 0.5, 1), 16, Infinity)));
    };

    SceneLoader.prototype.loadAlternative = function(scene) {
      var c;
      c = Color.random();
      scene.addObject(new Sphere($V([0, 0, 0]), 2, new ReflectionProperty(c, c, new Color(1, 1, 1), 32, 1.5)));
      c = Color.random();
      scene.addObject(new Sphere($V([1.25, 1.25, 3]), 0.5, new ReflectionProperty(c, c, new Color(0.5, 0.5, 1), 16, 1.5)));
      c = Color.random();
      scene.addObject(new Sphere($V([1.25, -1.25, 3]), 0.5, new ReflectionProperty(c, c, new Color(0.5, 0.5, 1), 16, 1.5)));
      c = Color.random();
      scene.addObject(new Sphere($V([0, -.75, 3]), 0.5, new ReflectionProperty(c, c, new Color(0.5, 0.5, 1), 16, 1.5)));
      return scene.addObject(new Sphere($V([2.5, 0, -1]), 0.5, new ReflectionProperty(new Color(0, 0, 0.75), new Color(0, 0, 1), new Color(0.5, 0.5, 1), 16, 1.5)));
    };

    return SceneLoader;

  })();

  this.SceneLoader = SceneLoader;

  this.trace = function(scene, color, pixelX, pixelY) {
    var rayTracer;
    rayTracer = new RayTracer(color, pixelX, pixelY, scene);
    return rayTracer.trace();
  };

  Sphere = (function() {
    function Sphere(center, radius, reflectionProperties) {
      this.center = center;
      this.radius = radius;
      this.reflectionProperties = reflectionProperties;
      this.radiusSquared = this.radius * this.radius;
    }

    Sphere.prototype.norm = function(intersectionPoint) {
      return intersectionPoint.subtract(this.center).toUnitVector();
    };

    Sphere.prototype.intersects = function(ray) {
      var c, c_minus_o, d, distSquared, o, rayDistanceClosestToCenter, shortestDistanceFromCenterToRaySquared, t1, t2, x;
      o = ray.line.anchor;
      d = ray.line.direction;
      c = this.center;
      c_minus_o = c.subtract(o);
      distSquared = c_minus_o.dot(c_minus_o);
      rayDistanceClosestToCenter = c_minus_o.dot(d);
      if (rayDistanceClosestToCenter < 0) {
        return false;
      }
      shortestDistanceFromCenterToRaySquared = distSquared - (rayDistanceClosestToCenter * rayDistanceClosestToCenter);
      if (shortestDistanceFromCenterToRaySquared > this.radiusSquared) {
        return false;
      }
      x = this.radiusSquared - shortestDistanceFromCenterToRaySquared;
      if (x < 0) {
        return false;
      }
      t1 = rayDistanceClosestToCenter - Math.sqrt(x);
      t2 = rayDistanceClosestToCenter + Math.sqrt(x);
      if (t1 < RayConfig.intersectionDelta) {
        return t2;
      }
      if (t2 < RayConfig.intersectionDelta) {
        return t1;
      }
      return Math.min(t1, t2);
    };

    Sphere.prototype.intersection = function(ray) {
      var i, intersectionPoint, normal;
      i = this.intersects(ray);
      if (!i) {
        return false;
      }
      intersectionPoint = ray.line.anchor.add(ray.line.direction.multiply(i));
      normal = this.norm(intersectionPoint);
      return [i, intersectionPoint, normal];
    };

    return Sphere;

  })();

  SphereSphereIntersection = (function() {
    function SphereSphereIntersection(sphere1, sphere2, reflectionProperties) {
      this.sphere1 = sphere1;
      this.sphere2 = sphere2;
      this.reflectionProperties = reflectionProperties;
    }

    SphereSphereIntersection.prototype.norm = function(intersectionPoint) {
      var s1, s2;
      s1 = this.sphere1.intersects(this.ray);
      s2 = this.sphere2.intersects(this.ray);
      if (s1 > s2) {
        return this.sphere1.norm(intersectionPoint);
      } else {
        return this.sphere2.norm(intersectionPoint);
      }
    };

    SphereSphereIntersection.prototype.intersects = function(ray) {
      var s1, s2;
      this.ray = ray;
      s1 = this.sphere1.intersects(ray);
      s2 = this.sphere2.intersects(ray);
      if (!(s1 && s2)) {
        return false;
      }
      return Math.min(s1, s2);
    };

    SphereSphereIntersection.prototype.intersection = function(ray) {
      var i, intersectionPoint, normal;
      i = this.intersects(ray);
      if (!i) {
        return false;
      }
      intersectionPoint = ray.line.anchor.add(ray.line.direction.multiply(i));
      normal = this.norm(intersectionPoint);
      return [i, intersectionPoint, normal];
    };

    return SphereSphereIntersection;

  })();

  /* Random log*/


  console.setRlog = function(p) {
    if (p == null) {
      p = 0.0001;
    }
    return this.shoulLog = Math.random() <= p;
  };

  console.rlog = function(msg) {
    if (!this.shoulLog) {
      return;
    }
    return console.log(msg);
  };

  Math.square = function(num) {
    return num * num;
  };

}).call(this);

/*
//@ sourceMappingURL=compiled.js.map
*/