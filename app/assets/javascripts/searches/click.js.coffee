trackClick = (e) ->
  e.stopPropagation()
  $link = $(e.currentTarget)
  data = $.extend {},
    $('#search').data(),
    { url: this.href },
    $link.data('click')
  #jQuery.ajax type: 'POST', async: false, url: 'https://search.usa.gov/api/v2/click', data: data
  jQuery.ajax type: 'POST', async: false, url: 'https://pusheen.staging.search.usa.gov/api/v2/click', data: data

$(document).on 'click', '#search a[data-click]', trackClick
