$(() ->
    #============================================================
    # Constants
    #============================================================

    $about = $("#about")
    $wall = $about.find(".wall")
    $counter = $wall.children(".counter")
    $table = $about.find(".table")
    $shadow = $table.children(".shadow")

    #============================================================
    # Set counter width
    #============================================================

    resizeCounter = () ->
        width = Math.min(3 * $wall.height(), $wall.width())
        $counter.width(width).height(width / 3)

    resizeCounter()
    $window.resize(resizeCounter)

    #============================================================
    # Style table shadow
    #============================================================

    resizeTableShadow = () ->
        $shadow.css(
            transform: "skewX(45deg) translateX(#{$shadow.height() / 2}px)"
        )

    resizeTableShadow()
    $window.resize(resizeTableShadow)

    #============================================================
    # Hover effects
    #============================================================

    #============================================================
    # Transition Eye Candy
    #============================================================

    $elements = $about.find(".portrait, .student, .hacker, .gamer")
    animateIn = (waypoint) ->
        $elements.velocity("stop").velocity("transition.slideDownIn", { stagger: 100, drag: true })
        waypoint.destroy()

    
    $about.data("waypointIn", animateIn)
)
