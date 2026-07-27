CoD.ServerBrowserServerInfo = {}

CoD.ServerBrowserServerInfo.Back = function (self, event)
	self:saveState()
	self:goBack(event.controller)
end

CoD.ServerBrowserServerInfo.Select = function (self, event)
	CoD.ServerList.SelectedFromServerInfo = true
	CoD.ServerList.SelectServer(self, event)
	CoD.ServerList.SelectedFromServerInfo = nil
end

CoD.ServerBrowserServerInfo.Join = function (self, event)
	CoD.ServerList.SelectedFromServerInfo = true
	CoD.ServerList.JoinServer(self, event)
	CoD.ServerList.SelectedFromServerInfo = nil
end

LUI.createMenu.ServerBrowserServerInfo = function ( owner )
	local self = CoD.GameOptionsMenu.New( owner, "ServerBrowserServerInfo" )

	if CoD.isZombie == true then
		self.infoPane:removeElement(self.gametypeIcon)
	end

	self:addTitle( UIExpression.ToUpper(nil, Engine.Localize("MENU_SERVER_INFORMATION")) )

	self.buttonList:addText("")

	if CoD.ServerList.SelectedServer == nil then
		self.buttonList:addText( Engine.Localize("SERVERBROWSER_NO_SERVER_SELECTED") )
	else
		self.connectButton = self.buttonList:addDvarLeftRightSelector( owner, Engine.Localize("MPUI_CONNECT_CAPS"), "", Engine.Localize("SERVERBROWSER_CONNECT_TO_SERVER_HINT") )
		self.connectButton:registerEventHandler( "button_action", CoD.ServerBrowserServerInfo.Select )
		self.connectButton:registerEventHandler( "ui_keyboard_input", CoD.ServerBrowserServerInfo.Join )

		self.buttonList:addText("")

		self.buttonList:addText(UIExpression.ToUpper(nil, Engine.Localize("EXE_SV_INFO_SERVERNAME")) .. ": " .. CoD.ServerList.SelectedServer.hostname)
		self.buttonList:addText(Engine.Localize("MENU_MAP_NAME_CAPS") .. ": " .. CoD.ServerList.SelectedServer.displayable_map)
		self.buttonList:addText(Engine.Localize("MENU_GAME_MODE_CAPS") .. ": " .. CoD.ServerList.SelectedServer.displayable_gametype)

		if CoD.isZombie then
			self.buttonList:addText(UIExpression.ToUpper(nil, Engine.Localize("ZOMBIE_ROUND")) .. ": " .. CoD.ServerList.SelectedServer.rounds)
		else
			self.buttonList:addText(UIExpression.ToUpper(nil, Engine.Localize("MENU_RULES_HARDCORE")) .. ": " .. (CoD.ServerList.SelectedServer.is_hardcore and Engine.Localize("MENU_YES_CAPS") or Engine.Localize("MENU_NO_CAPS")))
		end

		self.buttonList:addText(Engine.Localize("MENU_PING_CAPS") .. ": " .. CoD.ServerList.SelectedServer.ping)
		self.buttonList:addText(UIExpression.ToUpper(nil, Engine.Localize("EXE_SV_INFO_PASSWORD")) .. ": " .. (CoD.ServerList.SelectedServer.has_password and Engine.Localize("MENU_YES_CAPS") or Engine.Localize("MENU_NO_CAPS")))

		local modName = CoD.ServerList.SelectedServer.mod

		if modName ~= "" then
            if CoD.ServerList.SelectedServer.displayable_mod ~= "" then
                modName = CoD.ServerList.SelectedServer.displayable_mod
            end

            self.buttonList:addText(UIExpression.ToUpper(nil, Engine.Localize("EXE_SV_INFO_MOD")) .. ": " .. modName)
		end

		self.buttonList:addText("")

		if CoD.ServerList.SelectedServer.bots > 0 then
			self.buttonList:addText(Engine.Localize("MENU_PLAYERS_CAPS") .. ": " .. #CoD.ServerList.SelectedServer.players .. "/" .. CoD.ServerList.SelectedServer.maxplayers .. " (" .. CoD.ServerList.SelectedServer.bots .. ")")
		else
			self.buttonList:addText(Engine.Localize("MENU_PLAYERS_CAPS") .. ": " .. #CoD.ServerList.SelectedServer.players .. "/" .. CoD.ServerList.SelectedServer.maxplayers)
		end

        local playersPerRow = 4
        local totalRows = math.ceil(#CoD.ServerList.SelectedServer.players / playersPerRow)

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
                local player = CoD.ServerList.SelectedServer.players[playerIndex]

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
