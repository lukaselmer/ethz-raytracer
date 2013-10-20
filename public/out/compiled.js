(function() {
  var Camera, Color, Light, LightIntensity, Ray, RayTracer, ReflectionProperty, Scene, Sphere;

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
      this.rightDirection = this.direction.cross(this.upDirection).toUnitVector();
      this.upDirection = this.rightDirection.cross(this.direction).toUnitVector();
      this.imagePaneHeight = 2 * Math.tan(this.fieldOfView / 2) * this.distance;
      this.imagePaneWidth = this.imagePaneHeight / this.height * this.width;
      this.imageCenter = this.position.add(this.direction.multiply(this.distance));
      this.imageTop = this.imageCenter.add(this.upDirection.multiply(this.imagePaneHeight / 2));
      this.imageBottom = this.imageCenter.add(this.upDirection.multiply(-1 * this.imagePaneHeight / 2));
      this.imageLeft = this.imageCenter.add(this.rightDirection.multiply(-1 * this.imagePaneWidth / 2));
      return this.imageRight = this.imageCenter.add(this.rightDirection.multiply(this.imagePaneWidth / 2));
    };

    Camera.prototype.getCenter = function() {
      return this.position.add(this.direction);
    };

    return Camera;

  })();

  Color = (function() {
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

    return Color;

  })();

  Light = (function() {
    function Light(color, location, intensity) {
      this.color = color;
      this.location = location;
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

  this.loadScene = function() {
    var camera, fieldOfView, scene;
    fieldOfView = 40 / 180 * Math.PI;
    camera = new Camera($V([0, 0, 10]), $V([0, 0, -1]), $V([0, 1, 0]), 1, fieldOfView, RayConfig.width, RayConfig.height);
    scene = new Scene(camera, 0.2);
    scene.addLight(new Light(new Color(1, 1, 1), $V([10, 10, 10]), new LightIntensity(0, 1, 1)));
    scene.addObject(new Sphere($V([0, 0, 0]), 2, new ReflectionProperty(new Color(0.75, 0, 0), new Color(1, 0, 0), new Color(1, 1, 1), 32, Infinity)));
    scene.addObject(new Sphere($V([1.25, 1.25, 3]), 0.5, new ReflectionProperty(new Color(0, 0, 0.75), new Color(0, 0, 1), new Color(0.5, 0.5, 1), 16, 1.5)));
    return scene;
  };

  this.trace = function(scene, color, pixelX, pixelY) {
    var rayTracer;
    rayTracer = new RayTracer(color, pixelX, pixelY, scene);
    return rayTracer.trace();
  };

  Ray = (function() {
    function Ray(line, refraction, power) {
      this.line = line;
      this.refraction = refraction;
      this.power = power;
    }

    return Ray;

  })();

  this.RayConfig = {
    width: 600,
    height: 800,
    illumination: true,
    reflection: true,
    recDepth: 10
  };

  RayTracer = (function() {
    function RayTracer(color, pixelX, pixelY, scene) {
      this.color = color;
      this.pixelX = pixelX;
      this.pixelY = pixelY;
      this.scene = scene;
    }

    RayTracer.prototype.trace = function() {
      var c, ray;
      ray = this.castRay();
      c = new Color(0, 0, 0);
      c = this.traceRec(ray, c, RayConfig.recDepth);
      return this.color.setElements(c.toArray());
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
          color = color.add(this.reflect(pos, obj, ray, times));
        }
      }
      return color;
    };

    RayTracer.prototype.reflect = function(pos, obj, ray, times) {
      var ks, nv, specularReflection, w, wr;
      nv = obj.norm(pos);
      w = ray.line.direction;
      wr = nv.multiply(2 * w.dot(nv)).subtract(w).toUnitVector().multiply(-1);
      ks = obj.reflectionProperties.specularColor;
      specularReflection = this.traceRec(new Ray($L(pos, wr), 1, 1), new Color(0, 0, 0), times - 1);
      specularReflection = specularReflection.multiplyColor(ks);
      return specularReflection;
    };

    RayTracer.prototype.illuminate = function(pos, obj, ray, light) {
      var E, ambient, ambientColor, diffuse, frac, kd, ks, n, nv, specularHighlights, spepcularIntensity, w, wl, wr;
      nv = obj.norm(pos);
      w = ray.line.direction;
      wl = light.location.subtract(pos).toUnitVector();
      wr = nv.multiply(2).multiply(w.dot(nv)).subtract(w).toUnitVector();
      if (this.scene.intersections(new Ray($L(pos, wl), 1, 1)).length > 0) {
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

    RayTracer.prototype.castRay = function() {
      var camera, centerPixelX, centerPixelY, rayDirection;
      camera = this.scene.camera;
      centerPixelX = (this.pixelX + 0.5 - camera.width / 2) / camera.height * camera.imagePaneHeight;
      centerPixelY = (-this.pixelY - 0.5 + camera.height / 2) / camera.width * camera.imagePaneWidth;
      rayDirection = camera.imageCenter.add(camera.upDirection.multiply(centerPixelX)).add(camera.rightDirection.multiply(centerPixelY)).subtract(camera.position);
      return new Ray($L(camera.position, rayDirection), 1, 1);
    };

    return RayTracer;

  })();

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

    Scene.prototype.intersections = function(ray) {
      var object, _i, _len, _ref, _results;
      _ref = this.objects;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        object = _ref[_i];
        if (object.intersects(ray)) {
          _results.push(object);
        }
      }
      return _results;
    };

    Scene.prototype.firstIntersection = function(ray) {
      var min, ret;
      min = Infinity;
      ret = null;
      this.objects.forEach(function(object) {
        var i, intersectionPoint;
        i = object.intersects(ray);
        if (i && i < min) {
          min = i;
          intersectionPoint = ray.line.anchor.add(ray.line.direction.multiply(i));
          return ret = [intersectionPoint, object];
        }
      });
      return ret;
    };

    return Scene;

  })();

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
      var c, c_minus_o, d, distSquared, o, rayDistanceClosestToCenter, shortestDistanceFromCenterToRaySquared, t, x;
      console.setRlog();
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
      t = rayDistanceClosestToCenter - Math.sqrt(x);
      return t;
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

}).call(this);

/*
//@ sourceMappingURL=compiled.js.map
*/