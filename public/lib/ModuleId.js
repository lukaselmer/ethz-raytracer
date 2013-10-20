"use strict";

// DO NOT CHANGE ANYTHING HERE
// This function read the variables given in the URL as GET parameters
// For example if you call index.html?C1 then ModuleId.C1 equals true
// You can have several module by doing for example index.html?C1&C2

var ModuleId = {
	B1: false, //... specular reflection/refraction and recursive ray tracing
	B2: false, //... anti-aliasing
	B3: false, //... quadrics
	B4: false, //... CSG primitives
	C1: false, //... stereo
	C2: false, //... texture mapping
	C3: false, //... meshes
	D1: false, //... octree
	D2: false  //... area light
};

if(document.location.toString().indexOf('?') != -1) {
    var query = document.location.toString().replace(/^.*?\?/,'').split('&');
    query.forEach(function(q){
        ModuleId[q] = true;
    });
}
