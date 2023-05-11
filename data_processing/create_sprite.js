var spritezero = require("@mapbox/spritezero");
var fs = require("fs");
var glob = require("glob");
var path = require("path");

const data_folder = "../data",
  icons_folder = path.join(data_folder, "sprites_icons"),
  output_folder = path.join(data_folder, "sprites");

var svgs = glob
  .sync(path.resolve(path.join(icons_folder, "/*.svg")))
  .map(function (f) {
    return {
      svg: fs.readFileSync(f),
      id: path.basename(f).replace(".svg", ""),
    };
  });
var pngPath = path.resolve(path.join(output_folder, "/sprite" + ".png"));
var jsonPath = path.resolve(path.join(output_folder, "/sprite" + ".json"));

// Pass `true` in the layout parameter to generate a data layout
// suitable for exporting to a JSON sprite manifest file.
spritezero.generateLayout(
  { imgs: svgs, pixelRatio: 1, format: true },
  function (err, dataLayout) {
    if (err) return;
    fs.writeFileSync(jsonPath, JSON.stringify(dataLayout));
  }
);

// Pass `false` in the layout parameter to generate an image layout
// suitable for exporting to a PNG sprite image file.
spritezero.generateLayout(
  { imgs: svgs, pixelRatio: 1, format: false },
  function (err, imageLayout) {
    spritezero.generateImage(imageLayout, function (err, image) {
      if (err) return;
      fs.writeFileSync(pngPath, image);
    });
  }
);
