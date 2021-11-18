//= require jquery.rating

// Navigating to a page with ratings via TurboLinks shows the radio buttons
$(document).on('page:load', function () {
  $('input[type=radio].star').rating();
});

$(document).ready(function () {
  params = getParamsFromUrl()
  if ('q[rating_eq]' in params) {
    $("#rating_selector").val(params['q[rating_eq]']);
  }

  $('#rating_selector').change(function() {
    urlBase = window.location.href.split('?')[0]
    params = getParamsFromUrl()
    params['q[rating_eq]'] = $('#rating_selector').val()
    var str = jQuery.param( params );
    window.location.replace(urlBase + '?' +str)
  });

  function getParamsFromUrl() {
    urlParam = window.location.href.split('?')[1]

    if (typeof(urlParam)=="undefined") {
      urlParam = 'q[name_cont]=&q[title_cont]=&q[review_cont]=&q[approved_eq]=&q[rating_eq]=&button=&per_page=25'
    }
    decodedUrl = decodeURIComponent(urlParam)
    let searchParams = new URLSearchParams(decodedUrl);
    params = {}
    searchParams.forEach(function(value, key){
      params[key] = value
    })
    
    return params
  }
})