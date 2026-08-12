CoD.ServerBrowserServerInfo = {}

CoD.ServerBrowserServerInfo.Back = function (self, event)
	self:saveState()
	self:goBack(event.controller)
end

LUI.createMenu.ServerBrowserServerInfo = function ( owner )
	local self = CoD.GameOptionsMenu.New( owner, "ServerBrowserServerInfo" )

	if CoD.isZombie == true then
		self.infoPane:removeElement(self.gametypeIcon)
	end

	self:addTitle( UIExpression.ToUpper(nil, Engine.Localize("MENU_SERVER_INFORMATION")) )

	self.buttonList:addText("")

	local server = CoD.ServerList.Servers[CoD.ServerList.SelectedIndex]

	if server == nil then
		self.buttonList:addText( Engine.Localize("SERVERBROWSER_NO_SERVER_SELECTED") )
	else
		self.connectButton = self.buttonList:addDvarLeftRightSelector( owner, Engine.Localize("MPUI_CONNECT_CAPS"), "", Engine.Localize("SERVERBROWSER_CONNECT_TO_SERVER_HINT") )
		self.connectButton:registerEventHandler( "button_action", CoD.ServerList.InitJoinServer )
		self.connectButton:registerEventHandler( "ui_keyboard_input", CoD.ServerList.EnterPasswordKeyboardInput )

		self.buttonList:addText("")

		self.buttonList:addText(UIExpression.ToUpper(nil, Engine.Localize("EXE_SV_INFO_SERVERNAME")) .. ": " .. server.hostname)
		self.buttonList:addText(Engine.Localize("MENU_MAP_NAME_CAPS") .. ": " .. server.displayable_map)
		self.buttonList:addText(Engine.Localize("MENU_GAME_MODE_CAPS") .. ": " .. server.displayable_gametype)

		if CoD.isZombie then
			self.buttonList:addText(UIExpression.ToUpper(nil, Engine.Localize("ZOMBIE_ROUND")) .. ": " .. server.rounds)
		else
			self.buttonList:addText(UIExpression.ToUpper(nil, Engine.Localize("MENU_RULES_HARDCORE")) .. ": " .. (server.is_hardcore and Engine.Localize("MENU_YES_CAPS") or Engine.Localize("MENU_NO_CAPS")))
		end

		self.buttonList:addText(Engine.Localize("MENU_PING_CAPS") .. ": " .. server.ping)
		self.buttonList:addText(UIExpression.ToUpper(nil, Engine.Localize("EXE_SV_INFO_PASSWORD")) .. ": " .. (server.has_password and Engine.Localize("MENU_YES_CAPS") or Engine.Localize("MENU_NO_CAPS")))

		local modName = server.mod

		if modName ~= "" then
			if server.displayable_mod ~= nil then
				modName = server.displayable_mod
			end

			self.buttonList:addText(UIExpression.ToUpper(nil, Engine.Localize("EXE_SV_INFO_MOD")) .. ": " .. modName)
		end

		self.buttonList:addText(Engine.Localize("MENU_AIM_ASSIST_CAPS") .. ": " .. (server.aim_assist and Engine.Localize("MENU_YES_CAPS") or Engine.Localize("MENU_NO_CAPS")))

		self.buttonList:addText("")

		if server.bots > 0 then
			self.buttonList:addText(Engine.Localize("MENU_PLAYERS_CAPS") .. ": " .. #server.players .. "/" .. server.maxplayers .. " (" .. server.bots .. ")")
		else
			self.buttonList:addText(Engine.Localize("MENU_PLAYERS_CAPS") .. ": " .. #server.players .. "/" .. server.maxplayers)
		end

		local playersPerRow = 4
		local totalRows = math.ceil(#server.players / playersPerRow)

		for row = 1, totalRows, 1 do
			local rowContainer = LUI.UIElement.new({
				leftAnchor = true,
				rightAnchor = false,
				topAnchor = true,
				bottomAnchor = false,
				left = 0,
				top = 0,
				right = 200,
				bottom = CoD.CoD9Button.Height
			})

			local horizontalRowList = LUI.UIHorizontalList.new({
				leftAnchor = true,
				rightAnchor = true,
				topAnchor = true,
				bottomAnchor = true,
				left = 0,
				top = 0,
				right = 0,
				bottom = 0,
				spacing = 0
			})
			rowContainer:addElement(horizontalRowList)

			for col = 1, playersPerRow, 1 do
				local text = LUI.UIText.new({
					leftAnchor = true,
					rightAnchor = true,
					topAnchor = true,
					bottomAnchor = true,
					left = 0,
					top = 0,
					right = 0,
					bottom = 0,
					font = CoD.fonts.ExtraSmall,
					alignment = LUI.Alignment.Left
				})

				local playerIndex = ((row - 1) * playersPerRow) + col
				local player = server.players[playerIndex]

				if player and player.username then
					text:setText(player.username)
				else
					text:setText("")
				end

				horizontalRowList:addElement(text)
			end

			self.buttonList:addElement(rowContainer)
		end
	end

	if not self.buttonList:restoreState() then
		self.buttonList:processEvent( {
			name = "gain_focus"
		} )
	end

	self:registerEventHandler( "button_prompt_back", CoD.ServerBrowserServerInfo.Back )
	return self
end
