$(document).ready(function () {
  $("#company").isin_lookup("#isin");
  
  $("#profile_form").validate({
    rules: {
      'user[firstname]' : { required: true },
      'user[lastname]'  : { required: true },
      'user[isin]'  : { required: true },
      'user[city]'  : { required: true },
      'user[state]' : { required: true }
    },
    errorClass: 'validateErrorLabel',
    errorPlacement: function(err, element) {
      element.closest('.field').addClass("error");
    }
  });
});