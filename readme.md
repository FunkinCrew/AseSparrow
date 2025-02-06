# AseSparrow

An Aseprite extension to export animations into Sparrow V2 spritesheet format

# Installation

Download the `.aseprite-extension` from the [Github Releases](https://github.com/FunkinCrew/AseSparrow/releases), and then you should be able to double-click the file to install it easily. See the [Aseprite Documentation](https://www.aseprite.org/docs/extensions/) for further info on installing extensions into Aseprite.

# Usage (Aseprite)

Usage should be pretty simple and familiar if you've used Adobe Animate's "Export Sprite Sheet" option.

## Preparing

This extension uses [Aseprite's animation tag feature](https://www.aseprite.org/docs/tags/) for the spritesheet frame data. 
Whatever you tag on your timeline will be exported into the Sparrow XML file. 

## Exporting 

`File > Export > Export to Sparrow Sprite Sheet` 

The command installs itself with the other exporting options, so it should be just as easy to access. It will open a small popup dialog window with some options similar to Adobe Animate's.

# Export Options
## Output

- `Save Spritesheet as`
  - Where you want to save both your image and your xml file. They will be given the same name, so you don't need to input a file extension.
- `Image Dimensions`
  - The sizing of the output image file. Right now we just have it set to `Auto Size` which just uses Aseprite's in-built spritesheet auto sizing. Usually this is good enough especially since we're likely to export pixel art.
- `Width`
  - (unimplemented) Allows you to constrain the width of the output image file.
- `Height`
  - (unimplemented) Allows you to constrain the height of the output image file
- `Trim`
  - Whether or not the spritesheet should be trimmed before being created. This functions similar to the `Sprite > Trim` command, where it retains positioning of all animations. 
- `Border padding`
  - The space between each frame, and the edge of the spritesheet.
- `Shape padding`
  - The space between each frame in the spritesheet.

## Animations
- `Frame Rate`
  - Sparrow doesn't use "frame duration", so this will add extra "frames" into the sparrow .xml file, using the duration frame property in Aseprite. If you're using HaxeFlixel, you'd probably want this to match your `animation.add()`'s `frameRate` argument.
- `Layers`
  - Allows you to specify certain layers to be exported only. Similar to Aseprite's feature. 
    - Visible: Currently visible layers will be exported
    - Selected Layers: Currently selected layers will be exported
- `Included Animations`
  - A list of animations that will be included in the exported file. 




### Additional Info
- https://enigmaengine.github.io/docs/animation-format

