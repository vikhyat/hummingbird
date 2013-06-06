@initializeRatingInterface = (element, type) ->
  rating = parseInt element.attr("data-rating")
  anime_slug = element.attr("data-anime-slug")
  element.html ""

  if type == "starRatings"
    for i in [1..5]
      star = $("<a class='star' data-rating='" + i + "' href='javascript: void(0)'></a>")
      if rating >= i
        star.append $("<i class='icon icon-star'></i>")
      else
        star.append $("<i class='icon icon-star-empty'></i>")

      star.click ->
        element.find('.spinner').html $("<i class='pull-right icon icon-spin icon-spinner'></i>")

        $.post "/api/v1/libraries/" + anime_slug, {rating: parseInt($(this).attr("data-rating")) - 3}, (d) ->
          if d
            element.attr "data-rating", d.rating.value
            initializeRatingInterface element, type

      element.append star
      element.append $("<span> </span>")
  
  element.append $("<div class='spinner pull-right'></div>")
