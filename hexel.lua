function hexelPosition(way, ox, oy)
    local x, y = 0, 0

    if way == "vertical" then
        x = math.floor(ox / 2)
        y = math.floor((oy + x % 2) / 2) * 2 - x % 2
        x = x * 2
    else
        y = math.floor(oy / 2)
        x = math.floor((ox + y % 2) / 2) * 2 - y % 2
        y = y * 2
    end

    return x, y
end

function drawHexel(image, way, ix, iy)
    local op = app.activeCel.position
    local x, y = hexelPosition(way, ix + op.x, iy + op.y)
    
    for dx = 0, 1 do
        for dy = 0, 1 do
            image:drawPixel(x - op.x + dx + 1, y - op.y + dy + 1, app.fgColor)
        end
    end
    
end

function onDraw(ev)
    local spr = app.activeSprite

    print(ev)

    if true then -- ev and not ev.fromUndo then
        local way = hexel_dlg.data.way
        local image = app.activeCel.image
        local newImage = Image(image.width + 2, image.height + 2, image.colorMode)
        local iterator = image:pixels()
        local color = nil

        newImage:drawImage(image, Point(1, 1))

        if image.colorMode == ColorMode.INDEXED then
            color = app.fgColor.index
        end

        for elm in iterator do
            local pixelValue

            if elm() == color then
                drawHexel(newImage, way, elm.x, elm.y)
            end
        end

        local ap = app.activeCel.position
        app.activeCel.position = Point(ap.x - 1, ap.y - 1)
        app.activeCel.image:resize(image.width + 2, image.height + 2)
        app.activeCel.image = newImage

        app.refresh()
    end

    return
end

function reset()
    app.activeSprite.events:off(hexel_onChangeListener)
    hexel_isHexelDoing = false
end

function main()
    hexel_isHexelDoing = false
    hexel_onChangeListener = nil

    hexel_dlg = Dialog { title = "hexel"}

    hexel_dlg:combobox {
        id = "way",
        label = "Way:",
        option = "none",
        options = {
            "none",
            "vertical",
            "horizonal"
        },
        onchange = function()
            if hexel_dlg.data.way == "none" then
                if hexel_isHexelDoing then
                    reset()
                end
            else
                hexel_onChangeListener = app.activeSprite.events:on("change", function(ev)
                    onDraw(ev)
                end)
                hexel_isHexelDoing = true
            end
        end
    }
end

if hexel_isHexelDoing == nil then
    main()
else
    if hexel_isHexelDoing then
        reset()
    end
    main()
end

hexel_dlg:show { wait = false }