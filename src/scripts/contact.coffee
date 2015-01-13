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
    # $resume.click()
)