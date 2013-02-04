$ = window.jQuery
Raphael = window.Raphael

doc = $(document)

MOUSE_EVENTS = ['mousedown', 'mouseover', 'mousemove', 'mouseout', 'mouseup']


class BaseClass
  jQueryEventProxy: null

  constructor: (params = {}) ->
    @[property] = value for own property, value of params when property of @
    @jQueryEventProxy = $({})

  destroy: ->
    @trigger 'destroy'
    @off()

  for method in ['on', 'one', 'trigger', 'off'] then do (method) =>
    @::[method] = ->
      @jQueryEventProxy[method] arguments...


class Mark extends BaseClass
  set: (property, value, {fromMany} = {}) ->
    if typeof property is 'string'
      setter = @["set #{property}"]
      @[property] = if setter then setter.call @, value else value

    else
      map = property
      @set property, value, fromMany: true for property, value of map

    @trigger 'change', property, value unless fromMany

  toJSON: ->
    result = {}

    for property, value of @
      continue if property is 'jQueryEventProxy'
      continue if typeof value is 'function'
      result[property] = value

    result


class ToolControls extends BaseClass
  tool: null

  el: null
  handle: null
  label: null
  deleteButton: null

  template: '''
    <div class="marking-tool-controls">
      <span class="handle"></span>
      <span class="label"></span>
      <button name="delete-mark">&times;</button>
    </div>
  '''

  constructor: ->
    super

    @el = $(@template)
    @handle = @el.find '.handle'
    @label = @el.find '.label'
    @deleteButton = @el.find 'button[name="delete-mark"]'

    @el.on 'mousedown', =>
      @onMouseDown arguments...

    @el.on 'click', 'button[name="delete-mark"]', =>
      @onClickDelete arguments...

  onMarkChange: ->
    @label.html @tool.mark.label

  moveTo: (x, y) ->
    [x, y] = x if x instanceof Array

    # User margins to avoid problems with a parent's padding.
    @el.css
      left: 0
      'margin-left': x
      'margin-top': y
      position: 'absolute'
      top: 0

  onMouseDown: (e) ->
    @tool.select()

  onClickDelete: ->
    @tool.mark.destroy()

  select: ->
    @el.addClass 'selected'

  deselect: ->
    @el.removeClass 'selected'

  destroy: ->
    @el.off()
    @el.remove()


class Tool extends BaseClass
  @Mark: Mark
  @Controls: ToolControls

  cursors: null

  mark: null
  markDefaults: null

  surface: null
  shapeSet: null

  controls: null

  clicks: 0

  constructor: ->
    super

    @mark ?= new @constructor.Mark
    @mark.set @markDefaults if @markDefaults?

    @mark.on 'change', =>
      @onMarkChange arguments...

    @mark.on 'destroy', =>
      @destroy arguments...

    @shapeSet ?= @surface.paper.set()

    @controls = new @constructor.Controls tool: @
    @controls.el.appendTo @surface.container

    @initialize arguments...

    # Wait for shapes to be added in an overridden constructor.
    setTimeout =>
      for eventName in MOUSE_EVENTS
        @shapeSet[eventName] =>
          @handleEvents arguments...

  addShape: (type, params...) ->
    attributes = params.pop() if typeof params[params.length - 1] is 'object'

    shape = @surface.paper[type.toLowerCase()] params...
    shape.attr attributes

    @shapeSet.push shape
    shape

  onInitialClick: (e) ->
    @trigger 'initial-click', [e]
    @onFirstClick e

  onInitialDrag: (e) ->
    @onFirstDrag e

  onInitialRelease: (e) ->
    @clicks += 1
    @trigger 'initial-release', [e]
    @onFirstRelease arguments...

  # Override this if drawing the tool requires multiple drag steps (e.g. axes).
  isComplete: ->
    @clicks is 1

  handleEvents: (e) ->
    return if @surface.disabled

    eventName = e.type
    target = e.target || e.srcElement # For IE
    shape = @surface.paper.getById target.raphaelid
    name = '*'

    for property, value of @
      isArray = value instanceof Array or value instanceof @shapeSet.constructor
      if (value is shape) or (isArray and shape in value)
        name = property

    @["on #{eventName}"]?.call @, e, shape

    @["on #{eventName} #{name}"]?.call @, e, shape

    switch eventName
      when 'mouseover'
        @surface.container.css cursor: @cursors?[name]

      when 'mouseout'
        @surface.container.css cursor: ''

      when 'mousedown', 'touchstart'
        e.preventDefault()
        @select()

        if 'on drag' of @
          onDrag = => @['on drag'] arguments..., shape
          doc.on 'mousemove touchmove', onDrag
          doc.one 'mouseup touchend', => doc.off 'mousemove touchmove', onDrag

        if name and "on drag #{name}" of @
          onNamedDrag = => @["on drag #{name}"] arguments..., shape
          doc.on 'mousemove touchmove', onNamedDrag
          doc.one 'mouseup touchend', => doc.off 'mousemove touchmove', onNamedDrag

  mouseOffset: ->
    @surface.mouseOffset arguments...

  onMarkChange: ->
    @controls.onMarkChange arguments...
    @render arguments...

  onClickDelete: (e) ->
    @mark.destroy()
    @surface.container.focus()

  select: ->
    @controls.select arguments...
    @shapeSet.attr opacity: 1
    @shapeSet.toFront()
    @trigger 'select', arguments

  deselect: ->
    @controls.deselect arguments...
    @shapeSet.attr opacity: 0.5
    @trigger 'deselect', arguments

  destroy: ->
    super

    @controls.destroy()

    @shapeSet.animate
      opacity: 0
      r: 0
      'stroke-width': 0
      250
      'ease-in'
      =>
        @shapeSet.remove() # This also unbinds all events.

  initialize: ->
    # E.g.
    # @addShape 'circle'

  onFirstClick: (e) ->
    # E.g.
    # @mark.set position: @mouseOffset(e).x

  onFirstDrag: (e) ->
    # E.g.
    # @mark.set position: @mouseOffset(e).x

  onFirstRelease: (e) ->

  render: ->
    # E.g.
    # @shapeSet.attr cx: @mark.position
    # @controls.css
    #   left: @mark.position
    #   top: @mark.position


class MarkingSurface extends BaseClass
  tool: Tool

  container: null
  className: 'marking-surface'
  width: 400
  height: 300
  background: ''

  paper: null
  image: null
  marks: null
  tools: null

  zoomBy: 1
  panX: 0
  panY: 0

  selection: null

  disabled: false

  constructor: (params = {}) ->
    super

    @container ?= document.createElement 'div'
    @container = $(@container)
    @container.addClass @className
    @container.attr tabindex: 0, unselectable: true
    @container.on 'blur', => @onBlur arguments...
    @container.on 'focus', => @onFocus arguments...

    unless @container.parents().length is 0
      @width = @container.width() || @width unless 'width' of params
      @height = @container.height() || @height unless 'height' of params

    @paper ?= Raphael @container.get(0), @width, @height
    @image = @paper.image 'about:blank', 0, 0, @width, @height

    setTimeout => @image.attr src: @background

    @marks ?= []
    @tools ?= []

    disable() if @disabled

    @container.on 'mousedown touchstart', => @onMouseDown arguments...
    @container.on 'mousemove touchmove', => @onMouseMove arguments...
    @container.on 'keydown', => @onKeyDown arguments...

  resize: (@width, @height) ->
    @paper.setSize @width, @height
    @image.attr {@width, @height}

  zoom: (@zoomBy = 1) ->
    @pan()

  pan: (@panX = @panX, @panY = @panY) ->
    @panX = Math.min @panX, @width, @width - (@width / @zoomBy)
    @panY = Math.min @panY, @height, @height - (@height / @zoomBy)

    @paper.setViewBox @panX, @panY, @width / @zoomBy, @height / @zoomBy

    tool.render() for tool in @tools

  onMouseMove: (e) ->
    return if @zoomBy is 1
    {x, y} = @mouseOffset e
    @panX = (@width - (@width / @zoomBy)) * (x / @width)
    @panY = (@height - (@height / @zoomBy)) * (y / @height)
    @pan()

  onMouseDown: (e) ->
    return if @disabled
    return unless e.target in [@container.get(0), @paper.canvas, @image.node]
    return if e.isDefaultPrevented()

    $(document.activeElement).blur()
    @container.focus()

    e.preventDefault()

    if not @selection? or @selection.isComplete()
      tool = new @tool surface: @
      mark = tool.mark

      @tools.push tool
      @marks.push mark

      tool.on 'select', =>
        @selection?.deselect() unless @selection is tool

        index = i for t, i in @tools when t is tool
        @tools.splice index, 1
        @tools.push tool

        @selection = tool

      tool.on 'deselect', =>
        @selection = null

      tool.on 'destroy', =>
        index = i for t, i in @tools when t is tool
        @tools.splice index, 1
        @tools[@tools.length - 1]?.select() if tool is @selection

      mark.on 'destroy', =>
        index = i for m, i in @marks when m is mark
        @marks.splice index, 1

      tool.select()
      @trigger 'create-mark', [mark, tool]

    else
      tool = @selection

    tool.select()
    tool.onInitialClick e

    onDrag = => @onDrag arguments...
    doc.on 'mousemove touchmove', onDrag
    doc.one 'mouseup touchend', =>
      @onRelease arguments...
      doc.off 'mousemove touchmove', onDrag

  onDrag: (e) ->
    @selection.onInitialDrag e

  onRelease: (e) ->
    @selection.onInitialRelease e

  onKeyDown: (e) ->
    return if $(e.target).is 'input, textarea, select, button'

    if e.which in [8, 46] # Backspace and delete
      e.preventDefault()
      @selection?.mark.destroy()
    else if e.which is 9 and @selection? # Tab
      e.preventDefault()

      if e.shiftKey
        @tools.unshift @tools.pop()
      else
        @tools.push @tools.shift()

      @tools[@tools.length - 1]?.select()

  onFocus: ->
    @selection?.select()

  onBlur: ->
    return if @container.has document.activeElement
    @selection?.deselect()

  disable: (e) ->
    @disabled = true
    @container.attr disabled: true
    @container.addClass 'disabled'
    @selection?.deselect()

  enable: (e) ->
    @disabled = false
    @container.attr disabled: false
    @container.removeClass 'disabled'

  destroy: ->
    @container.off().remove()
    mark.destroy() for mark in @marks
    super

  mouseOffset: (e) ->
    originalEvent = e.originalEvent if 'originalEvent' of e
    e = originalEvent.touches[0] if originalEvent? and 'touches' of originalEvent
    {left, top} = @container.offset()
    left += parseFloat @container.css 'padding-left'
    left += parseFloat @container.css 'border-left-width'
    top += parseFloat @container.css 'padding-top'
    top += parseFloat @container.css 'border-top-width'
    x: e.pageX - left, y: e.pageY - top


MarkingSurface.Mark = Mark
MarkingSurface.ToolControls = ToolControls
MarkingSurface.Tool = Tool

window.MarkingSurface = MarkingSurface
module?.exports = MarkingSurface if module?
