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

        # Magic number to account for padding
        counterHeight = $counter.height() - 95
        textHeight = $text.height()

        console.log counterHeight

        $wrapper.children(".cancel").height(counterHeight * 0.09)
        $wrapper.children(".padding").height(counterHeight * 0.01)
        $actualText.height(Math.min(textHeight, counterHeight * 0.9))
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
