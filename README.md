Ethz Raytracer
==============

A raytracer for the computer graphics course at ethz.

Live demo
---------

The renderer is deployed to https://ethz-raytracer.firebaseapp.com/

Alternatively, the repository can be cloned from https://github.com/lukaselmer/ethz-raytracer , but then the code first has to be compiled (see compilation instructions).

Compilation instructions
------------------------

This raytracer is written in Coffeescript, which is very similar and compiles down to JavaScript. To compile the coffeescript sources:

* Install NodeJS
* `npm install --force`
* `npm install -g grunt-cli`
* `npm run build`

You can also use the `npm start` command to automatically build the files when the coffeescript files change.

Running the tests:

* Unit tests: `grunt karma:unit` (run automatically when the JS files are changed, works fine with `grunt watch`)
* CI tests `grunt karma:ci` (run only once, for continuous integration)


Code structure
--------------

Overview of the public folder:

```
public
├── data (data used in C2 and C3)
│   ├── Earth.tga
│   ├── EarthNormal.tga
│   ├── Moon.tga
│   ├── MoonNormal.tga
│   ├── ateneal.obj
│   ├── ateneam.obj
│   ├── dragon.obj
│   ├── mini.obj
│   ├── neoSimian-mech.obj
│   ├── neoSimian-organic.obj
│   ├── sphere.obj
│   └── teapot.obj
├── index.html (the main file to be opened in the browser)
├── lib (libraries used for the raytracer)
│   ├── bootstrap.min.js
│   ├── jquery-1.10.2.min.js
│   ├── read_obj.js
│   ├── read_tga.js
│   ├── startup.js
│   └── sylvester.src.js
├── out (compiled JS files)
│   ├── compiled.js
│   ├── compiled.js.map
│   ├── compiled.min.js
│   ├── compiled.src.coffee
│   ├── compiled.src.js
│   ├── compiled.src.map
│   ├── v1_compiled.js
│   └── v1_compiled.js.map
├── output (rendered images)
│   ├── cg-ex2-lukaselmer-A1.png
│   ├── cg-ex2-lukaselmer-A1B1.png
│   ├── cg-ex2-lukaselmer-A1B1B2.png
│   ├── cg-ex2-lukaselmer-A1B2.png
│   ├── cg-ex2-lukaselmer-B3.png
│   ├── cg-ex2-lukaselmer-B3B1.png
│   ├── cg-ex2-lukaselmer-B3B1B2.png
│   ├── cg-ex2-lukaselmer-B3B2.png
│   ├── cg-ex2-lukaselmer-B4.png
│   ├── cg-ex2-lukaselmer-B4B1.png
│   ├── cg-ex2-lukaselmer-B4B1B2.png
│   └── cg-ex2-lukaselmer-moduleid.png
└── src (source code)
    ├── BoundingBox.coffee
    ├── Camera.coffee
    ├── Color.coffee
    ├── Intersection.coffee
    ├── Light.coffee
    ├── LightIntensity.coffee
    ├── MeshLoader.coffee
    ├── NormalMap.coffee
    ├── Octree.coffee
    ├── Ray.coffee
    ├── RayConfig.coffee
    ├── RayTracer.coffee
    ├── ReflectionProperty.coffee
    ├── Scene.coffee
    ├── SceneLoader.coffee
    ├── Texture.coffee
    ├── figures
    │   ├── Cylinder.coffee
    │   ├── Ellipsoid.coffee
    │   ├── Hemisphere.coffee
    │   ├── Mesh.coffee
    │   ├── MultipleObjectsIntersection.coffee
    │   ├── Plane.coffee
    │   ├── Sphere.coffee
    │   └── Triangle.coffee
    └── helpers.coffee
```			
			
Unit Tests
----------

There are now some basic unit tests. To execute the tests run `grunt karma`. Make shure you run a browser on port 63342, otherwise the texture tests will fail.


Implemented Features
--------------------

The following features have been implemented:

### A1: Basic features

* Ray casting
* Ray-object intersection
* Shadows
* Phong lighting model

### B1: Specular reflection and specular refraction

The algorithm is programmed recursively.

### B2: Anti-aliasing

Anti-aliasing is implemented with a regular grid. Currently, there are no textures and with the current setup, no unwanted aliasing could be observed.

### B3: Quadrics

The two quadrics are implemented.

### B4: Boolean operations

The boolean operations are implemented.

### C1: Stereoscopic rendering

Is implemented, but yet untested due to the lack of stereoscopic glasses.

### C2: Texture mapping and bump mapping

Is implemented with

* Surface mapping
* Anti-aliasing
* North poles are on top
* Bump mapping

### C3: Triangle meshes

The triangle meshes are implemented and some additional objects have been rendered.

### D1: Octree

Is implemented. Without the octree, rendering meshes is nearly impossible. The depth of the octree can be configured, and should be set high of objects with many faces.

### D2: Area lights

The area lights for the shadow rays are implemented. The monte carlo integration is done with a jitter algorithm. Additional algorithms could be implemented.

