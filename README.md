Ethz Raytracer
==============

A raytracer for the computer graphics course at ethz.

Live demo
---------

The renderer is deployed to https://raytracer-eth.renuo.ch/


Compilation instructions
------------------------

This raytracer is written in Coffeescript, which is very similar and compiles down to JavaScript. To compile the coffeescript sources:

* Install NodeJS
* `npm install`
* `npm install -g grunt-cli`
* `grunt`


Code structure
--------------

Overview of the public folder:
|   index.html
|
+---data (data used in ex. 3)
|       Earth.tga
|       EarthNormal.tga
|       Moon.tga
|       MoonNormal.tga
|       sphere.obj
|
+---lib (libraries used for the raytracer)
|       read_obj.js
|       read_tga.js
|       startup.js
|       sylvester.src.js
|
+---out (compiled JS files)
|       compiled.js
|       compiled.js.map
|       compiled.src.coffee
|
+---output (rendered images)
|       cg-ex2-lukaselmer-A1.png
|       cg-ex2-lukaselmer-A1B1.png
|       cg-ex2-lukaselmer-A1B1B2.png
|       cg-ex2-lukaselmer-A1B2.png
|       cg-ex2-lukaselmer-B3.png
|       cg-ex2-lukaselmer-B3B1.png
|       cg-ex2-lukaselmer-B3B1B2.png
|       cg-ex2-lukaselmer-B3B2.png
|       cg-ex2-lukaselmer-B4.png
|       cg-ex2-lukaselmer-B4B1.png
|       cg-ex2-lukaselmer-B4B1B2.png
|       cg-ex2-lukaselmer-moduleid.png
|
\---src (source code)
    |   Camera.coffee
    |   Color.coffee
    |   helpers.coffee
    |   Intersection.coffee
    |   Light.coffee
    |   LightIntensity.coffee
    |   Ray.coffee
    |   RayConfig.coffee
    |   RayTracer.coffee
    |   ReflectionProperty.coffee
    |   Scene.coffee
    |   SceneLoader.coffee
    |
    \---figures (the different objects which can be rendered)
            Cylinder.coffee
            Ellipsoid.coffee
            Hemisphere.coffee
            MultipleObjectsIntersection.coffee
            Plane.coffee
            Sphere.coffee
			
Unit Tests
----------

Although there are only few tests yet, a unit testing framework is prepared. To execute the tests run `grunt karma`.


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







