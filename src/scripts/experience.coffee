$(window).load(() ->
    #============================================================
    # Helper functions
    #============================================================

    # Helper to calculate days in between two dates
    Date.daysInBetween = (fromDate, toDate) ->
        diff = toDate - fromDate
        return Math.floor(diff / 86400000)

    #============================================================
    # Constants
    #============================================================

    $experience = $("#experience")
    $timeline = $experience.find(".timeline")

    startDate = new Date("June 2010")
    endDate = new Date("June 2015")
    totalDays = Date.daysInBetween(startDate, endDate)

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
    $buttons.click(() ->
        $button = $(this)
        $experience.find(".#{$button.data("id")}").addClass("selected")
    )

    

)