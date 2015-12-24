# Note that when compiling with coffeescript, the plugin is wrapped in another
# anonymous function. We do not need to pass in undefined as well, since
# coffeescript uses (void 0) instead.
do ($ = jQuery, window, document) ->

  # window and document are passed through as local variable rather than global
  # as this (slightly) quickens the resolution process and can be more efficiently
  # minified (especially when both are regularly referenced in your plugin).

  # Create the defaults once
  pluginName = 'viewportChecker'
  defaults =
    callbackFunction: $.noop
    classToAdd: 'visible'
    classToAddForFullView: 'full-visible'
    classToRemove: 'invisible'
    invertBottomOffset: true
    offset: 100
    removeClassAfterAnimation: false
    repeat: false
    scrollBox: window
    scrollHorizontal: false

  # The actual plugin constructor
  class ViewportChecker
    constructor: (elements, options) ->
      # jQuery has an extend method which merges the contents of two or
      # more objects, storing the result in the first object. The first object
      # is generally empty as we don't want to alter the default options for
      # future instances of the plugin
      @$elements = $(elements)
      @settings = $.extend {}, defaults, options
      @_defaults = defaults
      @_name = pluginName
      @init()

    init: ->
      # Place initialization logic here
      # You already have access to the DOM element and the options via the instance,
      # e.g., @$element and @settings


      # Cache the given element and height of the browser
      @boxSize = 
        height: $(options.scrollBox).height()
        width: $(options.scrollBox).width()

      if (navigator.userAgent.toLowerCase().indexOf('webkit') != -1 ||
          navigator.userAgent.toLowerCase().indexOf('windows phone') != -1)
        @scrollElem = 'body'
      else
        @scrollElem = 'html'

    check: ->
      # Set some vars to check with
      if options.scrollHorizontal
        viewportStart = $(scrollElem).scrollLeft()
        viewportEnd = viewportStart + boxSize.width
      else
        viewportStart = $(scrollElem).scrollTop()
        viewportEnd = viewportStart + boxSize.height

      objOptions = {}
      attrOptions = {}

      #  Get any individual attribution data
      if @$element.data('vp-add-class')
        attrOptions.classToAdd = @$element.data('vp-add-class')
      if @$element.data('vp-remove-class')
        attrOptions.classToRemove = @$element.data('vp-remove-class')
      if @$element.data('vp-add-class-full-view')
        attrOptions.classToAddForFullView = @$element.data('vp-add-class-full-view')
      if @$element.data('vp-keep-add-class')
        attrOptions.removeClassAfterAnimation = @$element.data('vp-remove-after-animation')
      if @$element.data('vp-offset')
        attrOptions.offset = @$element.data('vp-offset')
      if @$element.data('vp-repeat')
        attrOptions.repeat = @$element.data('vp-repeat')
      if @$element.data('vp-scrollHorizontal')
        attrOptions.scrollHorizontal = @$element.data('vp-scrollHorizontal')
      if @$element.data('vp-invertBottomOffset')
        attrOptions.scrollHorizontal = @$element.data('vp-invertBottomOffset')

      # Extend objOptions with data attributes and default options
      $.extend objOptions, options
      $.extend objOptions, attrOptions

      # If class already exists; quit
      return if @$element.data('vp-animated') && !objOptions.repeat

      # Check if the offset is percentage based
      if String(objOptions.offset).indexOf('%') > 0
        objOptions.offset = parseInt(objOptions.offset, 10) / 100) * boxSize.height
        
      # Get the raw start and end positions
      rawStart = if objOptions.scrollHorizontal then @$element.offset().left else @$element.offset().top
      rawEnd = if objOptions.scrollHorizontal then rawStart + @$element.width() else rawStart + @$element.height()

      # Add the defined offset
      elemStart = Math.round(rawStart) + objOptions.offset
      elemEnd = if objOptions.scrollHorizontal then elemStart + @$element.width() else elemStart + @$element.height()

      if objOptions.invertBottomOffset
        elemEnd -= objOptions.offset * 2

      # Add class if in viewport
      if (elemStart < viewportEnd) && (elemEnd > viewportStart)

        # Remove class
        @$element.removeClass objOptions.classToRemove
        @$element.addClass objOptions.classToAdd

        # Do the callback function. Callback wil send the jQuery object as parameter
        objOptions.callbackFunction @$element, 'add'

        # Check if full element is in view
        if rawEnd <= viewportEnd && rawStart >= viewportStart
          @$element.addClass objOptions.classToAddForFullView
        else
          @$element.removeClass objOptions.classToAddForFullView

        # Set element as already animated
        @$element.data 'vp-animated', true

        if objOptions.removeClassAfterAnimation
          @$element.one 'webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend', =>
            @$element.removeClass objOptions.classToAdd

      # Remove class if not in viewport and repeat is true
      else if @$element.hasClass(objOptions.classToAdd) && (objOptions.repeat)
        "#{@$element.removeClass objOptions.classToAdd} #{objOptions.classToAddForFullView}"

        # Do the callback function.
        objOptions.callbackFunction @$element, 'remove'

        # Remove already-animated-flag
        @$element.data 'vp-animated', false

  # A really lightweight plugin wrapper around the constructor,
  # preventing against multiple instantiations
  $.fn[pluginName] = (command, options = {}) -> new ViewportChecker(@)












