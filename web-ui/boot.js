window.onload = function() {
  var container = document.getElementById("app");
  Elm.Main.init({
    node: container,
    flags: 10
  });
};
