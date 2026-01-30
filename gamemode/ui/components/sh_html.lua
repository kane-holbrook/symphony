AddCSLuaFile()

if SERVER then
    return
end

local PANEL = {}

function PANEL:Init()
    self:AddFunction("GMod", "OpenURL", function (url)
        gui.OpenURL(url)
    end)

    self:AddFunction("GMod", "Invoke", function (func, ...)
        return self[func](self, ...)
    end)
end

function PANEL:SetHTML(text)
    text = [[
        <style>
            @import url('https://fonts.googleapis.com/css2?family=Orbitron:wght@400..900&family=Rajdhani:wght@300;400;500;600;700&display=swap');
    
            ::-webkit-scrollbar {
                width: 12px;
                background-color: transparent;
            }
    
            ::-webkit-scrollbar-thumb {
                background-color: rgba(255, 255, 255, 0.3);
                border-radius: 6px;
                border: 3px solid transparent; /* adds padding around thumb */
                background-clip: content-box;
                cursor:pointer;
            }

            a
            {
                color:#aaf;
                text-decoration:none;
            }

            a:hover
            {
                color:#ccf;
            }
                
    
            ::-webkit-scrollbar-thumb:hover {
                background-color: rgba(255, 255, 255, 1);
                border-radius: 6px;
                border: 3px solid transparent; /* adds padding around thumb */
                background-clip: content-box;
            }
                
            body {
                color:white;
                font-family:'Rajdhani';
                font-size:110%;
                user-select:none;
            }
    
            h1, h2, h3, h4, h5 {
                font-family:'Orbitron'
            }
        </style>
    ]] 
        .. text
    return self.BaseClass.SetHTML(self, text)
end

vgui.Register("SSTRP.HTML", PANEL, "DHTML")