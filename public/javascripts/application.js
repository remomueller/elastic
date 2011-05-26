// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function createSpinner() {
  return new Element('img', { src: root_url + 'images/ajax-loader.gif', 'class': 'spinner', 'height': '11', 'width': '11' });
}

$(function(){
  $(".datepicker").datepicker({ showOtherMonths: true, selectOtherMonths: true, changeMonth: true, changeYear: true });  
  $("#ui-datepicker-div").hide();
  
  $(".pagination a, .page a, .next a, .prev a").live("click", function() {
    // $(".pagination").html(createSpinner()); //.html("Page is loading...");
    $.get(this.href, null, null, "script")
    return false;
  });
  
  $("#comments_search input").change(function() {
    $.get($("#comments_search").attr("action"), $("#comments_search").serialize(), null, "script");
    return false;
  });
  
  $(".field_with_errors input, .field_with_errors_cleared input, .field_with_errors textarea, .field_with_errors_cleared textarea").change(function() {
    var el = $(this);
    if(el.val() != '' && el.val() != null){
      $(el).parent().removeClass('field_with_errors');
      $(el).parent().addClass('field_with_errors_cleared');
    }else{
      $(el).parent().removeClass('field_with_errors_cleared');
      $(el).parent().addClass('field_with_errors');
    }
  });
  
  // $("#stickies_search input, #stickies_search select").change(function() {
  $("#stickies_search select").change(function() {
    $.get($("#stickies_search").attr("action"), $("#stickies_search").serialize(), null, "script");
    return false;
  });
  
  $(".per_page a").live("click", function() {
    object_class = $(this).data('object')
    $.get($("#"+object_class+"_search").attr("action"), $("#"+object_class+"_search").serialize() + "&"+object_class+"_per_page="+ $(this).data('count'), null, "script");
    return false;
  });
  
  $("#sticky_project_id").change(function(){
    $.post(root_url + 'projects/selection', $("#sticky_project_id").serialize(), null, "script")
    return false;
  });
  
});

/* Mouse Out Functions to Show and Hide Divs */

function isTrueMouseOut(e, handler) {
	if (e.type != 'mouseout') return false;
	var relTarget;
  if (e.relatedTarget) {
    relTarget = e.relatedTarget;
  } else if (e.type == 'mouseout') {
    relTarget = e.toElement;
  } else {
    relTarget = e.fromElement;
  }
  while (relTarget && relTarget != handler) {
    relTarget = relTarget.parentNode;
  }
	return (relTarget != handler);
}

function hideOnMouseOut(elements){
  $.each(elements, function(index, value){
    var element = $(value);
    element.mouseout(function(e, handler) {
      if (isTrueMouseOut(e||window.event, this)) element.hide();
    });
  });
}

function showMessage(elements){
  $.each(elements, function(index, value){
    var element = $(value);
    element.fadeIn(2000);
  })
}

function toggleSticky(element){
  $(element).toggle();
  $(element+'_description').toggleClass('collapsed');
}

function increaseSelectedIndex(element){
  var num_options = $(element + ' option').size()
  var element = $(element);
  var next_index = 0;
  if(element.attr('selectedIndex') <= 0){
    return false;
  }else{
    next_index = element.attr('selectedIndex') - 1;
  }
  element.attr('selectedIndex', next_index);
  element.change();
}

function decreaseSelectedIndex(element){
  var num_options = $(element + ' option').size()
  var element = $(element);
  var next_index = 0;
  if(element.attr('selectedIndex') < num_options - 1){
    next_index = element.attr('selectedIndex') + 1;
  }else{
    return false;
  }
  element.attr('selectedIndex', next_index);
  element.change();
}
