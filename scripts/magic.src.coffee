# Constants
$window = $(window)

# Helper to calculate days in between two dates
Date.daysInBetween = (fromDate, toDate) ->
    diff = toDate - fromDate
    return Math.floor(diff / 86400000)

# Helper to determine if a div has a scrollbar
do ($) ->
    $.fn.hasScrollBar = () ->
        hasScrollBar = {}
        e = this.get(0)
        hasScrollBar.vertical = e.scrollHeight > e.clientHeight
        hasScrollBar.horizontal = e.scrollWidth > e.clientWidth
        return hasScrollBar

# Initial Setup

# Register custom effects
$.Velocity.RegisterEffect("transition.cubeIn",
    defaultDuration: 1400
    calls: [
        [ { opacity: [ 1, 0 ], transformOriginX: [ "100%", "100%" ], transformOriginY: [ 0, 0 ], rotateX: [ 0, 180 ], rotateY: [0, 180] } ]
    ]
    reset: { transformOriginX: "50%", transformOriginY: "50%" }
)

# FastClick
$(() ->
    FastClick.attach(document.body);
)

$(() ->
    #============================================================
    # Constants
    #============================================================

    $about = $("#about")
    $wall = $about.find(".wall")
    $counter = $wall.children(".counter")
    $table = $about.find(".table")
    $shadow = $table.children(".shadow")
    $buttons = $counter.children(".portrait, .student, .hacker, .gamer")
    $contents = $counter.children(".content")
    $wrappers = $contents.children(".wrapper")

    #============================================================
    # Experience Page State
    #============================================================    

    # Current button that is selected
    $currentButton = $()
    # Whether user has clicked a button yet
    hasClicked = false
    # Array of timeout ids for the initial callouts
    calloutIDs = []

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
    # Content scrollbars
    #============================================================

    $wrappers.children(".text").children(".actual-text").each((index, text) ->
        $(text).perfectScrollbar(
            wheelPropagation: false
            swipePropagation: true
            suppressScrollX: true
        )
    )

    $wrappers.children(".text").children(".actual-text").resize(() ->
        $(this).perfectScrollbar("update")
    )

    #============================================================
    # Style content arrows
    #============================================================

    updateContentArrows = () ->
        $.each(["student", "hacker", "gamer"], (index, name) ->
            position = $counter.children(".#{name}").height() / 2
            $counter.children(".#{name}-content").children(".arrow").css("bottom", position)
        )

        position = $counter.children(".portrait").height() / 2
        $counter.children(".portrait-content").children(".arrow").css("top", position)

    #============================================================
    # Content sizing
    #============================================================    

    # HACKHACK for Chrome
    $contents.show().hide()

    # Update current content sizes
    updateContentSize = () ->
        $content = $currentButton.data("$content")
        $wrapper = $content.children(".wrapper")
        $text = $wrapper.children(".text")
        $actualText = $text.children(".actual-text").css("height", "auto")

        wallHeight = $wall.height() - 100
        textHeight = $text.height()

        $wrapper.children(".cancel").height(wallHeight * 0.09)
        $wrapper.children(".padding").height(wallHeight * 0.01)
        $actualText.height(Math.min(textHeight, wallHeight * 0.9))
        $actualText.perfectScrollbar("update")

    #============================================================
    # Content text shadows
    #============================================================

    # Update current content text shadows
    updateTextShadows = () ->
        $wrapperText = $currentButton.data("$content").children(".wrapper").children(".text")
        $text = $wrapperText.children(".actual-text")
        $fadeBefore = $wrapperText.children(".text-fade-before")
        $fadeAfter = $wrapperText.children(".text-fade-after")

        scrollTop = $text.scrollTop()
        scrollHeight = $text[0].scrollHeight

        if scrollTop > 5
            $fadeBefore.show()
        else
            $fadeBefore.hide()

        if $text.hasScrollBar().vertical and not (scrollHeight - scrollTop - $text.height() <= 1)
            $fadeAfter.show()
        else
            $fadeAfter.hide()

    #============================================================
    # Content API
    #============================================================

    # Preprocess to make runtime code simpler
    $.each(["portrait", "student", "hacker", "gamer"], (index, name) ->
        $button = $counter.children(".#{name}")
        $button.data("$others", $counter.children().filter(() ->
            return not ($(this).is($("#about .#{name}")) or $(this).hasClass("content"))
        ))
        $button.data("$content", $(".#{name}-content"))
    )

    selectContent = ($button) ->
        $buttons.addClass("disable")
        $button.data("$others").velocity("transition.fadeOut")
        $button.velocity({ left: "6%" }, 
            easing: "ease-in-out"
            complete: () ->
                $currentButton = $button
                $button.data("$content").show()
                updateContentSize()
                updateContentArrows()
                updateTextShadows()
                $button.data("$content").velocity("transition.fadeIn")
        )

    hideContent = () ->
        if $currentButton.length is 0 then return
        $currentButton.data("$content").velocity("stop").velocity("transition.fadeOut", 
            complete: () ->
                $currentButton.velocity("reverse", 
                    easing: "ease-in-out",
                    complete: () ->
                        $currentButton.data("$others").velocity("transition.fadeIn"
                            complete: () ->
                                $buttons.removeClass("disable")
                        )
                        $currentButton = $()
                )
        )

    #============================================================
    # Callout Eye Candy
    #============================================================

    setupCallouts = () ->
        if hasClicked then return
        $buttons.velocity("callout.swing", { stagger: 1000 })

    #============================================================
    # Event Handlers
    #============================================================    

    setupEventHandlers = () ->
        # Click buttons
        $buttons.click(() ->
            if not hasClicked
                hasClicked = true
                $buttons.velocity("stop", true).velocity({ rotateZ: 0 }, 200)
            selectContent($(this))
        )

        # Click cancel button on content wrapper
        $wrappers.children(".cancel").click(() ->
            hideContent()
        )

        # Resize event
        $window.resize(() ->
            if $currentButton.length isnt 0
                # Update content sizes, arrows, and text shadows if currently shown
                updateContentSize()
                updateContentArrows()
                updateTextShadows()
        )

        $wrappers.children(".text").children(".actual-text").scroll(updateTextShadows)

    #============================================================
    # Transition Eye Candy
    #============================================================

    
    animateIn = () ->
        $buttons.velocity("transition.slideDownIn", 
            stagger: 100
            drag: true
            complete: () ->
                setupCallouts()
                setupEventHandlers()
        )
    
    $about.data("transitionIn", animateIn)
)

$(() ->

    #============================================================
    # Constants
    #============================================================

    $contact = $("#contact")
    $github = $contact.find(".github img")
    $linkedin = $contact.find(".linkedin img")
    $resume = $contact.find(".resume img")
    $email = $contact.find(".email")

    #============================================================
    # Create email
    #============================================================

    email = "kevinDOTwuATberkeleyDOTedu".replace(/DOT/g, ".").replace(/AT/g, "@")
    $email.attr("href", "mailto:#{email}")
    $email.html(email)

    #============================================================
    # Source clicks
    #============================================================

    $github.click(() -> window.open("https://github.com/ImpGuard", "_blank"))
    $linkedin.click(() -> window.open("https://linkedin.com/in/impguard", "_blank"))
    $resume.click(() -> window.open("imgs/resume.pdf", "_blank"))

    #============================================================
    # Transition Eye Candy
    #============================================================

    $text = $contact.find(".title, .email")
    $icons = $contact.find(".github, .linkedin, .resume")
    animateIn = (waypoint) ->
        $text.velocity("transition.expandIn",
            complete: () ->
                $text.css("transform", "")
        )
        $icons.velocity("transition.shrinkIn", { display: "inline-block" })
    
    $contact.data("transitionIn", animateIn)
)
$window.load(() ->

    #============================================================
    # Constants
    #============================================================

    experienceData = window.exports.experience
    $experience = $("#experience")
    $container = $experience.children(".container")
    $timeline = $experience.find(".timeline")

    startDate = new Date("November 1 2012")
    endDate = new Date("June 1 2015")
    totalDays = Date.daysInBetween(startDate, endDate)

    # Fill in later
    langToColor = {
        "c++": 
            "primary": "#3FA9F5"
            "secondary": "#B2DDFB"
        "java":
            "primary": "#D10000"
            "secondary": "#FFE5E5"
        "python":
            "primary": "#FFD730"
            "secondary": "#FFFFE3"
        "cs":
            "primary": "#131226"
            "secondary": "#DFDEF2"
        "ts":
            "primary": "#0061C4"
            "secondary": "#E5FFFF"
        "js":
            "primary": "purple"
            "secondary": "gray"
        "less":
            "primary": "#16274C"
            "secondary": "#E2F3FF"
        "ux":
            "primary": "black"
            "secondary": "#E5E5E5"
        "ai":
            "primary": "#FF5C00"
            "secondary": "#FFFFE5"
        "eq":
            "primary": "#6B2886"
            "secondary": "#FFF4FF"
        "web":
            "primary": "#007E85"
            "secondary": "#E5FFFF"
        "misc.":
            "primary": "#6B3919"
            "secondary": "#FFECCC"
    }

    #============================================================
    # Experience Container Resize
    #============================================================

    containerMaxWidth = 1900

    resizeContainer = () ->
        if $window.width() >= containerMaxWidth
            $container.width(containerMaxWidth - 200)
        else
            $container.css({ width: "100%" })

    resizeContainer()
    $window.resize(resizeContainer)

    #============================================================
    # Experience Page State
    #============================================================

    # Current content being displayed
    $currentContent = $()
    $currentButton = $()

    #============================================================
    # Code dials
    #============================================================

    dialWidthRatio = 0.15
    dialHeightRatio = 0.9
    dialMaxSize = 200

    # Save global content with each breakdown
    $.each(experienceData, (index, item) -> 
        $("##{item.id}").data("breakdown", item.breakdown)
    )

    # Hide dial for a particular content
    hideCodeDials = ($content) ->
        $breakdown = $content.children(".breakdown")
        $breakdown.children(".block").css({ display: "none" })

    # Resize current content code dials
    resizeCodeDials = () ->
        $breakdown = $currentContent.children(".breakdown")
        dialSize = Math.min(dialMaxSize, dialHeightRatio * $breakdown.height(), dialWidthRatio * $breakdown.width())
        $breakdown.children(".block").width(dialSize).height(dialSize)
        $breakdown.children(".popup").children(".text").css({ bottom: dialSize / 2 })

    # Updates current content code dials, adding them if they don't exist
    updateCodeDials = () ->
        breakdown = $currentContent.data("breakdown")
        if not breakdown?
            return

        $breakdown = $currentContent.children(".breakdown")

        # Helper to animate dials
        showDials = () ->
            resizeCodeDials()
            $breakdown.children(".block").each((index, block) ->
                $block = $(block)
                dial = $block.data("dial")
                percent = $block.data("percent")

                dial.set(0)
                $block.velocity("fadeIn",
                    display: "inline-block"
                    complete: () ->
                        dial.animate(percent)
                )
            )

        # If dials already added, simply show them
        if $currentContent.data("hasDials")
            showDials()
            return

        # Create Dials
        dialSize = Math.min(dialMaxSize, dialHeightRatio * $breakdown.height(), dialWidthRatio * $breakdown.width())
        $.each(breakdown, (index, item) ->
            # Colors
            colors =langToColor[item.lang.toLowerCase()]

            # Create blocks
            $block = $("<div />").addClass("block").css(
                "display": "none"
                "width": dialSize
                "height": dialSize
            )

            # Create popup and expander
            $expander = $("<div >").addClass("expander")
            $popup = $("<div />").addClass("popup").append(
                $("<div />").addClass("text").html(item.content).css(
                    "border-color": colors.primary
                    "background-color": colors.secondary
                    "bottom": dialSize / 2
                ).append(
                    $("<div />").addClass("triangle-blank").css(
                        "border-right-color": colors.secondary
                    )
                )
            )

            # Create text
            $text = $("<div />").addClass("text").html(item.lang).append(
                $("<span />").addClass("percent").html("<br>#{item.percent}%")
            )
            $block.append($text)


            # Create dials
            dial = new ProgressBar.Circle($block[0],
                color: colors.primary
                strokeWidth: 5
                trailColor: colors.secondary
                trailWidth: 5
                fill: "white"
                easing: "bounce"
                duration: 2000
            )

            # Add hover event for block
            isLast = index is breakdown.length - 1
            $block.hover(
                () ->
                    popupFadeDelay = 0
                    if not isLast
                        $expander.velocity("stop").velocity({ width: "45%" }, 500, "ease-in-out")
                        popupFadeDelay = 300
                    $popup.velocity("stop").velocity("fadeIn",  
                        delay: popupFadeDelay
                        duration: 300 
                        display: "inline-block"
                    )
                () ->
                    if not isLast
                        $expander.velocity("stop").velocity({ width: "0" }, 500, "ease-in-out")
                    $popup.velocity("stop").velocity("fadeOut", 300)
            )

            # Save data for the dial
            $block.data("percent", item.percent / 100)
            $block.data("dial", dial)

            # Append
            $breakdown.append($block, $popup, $expander)
        )
        
        # Show dials
        showDials()

        # Note that dials have been added
        $currentContent.data("hasDials", true)

    #============================================================
    # Text content shadows
    #============================================================

    # Update current content text shadows
    updateTextShadows = () ->
        $wrapperText = $currentContent.children(".text")
        $text = $wrapperText.children(".actual-text")
        $fadeBefore = $wrapperText.children(".text-fade-before")
        $fadeAfter = $wrapperText.children(".text-fade-after")

        scrollTop = $text.scrollTop()
        scrollHeight = $text[0].scrollHeight

        if scrollTop > 5
            $fadeBefore.show()
        else
            $fadeBefore.hide()

        if $text.hasScrollBar().vertical and not (scrollHeight - scrollTop - $text.height() <= 1)
            $fadeAfter.show()
        else
            $fadeAfter.hide()

    #============================================================
    # Text Scrollbars
    #============================================================

    $experience.find(".content .text .actual-text").each((index, text) ->
        $(text).perfectScrollbar(
            wheelPropagation: false
            swipePropagation: true
            suppressScrollX: true
        )
    )

    $experience.find(".content .text .actual-text").resize(() ->
        $(this).perfectScrollbar("update")
    )

    #============================================================
    # Timeline Buttons
    #============================================================

    # Construct buttons on load
    colors = ["black", "white"]
    colorChoice = 0
    $.each(experienceData, (index, item) ->
        # Calculate position and height
        height = (item.duration + 1) * 30 / totalDays * 100
        position = (Date.daysInBetween(startDate, new Date(item.endDate)) - item.duration * 30) / totalDays * 100

        # Color choice
        color = colors[colorChoice++]
        colorChoice %= 2

        imageSRC = ""
        if (item.type is "project")
            imageSRC = "imgs/project-#{colors[colorChoice]}.svg"
        else
            imageSRC = "imgs/internship-#{colors[colorChoice]}.svg"

        # Create individual elements
        $connector = $("<div />")
            .addClass("connector")
            .css("background-color", color)
        $button = $("<div />")
            .addClass("button")
            .css({ "background-color": color, "border-color": color })
            .append(
                $("<div />").addClass("name").html(item.name).css("color", colors[colorChoice])
                $("<img />").addClass(item.type).attr({ src: imageSRC, alt: item.type })
            )
        $extension = $("<div />")
            .addClass("extension")
            .append($connector, $button)

        $item = $("<div />")
            .addClass("item")
            .append($extension)
            .css(
                "bottom": "#{position}%" 
                "height": "#{height}%" 
                "background-color": color
            )

        # Save data
        $button.data("id", item.id)
        $button.data("$item", $item)
        $button.data("color", color)

        $item.appendTo($timeline)
    )

    #============================================================
    # Timline content API
    #============================================================

    # Click functionality
    animateInContent = () ->
        $currentContent.css("display", "block")
        updateTextShadows()
        $currentContent.velocity("stop").velocity("transition.slideRightBigIn", 
            duration: 600
            complete: () ->
                $currentContent.css("transform", "none")
                updateCodeDials()
        )

    switchToItem = (id) ->
        $nextContent = $experience.find("##{id}")

        if $currentContent.length is 0
            $currentContent = $nextContent
            animateInContent($nextContent)
            return


        $currentContent.velocity("stop").velocity("transition.slideRightBigOut",
            duration: 600
            complete: () ->
                hideCodeDials($currentContent)
                $currentContent = $nextContent
                animateInContent()
        )

    #============================================================
    # Event Handlers
    #============================================================

    $buttons = $experience.find(".timeline .item .button")
    originalButtonWidth = $buttons.width()

    # Helper to set the color of an item
    selectedColor = "#FF7F35"
    setItemColor = ($item, color) ->
        $item.css("background-color", color)
        $item.find(".connector").css("background-color", color)
        $item.find(".button").css("border-color", color)

    setupEventHandlers = () ->
        # Button clicks
        $buttons.click(() ->
            if $currentButton.length != 0
                $currentButton.removeClass("selected")
                setItemColor($currentButton.data("$item"), $currentButton.data("color"))

            $currentButton = $(this)
            $currentButton.addClass("selected")
            setItemColor($currentButton.data("$item"), selectedColor)
            switchToItem($currentButton.data("id"))
        )

        # Text shadows
        $window.resize(() ->
            updateTextShadows()
        )

        $experience.find(".content .text .actual-text").scroll(updateTextShadows)

        # Code dials
        $window.resize(resizeCodeDials)

    #============================================================
    # Transition Eye Candy
    #============================================================

    $items = $timeline.find(".item")
    $extensions = $timeline.find(".extension")
    animateIn = (waypoint) ->
        switchToItem("introduction")
        $timeline.velocity("transition.slideLeftIn", 500, () ->
            $items.velocity("transition.fadeIn", { stagger: 60, drag: true, complete: () ->
                $extensions.velocity("transition.flipYIn", { stagger: 60, drag: true, complete: () ->
                    setupEventHandlers()
                })
            })
        )
    
    $experience.data("transitionIn", animateIn)
)
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
$(() ->

    #============================================================
    # Constants
    #============================================================

    $home = $("#home")

    #============================================================
    # Vivus
    #============================================================

    vivus = new Vivus("kevin", 
        type: "delayed"
        duration: 200
        delay: 100
        start: "manual"
    )

    #============================================================
    # Transition Eye Candy
    #============================================================
    
    animateIn = () ->
        vivus.play(1)
    
    $home.data("transitionIn", animateIn)
)
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
