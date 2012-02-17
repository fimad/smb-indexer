var mouseOverColor = "#E4E5F5";
var mouseOutColor = "#FFFFFF";

function selectElement(e){
  document.getElementById(e).style.backgroundColor = mouseOverColor;
}

function unselectElement(e){
  document.getElementById(e).style.backgroundColor = mouseOutColor;
}

function hideWindows(){
  $$(".message_box").each(Element.hide);
}

function showWindow(win,near){
  hideWindows()
  var pos = near.viewportOffset()
  win.setStyle({
    top: (pos.top+near.getHeight())+"px",
    left: (pos.left-win.getWidth()/2+near.getWidth()/2)+"px",
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
