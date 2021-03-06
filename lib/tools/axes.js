// Generated by CoffeeScript 1.6.3
(function() {
  var AxesTool, Tool, _ref,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Tool = ((typeof window !== "undefined" && window !== null ? window.MarkingSurface : void 0) || require('marking-surface')).Tool;

  AxesTool = (function(_super) {
    __extends(AxesTool, _super);

    function AxesTool() {
      this['on *drag dots'] = __bind(this['on *drag dots'], this);
      _ref = AxesTool.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    AxesTool.prototype.lines = null;

    AxesTool.prototype.dots = null;

    AxesTool.prototype.handleRadius = !!~navigator.userAgent.indexOf('iO') ? 20 : 10;

    AxesTool.prototype.fill = 'rgba(128, 128, 128, 0.1)';

    AxesTool.prototype.stroke = 'white';

    AxesTool.prototype.strokeWidth = 2;

    AxesTool.prototype.cursors = {
      'dots': 'move'
    };

    AxesTool.prototype.initialize = function() {
      var i;
      this.root.filter('shadow');
      this.lines = (function() {
        var _i, _results;
        _results = [];
        for (i = _i = 0; _i < 2; i = ++_i) {
          _results.push(this.addShape('line', {
            stroke: this.stroke,
            strokeWidth: this.strokeWidth
          }));
        }
        return _results;
      }).call(this);
      this.dots = (function() {
        var _i, _results;
        _results = [];
        for (i = _i = 0; _i < 4; i = ++_i) {
          _results.push(this.addShape('circle', {
            r: this.handleRadius,
            fill: this.fill,
            stroke: this.stroke,
            strokeWidth: this.strokeWidth
          }));
        }
        return _results;
      }).call(this);
      return this.mark.set({
        p0: [-(this.handleRadius * 2), -(this.handleRadius * 2)],
        p1: [-(this.handleRadius * 2), -(this.handleRadius * 2)],
        p2: [-(this.handleRadius * 2), -(this.handleRadius * 2)],
        p3: [-(this.handleRadius * 2), -(this.handleRadius * 2)]
      });
    };

    AxesTool.prototype.onFirstClick = function(e) {
      var newValues, point, points, x, y, _i, _len, _ref1;
      _ref1 = this.pointerOffset(e), x = _ref1.x, y = _ref1.y;
      points = this.drags === 0 ? ['p0', 'p1', 'p2', 'p3'] : ['p2', 'p3'];
      newValues = {};
      for (_i = 0, _len = points.length; _i < _len; _i++) {
        point = points[_i];
        newValues[point] = [x, y];
      }
      return this.mark.set(newValues);
    };

    AxesTool.prototype.onFirstDrag = function(e) {
      var newValues, point, points, x, y, _i, _len, _ref1;
      _ref1 = this.pointerOffset(e), x = _ref1.x, y = _ref1.y;
      points = this.drags === 0 ? ['p1', 'p3'] : ['p3'];
      newValues = {};
      for (_i = 0, _len = points.length; _i < _len; _i++) {
        point = points[_i];
        newValues[point] = [x, y];
      }
      return this.mark.set(newValues);
    };

    AxesTool.prototype.isComplete = function() {
      return this.drags === 2;
    };

    AxesTool.prototype.downedDotIndex = NaN;

    AxesTool.prototype['on *drag dots'] = function(e) {
      var i, s, x, y, _i, _len, _ref1, _ref2, _ref3;
      if ((_ref1 = e.type) === 'mousedown' || _ref1 === 'touchstart') {
        _ref2 = this.dots;
        for (i = _i = 0, _len = _ref2.length; _i < _len; i = ++_i) {
          s = _ref2[i];
          if (s.el === e.target) {
            this.downedDotIndex = i;
          }
        }
      }
      _ref3 = this.pointerOffset(e), x = _ref3.x, y = _ref3.y;
      return this.mark.set("p" + this.downedDotIndex, [x, y]);
    };

    AxesTool.prototype.render = function() {
      var i, intersection, line, point, _i, _j, _len, _len1, _ref1, _ref2, _ref3;
      _ref1 = ['p0', 'p1', 'p2', 'p3'];
      for (i = _i = 0, _len = _ref1.length; _i < _len; i = ++_i) {
        point = _ref1[i];
        this.dots[i].attr({
          cx: this.mark[point][0],
          cy: this.mark[point][1]
        });
      }
      this.lines[0].attr({
        x1: this.mark.p0[0],
        y1: this.mark.p0[1],
        x2: this.mark.p1[0],
        y2: this.mark.p1[1]
      });
      this.lines[1].attr({
        x1: this.mark.p2[0],
        y1: this.mark.p2[1],
        x2: this.mark.p3[0],
        y2: this.mark.p3[1]
      });
      intersection = this.mark.p0[0] === this.mark.p2[0] && this.mark.p0[1] === this.mark.p2[1] ? null : this.getIntersection(this.mark.p0, this.mark.p1, this.mark.p2, this.mark.p3);
      _ref2 = this.lines;
      for (_j = 0, _len1 = _ref2.length; _j < _len1; _j++) {
        line = _ref2[_j];
        line.attr({
          'strokeDasharray': intersection != null ? '' : '2, 2'
        });
      }
      if (intersection == null) {
        intersection = [(this.mark.p0[0] + this.mark.p1[0] + this.mark.p2[0] + this.mark.p3[0]) / 4, (this.mark.p0[1] + this.mark.p1[1] + this.mark.p2[1] + this.mark.p3[1]) / 4];
      }
      return (_ref3 = this.controls).moveTo.apply(_ref3, intersection);
    };

    AxesTool.prototype.getIntersection = function(p0, p1, p2, p3) {
      var grads, interX, interY, sortedX, sortedY;
      grads = [(p0[1] - p1[1]) / ((p0[0] - p1[0]) || 0.00001), (p2[1] - p3[1]) / ((p2[0] - p3[0]) || 0.00001)];
      interX = ((p2[1] - p0[1]) + (grads[0] * p0[0] - grads[1] * p2[0])) / (grads[0] - grads[1]);
      interY = grads[0] * (interX - p0[0]) + p0[1];
      sortedX = [p0[0], p1[0], p2[0], p3[0], interX].sort(function(a, b) {
        return a - b;
      });
      sortedY = [p0[1], p1[1], p2[1], p3[1], interY].sort(function(a, b) {
        return a - b;
      });
      if (sortedX[2] !== interX) {
        interX = NaN;
      }
      if (sortedY[2] !== interY) {
        interY = NaN;
      }
      if ((isNaN(interX)) || (isNaN(interY))) {
        return null;
      } else {
        return [interX, interY];
      }
    };

    return AxesTool;

  })(Tool);

  if (typeof window !== "undefined" && window !== null) {
    window.MarkingSurface.AxesTool = AxesTool;
  }

  if (typeof module !== "undefined" && module !== null) {
    module.exports = AxesTool;
  }

}).call(this);
