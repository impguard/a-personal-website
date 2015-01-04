$(() ->

    #============================================================
    # Constants
    #============================================================

    $home = $("#home")
    $window = $(window)
    $backgroundBlur = $home.find(".background-blur")
    maxPercentage = 15

    #============================================================
    # Parallax Effect
    #============================================================

    getPercentage = () ->
        return ($window.scrollTop() / $home.height()) * 100

    applyBlur = (check = true) ->
        blurAmount = getPercentage() / maxPercentage
        $backgroundBlur.css("opacity", blurAmount)

    $(window).scroll(applyBlur)
    $(window).resize(applyBlur)
)