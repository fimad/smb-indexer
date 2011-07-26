var mouseOverColor = "#E4E5F5";
var mouseOutColor = "#FFFFFF";

function selectElement(e){
  document.getElementById(e).style.backgroundColor = mouseOverColor;
}

function unselectElement(e){
  document.getElementById(e).style.backgroundColor = mouseOutColor;
}
