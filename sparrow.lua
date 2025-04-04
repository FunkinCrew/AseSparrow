function init(plugin)
    plugin:newCommand{
      id="ExportSparrow",
      title="Export to Sparrow Sprite Sheet",
      group="file_export_1",
      onclick=function()
        -- app.alert "Text" if no animation tags in current sprite
        if app.sprite.tags == nil or #app.sprite.tags == 0 then
          app.alert{title="AseSparrow", text={"No animation tags found in current sprite!", "Please add tags to your sprite before exporting."}}
          return
        end
        openSpritesheetDialog()
      end,
      onenabled=function()
        if app.activeSprite == nil then
          return false
        else
          return true
        end
      end
    }
end

local prevSprite = nil

function openSpritesheetDialog()
    local dlg = Dialog()
    -- dialog window title
    dlg:modify{ title = "Generate Sparrow Sprite Sheet" }

    -- todo: forloop through all animations and add checkboxes for each of them, then keep track of them for animation generating
    -- Need to make these actually work
    dlg:tab{ id="tab_tags",
         text="Animations",
          }
    local layer_options = { "Visible Layers", "Selected Layers"} 


    function recurseGroups(layer, layer_name)
        if layer_name == nil then
            layer_name = layer.name
        end
        if layer.isGroup then
            table.insert(layer_options, "Group: " .. layer.name)
            for i,sublayer in ipairs(layer.layers) do
                recurseGroups(sublayer, layer_name .. "/")
            end
        else
            if layer_name == layer.name then
                layer_name = ""
            end
            table.insert(layer_options, "Layer: " .. layer_name .. layer.name)
        end
    end

    -- TODO: implement selectable layers
    -- for i,layer in ipairs(app.sprite.layers) do
    --     recurseGroups(layer)
    -- end

    dlg:number{ id="frame_rate",
              label="Frame Rate: ",
              text="24",
              decimals=0
            }
    dlg:combobox{ id="layer_options",
              label="Layers: ",
              option="Visible Layers",
              options=layer_options
             }

    dlg:label{
          label="",
          text="Included Animations"
          }    
    
    for i,tag in ipairs(app.sprite.tags) do
        dlg:check{ id="tag_" .. tag.name,
            label="",
            text=tag.name,
            selected=true
        }
    end

    dlg:tab{ id="tab_output",
         text="Output",
          }

    -- file path stuff
    -- TODO: path file saving stuff
    dlg:file{ id="file_path",
          label="Save Spritesheet As:",
          title="Path to save spritesheet to",
          save=true,
          open=false,
          filetypes={""},
           }
    

    -- Image sizing
    dlg:combobox{ id="image_size",
              label="Image Dimensions: ",
              option="Auto size",
              options={ "Auto size (Power of Two) (unimplemented)", "Auto size","Custom (unimplemented)", },
              onchange=function()
                -- TODO do image resize crap
              end }
    
 

    dlg:number{ id="image_width",
              label="Width (unimplemented)",
              text="128",
              decimals=0,
              visible=false,
              onchange=function()
                end }
    
    dlg:number{ id="image_height",
                label="Height (unimplemented)",
                text="128",
                decimals=0,
                visible=false,
                onchange=function()
                  end }
    

    -- Trim and Stack frames checkboxes
    dlg:check{ id="trim_frames",
           label="",
           text="Trim",
           selected=true,
           onclick=function()
            local data = dlg.data
             generatePreview(data)
           end
            }
    -- note: Stacked frames is sorta implemented by default when using aseprites in-built spritesheet exporter, which we are using
    -- 
    -- dlg:check{ id="stack_frames",
    --      label="",
    --      text="Stack frames",
    --      selected=true
    --    }
    dlg:number{ id="border_padding",
       label="Border Padding",
       text="0",
       decimals=0,
       onchange=function()
         end }
    dlg:number{ id="shape_padding",
         label="Shape Padding",
         text="0",
         decimals=0,
         onchange=function()
            local data = dlg.data
            generatePreview(data)
           end }

    dlg:check{ id="keep_json",
           label="",
           text="Keep JSON spritesheet",
           selected=false
            }
    
    dlg:endtabs{ id="tab_output", selected="tab_output"}

    -- Bottom buttons to confirm and crap
    dlg:button{ id="confirm", text="Export" }
    dlg:button{ id="cancel", text="Cancel" }

    dlg:show()
    generatePreview(dlg.data)

    local data = dlg.data
    if data.confirm then
        -- generatePreview(data)
        exportSpriteSheet(data)
    end

end

function generatePreview(dlgData)
    
    -- if true then
    --     return
    -- end

    -- path stuff
    -- print(dlgData.trim_frames)
    -- Todo: spit out preview via app.commands.ExportSpriteSheet, using our config info
    -- then spit it to a temp directory, we can prob do just the image for preview, and then on final export, spit out the json and convert that to xml data
    -- exportSpriteSheet(dlgData);

    
    -- if prevSprite ~= nil then
    --     prevSprite:close()
    -- end
    -- prevSprite = Sprite{ fromFile=pngPath }
    

    -- app.refresh()
end

function getVisibleLayers()
    local layers = {}
    for i,layer in ipairs(app.activeSprite.layers) do
        if layer.isVisible then
            table.insert(layers, layer)
        end
    end
    return layers
end

function getSelectedLayers()
    return app.range.layers
end

-- Simple wrapper around app.command.ExportSpriteSheet that also feeds in our data to it
function exportSpriteSheet(dlgData)

    local layers = {}

    -- TODO: layers param only takes in one string, I believe we can select specific layernames with our dlgData,
    -- select them in the editor, and then export them with the selected-layers option/string

    if dlgData.layer_options == "Visible Layers" then
        layers = getVisibleLayers()
        app.range.layers = layers
        layers = "**selected-layers**"

    elseif dlgData.layer_options == "Selected Layers" then
        -- note: undocumented functionality of ExportSpriteSheet, we can get the selected layers by passing in "**selected-layers**"
        -- https://github.com/aseprite/aseprite/blob/main/src/app/commands/cmd_export_sprite_sheet.cpp#L214
        -- https://github.com/aseprite/aseprite/blob/main/src/app/ui/layer_frame_comboboxes.cpp#L37
        layers = "**selected-layers**"
        
    else
        layers = dlgData.layer_options
    end

    app.command.ExportSpriteSheet {
        ui=false,
        recent=false,
        askOverwrite=false,
        type=SpriteSheetType.PACKED,
        columns=0,
        rows=0,
        width=0,
        height=0,
        bestFit=true,
        textureFilename=dlgData.file_path .. ".png",
        dataFilename=dlgData.file_path .. ".json",
        dataFormat=SpriteSheetDataFormat.JSON_ARRAY,
        filenameFormat="{title} ({layer}) {frame}.{extension}",
        borderPadding=dlgData.border_padding,
        shapePadding=dlgData.shape_padding,
        innerPadding=0,
        trimSprite=dlgData.trim_frames,
        trim=false,
        trimByGrid=false,
        extrude=false,
        ignoreEmpty=false,
        mergeDuplicates=true,
        openGenerated=false,
        layer=layers,
        tag="",
        splitLayers=false,
        splitTags=false,
        splitGrid=false,
        listLayers=true,
        listTags=true,
        listSlices=true,
        fromTilesets=false,
    }

    exportXML(dlgData)
end

function exportXML(dlgData)
    -- TODO: Import json file, and read it's data, and re-encode it to xml
    local jsonObj = json.decode(readAll(dlgData.file_path .. ".json"))
    -- TODO: loop through jsonObj.meta.frameTags for each animation
    -- in each animation it will give you a to/from of which animations are in that tag
    -- from there, we get the sizing / positioning from jsonObj.frames, which we might have to access as an array? 
    local xmlHeader = '<?xml version="1.0" encoding="UTF-8"?>\n'
    local xmlRoot = '<TextureAtlas imagePath="' .. app.fs.fileTitle(dlgData.file_path) .. '.png">\n'
    local xmlSubtextures = ''

    for i,frametag in ipairs(jsonObj.meta.frameTags) do repeat
        
        if dlgData["tag_" .. frametag.name] == false then
            do break end
        end
        
        local rangeStart = frametag.from
        local rangeEnd = frametag.to

        local framerateOffset = 0

        for j = rangeStart, rangeEnd do
            local frameInfo = jsonObj.frames[j + 1]
            -- where in the texture atlas we need to look
            local atlasSize = frameInfo.frame
            -- how we need to make our potential spritesheet
            local frameSize = frameInfo.spriteSourceSize
            local sourceSize = frameInfo.sourceSize

            local intendedDuration = math.floor(((frameInfo.duration * 0.001) / (1 / dlgData.frame_rate)) + 0.5)
            
            local x = xmlWrap("x", math.floor(atlasSize.x))
            local y = xmlWrap("y", math.floor(atlasSize.y))
            local width = xmlWrap("width", math.floor(atlasSize.w))
            local height = xmlWrap("height", math.floor(atlasSize.h))
            
            local frameX = xmlWrap("frameX", math.floor(-frameSize.x))
            local frameY = xmlWrap("frameY", math.floor(-frameSize.y))
            local frameWidth = xmlWrap("frameWidth", math.floor(sourceSize.w))
            local frameHeight = xmlWrap("frameHeight", math.floor(sourceSize.h))

            local i = 0
            repeat 
                xmlSubtextures = xmlSubtextures .. '\t<SubTexture name="' .. frametag.name  .. string.format("%04d", j - rangeStart + framerateOffset + i) .. '"' .. x .. y .. width .. height .. frameX .. frameY .. frameWidth .. frameHeight .. ' />\n'
                i = i + 1
            until i >= intendedDuration
            framerateOffset = framerateOffset + (intendedDuration - 1)

        end

    until true end

    local xmlFooter = '</TextureAtlas>'

    local xml = xmlHeader .. xmlRoot .. xmlSubtextures .. xmlFooter
    local xmlFile = io.open(dlgData.file_path .. ".xml", "w")
    if xmlFile then 
        xmlFile:write(xml)
        xmlFile:close()
    end

    if dlgData.keep_json == false then
        -- delete the json file
        if app.os.name == "Windows" then
            os.execute("del " .. dlgData.file_path .. ".json")
        else
            os.execute("rm " .. dlgData.file_path .. ".json")
        end
    end
    
end

function xmlWrap(prop, value)
    return ' ' .. prop .. '="' .. value .. '"'
end

function readAll(file)
    local f = assert(io.open(file, "rb"))
    local content = f:read("*all")
    f:close()
    return content
end