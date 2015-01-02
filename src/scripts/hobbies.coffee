$(() ->

    # Constants
    $window = $(window)
    $hobbies = $("#hobbies")
    $container  = $hobbies.children(".container")
    $carousel = $container.children(".carousel")
    $cube = $carousel.children(".cube")
    $faces = [
        $cube.children(".front"), $cube.children(".back")
        $cube.children(".right"), $cube.children(".left")
        $cube.children(".top"), $cube.children(".bottom")
    ]
    $dots = $container.find(".dots")
    $title = $container.children(".title")
    $prev = $carousel.children(".prev")
    $next = $carousel.children(".next")

    #============================================================
    # Container
    #============================================================

    # Dynamically resize container
    resizeContainer = () ->
        $container.width(Math.min($hobbies.height(), $hobbies.width() * 0.95))

    $window.resize(resizeContainer)
    resizeContainer()

    #============================================================
    # Cube
    #============================================================

    currFace = 0
    # Helper functions to switch faces
    switchToFace = (transitionTime = 750) ->
        $cube.velocity($faces[currFace].data("transition"), transitionTime, "ease-in-out")

    # Dynamically adjust cube transforms
    resizeCube = () ->
        translation = $cube.outerWidth() / 2
        $faces[0].css({ transform: "translateZ(#{translation}px)" })
        $faces[1].css({ transform: "rotateX(180deg) translateZ(#{translation}px)" })
        $faces[2].css({ transform: "rotateY(90deg) translateZ(#{translation}px)" })
        $faces[3].css({ transform: "rotateY(-90deg) translateZ(#{translation}px)" })
        $faces[4].css({ transform: "rotateX(90deg) translateZ(#{translation}px)" })
        $faces[5].css({ transform: "rotateX(-90deg) translateZ(#{translation}px)" })

        $faces[0].data("transition", { translateZ: "-#{translation}px", rotateX: "0deg", rotateY: "0deg", rotateZ: "0deg" })
        $faces[1].data("transition", { translateZ: "-#{translation}px", rotateX: "-180deg", rotateY: "0deg", rotateZ: "0deg" })
        $faces[2].data("transition", { translateZ: "-#{translation}px", rotateX: "0deg", rotateY: "-90deg", rotateZ: "0deg" })
        $faces[3].data("transition", { translateZ: "-#{translation}px", rotateX: "0deg", rotateY: "90deg", rotateZ: "0deg" })
        $faces[4].data("transition", { translateZ: "-#{translation}px", rotateX: "-90deg", rotateY: "0deg", rotateZ: "0deg" })
        $faces[5].data("transition", { translateZ: "-#{translation}px", rotateX: "90deg", rotateY: "0deg", rotateZ: "0deg" })

        switchToFace(currFace)

    $window.resize(resizeCube)
    resizeCube()

    # Tweak to allow cube to overlap navbar
    $carousel.waypoint((direction) ->
        if direction is "up"
            $carousel.css("z-index", 2)
        else
            $carousel.css("z-index", 0)
    , { offset: 85 })

    #============================================================
    # Dots
    #============================================================

    numberOfDots = 8;

    # Logic to create dots
    do () ->
        for _ in [1..numberOfDots]
            $dots.append($("<div>").addClass("dot"))

    # Logic to dynamically resize dots
    
    resizeDots = () ->
        diameter = Math.round(Math.min(20, Math.max(10, 0.4 * $dots.height())))
        dotCSS = {
            width: diameter
            height: diameter
            marginRight: 0.8 * diameter
        }

        dotsWidth = (numberOfDots - 1) * dotCSS.marginRight + numberOfDots * dotCSS.width
        $dots.css({ width: dotsWidth, lineHeight: "#{$dots.height()}px" })

        $dots.children().each((index, dot) -> $(this).css(dotCSS))
        $dots.children(".dot:last-child").css("margin-right", 0)

    # Logic to select dot
    dots = $dots.children()
    currDot = 0
    toggleDot = (num) ->
        dots.eq(num).toggleClass("selected")

    incrementDot = () ->
        nextDot = (currDot + 1) % numberOfDots
        toggleDot(currDot)
        toggleDot(nextDot)
        currDot = nextDot

    decrementDot = () ->
        nextDot = (currDot - 1) % numberOfDots
        toggleDot(currDot)
        toggleDot(nextDot)
        currDot = nextDot        

    toggleDot(currDot)
    resizeDots()
    $window.resize(resizeDots)

    #============================================================
    # Selection logic
    #============================================================

    $prev.click(() ->
        decrementDot()
        currFace = (6 + (currFace - 1)) % 6
        switchToFace()
    )

    $next.click(() ->
        incrementDot()
        currFace = (currFace + 1) % 6
        switchToFace()
    )

)