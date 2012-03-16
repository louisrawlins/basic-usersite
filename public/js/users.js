$(document).ready(function () {
  $("#company").isin_lookup("#isin");
  
  var init = true;
  $("#admin_user_form").validate({
    rules: {
      'firstname' : { required: true },
      'lastname'  : { required: true },
      'email'     : {
        required: true,
        email: true
      },
      'email_confirmation' : {
        required: true,
        email: true
      },
      'isin'  : { required: true },
      'city'  : { required: true },
      'state' : { required: true }
    },
    errorClass: 'validateErrorLabel',
    errorPlacement: function(err, element) {
      element.closest('.field').addClass("error");
    },
    submitHandler: function(form) {
      if ($("#user_usertype").val() == 'member') {
        if ($(".taggedselect-hiddenSelect:first").val() == null) {
          flash.error('Please set at least one company for Member');
          $('#user_companies_tags').addClass('validateErrorLabel').focus();

          return false;
        } else if ($(".taggedselect-hiddenSelect:first").val().length > 10) {
          flash.error('Allowed maximum 10 companies per Member user');
          $('.taggedselect-input').focus();
          
          return false;
        }
      }
      form.submit();
    }
  });

  $("ul.tabs", wizard).tabs("div.panes > fieldset", function(event, index) {
    if (init) {
      init = false;
      return true;
    }
    
    return $("#admin_user_form").valid();
  });

  var api = $("ul.tabs", wizard).data("tabs");

  // "next tab" button
  $(".button.next", wizard).click(function() {
    api.next();
  });

  // "previous tab" button
  $(".button.prev", wizard).click(function() {
    api.prev();
  });

  var cache = {}, lastXhr;
  $("#user_companies_tags").taggedselect({
    maxTags: 10,
    tagSource: function (request, response) {
      var term = request.term;
      if (term in cache) {
        response(cache[term]);
        return;
      }
      lastXhr = $.getJSON("/search/isin_lookup", request, function(data, status, xhr) {
        cache[term] = data;
        if (xhr === lastXhr) {
          response(data);
        }
      });
    }
  });
  
  $("#user_usertype").change(function () {
    if ($(this).val() == 'member') {
      $("#user_first-login-company_container").hide();
      $("#user_companies_container").show();
      $("#user_companies_tags").taggedselect("fill");
      $("#user_subscription_container").show();
    } else {
      $("#user_companies_container").hide();
      $("#user_first-login-company_container").show();
      $("#user_companies_tags").taggedselect("destroy");
      $("#user_subscription_container").hide();
    }
  }).change();
  
});
