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
                "top": "#{position}%" 
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