BACKSPACE = 8
DELETE = 46
TAB = 9

class MarkingSurface extends BaseClass
  tool: Tool

  width: NaN
  height: NaN

  el: null
  tagName: 'span'
  className: 'marking-surface'
  tabIndex: 0
  defaultCursor: 'crosshair'

  svg: null

  zoomBy: 1
  zoomSnapTolerance: 0.05
  panX: 0.5
  panY: 0.5

  tools: null
  selection: null

  marks: null

  disabled: false

  offsetAtLastMousedown: null

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

    @el.addEventListener 'keydown', @onKeyDown, false

    @el.style.position = 'relative'
    @el.style.display = 'inline-block'
    @el.style.overflow = 'hidden'

    @el.style.cursor = @defaultCursor

    if @el.parentNode?
      @width ||= @el.clientWidth
      @height ||= @el.clientHeight

    @svg ?= new SVG {@width, @height}
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
    @el.focus()

    # Presuming the element won't move mid-drag
    @offsetAtLastMousedown = @elOffset()

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

        mark.on 'change', =>
          @trigger 'change', [mark]

        mark.on 'destroy', =>
          removeFrom mark, @marks
          @trigger 'destroy-mark', [mark]
          @trigger 'change', [mark]

        @marks.push mark
        @trigger 'create-mark', [mark]

        @trigger 'change', []

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

  onKeyDown: (e) =>
    return if @disabled
    return if e.altKey or e.ctrlKey
    return unless e.which in [BACKSPACE, DELETE, TAB]
    return unless document.activeElement is @el

    switch e.which
      when BACKSPACE, DELETE
        e.preventDefault()
        @selection?.mark.destroy()

      when TAB
        e.preventDefault()
        if e.shiftKey
          @tools[0]?.select()

        else
          e.preventDefault()
          current = @selection
          next = @tools[@tools.length - 2]

          if next?
            next.select()
            removeFrom current, @tools
            @tools.unshift current

  getValue: ->
    JSON.stringify @marks

  addShape: ->
    @svg.addShape arguments...

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
    @el.removeEventListener 'keydown', @onKeyDown, false
    super
    null

  elOffset: ->
    left = 0
    top = 0

    currentElement = @el
    while currentElement?
      left += currentElement.offsetLeft unless isNaN currentElement.offsetLeft
      top += currentElement.offsetTop unless isNaN currentElement.offsetTop
      currentElement = currentElement.offsetParent

    left += parseFloat getComputedStyle(document.body.parentNode).marginLeft
    top += parseFloat getComputedStyle(document.body.parentNode).marginTop

    {left, top}

  pointerOffset: (e) ->
    originalEvent = e.originalEvent if 'originalEvent' of e
    e = originalEvent.touches[0] if originalEvent? and 'touches' of originalEvent

    {left, top} = @offsetAtLastMousedown || @elOffset()
    x = e.pageX - left
    y = e.pageY - top

    {x, y}
