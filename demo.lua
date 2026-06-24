
local object = createObject(1337, 0, 10, 5)

addEventHandler("onClientResourceStart", resourceRoot, function()
    addOutline(getElementsByType("player")[1])
    addOutline(object)
end)
