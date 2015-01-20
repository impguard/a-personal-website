$(() ->

    # Constants
    hobbiesData = window.exports.hobbies
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
    # Global State
    #============================================================

    currHobbyDot = 0
    currFace = 0
    autorotateIntervalID = 0

    #============================================================
    # Container
    #============================================================

    # Dynamically resize container
    resizeContainer = () ->
        $container.width(Math.min($hobbies.height(), $hobbies.width() * 0.95))

    $window.resize(resizeContainer)
    resizeContainer()

    #============================================================
    # Cube API
    #============================================================

    # Helper functions to switch faces
    switchToFace = (transitionTime = 750) ->
        $cube.velocity("stop").velocity($faces[currFace].data("transition"), transitionTime, "ease-in-out")

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

        switchToFace(0)

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
    # Dot creation
    #============================================================

    numberOfDots = hobbiesData.length;

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

    #============================================================
    # Grab newly created dots
    #============================================================

    $dot = $dots.children(".dot")

    #============================================================
    # Dot API
    #============================================================

    # Logic to select dot 
    toggleDot = (num) ->
        $dot.eq(num).toggleClass("selected")

    selectDot  = (num) ->
        if num is currHobbyDot or num < 0 or num >= hobbiesData.length
            return false
        toggleDot(currHobbyDot)
        toggleDot(num)
        currHobbyDot = num      

    toggleDot(currHobbyDot)
    resizeDots()
    $window.resize(resizeDots)

    #============================================================
    # Selection API
    #============================================================

    randomizeFace = () ->
        return currFace = (currFace + Math.round(Math.random(5)) + 1) % 6

    updateTitle = (title) ->
        $title.empty().html(title)
        $title.velocity("stop").velocity("fadeIn", { duration: 300 })

    imgFolder = "imgs/"

    selectHobby = (hobbyNum) ->
        hobby = hobbiesData[hobbyNum]
        foundFace = false
        for $face, faceNum in $faces
            if $face.data("hobby") is hobby.name
                currFace = faceNum
                foundFace = true
                break

        if not foundFace
            randomizeFace()
            $image = $("<img />").attr("src", imgFolder + hobby.img)
            $faces[currFace].empty().append($image)
            $faces[currFace].data("hobby", hobby.name)

        updateTitle(hobby.name)
        selectDot(hobbyNum)
        switchToFace()

    initializeHobbies = () ->
        currFace = 0
        for i in [0..5]
            hobby = hobbiesData[currHobbyDot + i]
            $image = $("<img />").attr("src", imgFolder + hobby.img)
            $faces[i].empty().append($image)
            $faces[i].data("hobby", hobby.name)

        $title.empty().html(hobbiesData[currHobbyDot].name)
        switchToFace(0)

    initializeAutoselection = () ->
        window.clearInterval(autorotateIntervalID)
        autorotateIntervalID = window.setInterval(() ->
            nextHobby = ((currHobbyDot + 1) + hobbiesData.length) % hobbiesData.length
            selectHobby(nextHobby)
        , 3200)

    #============================================================
    # Event Handlers
    #============================================================

    createEventHandlers = () ->
        $prev.click(() ->
            initializeAutoselection()
            nextHobby = ((currHobbyDot - 1) + hobbiesData.length) % hobbiesData.length
            selectHobby(nextHobby)
        )

        $next.click(() ->
            initializeAutoselection()
            nextHobby = (currHobbyDot + 1) % hobbiesData.length
            selectHobby(nextHobby)
        )

        $dot.click(() ->
            initializeAutoselection()
            nextHobby = $(this).index()
            selectHobby(nextHobby)
        )

    #============================================================
    # Transition Eye Candy
    #============================================================

    $arrows = $hobbies.find(".prev, .next")
    animateIn = (waypoint) ->
        initializeHobbies()
        $cube.velocity("transition.cubeIn", () ->
            # Fix for mobile Safari, velocity does not work
            $arrows.animate({ opacity: 1 }, 500)
            $dot.velocity("transition.fadeIn", { display: "inline-block" })
            $title.velocity("transition.fadeIn")
            createEventHandlers()
            initializeAutoselection()
        )
    
    $hobbies.data("transitionIn", animateIn)
)