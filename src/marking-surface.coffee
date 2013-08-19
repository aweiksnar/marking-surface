class MarkingSurface extends BaseClass
  tool: Tool

  width: NaN
  height: NaN

  el: null
  tagName: 'div'
  className: 'marking-surface'
  tabIndex: 0

  svg: null

  zoomBy: 1
  zoomSnapTolerance: 0.05
  panX: 0.5
  panY: 0.5

  tools: null
  selection: null

  marks: null

  disabled: false

  constructor: ->
    super

    @el = document.querySelectorAll @el if typeof @el is 'string'
    @el ?= document.createElement @tagName
    @el.className = @className
    @el.setAttribute 'tabindex', @tabIndex

    @el.addEventListener 'mousemove', @onMouseMove, false
    @el.addEventListener 'touchmove', @onTouchMove, false

    @el.addEventListener 'mousedown', @onMouseDown, false
    @el.addEventListener 'touchstart', @onTouchStart, false

    if @el.parentNode?
      @width ||= @el.clientWidth
      @height ||= @el.clientHeight

    @svg ?= new SVG {@width, @height}
    @svg.el.style.display = 'block' # This is okay since it's always contained.
    @el.appendChild @svg.el

    @marks ?= []
    @tools ?= []

    disable() if @disabled

  resize: (@width = @width, @height = @height) ->
    @svg.attr {@width, @height}
    null

  zoom: (@zoomBy = 1) ->
    if @zoomBy < 1 + @zoomSnapTolerance
      @zoomBy = 1
      @panX = @constructor::panX
      @panY = @constructor::panY

    @pan()
    null

  pan: (@panX = @panX, @panY = @panY) ->
    minX = (@width - (@width / @zoomBy)) * @panX
    minY = (@height - (@height / @zoomBy)) * @panY
    width = @width / @zoomBy
    height = @height / @zoomBy

    @svg.attr 'viewBox', "#{minX} #{minY} #{width} #{height}"

    tool.render() for tool in @tools
    null

  onMouseMove: (e) =>
    return if @zoomBy is 1
    {x, y} = @pointerOffset e
    @pan x / @width, y / @height
    null

  onTouchMove: (e) =>
    @onMouseMove e # if e.touches.length is 2
    null

  onMouseDown: (e) =>
    return if @disabled
    return if e.defaultPrevented
    return if e.target in @el.querySelectorAll ".#{ToolControls::className}, .#{ToolControls::className} *"

    e.preventDefault()

    if not @selection? or @selection.isComplete()
      if @tool?
        tool = new @tool surface: @
        mark = tool.mark

        tool.on 'select', =>
          return if @selection is tool

          @selection?.deselect()

          removeFrom tool, @tools
          @tools.push tool

          @selection = tool
          @trigger 'select-tool', [@selection]

        tool.on 'deselect', =>
          @selection = null

        tool.on 'destroy', =>
          removeFrom tool, @tools
          @trigger 'destroy-tool', [tool]

          @tools[@tools.length - 1]?.select() if tool is @selection

        @tools.push tool
        @trigger 'create-tool', [tool]

        mark.on 'destroy', =>
          removeFrom mark, @marks
          @trigger 'destroy-mark', [mark]

        @marks.push mark
        @trigger 'create-mark', [mark]

    else
      tool = @selection

    if tool?
      tool.select()
      tool.onInitialClick e

    dragEvent = if e.type is 'mousedown' then 'mousemove' else 'touchmove'
    releaseEvent = if e.type is 'mousedown' then 'mouseup' else 'touchend'
    document.addEventListener dragEvent, @onDrag, false
    document.addEventListener releaseEvent, @onRelease, false

    null

  onDrag: (e) =>
    e.preventDefault()
    @selection?.onInitialDrag arguments...
    null

  onRelease: (e) =>
    e.preventDefault()
    dragEvent = if e.type is 'mouseup' then 'mousemove' else 'touchmove'
    document.removeEventListener dragEvent, @onDrag, false
    document.removeEventListener e.type, @onRelease, false

    @selection?.onInitialRelease arguments...
    null

  onTouchStart: (e) =>
    @onMouseDown e if e.touches.length is 1
    null

  disable: (e) ->
    return if @disabled
    @disabled = true
    @el.setAttribute 'disabled', 'disabled'
    @selection?.deselect()
    null

  enable: (e) ->
    return unless @disabled
    @disabled = false
    @el.removeAttribute 'disabled'
    null

  destroy: ->
    mark.destroy() for mark in @marks # Tools destroy themselves with their marks.
    @el.removeEventListener 'mousedown', @onMouseDown, false
    @el.removeEventListener 'mousemove', @onMouseMove, false
    @el.removeEventListener 'touchstart', @onTouchStart, false
    @el.removeEventListener 'touchmove', @onTouchMove, false
    super
    null

  pointerOffset: (e) ->
    originalEvent = e.originalEvent if 'originalEvent' of e
    e = originalEvent.touches[0] if originalEvent? and 'touches' of originalEvent

    elements = []
    currentElement = @el
    while currentElement?
      elements.push currentElement
      currentElement = currentElement.parentNode

    left = 0
    top = 0

    for element in elements
      left += element.offsetLeft unless isNaN element.offsetLeft
      top += element.offsetTop unless isNaN element.offsetTop

    x = e.pageX - left
    y = e.pageY - top

    {x, y}
