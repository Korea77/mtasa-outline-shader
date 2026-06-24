-- Author: https://github.com/Korea77

local sx, sy = guiGetScreenSize()



local Outline
Outline = {


    initializeSuccess = true,
    isRendering = false,
    counter = 0,
    
    rt = dxCreateRenderTarget(sx, sy, true),
    _localRender = function()
        local self = Outline
        dxDrawImage(0, 0, sx, sy, self.shaderEdge)
        dxSetRenderTarget(self.rt, true)
        dxSetRenderTarget()
    end,
    
    addElement = function(self, element)
        if not isElement(element) then return false end
        self.counter = self.counter + 1
        if not self.isRendering then
            self.isRendering = true
            addEventHandler("onClientHUDRender", root, self._localRender)
        end
        engineApplyShaderToWorldTexture(self.shaderMRT, "*", element)
        engineRemoveShaderFromWorldTexture(self.shaderMRT, "muzzle_texture*", element)
    end,

    removeElement = function(self, element)
        self.counter = self.counter - 1
        if self.isRendering and self.counter <= 0 then
            self.isRendering = false
            removeEventHandler("onClientHUDRender", root, self._localRender)
        end
        if isElement(element) then
            engineRemoveShaderFromWorldTexture(self.shaderMRT, "*", element)
        end

    end,


}
Outline.__index = Outline


addEventHandler("onClientResourceStart", resourceRoot, function()
    Outline.shaderMRT = dxCreateShader("shader.fx", 0, 0, false, "all")
    Outline.shaderEdge = dxCreateShader("edge.fx", 0, 0, false, "other")

    if not Outline.shaderMRT or not Outline.shaderEdge then
        outputChatBox("Outline shaders failed to load!")
        destroyElement(Outline.rt)
        Outline.initializeSuccess = false
    else
        dxSetShaderValue(Outline.shaderMRT, "SCREEN_RT", Outline.rt)
        dxSetShaderValue(Outline.shaderEdge, "gTexture0", Outline.rt)
        dxSetShaderValue(Outline.shaderEdge, "texelSize", 2 / sx, 2 / sy)
    end

end)
function addOutline(element) -- export
    if not Outline.initializeSuccess then return false end
    Outline:addElement(element)
end

function removeOutline(element) -- export
    if not Outline.initializeSuccess then return false end
    Outline:removeElement(element)
end
