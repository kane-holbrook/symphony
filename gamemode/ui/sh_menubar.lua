if SERVER then
	return
end

-- Hide the menubar
if IsValid(menubar.Control) then
	menubar.Control:Remove()
end


--[[
	Configure
		Attributes
		Groups
		Items
		Missions
		NPCs
		Soundtracks
		Settings
		Usergroups
		Workshop
	Tools
		Database
		Entities
		Performance
		Network
		Types
		Logs
	Overlays
		Chunks
		Paths
		Clusters
	Addons
	About
		Credits
-]]

function menubar.Init()
	menubar.Control = vgui.Create("DMenuBar")
	menubar.Control:Dock(TOP)
	menubar.Control:SetVisible(false)

	vguix.CreateFromXML(menubar.Control, [[
		<Rect Height="1ph" Dock="LEFT" Align="4" Padding="4, 0, 4, 0" Gap="16">
			<Rect Mat="sstrp25/v2/logo32.png" Fill="white" Width="0.75ph" Height="0.75ph" />
			<Rect FontWeight="800">Starship Troopers RP: 2025</Rect>
		</Rect>
	]])
	
	local addons = menubar.Control:AddMenu("Addons")
	addons:AddOption("LVS", function ()
	end)
	

	local cfg = menubar.Control:AddMenu("Config")
	cfg:AddOption("Settings") 
	cfg:AddOption("Attributes") 
	cfg:AddOption("Items") 
	cfg:AddOption("Usergroups", function ()
		local p = vgui.Create("Usergroups")
		p:Center()
		p:MakePopup()
	end) 

	local wnd = menubar.Control:AddMenu("Debug")
	

	wnd:AddOption("Entities", function ()
		local p = vgui.Create("EntityInspector")
		p:Center()
		p:MakePopup()
	end)

	wnd:AddOption("Net", function ()
		local p = vgui.Create("SSTRP.NetInspector")
		p:Center()
		p:MakePopup()
	end)

	wnd:AddOption("Logs", function ()
		local p = vgui.Create("SSTRP.LogViewer")
		p:Center()
		p:MakePopup()
	end)

	wnd:AddOption("WebRTC", function ()
		local p = vgui.Create("SSTRP.WebRTCInspector")
		p:Center()
		p:MakePopup()
	end)

	
end
menubar.Init()