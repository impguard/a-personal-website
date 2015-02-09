(function() {
  var $window;

  $window = $(window);

  Date.daysInBetween = function(fromDate, toDate) {
    var diff;
    diff = toDate - fromDate;
    return Math.floor(diff / 86400000);
  };

  (function($) {
    return $.fn.hasScrollBar = function() {
      var e, hasScrollBar;
      hasScrollBar = {};
      e = this.get(0);
      hasScrollBar.vertical = e.scrollHeight > e.clientHeight;
      hasScrollBar.horizontal = e.scrollWidth > e.clientWidth;
      return hasScrollBar;
    };
  })($);

  $.Velocity.RegisterEffect("transition.cubeIn", {
    defaultDuration: 1400,
    calls: [
      [
        {
          opacity: [1, 0],
          transformOriginX: ["100%", "100%"],
          transformOriginY: [0, 0],
          rotateX: [0, 180],
          rotateY: [0, 180]
        }
      ]
    ],
    reset: {
      transformOriginX: "50%",
      transformOriginY: "50%"
    }
  });

  $(function() {
    return FastClick.attach(document.body);
  });

  $(function() {
    var $about, $buttons, $contents, $counter, $currentButton, $shadow, $table, $wall, $wrappers, animateIn, calloutIDs, hasClicked, hideContent, resizeCounter, resizeTableShadow, selectContent, setupCallouts, setupEventHandlers, updateContentArrows, updateContentSize, updateTextShadows;
    $about = $("#about");
    $wall = $about.find(".wall");
    $counter = $wall.children(".counter");
    $table = $about.find(".table");
    $shadow = $table.children(".shadow");
    $buttons = $counter.children(".portrait, .student, .hacker, .gamer");
    $contents = $counter.children(".content");
    $wrappers = $contents.children(".wrapper");
    $currentButton = $();
    hasClicked = false;
    calloutIDs = [];
    resizeCounter = function() {
      var width;
      width = Math.min(3 * $wall.height(), $wall.width());
      return $counter.width(width).height(width / 3);
    };
    resizeCounter();
    $window.resize(resizeCounter);
    resizeTableShadow = function() {
      return $shadow.css({
        transform: "skewX(45deg) translateX(" + ($shadow.height() / 2) + "px)"
      });
    };
    resizeTableShadow();
    $window.resize(resizeTableShadow);
    $wrappers.children(".text").children(".actual-text").each(function(index, text) {
      return $(text).perfectScrollbar({
        wheelPropagation: false,
        swipePropagation: true,
        suppressScrollX: true
      });
    });
    $wrappers.children(".text").children(".actual-text").resize(function() {
      return $(this).perfectScrollbar("update");
    });
    updateContentArrows = function() {
      var position;
      $.each(["student", "hacker", "gamer"], function(index, name) {
        var position;
        position = $counter.children("." + name).height() / 2;
        return $counter.children("." + name + "-content").children(".arrow").css("bottom", position);
      });
      position = $counter.children(".portrait").height() / 2;
      return $counter.children(".portrait-content").children(".arrow").css("top", position);
    };
    $contents.show().hide();
    updateContentSize = function() {
      var $actualText, $content, $text, $wrapper, counterHeight, textHeight;
      $content = $currentButton.data("$content");
      $wrapper = $content.children(".wrapper");
      $text = $wrapper.children(".text");
      $actualText = $text.children(".actual-text").css("height", "auto");
      counterHeight = $counter.height() - 95;
      textHeight = $text.height();
      console.log(counterHeight);
      $wrapper.children(".cancel").height(counterHeight * 0.09);
      $wrapper.children(".padding").height(counterHeight * 0.01);
      $actualText.height(Math.min(textHeight, counterHeight * 0.9));
      return $actualText.perfectScrollbar("update");
    };
    updateTextShadows = function() {
      var $fadeAfter, $fadeBefore, $text, $wrapperText, scrollHeight, scrollTop;
      $wrapperText = $currentButton.data("$content").children(".wrapper").children(".text");
      $text = $wrapperText.children(".actual-text");
      $fadeBefore = $wrapperText.children(".text-fade-before");
      $fadeAfter = $wrapperText.children(".text-fade-after");
      scrollTop = $text.scrollTop();
      scrollHeight = $text[0].scrollHeight;
      if (scrollTop > 5) {
        $fadeBefore.show();
      } else {
        $fadeBefore.hide();
      }
      if ($text.hasScrollBar().vertical && !(scrollHeight - scrollTop - $text.height() <= 1)) {
        return $fadeAfter.show();
      } else {
        return $fadeAfter.hide();
      }
    };
    $.each(["portrait", "student", "hacker", "gamer"], function(index, name) {
      var $button;
      $button = $counter.children("." + name);
      $button.data("$others", $counter.children().filter(function() {
        return !($(this).is($("#about ." + name)) || $(this).hasClass("content"));
      }));
      return $button.data("$content", $("." + name + "-content"));
    });
    selectContent = function($button) {
      $buttons.addClass("disable");
      $button.data("$others").velocity("transition.fadeOut");
      return $button.velocity({
        left: "6%"
      }, {
        easing: "ease-in-out",
        complete: function() {
          $currentButton = $button;
          $button.data("$content").show();
          updateContentSize();
          updateContentArrows();
          updateTextShadows();
          return $button.data("$content").velocity("transition.fadeIn");
        }
      });
    };
    hideContent = function() {
      if ($currentButton.length === 0) {
        return;
      }
      return $currentButton.data("$content").velocity("stop").velocity("transition.fadeOut", {
        complete: function() {
          return $currentButton.velocity("reverse", {
            easing: "ease-in-out",
            complete: function() {
              $currentButton.data("$others").velocity("transition.fadeIn", {
                complete: function() {
                  return $buttons.removeClass("disable");
                }
              });
              return $currentButton = $();
            }
          });
        }
      });
    };
    setupCallouts = function() {
      if (hasClicked) {
        return;
      }
      return $buttons.velocity("callout.swing", {
        stagger: 1000
      });
    };
    setupEventHandlers = function() {
      $buttons.click(function() {
        if (!hasClicked) {
          hasClicked = true;
          $buttons.velocity("stop", true).velocity({
            rotateZ: 0
          }, 200);
        }
        return selectContent($(this));
      });
      $wrappers.children(".cancel").click(function() {
        return hideContent();
      });
      $window.resize(function() {
        if ($currentButton.length !== 0) {
          updateContentSize();
          updateContentArrows();
          return updateTextShadows();
        }
      });
      return $wrappers.children(".text").children(".actual-text").scroll(updateTextShadows);
    };
    animateIn = function() {
      return $buttons.velocity("transition.slideDownIn", {
        stagger: 100,
        drag: true,
        complete: function() {
          setupCallouts();
          return setupEventHandlers();
        }
      });
    };
    return $about.data("transitionIn", animateIn);
  });

  $(function() {
    var $contact, $email, $github, $icons, $linkedin, $resume, $text, animateIn, email;
    $contact = $("#contact");
    $github = $contact.find(".github img");
    $linkedin = $contact.find(".linkedin img");
    $resume = $contact.find(".resume img");
    $email = $contact.find(".email");
    email = "kevinDOTwuATberkeleyDOTedu".replace(/DOT/g, ".").replace(/AT/g, "@");
    $email.attr("href", "mailto:" + email);
    $email.html(email);
    $github.click(function() {
      return window.open("https://github.com/ImpGuard", "_blank");
    });
    $linkedin.click(function() {
      return window.open("https://linkedin.com/in/impguard", "_blank");
    });
    $resume.click(function() {
      return window.open("imgs/resume.pdf", "_blank");
    });
    $text = $contact.find(".title, .email");
    $icons = $contact.find(".github, .linkedin, .resume");
    animateIn = function(waypoint) {
      $text.velocity("transition.expandIn", {
        complete: function() {
          return $text.css("transform", "");
        }
      });
      return $icons.velocity("transition.shrinkIn", {
        display: "inline-block"
      });
    };
    return $contact.data("transitionIn", animateIn);
  });

  $window.load(function() {
    var $buttons, $container, $currentButton, $currentContent, $experience, $extensions, $items, $timeline, animateIn, animateInContent, colorChoice, colors, containerMaxWidth, dialHeightRatio, dialMaxSize, dialWidthRatio, endDate, experienceData, hideCodeDials, langToColor, originalButtonWidth, resizeCodeDials, resizeContainer, selectedColor, setItemColor, setupEventHandlers, startDate, switchToItem, totalDays, updateCodeDials, updateTextShadows;
    experienceData = window.exports.experience;
    $experience = $("#experience");
    $container = $experience.children(".container");
    $timeline = $experience.find(".timeline");
    startDate = new Date("November 1 2012");
    endDate = new Date("June 1 2015");
    totalDays = Date.daysInBetween(startDate, endDate);
    langToColor = {
      "c++": {
        "primary": "#3FA9F5",
        "secondary": "#B2DDFB"
      },
      "java": {
        "primary": "#D10000",
        "secondary": "#FFE5E5"
      },
      "python": {
        "primary": "#FFD730",
        "secondary": "#FFFFE3"
      },
      "cs": {
        "primary": "#131226",
        "secondary": "#DFDEF2"
      },
      "ts": {
        "primary": "#0061C4",
        "secondary": "#E5FFFF"
      },
      "js": {
        "primary": "purple",
        "secondary": "gray"
      },
      "less": {
        "primary": "#16274C",
        "secondary": "#E2F3FF"
      },
      "ux": {
        "primary": "black",
        "secondary": "#E5E5E5"
      },
      "ai": {
        "primary": "#FF5C00",
        "secondary": "#FFFFE5"
      },
      "eq": {
        "primary": "#6B2886",
        "secondary": "#FFF4FF"
      },
      "web": {
        "primary": "#007E85",
        "secondary": "#E5FFFF"
      },
      "misc.": {
        "primary": "#6B3919",
        "secondary": "#FFECCC"
      }
    };
    containerMaxWidth = 1900;
    resizeContainer = function() {
      if ($window.width() >= containerMaxWidth) {
        return $container.width(containerMaxWidth - 200);
      } else {
        return $container.css({
          width: "100%"
        });
      }
    };
    resizeContainer();
    $window.resize(resizeContainer);
    $currentContent = $();
    $currentButton = $();
    dialWidthRatio = 0.15;
    dialHeightRatio = 0.9;
    dialMaxSize = 200;
    $.each(experienceData, function(index, item) {
      return $("#" + item.id).data("breakdown", item.breakdown);
    });
    hideCodeDials = function($content) {
      var $breakdown;
      $breakdown = $content.children(".breakdown");
      return $breakdown.children(".block").css({
        display: "none"
      });
    };
    resizeCodeDials = function() {
      var $breakdown, dialSize;
      $breakdown = $currentContent.children(".breakdown");
      dialSize = Math.min(dialMaxSize, dialHeightRatio * $breakdown.height(), dialWidthRatio * $breakdown.width());
      $breakdown.children(".block").width(dialSize).height(dialSize);
      return $breakdown.children(".popup").children(".text").css({
        bottom: dialSize / 2
      });
    };
    updateCodeDials = function() {
      var $breakdown, breakdown, dialSize, showDials;
      breakdown = $currentContent.data("breakdown");
      if (breakdown == null) {
        return;
      }
      $breakdown = $currentContent.children(".breakdown");
      showDials = function() {
        resizeCodeDials();
        return $breakdown.children(".block").each(function(index, block) {
          var $block, dial, percent;
          $block = $(block);
          dial = $block.data("dial");
          percent = $block.data("percent");
          dial.set(0);
          return $block.velocity("fadeIn", {
            display: "inline-block",
            complete: function() {
              return dial.animate(percent);
            }
          });
        });
      };
      if ($currentContent.data("hasDials")) {
        showDials();
        return;
      }
      dialSize = Math.min(dialMaxSize, dialHeightRatio * $breakdown.height(), dialWidthRatio * $breakdown.width());
      $.each(breakdown, function(index, item) {
        var $block, $expander, $popup, $text, colors, dial, isLast;
        colors = langToColor[item.lang.toLowerCase()];
        $block = $("<div />").addClass("block").css({
          "display": "none",
          "width": dialSize,
          "height": dialSize
        });
        $expander = $("<div >").addClass("expander");
        $popup = $("<div />").addClass("popup").append($("<div />").addClass("text").html(item.content).css({
          "border-color": colors.primary,
          "background-color": colors.secondary,
          "bottom": dialSize / 2
        }).append($("<div />").addClass("triangle-blank").css({
          "border-right-color": colors.secondary
        })));
        $text = $("<div />").addClass("text").html(item.lang).append($("<span />").addClass("percent").html("<br>" + item.percent + "%"));
        $block.append($text);
        dial = new ProgressBar.Circle($block[0], {
          color: colors.primary,
          strokeWidth: 5,
          trailColor: colors.secondary,
          trailWidth: 5,
          fill: "white",
          easing: "bounce",
          duration: 2000
        });
        isLast = index === breakdown.length - 1;
        $block.hover(function() {
          var popupFadeDelay;
          popupFadeDelay = 0;
          if (!isLast) {
            $expander.velocity("stop").velocity({
              width: "45%"
            }, 500, "ease-in-out");
            popupFadeDelay = 300;
          }
          return $popup.velocity("stop").velocity("fadeIn", {
            delay: popupFadeDelay,
            duration: 300,
            display: "inline-block"
          });
        }, function() {
          if (!isLast) {
            $expander.velocity("stop").velocity({
              width: "0"
            }, 500, "ease-in-out");
          }
          return $popup.velocity("stop").velocity("fadeOut", 300);
        });
        $block.data("percent", item.percent / 100);
        $block.data("dial", dial);
        return $breakdown.append($block, $popup, $expander);
      });
      showDials();
      return $currentContent.data("hasDials", true);
    };
    updateTextShadows = function() {
      var $fadeAfter, $fadeBefore, $text, $wrapperText, scrollHeight, scrollTop;
      $wrapperText = $currentContent.children(".text");
      $text = $wrapperText.children(".actual-text");
      $fadeBefore = $wrapperText.children(".text-fade-before");
      $fadeAfter = $wrapperText.children(".text-fade-after");
      scrollTop = $text.scrollTop();
      scrollHeight = $text[0].scrollHeight;
      if (scrollTop > 5) {
        $fadeBefore.show();
      } else {
        $fadeBefore.hide();
      }
      if ($text.hasScrollBar().vertical && !(scrollHeight - scrollTop - $text.height() <= 1)) {
        return $fadeAfter.show();
      } else {
        return $fadeAfter.hide();
      }
    };
    $experience.find(".content .text .actual-text").each(function(index, text) {
      return $(text).perfectScrollbar({
        wheelPropagation: false,
        swipePropagation: true,
        suppressScrollX: true
      });
    });
    $experience.find(".content .text .actual-text").resize(function() {
      return $(this).perfectScrollbar("update");
    });
    colors = ["black", "white"];
    colorChoice = 0;
    $.each(experienceData, function(index, item) {
      var $button, $connector, $extension, $item, color, height, imageSRC, position;
      height = (item.duration + 1) * 30 / totalDays * 100;
      position = (Date.daysInBetween(startDate, new Date(item.endDate)) - item.duration * 30) / totalDays * 100;
      color = colors[colorChoice++];
      colorChoice %= 2;
      imageSRC = "";
      if (item.type === "project") {
        imageSRC = "imgs/project-" + colors[colorChoice] + ".svg";
      } else {
        imageSRC = "imgs/internship-" + colors[colorChoice] + ".svg";
      }
      $connector = $("<div />").addClass("connector").css("background-color", color);
      $button = $("<div />").addClass("button").css({
        "background-color": color,
        "border-color": color
      }).append($("<div />").addClass("name").html(item.name).css("color", colors[colorChoice]), $("<img />").addClass(item.type).attr({
        src: imageSRC,
        alt: item.type
      }));
      $extension = $("<div />").addClass("extension").append($connector, $button);
      $item = $("<div />").addClass("item").append($extension).css({
        "bottom": "" + position + "%",
        "height": "" + height + "%",
        "background-color": color
      });
      $button.data("id", item.id);
      $button.data("$item", $item);
      $button.data("color", color);
      return $item.appendTo($timeline);
    });
    animateInContent = function() {
      $currentContent.css("display", "block");
      updateTextShadows();
      return $currentContent.velocity("stop").velocity("transition.slideRightBigIn", {
        duration: 600,
        complete: function() {
          $currentContent.css("transform", "none");
          return updateCodeDials();
        }
      });
    };
    switchToItem = function(id) {
      var $nextContent;
      $nextContent = $experience.find("#" + id);
      if ($currentContent.length === 0) {
        $currentContent = $nextContent;
        animateInContent($nextContent);
        return;
      }
      return $currentContent.velocity("stop").velocity("transition.slideRightBigOut", {
        duration: 600,
        complete: function() {
          hideCodeDials($currentContent);
          $currentContent = $nextContent;
          return animateInContent();
        }
      });
    };
    $buttons = $experience.find(".timeline .item .button");
    originalButtonWidth = $buttons.width();
    selectedColor = "#FF7F35";
    setItemColor = function($item, color) {
      $item.css("background-color", color);
      $item.find(".connector").css("background-color", color);
      return $item.find(".button").css("border-color", color);
    };
    setupEventHandlers = function() {
      $buttons.click(function() {
        if ($currentButton.length !== 0) {
          $currentButton.removeClass("selected");
          setItemColor($currentButton.data("$item"), $currentButton.data("color"));
        }
        $currentButton = $(this);
        $currentButton.addClass("selected");
        setItemColor($currentButton.data("$item"), selectedColor);
        return switchToItem($currentButton.data("id"));
      });
      $window.resize(function() {
        return updateTextShadows();
      });
      $experience.find(".content .text .actual-text").scroll(updateTextShadows);
      return $window.resize(resizeCodeDials);
    };
    $items = $timeline.find(".item");
    $extensions = $timeline.find(".extension");
    animateIn = function(waypoint) {
      switchToItem("introduction");
      return $timeline.velocity("transition.slideLeftIn", 500, function() {
        return $items.velocity("transition.fadeIn", {
          stagger: 60,
          drag: true,
          complete: function() {
            return $extensions.velocity("transition.flipYIn", {
              stagger: 60,
              drag: true,
              complete: function() {
                return setupEventHandlers();
              }
            });
          }
        });
      });
    };
    return $experience.data("transitionIn", animateIn);
  });

  $(function() {
    var $arrows, $carousel, $container, $cube, $dot, $dots, $faces, $hobbies, $next, $prev, $title, animateIn, autorotateIntervalID, createEventHandlers, currFace, currHobbyDot, hobbiesData, imgFolder, initializeAutoselection, initializeHobbies, numberOfDots, randomizeFace, resizeContainer, resizeCube, resizeDots, selectDot, selectHobby, switchToFace, toggleDot, updateTitle;
    hobbiesData = window.exports.hobbies;
    $hobbies = $("#hobbies");
    $container = $hobbies.children(".container");
    $carousel = $container.children(".carousel");
    $cube = $carousel.children(".cube");
    $faces = [$cube.children(".front"), $cube.children(".back"), $cube.children(".right"), $cube.children(".left"), $cube.children(".top"), $cube.children(".bottom")];
    $dots = $container.find(".dots");
    $title = $container.children(".title");
    $prev = $carousel.children(".prev");
    $next = $carousel.children(".next");
    currHobbyDot = 0;
    currFace = 0;
    autorotateIntervalID = 0;
    resizeContainer = function() {
      return $container.width(Math.min($hobbies.height(), $hobbies.width() * 0.95));
    };
    $window.resize(resizeContainer);
    resizeContainer();
    switchToFace = function(transitionTime) {
      if (transitionTime == null) {
        transitionTime = 750;
      }
      return $cube.velocity("stop").velocity($faces[currFace].data("transition"), transitionTime, "ease-in-out");
    };
    resizeCube = function() {
      var translation;
      translation = $cube.outerWidth() / 2;
      $faces[0].css({
        transform: "translateZ(" + translation + "px)"
      });
      $faces[1].css({
        transform: "rotateX(180deg) translateZ(" + translation + "px)"
      });
      $faces[2].css({
        transform: "rotateY(90deg) translateZ(" + translation + "px)"
      });
      $faces[3].css({
        transform: "rotateY(-90deg) translateZ(" + translation + "px)"
      });
      $faces[4].css({
        transform: "rotateX(90deg) translateZ(" + translation + "px)"
      });
      $faces[5].css({
        transform: "rotateX(-90deg) translateZ(" + translation + "px)"
      });
      $faces[0].data("transition", {
        translateZ: "-" + translation + "px",
        rotateX: "0deg",
        rotateY: "0deg",
        rotateZ: "0deg"
      });
      $faces[1].data("transition", {
        translateZ: "-" + translation + "px",
        rotateX: "-180deg",
        rotateY: "0deg",
        rotateZ: "0deg"
      });
      $faces[2].data("transition", {
        translateZ: "-" + translation + "px",
        rotateX: "0deg",
        rotateY: "-90deg",
        rotateZ: "0deg"
      });
      $faces[3].data("transition", {
        translateZ: "-" + translation + "px",
        rotateX: "0deg",
        rotateY: "90deg",
        rotateZ: "0deg"
      });
      $faces[4].data("transition", {
        translateZ: "-" + translation + "px",
        rotateX: "-90deg",
        rotateY: "0deg",
        rotateZ: "0deg"
      });
      $faces[5].data("transition", {
        translateZ: "-" + translation + "px",
        rotateX: "90deg",
        rotateY: "0deg",
        rotateZ: "0deg"
      });
      return switchToFace(0);
    };
    $window.resize(resizeCube);
    resizeCube();
    $carousel.waypoint(function(direction) {
      if (direction === "up") {
        return $carousel.css("z-index", 2);
      } else {
        return $carousel.css("z-index", 0);
      }
    }, {
      offset: 85
    });
    numberOfDots = hobbiesData.length;
    (function() {
      var _, _i, _results;
      _results = [];
      for (_ = _i = 1; 1 <= numberOfDots ? _i <= numberOfDots : _i >= numberOfDots; _ = 1 <= numberOfDots ? ++_i : --_i) {
        _results.push($dots.append($("<div>").addClass("dot")));
      }
      return _results;
    })();
    resizeDots = function() {
      var diameter, dotCSS, dotsWidth;
      diameter = Math.round(Math.min(20, Math.max(10, 0.4 * $dots.height())));
      dotCSS = {
        width: diameter,
        height: diameter,
        marginRight: 0.8 * diameter
      };
      dotsWidth = (numberOfDots - 1) * dotCSS.marginRight + numberOfDots * dotCSS.width;
      $dots.css({
        width: dotsWidth,
        lineHeight: "" + ($dots.height()) + "px"
      });
      $dots.children().each(function(index, dot) {
        return $(this).css(dotCSS);
      });
      return $dots.children(".dot:last-child").css("margin-right", 0);
    };
    $dot = $dots.children(".dot");
    toggleDot = function(num) {
      return $dot.eq(num).toggleClass("selected");
    };
    selectDot = function(num) {
      if (num === currHobbyDot || num < 0 || num >= hobbiesData.length) {
        return false;
      }
      toggleDot(currHobbyDot);
      toggleDot(num);
      return currHobbyDot = num;
    };
    toggleDot(currHobbyDot);
    resizeDots();
    $window.resize(resizeDots);
    randomizeFace = function() {
      return currFace = (currFace + Math.round(Math.random(5)) + 1) % 6;
    };
    updateTitle = function(title) {
      $title.empty().html(title);
      return $title.velocity("stop").velocity("fadeIn", {
        duration: 300
      });
    };
    imgFolder = "imgs/";
    selectHobby = function(hobbyNum) {
      var $face, $image, faceNum, foundFace, hobby, _i, _len;
      hobby = hobbiesData[hobbyNum];
      foundFace = false;
      for (faceNum = _i = 0, _len = $faces.length; _i < _len; faceNum = ++_i) {
        $face = $faces[faceNum];
        if ($face.data("hobby") === hobby.name) {
          currFace = faceNum;
          foundFace = true;
          break;
        }
      }
      if (!foundFace) {
        randomizeFace();
        $image = $("<img />").attr("src", imgFolder + hobby.img);
        $faces[currFace].empty().append($image);
        $faces[currFace].data("hobby", hobby.name);
      }
      updateTitle(hobby.name);
      selectDot(hobbyNum);
      return switchToFace();
    };
    initializeHobbies = function() {
      var $image, hobby, i, _i;
      currFace = 0;
      for (i = _i = 0; _i <= 5; i = ++_i) {
        hobby = hobbiesData[currHobbyDot + i];
        $image = $("<img />").attr("src", imgFolder + hobby.img);
        $faces[i].empty().append($image);
        $faces[i].data("hobby", hobby.name);
      }
      $title.empty().html(hobbiesData[currHobbyDot].name);
      return switchToFace(0);
    };
    initializeAutoselection = function() {
      window.clearInterval(autorotateIntervalID);
      return autorotateIntervalID = window.setInterval(function() {
        var nextHobby;
        nextHobby = ((currHobbyDot + 1) + hobbiesData.length) % hobbiesData.length;
        return selectHobby(nextHobby);
      }, 3200);
    };
    createEventHandlers = function() {
      $prev.click(function() {
        var nextHobby;
        initializeAutoselection();
        nextHobby = ((currHobbyDot - 1) + hobbiesData.length) % hobbiesData.length;
        return selectHobby(nextHobby);
      });
      $next.click(function() {
        var nextHobby;
        initializeAutoselection();
        nextHobby = (currHobbyDot + 1) % hobbiesData.length;
        return selectHobby(nextHobby);
      });
      return $dot.click(function() {
        var nextHobby;
        initializeAutoselection();
        nextHobby = $(this).index();
        return selectHobby(nextHobby);
      });
    };
    $arrows = $hobbies.find(".prev, .next");
    animateIn = function(waypoint) {
      initializeHobbies();
      return $cube.velocity("transition.cubeIn", function() {
        $arrows.animate({
          opacity: 1
        }, 500);
        $dot.velocity("transition.fadeIn", {
          display: "inline-block"
        });
        $title.velocity("transition.fadeIn");
        createEventHandlers();
        return initializeAutoselection();
      });
    };
    return $hobbies.data("transitionIn", animateIn);
  });

  $(function() {
    var $home, animateIn, vivus;
    $home = $("#home");
    vivus = new Vivus("kevin", {
      type: "delayed",
      duration: 200,
      delay: 100,
      start: "manual"
    });
    animateIn = function() {
      return vivus.play(1);
    };
    return $home.data("transitionIn", animateIn);
  });

  $window.load(function() {
    var $currentSelector, $links, $navbar, $selectors, createNavHandler, isScrolling, navbarHeight, transitionInHandler;
    $navbar = $("#navbar");
    $links = $("#navbar > nav > div");
    $selectors = $("#navbar .selector");
    navbarHeight = 85;
    $currentSelector = $();
    isScrolling = false;
    createNavHandler = function($link, themeClass, darkClass, textColor) {
      var $selector;
      $selector = $link.children(".selector");
      return function(direction) {
        if (direction === "down") {
          $navbar.removeClass($navbar.data("color"));
          $navbar.addClass(themeClass);
          $navbar.data("color", themeClass);
          $selectors.removeClass($selectors.data("color"));
          $selectors.addClass(darkClass);
          $selectors.data("color", darkClass);
          $links.css("color", textColor);
          $link.css("color", "white");
          $currentSelector.velocity({
            top: "-" + navbarHeight + "px"
          }, 200);
          $selector.velocity({
            top: "0"
          }, 200);
          return $currentSelector = $selector;
        } else {
          if (this.previous() != null) {
            return this.previous().callback("down");
          }
        }
      };
    };
    transitionInHandler = function(waypoint) {
      var $element, handlerIn;
      $element = $(waypoint.element);
      if ($element.data("hasTransitionIn") != null) {
        waypoint.destroy();
        return;
      }
      handlerIn = $element.data("transitionIn");
      if (handlerIn != null) {
        handlerIn();
      }
      return $element.data("hasTransitionIn", true);
    };
    return $.each(["home", "about", "experience", "hobbies", "contact"], function(index, name) {
      var $a, $id, $link, $selector, bottomWaypoint, darkClass, options, optionsBottom, optionsTop, scrollToId, themeClass, topWaypoint;
      $id = $("#" + name);
      $link = $("#" + name + "-link");
      themeClass = name + "-theme";
      darkClass = name + "-dark";
      options = {
        offset: "85px",
        continuous: false,
        group: "nav"
      };
      if (name === "experience") {
        $id.waypoint(createNavHandler($link, themeClass, darkClass, "black"), options);
      } else {
        $id.waypoint(createNavHandler($link, themeClass, darkClass, "white"), options);
      }
      optionsTop = {
        offset: "85px",
        continuous: false,
        group: "transitionIn"
      };
      optionsBottom = {
        offset: function() {
          return -$(this.element).outerHeight() + 86;
        },
        continuous: false,
        group: "transitionIn"
      };
      topWaypoint = $id.waypoint(function(direction) {
        if (direction === "down") {
          return transitionInHandler(this);
        }
      }, optionsTop);
      bottomWaypoint = $id.waypoint(function(direction) {
        if (direction === "up") {
          return transitionInHandler(this);
        }
      }, optionsBottom);
      scrollToId = function() {
        var offset;
        offset = $link.attr("id") === "home-link" ? 0 : 5;
        return $id.velocity("scroll", {
          duration: 600,
          offset: offset
        });
      };
      $link.click(scrollToId);
      $id.click(scrollToId);
      $selector = $link.children(".selector");
      $a = $link.find("a");
      return $link.hover(function() {
        $a.css("color", "white");
        return $selector.velocity("stop").velocity({
          top: "0"
        }, 200);
      }, function() {
        $a.css("color", "inherit");
        if ($selector[0] !== $currentSelector[0]) {
          return $selector.velocity("stop").velocity({
            top: "-" + navbarHeight + "px"
          }, 200);
        }
      });
    });
  });

}).call(this);

//# sourceMappingURL=magic.js.map
