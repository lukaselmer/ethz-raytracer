// Generated by CoffeeScript 1.6.3
/* Random log*/


(function() {
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
//@ sourceMappingURL=helpers.map
*/