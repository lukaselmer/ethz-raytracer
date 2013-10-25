(function() {
  var Camera, Color, Cylinder, Ellipsoid, Hemisphere, Intersection, Light, LightIntensity, MultipleObjectsIntersection, Plane, Ray, RayTracer, ReflectionProperty, Scene, SceneLoader, Sphere;

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

  Intersection = (function() {
    function Intersection(ray, figure, normalFigure, t1, t2, reflectionProperties) {
      var _ref, _ref1;
      this.ray = ray;
      this.figure = figure;
      this.normalFigure = normalFigure;
      this.t1 = t1;
      this.t2 = t2;
      this.reflectionProperties = reflectionProperties;
      if ((-RayConfig.intersectionDelta < (_ref = this.t1) && _ref < RayConfig.intersectionDelta)) {
        this.t1 = 0;
      }
      if ((-RayConfig.intersectionDelta < (_ref1 = this.t2) && _ref1 < RayConfig.intersectionDelta)) {
        this.t2 = 0;
      }
      if (this.t1 > 0 && this.t2 > 0) {
        this.distance = Math.min(this.t1, this.t2);
        this.distance2 = Math.max(this.t1, this.t2);
      } else if (this.t1 > 0 && this.t2 <= 0) {
        this.distance = this.t1;
        this.distance2 = this.t2;
      } else if (this.t2 > 0 && this.t1 <= 0) {
        this.distance = this.t2;
        this.distance2 = this.t2;
      }
    }

    Intersection.prototype.getNormal = function() {
      if (!this.normal) {
        this.normal = this.normalFigure.norm(this.getPoint(), this.ray);
      }
      return this.normal;
    };

    Intersection.prototype.getPoint = function() {
      if (!this.point) {
        this.point = this.ray.line.anchor.add(this.ray.line.direction.multiply(this.distance));
      }
      return this.point;
    };

    return Intersection;

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
      recDepth: 2,
      intersectionDelta: 0.00001,
      strongRefraction: true
    };
  };

  initRayConfig();

  RayTracer = (function() {
    function RayTracer(pixelX, pixelY, scene) {
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
        return _this.traceRec(ray, RayConfig.recDepth);
      };
      colors = rays.map(function(ray) {
        return traceRay(ray);
      });
      averageColorVector = colors.map(function(c) {
        return c.toVector();
      }).reduce(function(previous, current) {
        return previous.add(current);
      }).multiply(1 / colors.length);
      return averageColorVector;
    };

    RayTracer.prototype.traceRec = function(ray, times) {
      var color, globalAmbient, globalAmbientColor, intersection, light, _i, _len, _ref;
      color = new Color(0, 0, 0);
      intersection = this.scene.firstIntersection(ray);
      if (!intersection) {
        return color;
      }
      globalAmbient = this.scene.globalAmbient;
      globalAmbientColor = intersection.figure.reflectionProperties.ambientColor.multiply(globalAmbient);
      color = color.add(globalAmbientColor);
      if (RayConfig.illumination) {
        _ref = this.scene.lights;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          light = _ref[_i];
          color = color.add(this.illuminate(intersection, ray, light));
        }
      }
      if (times <= 0) {
        return color;
      }
      if (RayConfig.reflection) {
        color = color.add(this.reflectAndRefract(intersection, ray, times));
      }
      return color;
    };

    RayTracer.prototype.reflectAndRefract = function(intersection, ray, times) {
      var color, f, reflectedRay, refractedRay, specularReflection, specularRefraction, _ref;
      f = intersection.figure;
      _ref = this.specularRays(intersection, ray), reflectedRay = _ref[0], refractedRay = _ref[1];
      color = new Color(0, 0, 0);
      if (reflectedRay != null) {
        specularReflection = this.traceRec(reflectedRay, times - 1);
        specularReflection = specularReflection.multiplyColor(f.reflectionProperties.specularColor);
        color = color.add(specularReflection.multiply(reflectedRay.power));
      }
      if (refractedRay != null) {
        specularRefraction = this.traceRec(refractedRay, times - 1);
        if (!(ray.isInside() && RayConfig.strongRefraction)) {
          specularRefraction = specularRefraction.multiplyColor(f.reflectionProperties.specularColor);
        }
        color = color.add(specularRefraction.multiply(refractedRay.power));
      }
      return color;
    };

    RayTracer.prototype.specularRays = function(intersection, ray) {
      var cos_theta_i, cos_theta_t, i, i_dot_n, n, n1, n2, p, r1, r2, ratio, reflectionDirection, reflectionPowerRatio, refractionDirection, refractionPowerRatio, sin_theta_t_2;
      n = intersection.getNormal();
      p = intersection.getPoint();
      if (ray.isInside()) {
        n = n.multiply(-1);
      }
      i = p.subtract(ray.line.anchor).toUnitVector();
      n1 = ray.refraction;
      n2 = ray.isInside() ? 1 : intersection.figure.reflectionProperties.refractionIndex;
      i_dot_n = i.dot(n);
      cos_theta_i = -i_dot_n;
      reflectionDirection = i.add(n.multiply(2 * cos_theta_i)).toUnitVector();
      if (n2 === Infinity) {
        return [new Ray($L(p, reflectionDirection), n1, ray.power), null];
      }
      ratio = n1 / n2;
      sin_theta_t_2 = Math.square(ratio) * (1 - Math.square(cos_theta_i));
      if (sin_theta_t_2 > 1) {
        return [new Ray($L(p, reflectionDirection), n1, ray.power), null];
      }
      cos_theta_t = Math.sqrt(1 - sin_theta_t_2);
      refractionDirection = i.multiply(ratio).add(n.multiply((ratio * cos_theta_i) - cos_theta_t)).toUnitVector();
      r1 = Math.square((n1 * cos_theta_i - n2 * cos_theta_t) / (n1 * cos_theta_i + n2 * cos_theta_t));
      r2 = Math.square((n2 * cos_theta_i - n1 * cos_theta_t) / (n2 * cos_theta_i + n1 * cos_theta_t));
      reflectionPowerRatio = (r1 + r2) / 2;
      refractionPowerRatio = 1 - reflectionPowerRatio;
      if (!((0 <= reflectionPowerRatio && reflectionPowerRatio <= 1) && (0 <= refractionPowerRatio && refractionPowerRatio <= 1))) {
        return [new Ray($L(p, reflectionDirection), n1, ray.power), null];
      }
      if (!((0 <= reflectionPowerRatio && reflectionPowerRatio <= 1) && (0 <= refractionPowerRatio && refractionPowerRatio <= 1))) {
        throw "Invalid state: reflectionPowerRatio: " + reflectionPowerRatio + ", refractionPowerRatio: " + refractionPowerRatio;
      }
      return [new Ray($L(p, reflectionDirection), n1, ray.power * reflectionPowerRatio), new Ray($L(p, refractionDirection), n2, ray.power * refractionPowerRatio)];
    };

    RayTracer.prototype.illuminate = function(intersection, ray, light) {
      var E, ambient, ambientColor, diffuse, f, frac, kd, ks, n, nv, p, specularHighlights, spepcularIntensity, w, wl, wr;
      f = intersection.figure;
      p = intersection.getPoint();
      nv = intersection.getNormal();
      w = ray.line.direction;
      wl = light.location.subtract(p).toUnitVector();
      wr = nv.multiply(2).multiply(w.dot(nv)).subtract(w).toUnitVector();
      if (this.scene.firstIntersection(new Ray($L(p, wl), ray.refraction, 1))) {
        return new Color(0, 0, 0);
      }
      ambient = light.intensity.ambient;
      ambientColor = f.reflectionProperties.ambientColor.multiply(ambient);
      kd = f.reflectionProperties.diffuseColor;
      E = light.intensity.diffuse * nv.dot(wl);
      diffuse = kd.multiply(E * light.intensity.diffuse);
      n = f.reflectionProperties.specularExponent;
      ks = f.reflectionProperties.specularColor;
      frac = Math.pow(wr.dot(wl), n) / nv.dot(wl);
      spepcularIntensity = frac * E;
      if (frac < 0) {
        spepcularIntensity = 0;
      }
      specularHighlights = ks.multiply(spepcularIntensity);
      return ambientColor.add(diffuse).add(specularHighlights);
    };

    RayTracer.prototype.castRays = function(antialiasing) {
      var antialiasing_translation_mean, arr, camera, direction, i, j, p, pixelX, pixelY, x, _i, _j, _k, _len, _len1, _results;
      camera = this.scene.camera;
      antialiasing_translation_mean = (1 + antialiasing) / 2;
      x = (function() {
        _results = [];
        for (var _i = 1; 1 <= antialiasing ? _i <= antialiasing : _i >= antialiasing; 1 <= antialiasing ? _i++ : _i--){ _results.push(_i); }
        return _results;
      }).apply(this);
      arr = [];
      for (_j = 0, _len = x.length; _j < _len; _j++) {
        i = x[_j];
        for (_k = 0, _len1 = x.length; _k < _len1; _k++) {
          j = x[_k];
          pixelX = (this.pixelX + i / antialiasing - antialiasing_translation_mean + 0.5) - (camera.width / 2);
          pixelY = ((this.pixelY + j / antialiasing - antialiasing_translation_mean + 0.5) - (camera.height / 2)) * -1;
          p = camera.imageCenter.add(camera.upDirection.multiply(pixelY / camera.height * camera.imagePaneHeight));
          p = p.add(camera.rightDirection.multiply(pixelX / camera.width * camera.imagePaneWidth));
          direction = p.subtract(camera.position);
          arr.push(new Ray($L(camera.position, direction), 1, 1));
        }
      }
      return arr;
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
      var dist, figure, i, min, ret, _i, _len, _ref;
      min = Infinity;
      ret = null;
      _ref = this.objects;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        figure = _ref[_i];
        i = figure.intersection(ray);
        if (!i) {
          continue;
        }
        dist = i.distance;
        if (dist !== null && dist < min) {
          ret = i;
          min = dist;
        }
      }
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
      scene.addObject(new Sphere($V([1.25, 1.25, 3]), 0.5, new ReflectionProperty(new Color(0, 0, 0.75), new Color(0, 0, 1), new Color(0.5, 0.5, 1), 16, 1.5)));
      if (ModuleId.SP1) {
        return scene.addObject(new Plane($V([0, -1, 0]), $V([1, 1, 0]), new ReflectionProperty(new Color(0, 0.75, 0.75), new Color(0, 1, 1), new Color(0.5, 1, 1), 16, Infinity)));
      }
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
      var cylinder, m1, m2, mtot, red, sphere1, sphere2, yellow;
      sphere1 = new Sphere($V([1.25, 1.25, 3]), 0.5, null);
      sphere2 = new Sphere($V([0.25, 1.25, 3]), 1, null);
      scene.addObject(new MultipleObjectsIntersection(sphere1, sphere2, new ReflectionProperty(new Color(0, 0, 0.75), new Color(0, 0, 1), new Color(0.5, 0.5, 1), 16, 1.5)));
      red = new ReflectionProperty(new Color(0.75, 0, 0), new Color(1, 0, 0), new Color(1, 1, 1), 32.0, Infinity);
      yellow = new ReflectionProperty(new Color(0.75, 0.75, 0), new Color(1, 1, 0), new Color(1, 1, 1), 32.0, Infinity);
      scene.addObject(new Hemisphere(new Sphere($V([0, 0, 0]), 2, red), new Plane($V([0, 0, 0]), $V([-1, 0, 1]).toUnitVector(), yellow)));
      if (ModuleId.SP1) {
        sphere1 = new Sphere($V([0, 0.5, 3]), 1, null);
        sphere2 = new Sphere($V([0, -0.5, 3]), 1, null);
        m1 = new MultipleObjectsIntersection(sphere1, sphere2, null);
        sphere1 = new Sphere($V([0.5, 0, 3]), 1, null);
        sphere2 = new Sphere($V([-0.5, 0, 3]), 1, null);
        m2 = new MultipleObjectsIntersection(sphere1, sphere2, null);
        mtot = new MultipleObjectsIntersection(m1, m2, new ReflectionProperty(new Color(0, 0, 0.75), new Color(0, 0, 1), new Color(0.5, 0.5, 1), 16, 1.5));
        scene.addObject(mtot);
        cylinder = new Cylinder($V([0, 0, 0]), false, true, false, 2, 0, 1, null);
        sphere1 = new Sphere($V([-2, 1.25, 0]), 1, null);
        return scene.addObject(new MultipleObjectsIntersection(cylinder, sphere1, new ReflectionProperty(new Color(0.75, 0, 0), new Color(1, 0, 0), new Color(1, 1, 1), 32, 1.75)));
      }
    };

    SceneLoader.prototype.loadAlternative = function(scene) {
      var c, m1, m2, mtot, sphere1, sphere2;
      c = Color.random();
      scene.addObject(new Sphere($V([-3, 3, 0]), 2, new ReflectionProperty(c, c, new Color(1, 1, 1), 32, 1.5)));
      c = Color.random();
      scene.addObject(new Sphere($V([1.25, 1.25, 3]), 0.5, new ReflectionProperty(c, c, new Color(0.5, 0.5, 1), 16, 1.5)));
      c = Color.random();
      scene.addObject(new Sphere($V([1.25, -1.25, 3]), 0.5, new ReflectionProperty(c, c, new Color(0.5, 0.5, 1), 16, 1.5)));
      c = Color.random();
      scene.addObject(new Sphere($V([-1, -0.75, 3]), 0.5, new ReflectionProperty(c, c, new Color(0.5, 0.5, 1), 16, 1.5)));
      scene.addObject(new Sphere($V([2.5, 0, -1]), 0.5, new ReflectionProperty(new Color(0, 0, 0.75), new Color(0, 0, 1), new Color(0.5, 0.5, 1), 16, 1.5)));
      sphere1 = new Sphere($V([0, 0.5, 3]), 1, null);
      sphere2 = new Sphere($V([0, -0.5, 3]), 1, null);
      m1 = new MultipleObjectsIntersection(sphere1, sphere2, null);
      sphere1 = new Sphere($V([0.5, 0, 3]), 1, null);
      sphere2 = new Sphere($V([-0.5, 0, 3]), 1, null);
      m2 = new MultipleObjectsIntersection(sphere1, sphere2, null);
      mtot = new MultipleObjectsIntersection(m1, m2, new ReflectionProperty(new Color(0, 0, 0.75), new Color(0, 0, 1), new Color(0.5, 0.5, 1), 16, 1.5));
      return scene.addObject(mtot);
    };

    return SceneLoader;

  })();

  this.SceneLoader = SceneLoader;

  this.trace = function(scene, color, pixelX, pixelY) {
    var rayTracer;
    rayTracer = new RayTracer(color, pixelX, pixelY, scene);
    return rayTracer.trace();
  };

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

    Cylinder.prototype.norm = function(intersectionPoint, ray) {
      var intersection, n;
      intersection = $V([(this.fixed_x ? 0 : (intersectionPoint.e(1)) / this.radius_x_2), (this.fixed_y ? 0 : (intersectionPoint.e(2)) / this.radius_y_2), (this.fixed_z ? 0 : (intersectionPoint.e(3)) / this.radius_z_2)]);
      n = intersection.subtract(this.axis_line);
      return n.toUnitVector();
    };

    Cylinder.prototype.solutions = function(ray) {
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
      if (t1 <= t2) {
        return [t1, t2];
      }
      return [t2, t1];
    };

    Cylinder.prototype.intersection = function(ray) {
      var i, t1, t2;
      i = this.solutions(ray);
      if (!i) {
        return null;
      }
      t1 = i[0], t2 = i[1];
      return new Intersection(ray, this, this, t1, t2, this.reflectionProperties);
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

    Ellipsoid.prototype.norm = function(intersectionPoint, ray) {
      var n, t;
      n = intersectionPoint.subtract(this.center);
      t = $M([[2 / this.radius_x_2, 0, 0], [0, 2 / this.radius_y_2, 0], [0, 0, 2 / this.radius_z_2]]);
      n = t.multiply(n);
      return n.toUnitVector();
    };

    Ellipsoid.prototype.solutions = function(ray) {
      var a, b, c, dir, oc;
      oc = ray.line.anchor.subtract(this.center);
      dir = ray.line.direction.toUnitVector();
      a = ((dir.e(1) * dir.e(1)) / this.radius_x_2) + ((dir.e(2) * dir.e(2)) / this.radius_y_2) + ((dir.e(3) * dir.e(3)) / this.radius_z_2);
      b = ((2 * oc.e(1) * dir.e(1)) / this.radius_x_2) + ((2 * oc.e(2) * dir.e(2)) / this.radius_y_2) + ((2 * oc.e(3) * dir.e(3)) / this.radius_z_2);
      c = ((oc.e(1) * oc.e(1)) / this.radius_x_2) + ((oc.e(2) * oc.e(2)) / this.radius_y_2) + ((oc.e(3) * oc.e(3)) / this.radius_z_2) - 1;
      return Math.solveN2(a, b, c);
    };

    Ellipsoid.prototype.intersection = function(ray) {
      var i, t1, t2;
      i = this.solutions(ray);
      if (!i) {
        return null;
      }
      t1 = i[0], t2 = i[1];
      return new Intersection(ray, this, this, t1, t2, this.reflectionProperties);
    };

    return Ellipsoid;

  })();

  Hemisphere = (function() {
    function Hemisphere(sphere, plane) {
      this.sphere = sphere;
      this.plane = plane;
    }

    Hemisphere.prototype.intersection = function(ray) {
      var p, p1, s, s1, s2;
      s = this.sphere.intersection(ray);
      p = this.plane.intersection(ray);
      if (!(s && p)) {
        return null;
      }
      s1 = s.distance;
      s2 = s.distance2;
      p1 = p.distance;
      if (s1 < p1 && s2 < p1) {
        return null;
      }
      if (s1 > p1 && s2 > p1) {
        return s;
      }
      if (s1 < p1 && s2 > p1) {
        return p;
      }
      throw "Invalid state: s1: " + s2 + ", s1: " + s2 + ", p1: " + p1;
    };

    Hemisphere.prototype.solutions = function(ray) {
      var i;
      i = this.intersection(ray);
      if (!i) {
        return null;
      }
      return [i.t1, i.t2];
    };

    return Hemisphere;

  })();

  MultipleObjectsIntersection = (function() {
    function MultipleObjectsIntersection(figure1, figure2, reflectionProperties) {
      this.figure1 = figure1;
      this.figure2 = figure2;
      this.reflectionProperties = reflectionProperties;
    }

    MultipleObjectsIntersection.prototype.norm = function(intersectionPoint, ray) {
      var f, i1, i11, i12, i2, i21, i22, _ref, _ref1;
      i1 = this.figure1.solutions(ray);
      i2 = this.figure2.solutions(ray);
      i11 = i1[0], i12 = i1[1];
      if (i11 > i12) {
        _ref = [i12, i11], i11 = _ref[0], i12 = _ref[1];
      }
      i21 = i2[0], i22 = i2[1];
      if (i21 > i22) {
        _ref1 = [i22, i21], i21 = _ref1[0], i22 = _ref1[1];
      }
      f = i21 < i11 ? this.figure1 : this.figure2;
      return f.norm(intersectionPoint, ray);
    };

    MultipleObjectsIntersection.prototype.solutions = function(ray) {
      var i;
      i = this.intersection(ray);
      if (!i) {
        return null;
      }
      return [i.t1, i.t2];
    };

    MultipleObjectsIntersection.prototype.intersection = function(ray) {
      var f1, f2, i1, i11, i12, i2, i21, i22, _ref, _ref1, _ref2;
      f1 = this.figure1;
      f2 = this.figure2;
      i1 = f1.solutions(ray);
      i2 = f2.solutions(ray);
      if (!(i1 && i2)) {
        return null;
      }
      i11 = i1[0], i12 = i1[1];
      if (i11 > i12) {
        _ref = [i12, i11], i11 = _ref[0], i12 = _ref[1];
      }
      i21 = i2[0], i22 = i2[1];
      if (i21 > i22) {
        _ref1 = [i22, i21], i21 = _ref1[0], i22 = _ref1[1];
      }
      if (i21 < i11) {
        _ref2 = [f2, i2, i21, i22, f1, i1, i11, i12], f1 = _ref2[0], i1 = _ref2[1], i11 = _ref2[2], i12 = _ref2[3], f2 = _ref2[4], i2 = _ref2[5], i21 = _ref2[6], i22 = _ref2[7];
      }
      if (i12 <= i21) {
        return null;
      }
      return new Intersection(ray, this, f2, i21, Math.min(i12, i22), this.reflectionProperties);
    };

    return MultipleObjectsIntersection;

  })();

  Plane = (function() {
    function Plane(point, normal, reflectionProperties) {
      this.point = point;
      this.normal = normal;
      this.reflectionProperties = reflectionProperties;
      this.normal = this.normal.toUnitVector();
    }

    Plane.prototype.norm = function(intersectionPoint, ray) {
      return this.normal;
    };

    Plane.prototype.intersection = function(ray) {
      var c, distance, epsilon;
      c = ray.line.direction.dot(this.normal);
      if (c === 0) {
        return null;
      }
      distance = this.point.subtract(ray.line.anchor).dot(this.normal) / c;
      if (distance < RayConfig.intersectionDelta) {
        return null;
      }
      epsilon = 0.01;
      return new Intersection(ray, this, this, distance, distance - epsilon, this.reflectionProperties);
    };

    Plane.prototype.solutions = function(ray) {
      var i;
      i = this.intersection(ray);
      if (!i) {
        return null;
      }
      return [i.t1, i.t2];
    };

    return Plane;

  })();

  Sphere = (function() {
    function Sphere(center, radius, reflectionProperties) {
      this.center = center;
      this.radius = radius;
      this.reflectionProperties = reflectionProperties;
      this.radiusSquared = this.radius * this.radius;
    }

    Sphere.prototype.norm = function(intersectionPoint, ray) {
      return intersectionPoint.subtract(this.center).toUnitVector();
    };

    Sphere.prototype.solutions = function(ray) {
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
        return null;
      }
      t1 = rayDistanceClosestToCenter - Math.sqrt(x);
      t2 = rayDistanceClosestToCenter + Math.sqrt(x);
      if (t1 < RayConfig.intersectionDelta) {
        return [t2, t2];
      }
      if (t2 < RayConfig.intersectionDelta) {
        return [t1, t1];
      }
      return [t1, t2];
    };

    Sphere.prototype.intersection = function(ray) {
      var i, t1, t2;
      i = this.solutions(ray);
      if (!i) {
        return null;
      }
      t1 = i[0], t2 = i[1];
      return new Intersection(ray, this, this, t1, t2, this.reflectionProperties);
    };

    return Sphere;

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

  Math.solveN2 = function(a, b, c) {
    var root, t1, t2, under_root;
    under_root = (b * b) - (4 * a * c);
    if (under_root < 0 || a === 0 || b === 0) {
      return null;
    }
    root = Math.sqrt(under_root);
    t1 = (-b + root) / (2 * a);
    t2 = (-b - root) / (2 * a);
    if (t1 < RayConfig.intersectionDelta) {
      return [t2, t2];
    }
    if (t2 < RayConfig.intersectionDelta) {
      return [t1, t1];
    }
    return [t1, t2];
  };

}).call(this);

/*
//@ sourceMappingURL=compiled.js.map
*/