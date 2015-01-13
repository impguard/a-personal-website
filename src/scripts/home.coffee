$(() ->

    #============================================================
    # Constants
    #============================================================

    $home = $("#home")
    $backgroundBlur = $home.find(".background-blur")
    maxPercentage = 35

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