"use strict";

// DO NOT CHANGE ANYTHING HERE
// This function read the variables given in the URL as GET parameters
// For example if you call index.html?C1 then ModuleId.C1 equals true
// You can have several module by doing for example index.html?C1&C2

var ModuleId = {
    B1: undefined, //... specular reflection/refraction and recursive ray tracing
    B2: undefined, //... anti-aliasing
    B3: undefined, //... quadrics
    B4: undefined, //... CSG primitives
    C1: undefined, //... stereo
    C2: undefined, //... texture mapping
    C3: undefined, //... meshes
    D1: undefined, //... octree
    D2: undefined  //... area light
};

$(document).ready(function () {
    if (document.location.toString().indexOf('?') != -1) {
        var query = document.location.toString().replace(/^.*?\?/, '').replace('#', '').split('&');
        query.forEach(function (q) {
            var tmp = q.split('=')
            var k = tmp[0];
            var v = tmp[1];
            if (v === undefined || v === '1' || v === 'true') v = true;
            else v = false;

            ModuleId[k] = v;
        });
    }

    for (var k in ModuleId) {
        var v = ModuleId[k];

        var checkbox = document.createElement('input');
        checkbox.type = 'checkbox';
        checkbox.value = 1;
        checkbox.name = k;
        checkbox.id = k;
        if (v) checkbox.setAttribute('checked', 'checked');

        var label = document.createElement('label');
        label.setAttribute('class', 'btn btn-primary' + (v ? ' active' : ''));
        label.appendChild(checkbox);
        $(label).data('option', k);
        label.innerHTML += k;

        $('#renderOptions').append(label);
    }


});
