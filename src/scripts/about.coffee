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

    #============================================================
    # Experience Page State
    #============================================================    

    # Current button that is selected
    $currentButton = $()

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
    # Style content arrows
    #============================================================

    styleContentArrows = () ->
        $.each(["student", "hacker", "gamer"], (index, name) ->
            position = $counter.children(".#{name}").height() / 2
            $counter.children(".#{name}-content").children(".arrow").css("bottom", position)
        )

        position = $counter.children(".portrait").height() / 2
        $counter.children(".portrait-content").children(".arrow").css("top", position)

    #============================================================
    # Content scrollbars
    #============================================================

    $contents.children(".text").children(".actual-text").each((index, text) ->
        $(text).perfectScrollbar(
            wheelPropagation: false
            swipePropagation: true
            suppressScrollX: true
        )
    )

    $contents.children(".text").children(".actual-text").resize(() ->
        $(this).perfectScrollbar("update")
    )

    #============================================================
    # Content text shadows
    #============================================================

    # Update current content text shadows
    updateTextShadows = () ->
        $wrapperText = $currentButton.data("$content").children(".text")
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
                $button.data("$content").css("display", "block")
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
    # Event Handlers
    #============================================================    

    setupEventHandlers = () ->
        # Click buttons
        $buttons.click(() ->
            selectContent($(this))
        )

        # Click cancel button on content
        $contents.children(".cancel").click(() ->
            hideContent()
        )

        # Text shadows
        $window.resize(() ->
            if $currentButton.length isnt 0
                updateTextShadows()
        )

        $counter.children(".content").children(".text").children(".actual-text").scroll(updateTextShadows)

        

    #============================================================
    # Transition Eye Candy
    #============================================================

    
    animateIn = () ->
        $buttons.velocity("transition.slideDownIn", 
            stagger: 100
            drag: true
            complete: () ->
                styleContentArrows()
                setupEventHandlers()
        )

    
    $about.data("transitionIn", animateIn)
)
