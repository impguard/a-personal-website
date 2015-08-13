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

    email = "contactATkevinwuDOTio".replace(/DOT/g, ".").replace(/AT/g, "@")
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
