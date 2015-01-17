$window.load(() ->

    #============================================================
    # Constants
    #============================================================

    $navbar = $("#navbar")
    $links = $("#navbar > nav > div")
    $selectors = $("#navbar .selector")
    navbarHeight = 85

    # Navbar state
    $currentSelector = $()
    isScrolling = false;

    #============================================================
    # Handle Nav Events
    #============================================================

    # Helper to create handler for navbar
    createNavHandler = ($link, themeClass, darkClass, textColor) ->
        $selector = $link.children(".selector")
        return (direction) ->
            if direction is "down"
                # navbar color
                $navbar.removeClass($navbar.data("color"))
                $navbar.addClass(themeClass)
                $navbar.data("color", themeClass)
                # selectors color
                $selectors.removeClass($selectors.data("color"))
                $selectors.addClass(darkClass)
                $selectors.data("color", darkClass)
                # text color
                $links.css("color", textColor)
                $link.css("color", "white")
                # handle selector transitions
                $currentSelector.velocity({ top: "-#{navbarHeight}px" }, 200)
                $selector.velocity({ top: "0" }, 200)
                $currentSelector = $selector
            else
                if this.previous()?
                    # call previous links callback when scrolling up
                    this.previous().callback("down")

    # Helper to handle transition into each page
    transitionInHandler = (waypoint) ->
        $element = $(waypoint.element)
        if $element.data("hasTransitionIn")?
            waypoint.destroy()
            return

        handlerIn = $element.data("transitionIn")
        if handlerIn? then handlerIn()
        $element.data("hasTransitionIn", true)

    $.each(["home", "about", "experience", "hobbies", "contact"], (index, name) ->
        $id = $("##{name}")
        $link = $("##{name}-link")
        themeClass = name + "-theme"
        darkClass = name + "-dark"

        # Handle navbar waypoints
        options = { offset: "85px", continuous: false, group: "nav" }
        if name is "experience"
            $id.waypoint(createNavHandler($link, themeClass, darkClass, "black"), options)
        else
            $id.waypoint(createNavHandler($link, themeClass, darkClass, "white"), options)

        # Handle page transition in handlers
        optionsTop = { offset: "85px", continuous: false, group: "transitionIn" }
        optionsBottom = 
            offset: () ->
                -$(this.element).outerHeight() + 86
            continuous: false
            group: "transitionIn"


        topWaypoint = $id.waypoint((direction) ->
            if direction is "down"
                transitionInHandler(this)
        , optionsTop)

        bottomWaypoint = $id.waypoint((direction) ->
            if direction is "up"
                transitionInHandler(this)
        , optionsBottom)

        # Handle link click and page click transition
        scrollToId = () ->
            offset = if $link.attr("id") is "home-link" then 0 else 5
            # Offset to scroll over padding at the top of each page
            $id.velocity("scroll", { duration: 600, offset: offset })

        $link.click(scrollToId)
        $id.click(scrollToId)

        # Handle link hover text color and selectors
        $selector = $link.children(".selector")
        $a = $link.find("a")
        $link.hover(
            () ->
                $a.css("color", "white")
                $selector.velocity("stop").velocity({ top: "0" }, 200)
            () ->
                $a.css("color", "inherit")
                if $selector[0] isnt $currentSelector[0]
                    $selector.velocity("stop").velocity({ top: "-#{navbarHeight}px" }, 200)            
        )
    )
)
