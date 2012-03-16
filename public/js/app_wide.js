

var flash = {
  error: function (msg) {
    var flash = $('<div class="flash error" style="display:none;">'+msg+'</div>');
    $('#flashes').append(flash);
    $(flash).fadeIn(400);
    this.hide();
  },

  notice: function (msg) {
    var flash = $('<div class="flash notice" style="display:none;">'+msg+'</div>');
    $('#flashes').append(flash);
    $(flash).fadeIn(400);
    this.hide();
  },

  hide: function() {
    setTimeout(function(){
      $('.flash').fadeOut(1000, function(){
        $('#flashes .flash').remove();
      });
    }, 5000);
  }
};

jQuery.fn.haveThisText = function(pat){
  var noteHaveText = 0;
  var node = this;
  var title = node.find('.note-title').find('*').contents().filter(function(){ 
    return this.nodeType == 3; 
  });
  var content = node.find('.note-content').find('*').contents().filter(function(){ 
    return this.nodeType == 3; 
  });
  var tags = node.find('.tagbox').find('*').contents().filter(function(){ 
    return this.nodeType == 3; 
  });
  var text = $.merge(title, content);
  text = $.merge(text, tags);
  text.each(function(){
    if( this.data.toUpperCase().indexOf(pat.toUpperCase()) >=0 ){
      noteHaveText = 1;
      return false;
    }
  });
  return noteHaveText;
};

$(document).ready(function () {
  if (!window.console) console = {log: function() {}};

  // Make sure 100% height works for navigation elements.
  function setContentHeight(heightToSubtract) {

    var contentHeight = $(window).height() - heightToSubtract;

    // Provided contentHeight is big enough to modify -- else, buttons get cut off.
    if (contentHeight > 530) {
    
      // It's not ideal, but less-jarring than without animation.
      $('#content').stop(true, true).animate({
        height: contentHeight
      }, 200);
    }

  } // setContentHeight

  // Run it onLoad.
  setContentHeight($('header#mainHeader').height());

  // And when window is resized.
  $(window).resize(function() {
    setContentHeight($('header#mainHeader').height());
  });


  var weekday = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  var monthNames = [ "Jan", "Feb", "Mar", "Apr", "May", "June",
                     "July", "Aug", "Sep", "Oct", "Nov", "Dec" ];

  var dialogLock = false;
  $('[data-dialog]').click(function(e){
    e.preventDefault();
    dialogLock = true;
    $('body').append($('<div class="dialog-bg" />'));
    $('.dialog-bg').fadeIn(100);
    
    var dialog = $('#'+$(e.target).data("dialog")+'');
    dialog.prepend($('<header>'+dialog.attr('title')+'<a href="" class="close">X</a></header>'));
    dialog.css({top: '-500px', opacity: 0, display: 'block'});
    dialog.animate({top: '100px', opacity: 1}, 400);
    dialog.find('.close').click(function(e){
      e.preventDefault();
      dialog.animate({top: '-500px', opacity: 0}, 400, function(){
        $('.dialog-bg').fadeOut(200, function(){
          $(this).remove();
          //$('body').css('overflow', 'auto');
          dialogLock = false;
          dialog.children('header').remove();
        });
      });
    });
    $(document).keyup(function(e){
      if ( e.keyCode == 27 ) {
        e.preventDefault();
        dialog.find('.close').click();
      }
    });
    return false;
  });
  
  if($('#flashes .flash').length>0){
    flash.hide();
  }

  $('.tabs ul.tabs-navigation li a.selected').each(function(){
    var href = $(this).attr('href');
    $(this).closest('.tabs').find('.tab-pane').hide();
    $(this).closest('.tabs').find('#'+href).show();
  });

  $('.tabs ul.tabs-navigation li a').live('click', function(e){
    e.preventDefault();
    var href = $(e.target).attr('href');
    $(e.target).closest('ul').find('li a').removeClass('selected');
    $(e.target).addClass('selected');
    $(e.target).closest('.tabs').find('.tab-pane').hide();
    $(e.target).closest('.tabs').find('#'+href).show();
  });



});
