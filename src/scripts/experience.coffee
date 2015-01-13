$window.load(() ->

    #============================================================
    # Constants
    #============================================================

    $experience = $("#experience")
    $timeline = $experience.find(".timeline")

    startDate = new Date("June 1 2010")
    endDate = new Date("June 1 2015")
    totalDays = Date.daysInBetween(startDate, endDate)

    # Fill in later
    langToColor = {
        "c++": 
            "secondary": "gray"
            "primary": "black"
        "java":
            "secondary": "gray"
            "primary": "orange"
        "ts":
            "secondary": "gray"
            "primary": "red"
        "js":
            "secondary": "gray"
            "primary": "purple"
    }

    #============================================================
    # Experience Page State
    #============================================================    

    # Current content being displayed
    $currentContent = $()

    #============================================================
    # Code dials
    #============================================================

    dialHeightRatio = 0.9

    $.each(window.exports.experience, (index, item) -> 
        $("##{item.id}").data("breakdown", item.breakdown)
    )

    resizeCodeDials = () ->
        $breakdown = $currentContent.children(".breakdown")
        dialSize = dialHeightRatio * $breakdown.height()
        $breakdown.children(".block").width(dialSize).height(dialSize)

    updateCodeDials = () ->
        breakdown = $currentContent.data("breakdown")
        if not breakdown?
            return

        $breakdown = $currentContent.children(".breakdown")
        if $currentContent.data("hasDials")
            $breakdown.children(".block").each((index, block) ->
                $block = $(block)
                dial = $block.data("dial")
                percent = $block.data("percent")

                dial.set(0)
                dial.animate($block.data("percent"))
            )
            return

        dialSize = dialHeightRatio * $breakdown.height()

        $.each(breakdown, (index, item) ->
            # Colors
            colors =langToColor[item.lang.toLowerCase()]

            # Create blocks
            $block = $("<div />").addClass("block").css(
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
                        $expander.velocity("stop").velocity({ width: "40%" }, 500, "ease-in-out")
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

            # Append and animate
            $breakdown.append($block, $popup, $expander)
            dial.animate($block.data("percent"))
        )

        # Save data for content
        $currentContent.data("hasDials", true)

    $window.resize(resizeCodeDials)

    #============================================================
    # Text content shadows
    #============================================================

    updateTextShadows = () ->
        $text = $currentContent.children(".text")
        $fadeBefore = $text.children(".text-fade-before")
        $fadeAfter = $text.children(".text-fade-after")

        scrollTop = $text.scrollTop()
        scrollHeight = $text[0].scrollHeight

        $fadeAfter.css("top", scrollTop)
        $fadeBefore.css("top", scrollTop)

        if scrollTop > 5
            $fadeBefore.show()
        else
            $fadeBefore.hide()

        if $text.hasScrollBar().vertical and not (scrollHeight - scrollTop - $text.height() <= 1)
            $fadeAfter.show()
        else
            $fadeAfter.hide()

    $window.resize(() ->
        updateTextShadows()
    )

    $experience.find(".content .text").scroll(updateTextShadows)

    #============================================================
    # Text Scrollbars
    #============================================================

    $experience.find(".content .text").each((index, text) ->
        $(text).perfectScrollbar(
            wheelPropagation: false
            swipPropagation: false
        )
    ) 

    #============================================================
    # Timeline Buttons
    #============================================================

    # Construct buttons on load
    colors = ["black", "white"]
    colorChoice = 0
    $.each(window.exports.experience, (index, item) ->
        # Calculate position and height
        height = item.duration * 30 / totalDays * 100
        position = Date.daysInBetween(startDate, new Date(item.endDate)) / totalDays * 100 - height / 2

        # Color choice
        color = colors[colorChoice++]
        colorChoice %= 2

        imageSRC = ""
        if (item.type is "project")
            imageSRC = "imgs/project-#{colors[colorChoice]}.svg"
        else
            imageSRC = "imgs/internship-#{colors[colorChoice]}.svg"

        # Create individual elements
        $duration = $("<div />").addClass("duration").css("background-color", color)
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
            .data("id", item.id)

        $item = $("<div />")
            .addClass("item")
            .append($duration, $connector, $button)
            .css({ top: "#{position}%", height: "#{height}%" })

        $item.appendTo($timeline)
    )

    $buttons = $experience.find(".timeline .item .button")
    originalButtonWidth = $buttons.width()

    # Save width of each button
    $buttons.each(() ->
        $button = $(this)
        $button.data("expandedWidth", $button.children(".name").outerWidth() + originalButtonWidth)
    )

    # Hover functionality
    $buttons.hover(
        () ->
            $button = $(this)
            $name = $button.children(".name")
            $button.velocity("stop").velocity({ width: $button.data("expandedWidth") }, 200)
            $name.velocity("stop").velocity("fadeIn", { delay: 100, duration: 200 })
        () ->
            $button = $(this)
            $name = $button.children(".name")
            $button.velocity("stop").velocity({ width: originalButtonWidth }, 200)
            $name.velocity("stop").velocity("fadeOut", { duration: 100 })
    )

    # Click functionality
    switchToItem = (id) ->
        $nextContent = $experience.find("##{id}")
        $currentContent.removeClass("selected")
        $nextContent.addClass("selected")
        $currentContent = $nextContent
        updateTextShadows()
        updateCodeDials()

    switchToItem("introduction")

    $buttons.click(() ->
        $button = $(this)
        switchToItem($(this).data("id"))
    )

    #============================================================
    # Transition Eye Candy
    #============================================================

    animateIn = () ->
        console.log("in")
    
    $experience.data("waypointIn", animateIn)
)