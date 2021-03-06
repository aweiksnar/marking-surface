// Generated by CoffeeScript 1.6.3
(function() {
  var RectangleTool, Tool, _ref,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Tool = ((typeof window !== "undefined" && window !== null ? window.MarkingSurface : void 0) || require('marking-surface')).Tool;

  RectangleTool = (function(_super) {
    var startCoords;

    __extends(RectangleTool, _super);

    function RectangleTool() {
      this.dragFromBottomLeft = __bind(this.dragFromBottomLeft, this);
      this.dragFromBottomRight = __bind(this.dragFromBottomRight, this);
      this.dragFromTopRight = __bind(this.dragFromTopRight, this);
      this.dragFromTopLeft = __bind(this.dragFromTopLeft, this);
      _ref = RectangleTool.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    RectangleTool.prototype.outside = null;

    RectangleTool.prototype.handles = null;

    RectangleTool.prototype.topLeftHandle = null;

    RectangleTool.prototype.topRightHandle = null;

    RectangleTool.prototype.bottomRightHandle = null;

    RectangleTool.prototype.bottomLeftHandle = null;

    RectangleTool.prototype.handleSize = !!~navigator.userAgent.indexOf('iO') ? 20 : 10;

    RectangleTool.prototype.fill = 'rgba(128, 128, 128, 0.1)';

    RectangleTool.prototype.stroke = 'white';

    RectangleTool.prototype.strokeWidth = 2;

    RectangleTool.prototype.defaultSize = 10;

    startCoords = null;

    RectangleTool.prototype.pointerOffsetFromShape = null;

    RectangleTool.prototype.cursors = {
      outside: '*grab',
      handles: 'move'
    };

    RectangleTool.prototype.initialize = function() {
      this.root.filter('shadow');
      this.outside = this.addShape('rect', {
        fill: this.fill,
        stroke: this.stroke,
        strokeWidth: this.strokeWidth
      });
      this.topLeftHandle = this.addShape('rect', {
        width: this.handleSize,
        height: this.handleSize,
        fill: this.fill,
        stroke: this.stroke,
        strokeWidth: this.strokeWidth
      });
      this.topRightHandle = this.addShape('rect', {
        width: this.handleSize,
        height: this.handleSize,
        fill: this.fill,
        stroke: this.stroke,
        strokeWidth: this.strokeWidth
      });
      this.bottomRightHandle = this.addShape('rect', {
        width: this.handleSize,
        height: this.handleSize,
        fill: this.fill,
        stroke: this.stroke,
        strokeWidth: this.strokeWidth
      });
      this.bottomLeftHandle = this.addShape('rect', {
        width: this.handleSize,
        height: this.handleSize,
        fill: this.fill,
        stroke: this.stroke,
        strokeWidth: this.strokeWidth
      });
      this.handles = [this.topLeftHandle, this.topRightHandle, this.bottomRightHandle, this.bottomLeftHandle];
      return this.mark.set({
        left: 0,
        top: 0,
        width: this.defaultSize,
        height: this.defaultSize
      });
    };

    RectangleTool.prototype['on *start outside'] = function(e) {
      this.startCoords = this.pointerOffset(e);
      return this.pointerOffsetFromShape = {
        x: this.startCoords.x - this.mark.left,
        y: this.startCoords.y - this.mark.top
      };
    };

    RectangleTool.prototype['on *drag outside'] = function(e) {
      var x, y, _ref1;
      _ref1 = this.pointerOffset(e), x = _ref1.x, y = _ref1.y;
      return this.mark.set({
        left: x - this.pointerOffsetFromShape.x,
        top: y - this.pointerOffsetFromShape.y
      });
    };

    RectangleTool.prototype.onFirstClick = function(e) {
      this.startCoords = this.pointerOffset(e);
      return this.mark.set({
        left: this.startCoords.x - (this.defaultSize / 2),
        top: this.startCoords.y - (this.defaultSize / 2)
      });
    };

    RectangleTool.prototype.onFirstDrag = function(e) {
      return this['on *drag handles'](e);
    };

    RectangleTool.prototype['on *start topLeftHandle'] = function(e) {
      return this.startCoords = {
        x: this.mark.left + this.mark.width,
        y: this.mark.top + this.mark.height
      };
    };

    RectangleTool.prototype['on *start topRightHandle'] = function(e) {
      return this.startCoords = {
        x: this.mark.left,
        y: this.mark.top + this.mark.height
      };
    };

    RectangleTool.prototype['on *start bottomRightHandle'] = function(e) {
      return this.startCoords = {
        x: this.mark.left,
        y: this.mark.top
      };
    };

    RectangleTool.prototype['on *start bottomLeftHandle'] = function(e) {
      return this.startCoords = {
        x: this.mark.left + this.mark.width,
        y: this.mark.top
      };
    };

    RectangleTool.prototype['on *drag handles'] = function(e) {
      var dragMethod, x, y, _ref1;
      _ref1 = this.pointerOffset(e), x = _ref1.x, y = _ref1.y;
      dragMethod = x < this.startCoords.x && y < this.startCoords.y ? 'dragFromTopLeft' : x >= this.startCoords.x && y < this.startCoords.y ? 'dragFromTopRight' : x >= this.startCoords.x && y >= this.startCoords.y ? 'dragFromBottomRight' : x < this.startCoords.x && y >= this.startCoords.y ? 'dragFromBottomLeft' : void 0;
      return this[dragMethod](e);
    };

    RectangleTool.prototype.dragFromTopLeft = function(e) {
      var x, y, _ref1;
      _ref1 = this.pointerOffset(e), x = _ref1.x, y = _ref1.y;
      x -= this.handleSize / 2;
      y -= this.handleSize / 2;
      return this.mark.set({
        left: x,
        top: y,
        width: this.mark.width + (this.mark.left - x),
        height: this.mark.height + (this.mark.top - y)
      });
    };

    RectangleTool.prototype.dragFromTopRight = function(e) {
      var x, y, _ref1;
      _ref1 = this.pointerOffset(e), x = _ref1.x, y = _ref1.y;
      x += this.handleSize / 2;
      y -= this.handleSize / 2;
      return this.mark.set({
        top: y,
        width: x - this.mark.left,
        height: this.mark.height + (this.mark.top - y)
      });
    };

    RectangleTool.prototype.dragFromBottomRight = function(e) {
      var x, y, _ref1;
      _ref1 = this.pointerOffset(e), x = _ref1.x, y = _ref1.y;
      x += this.handleSize / 2;
      y += this.handleSize / 2;
      return this.mark.set({
        width: x - this.mark.left,
        height: y - this.mark.top
      });
    };

    RectangleTool.prototype.dragFromBottomLeft = function(e) {
      var x, y, _ref1;
      _ref1 = this.pointerOffset(e), x = _ref1.x, y = _ref1.y;
      x -= this.handleSize / 2;
      y += this.handleSize / 2;
      return this.mark.set({
        left: x,
        width: this.mark.width + (this.mark.left - x),
        height: y - this.mark.top
      });
    };

    RectangleTool.prototype.render = function() {
      var _ref1;
      this.outside.attr({
        x: this.mark.left,
        y: this.mark.top,
        width: this.mark.width,
        height: this.mark.height
      });
      this.topLeftHandle.attr({
        x: this.mark.left,
        y: this.mark.top
      });
      this.topRightHandle.attr({
        x: this.mark.left + (this.mark.width - this.handleSize),
        y: this.mark.top
      });
      this.bottomRightHandle.attr({
        x: this.mark.left + (this.mark.width - this.handleSize),
        y: this.mark.top + (this.mark.height - this.handleSize)
      });
      this.bottomLeftHandle.attr({
        x: this.mark.left,
        y: this.mark.top + (this.mark.height - this.handleSize)
      });
      return (_ref1 = this.controls).moveTo.apply(_ref1, this.getControlsPosition());
    };

    RectangleTool.prototype.getControlsPosition = function() {
      return [this.mark.left + this.mark.width, this.mark.top];
    };

    return RectangleTool;

  })(Tool);

  if (typeof window !== "undefined" && window !== null) {
    window.MarkingSurface.RectangleTool = RectangleTool;
  }

  if (typeof module !== "undefined" && module !== null) {
    module.exports = RectangleTool;
  }

}).call(this);
