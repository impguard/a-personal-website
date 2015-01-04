$(() ->

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

    createHandler = ($link, themeClass, darkClass, textColor) ->
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
                # call previous links callback when scrolling up
                if this.previous()?
                    this.previous().callback("down")


    $.each(["home", "about", "experience", "hobbies", "contact"], (index, name) ->
        $id = $("##{name}")
        $link = $("##{name}-link")
        themeClass = name + "-theme"
        darkClass = name + "-dark"

        # Handle waypoints
        options = { offset: "85px", continuous: false, group: "nav" }
        if name is "experience"
            $id.waypoint(createHandler($link, themeClass, darkClass, "black"), options)
        else
            $id.waypoint(createHandler($link, themeClass, darkClass, "white"), options)

        # Handle link click transition
        $link.click(() ->
            # Magic number to scroll slightly over
            $id.velocity("scroll", { duration: 600, offset: -navbarHeight + 5 })
        )

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
