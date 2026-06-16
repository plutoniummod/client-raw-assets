require( "T6.Lobby" )
require( "T6.Menus.PopupMenus" )
require( "T6.ListBox" )

CoD.Mods = {}
CoD.Mods.ModsInfo = {}
CoD.Mods.CurrentModInfo = {}
CoD.Mods.ModPrefix = CoD.isZombie and "zm_" or "mp_"

CoD.ModInfo = {}

CoD.ModInfo.new = function()
	local self = LUI.UIVerticalList.new()
	self.id = "ModInfo"

	self:setLeftRight( true, true, 0, 0 )
	self:setTopBottom( true, true, 0, 0 )

	local title = LUI.UIText.new()
	title:setLeftRight( true, false, 0, 0 )
	title:setTopBottom( true, false, 0, 42 )
	title:setRGB( CoD.BOIIOrange.r, CoD.BOIIOrange.g, CoD.BOIIOrange.b )
	title:setFont( CoD.fonts.Big )
	self:addElement( title )
	self.title = title

	local author = LUI.UIText.new()
	author:setLeftRight( true, false, 0, 0 )
	author:setTopBottom( true, false, 0, 26 )
	author:setFont( CoD.fonts.Big )
	self:addElement( author )
	self.author = author

	local description = LUI.UIText.new()
	description:setLeftRight( true, false, 0, 0 )
	description:setTopBottom( true, false, 0, 26 )
	description:setFont( CoD.fonts.Big )
	self:addElement( description )
	self.description = description

	local version = LUI.UIText.new()
	version:setLeftRight( true, false, 0, 0 )
	version:setTopBottom( true, false, 0, 26 )
	version:setFont( CoD.fonts.Big )
	self:addElement( version )
	self.version = version

	return self
end

CoD.Mods.LoadMod = function( self, event )
	if CoD.Mods.CurrentModInfo and CoD.Mods.CurrentModInfo.modname ~= nil then
		Engine.Exec( 0, "loadmod " .. CoD.Mods.CurrentModInfo.modname .. "\n" )
	end
end

LUI.createMenu.LoadModModal = function( controller )
	local self = CoD.Menu.NewSmallPopup( "LoadModModal" )
	self.m_ownerController = controller

	self:addBackButton()
	self:addTitle( Engine.Localize( "MOD_LOAD" ) )

	self.buttonList = CoD.ButtonList.new( {
		leftAnchor = true,
		rightAnchor = true,
		left = 0,
		right = 0,
		topAnchor = false,
		bottomAnchor = true,
		top = -CoD.ButtonPrompt.Height * 1 - CoD.CoD9Button.Height * 3 + 10,
		bottom = 0
	} )

	self.yesButton = self.buttonList:addButton( Engine.Localize( "MPUI_YES" ) )
	self.yesButton:registerEventHandler( "button_action", CoD.Mods.LoadMod )
	self.yesButton:processEvent( { name = "gain_focus" } )

	self.cancelButton = self.buttonList:addButton( Engine.Localize( "MPUI_CANCEL" ) )
	self.cancelButton:setActionEventName("button_prompt_back")

	self:addElement( self.buttonList )

	Engine.PlaySound( "cac_loadout_edit_sel" )

	return self
end

CoD.Mods.ModListCreateButtonMutables = function( controller, mutables )
	local text = LUI.UIText.new()
	text:setLeftRight( true, false, 0, 0 )
	text:setTopBottom( true, true, 0, 0 )
	text:setRGB( 1, 1, 1 )
	text:setAlpha( 1 )
	mutables:addElement( text )
	mutables.text = text
end

CoD.Mods.ModListGetButtonData = function( controller, index, mutables, self )
	local modInfo = CoD.Mods.ModsInfo[index]
	if modInfo ~= nil then
		mutables.text:setText( modInfo.name )
	else
		mutables.text:setText( "" )
	end
end

CoD.Mods.ModListBackEventHandler = function( self, event )
	CoD.Menu.ButtonPromptBack( self, event )
end

CoD.Mods.ModListRefreshEventHandler = function( self, event )
	for k in pairs( CoD.Mods.ModsInfo ) do
		CoD.Mods.ModsInfo[k] = nil
	end

	local modCount = Engine.GetModCount()
	for i = 0, modCount - 1, 1 do
		local modInfo = Engine.GetModInfo( i )
		if not modInfo then
			break
		end
		table.insert( CoD.Mods.ModsInfo, modInfo )
	end

	self.listBox:setTotalItems( modCount )
	Engine.PlaySound( "cac_grid_equip_item" )
end

CoD.Mods.ModListUnloadEventHandler = function( self, event )
	if Dvar.fs_game:get() ~= "" then
		Engine.Exec( 0, "loadmod \"\"" )
	end
end

CoD.Mods.ModListFocusChangedEventHandler = function( self, event )
	local focusedIndex = self.listBox:getFocussedIndex()

	local modInfo = CoD.Mods.ModsInfo[focusedIndex]
	if modInfo ~= nil then
		self.modInfo.title:setText( modInfo.name )
		self.modInfo.author:setText( Engine.Localize("MENU_FILESHARE_AUTHOR") .. " " .. modInfo.author )
		self.modInfo.description:setText( Engine.Localize( "MOD_DESCRIPTION", modInfo.description ) )
		self.modInfo.version:setText( Engine.Localize( "MOD_VERSION", modInfo.version ) )
	end
end

CoD.Mods.ModListSelectionClickedEventHandler = function( self, event )
	local focusedIndex = self.listBox:getFocussedIndex()

	local modInfo = CoD.Mods.ModsInfo[focusedIndex]
	if modInfo ~= nil then
		CoD.Mods.CurrentModInfo = modInfo
		self:openPopup( "LoadModModal", event.controller )
		return
	end

	CoD.Mods.CurrentModInfo = nil
end

CoD.Mods.ModListInit = function( self )
	self.leftButtonPromptBar:removeAllChildren()
	self.rightButtonPromptBar:removeAllChildren()
	self:addLeftButtonPrompt( self.backButton )
	self:addRightButtonPrompt( self.unloadButton )
	self:addRightButtonPrompt( self.refreshButton )

	for k in pairs( CoD.Mods.ModsInfo ) do
		CoD.Mods.ModsInfo[k] = nil
	end

	local modCount = Engine.GetModCount()
	for i = 0, modCount - 1, 1 do
		local modInfo = Engine.GetModInfo( i )
		if not modInfo then
			break
		end
		table.insert( CoD.Mods.ModsInfo, modInfo )
	end

	self.listBox:setTotalItems( modCount )
	self.listBox:refresh()
end

LUI.createMenu.Mods = function( controller )
	local self = CoD.Menu.New( "Mods" )
	self.controller = controller

	self:setPreviousMenu( "MainLobby" )
	self:registerEventHandler( "open_menu", CoD.Lobby.OpenMenu )
	self:addSelectButton()
	self:addBackButton()

	self:addTitle( Engine.Localize( "MENU_MODS_CAPS" ) )

	local listBox = CoD.ListBox.new( nil, controller, 15, CoD.CoD9Button.Height, 500, CoD.Mods.ModListCreateButtonMutables, CoD.Mods.ModListGetButtonData, 0, 0 )
	listBox:setLeftRight( true, false, 0, 500 )
	listBox:setTopBottom( true, false, 75, 75 + 530 )
	listBox:addScrollBar( 530 + (8 * 12), 2 )
	listBox.noDataText = Engine.Localize( "MOD_NONE_FOR_MODE", CoD.Mods.ModPrefix )
	self:addElement( listBox )
	self.listBox = listBox

	local modInfo = CoD.ModInfo.new()
	modInfo:setLeftRight( true, false, 550, 550 + 500 )
	modInfo:setTopBottom( true, false, 75, 75 + 530 )
	self:addElement( modInfo )
	self.modInfo = modInfo

	self.backButton = CoD.ButtonPrompt.new( "secondary", Engine.Localize( "MENU_BACK" ), self, "button_prompt_back" )
	self.unloadButton = CoD.ButtonPrompt.new( "alt1", Engine.Localize( "MENU_UNLOAD" ), self, "button_prompt_unload", false, nil, false, nil, "U" )
	self.refreshButton = CoD.ButtonPrompt.new( "alt2", Engine.Localize( "MENU_REFRESH" ), self, "button_prompt_refresh", false, nil, false, nil, "R" )

	self:registerEventHandler( "button_prompt_back", CoD.Mods.ModListBackEventHandler )
	self:registerEventHandler( "button_prompt_refresh", CoD.Mods.ModListRefreshEventHandler )
	self:registerEventHandler( "button_prompt_unload", CoD.Mods.ModListUnloadEventHandler )
	self:registerEventHandler( "listbox_focus_changed", CoD.Mods.ModListFocusChangedEventHandler )
	self:registerEventHandler( "click", CoD.Mods.ModListSelectionClickedEventHandler )

	CoD.Mods.ModListInit( self )

	return self
end
