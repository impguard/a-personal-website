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