var mouseOverColor = "#e4e5e7";
var mouseOutColor = "transparent";

function selectElement(e){
  document.getElementById(e).style.backgroundColor = mouseOverColor;
}

function unselectElement(e){
  document.getElementById(e).style.backgroundColor = mouseOutColor;
}

function hideWindows(){
  $$(".message_box").each(Element.hide);
  $$(".bar_menu > div").each( function (e){Element.removeClassName(e,"chosen")} );
}

function showWindow(win,near){
  hideWindows()
  var near_parent = $(near.parentNode);
  var pos = near_parent.viewportOffset()
  near.addClassName("chosen");
  win.setStyle({
    width: near_parent.getWidth()+"px",
    top: (pos.top+near_parent.getHeight())+"px",
    left: (pos.left-near_parent.getWidth()/2+near_parent.getWidth()/2)+"px",
  });
  win.show();
}

function toggleWindow(win,near){
  if( win.getStyle("display") == "none" ){
    showWindow(win,near);
  }else{
    hideWindows();
  }
}
