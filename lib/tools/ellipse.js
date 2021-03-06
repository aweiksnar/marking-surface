// Generated by CoffeeScript 1.6.3
(function() {
  var EllipseTool, Tool, _ref,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Tool = ((typeof window !== "undefined" && window !== null ? window.MarkingSurface : void 0) || require('marking-surface')).Tool;

  EllipseTool = (function(_super) {
    __extends(EllipseTool, _super);

    function EllipseTool() {
      this['on *end'] = __bind(this['on *end'], this);
      this['on *drag yHandle'] = __bind(this['on *drag yHandle'], this);
      this['on *drag xHandle'] = __bind(this['on *drag xHandle'], this);
      this['on *drag outside'] = __bind(this['on *drag outside'], this);
      _ref = EllipseTool.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    EllipseTool.prototype.path = null;

    EllipseTool.prototype.outside = null;

    EllipseTool.prototype.xHandle = null;

    EllipseTool.prototype.yHandle = null;

    EllipseTool.prototype.handleRadius = !!~navigator.userAgent.indexOf('iO') ? 20 : 10;

    EllipseTool.prototype.fill = 'rgba(128, 128, 128, 0.1)';

    EllipseTool.prototype.stroke = 'white';

    EllipseTool.prototype.strokeWidth = 2;

    EllipseTool.prototype.defaultRadius = 2;

    EllipseTool.prototype.defaultSquash = 0.5;

    EllipseTool.prototype.dragOffsetFromCenter = null;

    EllipseTool.prototype.cursors = {
      outside: '*grab',
      xHandle: 'move',
      yHandle: 'move'
    };

    EllipseTool.prototype.initialize = function() {
      this.root.filter('shadow');
      this.path = this.addShape('path', {
        d: 'M 0 0',
        stroke: this.stroke,
        strokeWidth: this.strokeWidth,
        strokeDasharray: [this.strokeWidth * 4, this.strokeWidth * 4]
      });
      this.outside = this.addShape('ellipse', {
        fill: this.fill,
        stroke: this.stroke,
        strokeWidth: this.strokeWidth
      });
      this.xHandle = this.addShape('circle', {
        r: this.handleRadius,
        fill: this.fill,
        stroke: this.stroke,
        strokeWidth: this.strokeWidth
      });
      this.yHandle = this.addShape('circle', {
        r: this.handleRadius,
        fill: this.fill,
        stroke: this.stroke,
        strokeWidth: this.strokeWidth
      });
      return this.mark.set({
        center: [0, 0],
        angle: 0,
        rx: 0,
        ry: 0
      });
    };

    EllipseTool.prototype.onFirstClick = function(e) {
      var x, y, _ref1;
      _ref1 = this.pointerOffset(e), x = _ref1.x, y = _ref1.y;
      return this.mark.set({
        center: [x, y],
        rx: this.defaultRadius,
        ry: this.defaultRadius * this.defaultSquash
      });
    };

    EllipseTool.prototype.onFirstDrag = function(e) {
      this['on *drag xHandle'](e);
      return this.mark.set('ry', this.mark.rx * this.defaultSquash);
    };

    EllipseTool.prototype['on *start'] = function(e) {
      var x, y, _ref1;
      _ref1 = this.pointerOffset(e), x = _ref1.x, y = _ref1.y;
      return this.dragOffsetFromCenter = {
        x: x - this.mark.center[0],
        y: y - this.mark.center[1]
      };
    };

    EllipseTool.prototype['on *drag outside'] = function(e) {
      var x, y, _ref1;
      _ref1 = this.pointerOffset(e), x = _ref1.x, y = _ref1.y;
      return this.mark.set('center', [x - this.dragOffsetFromCenter.x, y - this.dragOffsetFromCenter.y]);
    };

    EllipseTool.prototype['on *drag xHandle'] = function(e) {
      var x, y, _ref1;
      _ref1 = this.pointerOffset(e), x = _ref1.x, y = _ref1.y;
      return this.mark.set({
        angle: this.getAngle(this.mark.center[0], this.mark.center[1], x, y),
        rx: this.getHypotenuse(this.mark.center[0], this.mark.center[1], x, y)
      });
    };

    EllipseTool.prototype['on *drag yHandle'] = function(e) {
      var x, y, _ref1;
      _ref1 = this.pointerOffset(e), x = _ref1.x, y = _ref1.y;
      return this.mark.set({
        angle: 90 + this.getAngle(this.mark.center[0], this.mark.center[1], x, y),
        ry: this.getHypotenuse(this.mark.center[0], this.mark.center[1], x, y)
      });
    };

    EllipseTool.prototype['on *end'] = function() {
      return this.dragOffsetFromCenter = null;
    };

    EllipseTool.prototype.render = function() {
      var _ref1;
      this.group.attr('transform', "translate(" + this.mark.center + ") rotate(" + this.mark.angle + ")");
      this.path.attr('d', "M 0 " + (-this.mark.ry) + " L 0 0 M " + this.mark.rx + " 0 L 0 0");
      this.outside.attr({
        rx: this.mark.rx,
        ry: this.mark.ry
      });
      this.xHandle.attr('cx', this.mark.rx);
      this.yHandle.attr('cy', -this.mark.ry);
      return (_ref1 = this.controls).moveTo.apply(_ref1, this.getControlsPosition());
    };

    EllipseTool.prototype.getControlsPosition = function() {
      return this.mark.center;
    };

    EllipseTool.prototype.getAngle = function(x1, y1, x2, y2) {
      var deltaX, deltaY;
      deltaX = x2 - x1;
      deltaY = y2 - y1;
      return Math.atan2(deltaY, deltaX) * (180 / Math.PI);
    };

    EllipseTool.prototype.getHypotenuse = function(x1, y1, x2, y2) {
      var aSquared, bSquared;
      aSquared = Math.pow(x2 - x1, 2);
      bSquared = Math.pow(y2 - y1, 2);
      return Math.sqrt(aSquared + bSquared);
    };

    return EllipseTool;

  })(Tool);

  if (typeof window !== "undefined" && window !== null) {
    window.MarkingSurface.EllipseTool = EllipseTool;
  }

  if (typeof module !== "undefined" && module !== null) {
    module.exports = EllipseTool;
  }

}).call(this);
