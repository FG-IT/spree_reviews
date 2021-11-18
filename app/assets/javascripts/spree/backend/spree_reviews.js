//= require jquery.rating

// Navigating to a page with ratings via TurboLinks shows the radio buttons
$(document).on('page:load', function () {
  $('input[type=radio].star').rating();
});

$(document).ready(function () {
  let params = getParamsFromUrl()
  if ('q[rating_eq]' in params) {
    $("#rating_selector").val(params['q[rating_eq]']);
  }

  $('#rating_selector').change(function() {
    let urlBase = window.location.href.split('?')[0]
    let params = getParamsFromUrl()
    params['q[rating_eq]'] = $('#rating_selector').val()
    var str = jQuery.param( params );
    window.location.replace(urlBase + '?' +str)
  });

  function getParamsFromUrl() {
    let urlParam = window.location.href.split('?')[1]

    if (typeof(urlParam)=="undefined") {
      urlParam = 'q[name_cont]=&q[title_cont]=&q[review_cont]=&q[approved_eq]=&q[rating_eq]=&button=&per_page=25'
    }
    let decodedUrl = decodeURIComponent(urlParam)
    let searchParams = new URLSearchParams(decodedUrl);
    let params = {}
    searchParams.forEach(function(value, key){
      params[key] = value
    })
    
    return params
  }
})