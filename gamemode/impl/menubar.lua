if SERVER then
    AddCSLuaFile()
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
			<Rect Mat="symphony/logo32.png" Fill="white" Width="0.75ph" Height="0.75ph" />
		</Rect>
	]])
	

	local cfg = menubar.Control:AddMenu("Server")
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


	
	
	local addons = menubar.Control:AddMenu("Other addons")
	list.RemoveEntry("DesktopWindows", "PlayerEditor")

	for k, wdgt in pairs( list.Get( "DesktopWindows" ) ) do

		
		local opt
		opt = addons:AddOption(wdgt.title, function ()
			-- Changing parents causes loss of input and I don't have time to figure out why
			if ( IsValid( opt.Window ) && opt.Window:GetParent() != g_ContextMenu ) then
				opt.Window:Remove()
			end

			-- wdgt might have changed using autorefresh, so grab it again
			local newWdgt = list.GetEntry( "DesktopWindows", k )

			if ( newWdgt.onewindow and IsValid( opt.Window ) ) then
				opt.Window:Center()
				return
			end

			-- Make the window
			opt.Window = g_ContextMenu:Add( "DFrame" )
			opt.Window:SetSize( newWdgt.width, newWdgt.height )
			opt.Window:SetTitle( newWdgt.title )
			opt.Window:Center()

			newWdgt.init( opt, opt.Window )
		end)

	end

	
end
menubar.Init()


-- Remove the widgets
if IsValid(g_ContextMenu) and IsValid(g_ContextMenu.DesktopWidgets) then
	g_ContextMenu.DesktopWidgets:SetVisible(false)
end

hook.Add("ContextMenuCreated", function (pnl)
    timer.Simple(0, function ()
		pnl.DesktopWidgets:SetVisible(false)
	end)
end)

concommand.Remove("open_playermodel_selector") -- Remove the command to prevent confusion