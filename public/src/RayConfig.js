// Generated by CoffeeScript 1.6.3
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
  ALT: undefined
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
    intersectionDelta: 0.0000000001
  };
};

initRayConfig();
