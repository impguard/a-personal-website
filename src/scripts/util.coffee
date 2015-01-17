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
