function reloadHoldersWidget() {
  $.ajax({
    dataType: 'jsonp',
    jsonp: 'callback',
    url: "/engine/get/holderssummary",
    data:  globalSettings.getApiCallData(),
    error: function(jqXHR, textStatus, errorThrown){
      console.log("API Error: Status " + jqXHR.status);
    },
    success: function(json){
      console.log("numHolders: " + json["numHolders"]);
      $("#holders_widget [name=numNewBuyers]").text(json["numNewBuyers"]);
      $("#holders_widget [name=numTotalSellers]").text(json["numTotalSellers"]);
      $("#holders_widget [name=numBuyers]").text(json["numBuyers"]);
      $("#holders_widget [name=numSellers]").text(json["numSellers"]);
      $("#holders_widget [name=numHolders]").text(json["numHolders"]);
  
      /* 
      var holders_summary = {};
      holders_summary.new_buyers    = json["numNewBuyers"];
      holders_summary.total_sellers = json["numTotalSellers"];
      holders_summary.buyers        = json["numBuyers"];
      holders_summary.sellers       = json["numSellers"];
      */
    }
  });
}



function reloadOutliersWidget() {
  $.ajax({
    dataType: 'jsonp',
    jsonp: 'callback',
    url: "/engine/get/potentialsellers",
    data: globalSettings.getApiCallData(),
    error: function(jqXHR, textStatus, errorThrown){
      console.log("API Error: Status " + jqXHR.status); 
    },
    success: function(json){
      $("#outliers_widget [name=risk]").text(json["totalResultCount"]);
    }
  });
}

$(document).ready(function () {
  
  $("#add-meeting").validate({
    rules: {
      'meeting_date' : { required: true },
      'meeting_fund' : { required: true },
      'meeting_investment_bank' : { required: true },
      'meeting_banking_contact_1' : { required: true },
      'meeting_location' : { required: true },
      'meeting_fund_contact_1' : { required: true }
    },
    errorClass: 'validateErrorLabel',
    errorPlacement: function(err, element) {
      element.closest('.field').addClass("error");
    },
    submitHandler: function(form) {
      $(form.elements['submit']).val('Saving...');
      $(form).find('fieldset').css('opacity', '.5');
      $(form).find('input').attr('disabled', 'disabled');
      $(form).find('textarea').attr('disabled', 'disabled');

      $.ajax({
        url:    '/meeting',
        type:   'POST',
        data: {
          date:               form.elements['meeting_date'].value,
          found:              form.elements['meeting_found'].value,
          group:              form.elements['meeting_group'].value,
          investment_bank:    form.elements['meeting_investment_bank'].value,
          banking_contact_1:  form.elements['meeting_banking_contact_1'].value,
          banking_contact_2:  form.elements['meeting_banking_contact_2'].value,
          notes:              form.elements['meeting_notes'].value,
          location:           form.elements['meeting_location'].value,
          type_of_visit:      form.elements['meeting_type_of_visit'].value,
          fund_contact_1:     form.elements['meeting_fund_contact_1'].value,
          fund_contact_2:     form.elements['meeting_fund_contact_2'].value,
          fund_contact_3:     form.elements['meeting_fund_contact_3'].value,
          fund_contact_4:     form.elements['meeting_fund_contact_4'].value,
          vm_recommend:       $(form).find('.meeting_vm_recommend:checked').val()
        },
        success: function (data) {
          $(form).find('fieldset').css('opacity', '1');
          $(form).find('input').removeAttr('disabled').val('');
          $(form).find('textarea').removeAttr('disabled').val('');
          $(form.elements['submit']).val('Save');
          //hide popup
          $(form).closest('.popup-dialog').find('.close').click();

          flash.notice('New meeting log has been saved.');
        },
        error: function (data) {
          $(form).find('fieldset').css('opacity', '1');
          $(form).find('input').removeAttr('disabled').val('');
          $(form).find('textarea').removeAttr('disabled').val('');
          $(form.elements['submit']).val('Save');
          //hide popup
          $(form).closest('.popup-dialog').find('.close').click();

          flash.error('Some error happened. Try later.');
        }
      });
    }
  });

  $( "#meeting_date" ).datepicker({ "dateFormat": "DD, d M, yy" });



});
