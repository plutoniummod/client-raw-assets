require("T6.ServerListButton")

CoD.ServerList = {}

CoD.ServerList.COLUMN_PASSWORD     = 1
CoD.ServerList.COLUMN_MOD          = 2
CoD.ServerList.COLUMN_SERVER_NAME  = 3
CoD.ServerList.COLUMN_MAP          = 4
CoD.ServerList.COLUMN_ROUND        = CoD.MPZM(nil, 5)
CoD.ServerList.COLUMN_HARDCORE     = CoD.MPZM(5, nil)
CoD.ServerList.COLUMN_GAME_MODE    = 6
CoD.ServerList.COLUMN_PLAYERS      = 7
CoD.ServerList.COLUMN_PING         = 8

CoD.ServerList.Columns = {}

CoD.ServerList.Columns[CoD.ServerList.COLUMN_PASSWORD] = {}
CoD.ServerList.Columns[CoD.ServerList.COLUMN_PASSWORD].Width = 30
CoD.ServerList.Columns[CoD.ServerList.COLUMN_PASSWORD].Icon = "menu_mp_lobby_locked"

CoD.ServerList.Columns[CoD.ServerList.COLUMN_MOD] = {}
CoD.ServerList.Columns[CoD.ServerList.COLUMN_MOD].Width = 30
CoD.ServerList.Columns[CoD.ServerList.COLUMN_MOD].Icon = "menu_mp_lobby_customgame"

CoD.ServerList.Columns[CoD.ServerList.COLUMN_SERVER_NAME] = {}
CoD.ServerList.Columns[CoD.ServerList.COLUMN_SERVER_NAME].Width = 300
CoD.ServerList.Columns[CoD.ServerList.COLUMN_SERVER_NAME].Text = UIExpression.ToUpper(nil, Engine.Localize("MENU_SERVERNAME"))

CoD.ServerList.Columns[CoD.ServerList.COLUMN_MAP] = {}
CoD.ServerList.Columns[CoD.ServerList.COLUMN_MAP].Width = 130
CoD.ServerList.Columns[CoD.ServerList.COLUMN_MAP].Text = Engine.Localize("MENU_MAP_NAME_CAPS")

if CoD.isZombie then
	CoD.ServerList.Columns[CoD.ServerList.COLUMN_ROUND] = {}
	CoD.ServerList.Columns[CoD.ServerList.COLUMN_ROUND].Width = 30
	CoD.ServerList.Columns[CoD.ServerList.COLUMN_ROUND].Icon = "hud_chalk_5"
	CoD.ServerList.Columns[CoD.ServerList.COLUMN_ROUND].IconTextRows = true
else
	CoD.ServerList.Columns[CoD.ServerList.COLUMN_HARDCORE] = {}
	CoD.ServerList.Columns[CoD.ServerList.COLUMN_HARDCORE].Width = 30
	CoD.ServerList.Columns[CoD.ServerList.COLUMN_HARDCORE].Icon = "hud_status_dead"
end

CoD.ServerList.Columns[CoD.ServerList.COLUMN_GAME_MODE] = {}
CoD.ServerList.Columns[CoD.ServerList.COLUMN_GAME_MODE].Width = 130
CoD.ServerList.Columns[CoD.ServerList.COLUMN_GAME_MODE].Text = Engine.Localize("MENU_GAME_MODE_CAPS")

CoD.ServerList.Columns[CoD.ServerList.COLUMN_PLAYERS] = {}
CoD.ServerList.Columns[CoD.ServerList.COLUMN_PLAYERS].Width = 105
CoD.ServerList.Columns[CoD.ServerList.COLUMN_PLAYERS].Text = Engine.Localize("MENU_PLAYERS_CAPS")

CoD.ServerList.Columns[CoD.ServerList.COLUMN_PING] = {}
CoD.ServerList.Columns[CoD.ServerList.COLUMN_PING].Width = 75
CoD.ServerList.Columns[CoD.ServerList.COLUMN_PING].Text = Engine.Localize("MENU_PING_CAPS")

CoD.ServerList.RowHeight = CoD.CoD9Button.Height
CoD.ServerList.ColumnSpacing = 5
CoD.ServerList.NumElements = 18
CoD.ServerList.TotalWidth = 0

for Column = 1, #CoD.ServerList.Columns, 1 do
	CoD.ServerList.TotalWidth = CoD.ServerList.TotalWidth + CoD.ServerList.Columns[Column].Width

	if Column < #CoD.ServerList.Columns then
		CoD.ServerList.TotalWidth = CoD.ServerList.TotalWidth + CoD.ServerList.ColumnSpacing
	end
end

CoD.ServerList.Servers = {}
CoD.ServerList.StoredServers = {}
CoD.ServerList.SelectedIndex = nil
CoD.ServerList.HoveredIndex = nil
CoD.ServerList.HasSelected = false
CoD.ServerList.FocusSelected = false
CoD.ServerList.Generating = false
CoD.ServerList.HoldingUpButton = false
CoD.ServerList.HoldingDownButton = false
CoD.ServerList.OpenedOnce = false
CoD.ServerList.EnterPasswordKeyboardOpen = false
CoD.ServerList.JoinTime = nil

CoD.ServerList.UpdateButtons = function(self)
	local button = self.m_firstButton
	while button ~= nil do
		local serverListButton = button.body.m_mutables.serverListButton

		if CoD.ServerList.SelectedIndex ~= nil and serverListButton.index ~= nil and CoD.ServerList.SelectedIndex == serverListButton.index then
			button.body.buttonBorder:show()
		else
			button.body.buttonBorder:hide()
		end

		if CoD.ServerList.HoveredIndex ~= nil and serverListButton.index ~= nil and CoD.ServerList.HoveredIndex == serverListButton.index and CoD.ServerList.SelectedIndex ~= serverListButton.index then
			button.body.buttonBg:setRGB(1, 1, 1)
		else
			button.body.buttonBg:setRGB(0, 0, 0)
		end

		button = button.nextButton
	end
end

CoD.ServerList.SetPositionText = function (self)
	local textField = self.m_positionText.textFieldSelected
	local text = ""

	if CoD.ServerList.SelectedIndex ~= nil then
		text = Engine.Localize(CoD.ListBox.POSITION_TEXT_DEFAULT, CoD.ServerList.SelectedIndex, self.m_totalItems)
	end

	textField:setText(text)

	local _, __, textWidth, ___ = GetTextDimensions(text .. " ", textField.font, textField.fontHeight)

	textField:setLeftRight(false, false, 0, math.abs(textWidth))
end

CoD.ServerList.Generate = function(self, index)
	CoD.ServerList.Generating = true

	if CoD.ServerList.SelectedIndex == nil then
		CoD.ServerList.HasSelected = false

		if #CoD.ServerList.Servers > 0 then
			CoD.ServerList.SelectedIndex = 1
		end
	end

	local relativeHoveredIndex = nil

	if CoD.ServerList.HoveredIndex ~= nil then
		relativeHoveredIndex = CoD.ServerList.HoveredIndex - self.m_pageStartIndex
	end

	self:generateOld(index)

	if relativeHoveredIndex ~= nil then
		CoD.ServerList.HoveredIndex = self.m_pageStartIndex + relativeHoveredIndex
		CoD.ServerList.UpdateButtons(self)
	end

	CoD.ServerList.SetPositionText(self)

	CoD.ServerList.Generating = false
end

CoD.ServerList.HandleGamepadButton = function (self, event)
	if LUI.UIElement.handleGamepadButton(self, event) then
		return true
	elseif event.button == self.buttonName and not event.buttonRepeat then
		local serverList = self:getParent()

		if event.qualifier == "mwheel" then
			if event.down == true then
				CoD.ServerList.FocusSelected = false

				local index = serverList.m_pageStartIndex + math.floor(serverList.m_numButtons / 2)

				if event.button == "up" then
					local pageEndIndex = serverList.m_pageStartIndex + serverList.m_numButtons - 1

					-- have to move up 1 more at the bottom of the list
					if pageEndIndex >= serverList.m_totalItems then
						index = index - 2
					else
						index = index - 1
					end
				elseif event.button == "down" then
					index = index + 1
				end

				local prevHoveredIndex = CoD.ServerList.HoveredIndex

				serverList:generate(index)

				if CoD.ServerList.HoveredIndex ~= prevHoveredIndex then
					Engine.PlaySound("cac_grid_nav")
				end
			end
		else
			if event.button == "up" then
				CoD.ServerList.HoldingUpButton = false
			elseif event.button == "down" then
				CoD.ServerList.HoldingDownButton = false
			end

			self:cancelRepetition()

			if event.down == true then
				if event.button == "up" then
					CoD.ServerList.HoldingUpButton = true
				elseif event.button == "down" then
					CoD.ServerList.HoldingDownButton = true
				end

				CoD.ServerList.HoveredIndex = nil

				serverList:generate(CoD.ServerList.SelectedIndex)

				self.controller = event.controller

				local repeatTimer = LUI.UITimer.new(self.firstDelay, {
					name = "repeat",
					numRepeats = 1
				})
				self:addElement(repeatTimer)
				self.repeatTimer = repeatTimer

				if event.name ~= self.event.name then
					self:sendButtonRepeat()
				end
			end
		end
	end
end

CoD.ServerList.UnhoverServer = function (self, event)
	if CoD.ServerList.HoveredIndex ~= self.index then
		return
	end

	CoD.ServerList.HoveredIndex = nil
	CoD.ServerList.UpdateButtons(self.parent)
end

CoD.ServerList.HoverServer = function (self, event)
	if CoD.ServerList.HoldingUpButton or CoD.ServerList.HoldingDownButton then
		CoD.ServerList.HasSelected = true
		CoD.ServerList.FocusSelected = true
		CoD.ServerList.SelectedIndex = self.index
		CoD.ServerList.HoveredIndex = nil
		CoD.ServerList.UpdateButtons(self.parent)
		CoD.ServerList.SetPositionText(self.parent)
		return
	end

	if CoD.ServerList.Generating then
		return
	end

	CoD.ServerList.FocusSelected = false

	if CoD.ServerList.HoveredIndex == nil or self.index == nil or CoD.ServerList.HoveredIndex ~= self.index then
		CoD.ServerList.HoveredIndex = self.index
		CoD.ServerList.UpdateButtons(self.parent)
	end
end

CoD.ServerList.SelectServer = function (self, event)
	CoD.ServerList.HasSelected = true

	if CoD.ServerList.SelectedIndex == nil or self.index == nil or CoD.ServerList.SelectedIndex ~= self.index then
		Engine.PlaySound("cac_grid_nav")
		CoD.ServerList.SelectedIndex = self.index
		CoD.ServerList.UpdateButtons(self.parent)
		CoD.ServerList.SetPositionText(self.parent)
		return
	end

	Engine.PlaySound("cac_grid_equip_item")
	CoD.ServerList.InitJoinServer(self, event)
end

CoD.ServerList.InitJoinServer = function (self, event)
	CoD.ServerList.EnterPasswordKeyboardOpen = false

	CoD.ServerList.JoinServer(self, event)
end

CoD.ServerList.JoinServer = function (self, event)
	local server = CoD.ServerList.Servers[CoD.ServerList.SelectedIndex]

	if server == nil then
		return
	end

	if server.has_password and not CoD.ServerList.EnterPasswordKeyboardOpen then
		CoD.ServerList.EnterPasswordKeyboardOpen = true
		Engine.Exec(0, "ui_keyboard_new " .. CoD.KEYBOARD_TYPE_REGISTRATION_INPUT_PASSWORD .. " \"" .. Engine.Localize("MPUI_ENTER_PASSWORD") .. "\" " .. "n/a" .. " " .. 256 .. " " .. 1)
		return
	end

	local now = UIExpression.milliseconds()

	if CoD.ServerList.JoinTime ~= nil and (now - CoD.ServerList.JoinTime) <= 1000 then
		return
	end

	CoD.ServerList.JoinTime = now

	Engine.Exec(event.controller, "stopRefreshServers\n")
	Engine.Exec(event.controller, "connect \"" .. server.ip .. ":" .. server.port .. "\"\n")
end

CoD.ServerList.EnterPasswordKeyboardInput = function (self, event)
	if not CoD.ServerList.EnterPasswordKeyboardOpen then
		return
	end

	if event.type ~= CoD.KEYBOARD_TYPE_REGISTRATION_INPUT_PASSWORD then
		return
	end

	if CoD.ServerList.SelectedIndex == nil or self.index == nil or CoD.ServerList.SelectedIndex ~= self.index then
		return
	end

	if event.input ~= nil then
		Engine.ExecNow(event.controller, "set password \"" .. event.input .. "\"\n")
	end

	CoD.ServerList.JoinServer(self, event)
end

CoD.ServerList.ButtonPromptRefresh = function (self, event)
	Engine.PlaySound("cac_grid_equip_item")
	Engine.Exec(event.controller, "refreshServers\n")
end

CoD.ServerList.JumpToTop = function (self, event)
	if self.m_totalItems == 0 then
		return
	end

	if CoD.ServerList.FocusSelected then
		CoD.ServerList.SelectedIndex = nil
	end

	Engine.PlaySound("cac_grid_nav")
	self:generate()
end

CoD.ServerList.SetDisplayables = function(server)
	if CoD.isZombie then
		if server.gametype == "zclassic" then
			server.displayable_gametype = Engine.Localize("MPUI_ZCLASSIC")

			local reference_map = UIExpression.TableLookup(nil, CoD.gametypesTable, 0, 0, 1, server.gametype, 7)

			if server.map ~= "zm_transit" then
				reference_map = UIExpression.ToUpper(nil, reference_map .. "_" .. server.map)
			end

			server.displayable_map = Engine.Localize(reference_map)

			if string.find(server.displayable_map, reference_map, 1, true) then
				server.displayable_map = server.map
			end
		else
			local reference_gametype = UIExpression.TableLookup(nil, CoD.gametypesTable, 0, 0, 1, server.gametype, 7)

			if reference_gametype == "" then
				server.displayable_gametype = server.gametype
			else
				server.displayable_gametype = Engine.Localize(reference_gametype)

				if string.find(server.displayable_gametype, reference_gametype, 1, true) then
					server.displayable_gametype = server.gametype
				end
			end

			local reference_map = UIExpression.TableLookup(nil, CoD.gametypesTable, 0, 5, 3, server.location, 16)

			if reference_map == "" then
				server.displayable_map = server.location
			else
				server.displayable_map = Engine.Localize(reference_map)

				if string.find(server.displayable_map, reference_map, 1, true) then
					server.displayable_map = server.location
				end
			end

			-- .displayable_map can be empty if .location is empty which happens if server hasn't been updated
			if server.displayable_map == "" then
				local reference_map = UIExpression.TableLookup(nil, CoD.mapsTable, 0, server.map, 3)

				if reference_map == "" then
					server.displayable_map = server.map
				else
					server.displayable_map = Engine.Localize(reference_map)

					if string.find(server.displayable_map, reference_map, 1, true) then
						server.displayable_map = server.map
					end
				end
			end
		end
	else
		local reference_gametype = UIExpression.TableLookup(nil, CoD.gametypesTable, 0, 0, 1, server.gametype, 7)

		if reference_gametype == "" then
			server.displayable_gametype = server.gametype
		else
			server.displayable_gametype = Engine.Localize(reference_gametype)

			if string.find(server.displayable_gametype, reference_gametype, 1, true) then
				server.displayable_gametype = server.gametype
			end
		end

		local reference_map = UIExpression.TableLookup(nil, CoD.mapsTable, 0, server.map, 3)

		if reference_map == "" then
			server.displayable_map = server.map
		else
			server.displayable_map = Engine.Localize(reference_map)

			if string.find(server.displayable_map, reference_map, 1, true) then
				server.displayable_map = server.map
			end
		end
	end

	if server.displayable_gametype == nil then
		server.displayable_gametype = ""
	end

	if server.displayable_map == nil then
		server.displayable_map = ""
	end
end

CoD.ServerList.FilterFunc = function(server)
	local searchFilter = string.lower(UIExpression.DvarString(0, "ui_serverbrowser_searchfilter"))

	if searchFilter ~= "" then
		local hostname = string.lower(server.hostname)
		local displayable_map = string.lower(server.displayable_map)
		local displayable_gametype = string.lower(server.displayable_gametype)

		if not string.find(hostname, searchFilter, 1, true) and not string.find(displayable_map, searchFilter, 1, true) and not string.find(displayable_gametype, searchFilter, 1, true) then
			return false
		end
	end

	if tonumber(server.ping) > UIExpression.DvarInt(0, "ui_serverbrowser_searchfilter_maxping") then
		return false
	end

	if UIExpression.DvarBool(0, "ui_serverbrowser_searchfilter_emptyservers") == 0 then
		if #server.players == 0 then
			return false
		end
	end

	if UIExpression.DvarBool(0, "ui_serverbrowser_searchfilter_fullservers") == 0 then
		if #server.players == server.maxplayers then
			return false
		end
	end

	local passwordProtect = UIExpression.DvarInt(0, "ui_serverbrowser_searchfilter_passwordprotected")
	if passwordProtect == 0 then
		if server.has_password then
			return false
		end
	elseif passwordProtect == 1 then
		if not server.has_password then
			return false
		end
	end

	local mods = UIExpression.DvarInt(0, "ui_serverbrowser_searchfilter_mods")
	if mods == 0 then
		if server.mod ~= "" then
			return false
		end
	elseif mods == 1 then
		if server.mod == "" then
			return false
		end
	end

	local aim_assist = UIExpression.DvarInt(0, "ui_serverbrowser_searchfilter_aimassist")
	if aim_assist == 0 then
		if server.aim_assist then
			return false
		end
	elseif aim_assist == 1 then
		if not server.aim_assist then
			return false
		end
	end

	local lowerHostname = string.lower(server.hostname)
	if UIExpression.DvarBool(0, "ui_serverbrowser_searchfilter_hidebrainrot") == 1 then
		if CoD.isZombie then
			if string.find(lowerHostname, "bank", 1, true) then
				return false
			end
		else
			if string.find(lowerHostname, "sniper", 1, true) or string.find(lowerHostname, "trickshot", 1, true) then
				return false
			end
		end
	end

	local gametype = UIExpression.DvarString(0, "ui_serverbrowser_searchfilter_gamemode")
	if gametype ~= "" then
		if server.gametype ~= gametype then
			return false
		end
	end

	local map = UIExpression.DvarString(0, "ui_serverbrowser_searchfilter_map")
	if map ~= "" then
		if map == "zm_transit" then
			if server.map ~= map and server.map ~= "zm_transit_dr" then
				return false
			end
		else
			if server.map ~= map then
				return false
			end
		end
	end

	if not CoD.isZombie then
		local hard_core = UIExpression.DvarInt(0, "ui_serverbrowser_searchfilter_hardcore")
		if hard_core == 0 then
			if server.is_hardcore then
				return false
			end
		elseif hard_core == 1 then
			if not server.is_hardcore then
				return false
			end
		end
	end

	return true
end

CoD.ServerList.SortFunc = function(server1, server2)
	local val1, val2
	local sortHeader = UIExpression.DvarInt(0, "ui_serverbrowser_sortheader")

	if sortHeader == CoD.ServerList.COLUMN_PASSWORD then
		val1, val2 = server1.has_password and 0 or 1, server2.has_password and 0 or 1
	elseif sortHeader == CoD.ServerList.COLUMN_MOD then
		val1, val2 = server1.mod ~= "" and 0 or 1, server2.mod ~= "" and 0 or 1
	elseif sortHeader == CoD.ServerList.COLUMN_SERVER_NAME then
		val1, val2 = string.lower(server1.hostname), string.lower(server2.hostname)
	elseif sortHeader == CoD.ServerList.COLUMN_MAP then
		val1, val2 = string.lower(server1.displayable_map), string.lower(server2.displayable_map)
	elseif sortHeader == CoD.ServerList.COLUMN_ROUND then
		val1, val2 = tonumber(server1.rounds), tonumber(server2.rounds)
	elseif sortHeader == CoD.ServerList.COLUMN_HARDCORE then
		val1, val2 = server1.is_hardcore and 0 or 1, server2.is_hardcore and 0 or 1
	elseif sortHeader == CoD.ServerList.COLUMN_GAME_MODE then
		val1, val2 = string.lower(server1.displayable_gametype), string.lower(server2.displayable_gametype)
	elseif sortHeader == CoD.ServerList.COLUMN_PLAYERS then
		val1, val2 = tonumber(#server1.players), tonumber(#server2.players)
	elseif sortHeader == CoD.ServerList.COLUMN_PING then
		val1, val2 = tonumber(server1.ping), tonumber(server2.ping)
	end

	if val1 == val2 then
		local name1, name2 = string.lower(server1.hostname), string.lower(server2.hostname)

		return name1 < name2
	else
		if UIExpression.DvarBool(0, "ui_serverbrowser_sortheader_reverse") == 1 then
			return val1 > val2
		else
			return val1 < val2
		end
	end
end

CoD.ServerList.FindServerIndex = function(server)
	if server ~= nil then
		for index = 1, #CoD.ServerList.Servers, 1 do
			if server.ip == CoD.ServerList.Servers[index].ip and server.port == CoD.ServerList.Servers[index].port then
				return index
			end
		end
	end

	return nil
end

CoD.ServerList.StoredServerListRefresh = function(self, event)
	if event.servers == nil then
		CoD.ServerList.StoredServers = {}
	else
		local numServers = #event.servers

		for index = 1, numServers, 1 do
			local server = event.servers[index]

			local numStoredServers = #CoD.ServerList.StoredServers
			local foundIndex = numStoredServers + 1

			for storedIndex = 1, numStoredServers, 1 do
				local storedServer = CoD.ServerList.StoredServers[storedIndex]

				if storedServer.ip == server.ip and storedServer.port == server.port then
					foundIndex = storedIndex
					break
				end
			end

			CoD.ServerList.SetDisplayables(server)

			CoD.ServerList.StoredServers[foundIndex] = server
		end
	end

	CoD.ServerList.ServerListRefresh(self, event)
end

CoD.ServerList.ServerListRefresh = function(self, event)
	local prevSelectedIndex = CoD.ServerList.SelectedIndex
	local prevHoveredIndex = CoD.ServerList.HoveredIndex

	if prevHoveredIndex == nil then
		prevHoveredIndex = self.m_pageStartIndex
	end

	local selectedServer = CoD.ServerList.Servers[prevSelectedIndex]
	local hoveredServer = CoD.ServerList.Servers[prevHoveredIndex]
	local relativeHoveredIndex = prevHoveredIndex - self.m_pageStartIndex

	CoD.ServerList.Servers = {}
	local numServers = #CoD.ServerList.StoredServers

	for index = 1, numServers, 1 do
		local server = CoD.ServerList.StoredServers[index]

		local matchesFilter = CoD.ServerList.FilterFunc(server)

		if matchesFilter then
			CoD.ServerList.Servers[#CoD.ServerList.Servers + 1] = server
		end
	end

	table.sort(CoD.ServerList.Servers, CoD.ServerList.SortFunc)

	if CoD.ServerList.HasSelected then
		CoD.ServerList.SelectedIndex = CoD.ServerList.FindServerIndex(selectedServer)
	else
		CoD.ServerList.SelectedIndex = nil
	end

	if not CoD.ServerBrowser.PopupOpen then
		local index = nil

		if CoD.ServerList.FocusSelected then
			index = CoD.ServerList.SelectedIndex
		else
			if self.m_pageStartIndex <= 1 then
				index = 1
			elseif (self.m_pageStartIndex + self.m_numButtons - 1) >= self.m_totalItems then
				index = #CoD.ServerList.Servers
			else
				local hoveredIndex = CoD.ServerList.FindServerIndex(hoveredServer)

				if hoveredIndex == nil then
					hoveredIndex = self.m_pageStartIndex
				end

				index = hoveredIndex + math.floor(self.m_numButtons / 2) - relativeHoveredIndex
			end
		end

		self:setTotalItems(#CoD.ServerList.Servers, index)
	end
end

CoD.ServerList.CreateButtonMutables = function (LocalClientIndex, element, mutables)
	element.serverListButton = CoD.ServerListButton.new({
		left = 0,
		top = 0,
		right = 0,
		bottom = CoD.ServerList.RowHeight,
		leftAnchor = true,
		topAnchor = true,
		rightAnchor = true,
		bottomAnchor = false,
		spacing = CoD.ServerList.ColumnSpacing
	}, LocalClientIndex)

	element.serverListButton:registerEventHandler("button_up", CoD.ServerList.UnhoverServer)
	element.serverListButton:registerEventHandler("button_over", CoD.ServerList.HoverServer)
	element.serverListButton:registerEventHandler("button_action", CoD.ServerList.SelectServer)
	element.serverListButton:registerEventHandler("ui_keyboard_input", CoD.ServerList.EnterPasswordKeyboardInput)
	element:addElement(element.serverListButton)
end

CoD.ServerList.GetButtonData = function (LocalClientIndex, index, element, parent)
	element.serverListButton.server = CoD.ServerList.Servers[index]
	element.serverListButton.parent = parent
	element.serverListButton.index = index

	local ColumnValues = {}
	ColumnValues[CoD.ServerList.COLUMN_PASSWORD] = element.serverListButton.server.has_password
	ColumnValues[CoD.ServerList.COLUMN_MOD] = element.serverListButton.server.mod ~= ""
	ColumnValues[CoD.ServerList.COLUMN_SERVER_NAME] = element.serverListButton.server.hostname
	ColumnValues[CoD.ServerList.COLUMN_MAP] = element.serverListButton.server.displayable_map

	if CoD.isZombie then
		ColumnValues[CoD.ServerList.COLUMN_ROUND] = element.serverListButton.server.rounds
	else
		ColumnValues[CoD.ServerList.COLUMN_HARDCORE] = element.serverListButton.server.is_hardcore
	end

	ColumnValues[CoD.ServerList.COLUMN_GAME_MODE] = element.serverListButton.server.displayable_gametype

	if element.serverListButton.server.bots > 0 then
		ColumnValues[CoD.ServerList.COLUMN_PLAYERS] = #element.serverListButton.server.players .. "/" .. element.serverListButton.server.maxplayers .. " (" .. element.serverListButton.server.bots .. ")"
	else
		ColumnValues[CoD.ServerList.COLUMN_PLAYERS] = #element.serverListButton.server.players .. "/" .. element.serverListButton.server.maxplayers
	end

	ColumnValues[CoD.ServerList.COLUMN_PING] = element.serverListButton.server.ping

	for Column = 1, #CoD.ServerList.Columns, 1 do
		if element.serverListButton.Columns[Column].Icon ~= nil then
			if ColumnValues[Column] then
				element.serverListButton.Columns[Column].Icon:setImage(RegisterMaterial(CoD.ServerList.Columns[Column].Icon))
				element.serverListButton.Columns[Column].Icon:setAlpha(1)
			else
				element.serverListButton.Columns[Column].Icon:setAlpha(0)
			end
		elseif element.serverListButton.Columns[Column].Text ~= nil then
			element.serverListButton.Columns[Column].Text:setText(ColumnValues[Column])

			local scale = 0.5
			local maxTextWidth = CoD.ServerList.Columns[Column].Width - (CoD.ServerListButton.TextOffset * 2)
			local _, __, textWidth, ___ = GetTextDimensions(ColumnValues[Column], CoD.ServerListButton.Font, CoD.ServerListButton.TextHeight)

			if textWidth > maxTextWidth then
				scale = scale * (maxTextWidth / textWidth)
			end

			element.serverListButton.Columns[Column].Text:setTopBottom(false, false, -CoD.ServerListButton.TextHeight * scale, CoD.ServerListButton.TextHeight * scale)
		end
	end
end

CoD.ServerList.ResetDvars = function ()
	Engine.ExecNow(0, "set ui_serverbrowser_searchfilter \"\"\n")
	Engine.ExecNow(0, "set ui_serverbrowser_searchfilter_maxping 1000\n")
	Engine.ExecNow(0, "set ui_serverbrowser_searchfilter_emptyservers 1\n")
	Engine.ExecNow(0, "set ui_serverbrowser_searchfilter_fullservers 1\n")
	Engine.ExecNow(0, "set ui_serverbrowser_searchfilter_passwordprotected 2\n")
	Engine.ExecNow(0, "set ui_serverbrowser_searchfilter_mods 2\n")
	Engine.ExecNow(0, "set ui_serverbrowser_searchfilter_aimassist 2\n")
	Engine.ExecNow(0, "set ui_serverbrowser_searchfilter_hidebrainrot 0\n")
	Engine.ExecNow(0, "set ui_serverbrowser_searchfilter_gamemode \"\"\n")
	Engine.ExecNow(0, "set ui_serverbrowser_searchfilter_map \"\"\n")

	if not CoD.isZombie then
		Engine.ExecNow(0, "set ui_serverbrowser_searchfilter_hardcore 2\n")
	end

	Engine.ExecNow(0, "set ui_serverbrowser_sortheader " .. CoD.ServerList.COLUMN_PING .. "\n")
	Engine.ExecNow(0, "set ui_serverbrowser_sortheader_reverse 0\n")
end

CoD.ServerList.new = function (defaultAnimationState, LocalClientIndex)
	local self = CoD.ListBox.new(defaultAnimationState, LocalClientIndex, CoD.ServerList.NumElements, CoD.ServerList.RowHeight, CoD.ServerList.TotalWidth, CoD.ServerList.CreateButtonMutables, CoD.ServerList.GetButtonData)

	self.id = "ServerList"
	self:addScrollBar()

	self.generateOld = self.generate
	self.generate = CoD.ServerList.Generate

	self.buttonRepeaterUp.handleGamepadButton = CoD.ServerList.HandleGamepadButton
	self.buttonRepeaterDown.handleGamepadButton = CoD.ServerList.HandleGamepadButton
	self.buttonRepeaterClick.handleGamepadButton = CoD.ServerList.HandleGamepadButton

	self.m_positionTextString = ""

	self.m_positionText.textFieldSelected = LUI.UIText.new({
		left = 0,
		top = -CoD.textSize.ExtraSmall / 2,
		right = 0,
		bottom = CoD.textSize.ExtraSmall / 2,
		leftAnchor = false,
		topAnchor = false,
		rightAnchor = false,
		bottomAnchor = false,
		font = CoD.fonts.ExtraSmall,
		alignment = LUI.Alignment.Left
	})
	self.m_positionText.textFieldSelected.font = CoD.fonts.ExtraSmall
	self.m_positionText.textFieldSelected.fontHeight = -CoD.textSize.ExtraSmall / 2 - CoD.textSize.ExtraSmall / 2
	self.m_positionText:addElement(self.m_positionText.textFieldSelected)

	-- update buttons after everything else
	self:registerEventHandler("listbox_button_gain_focus", CoD.ServerList.UpdateButtons)
	self:registerEventHandler("listbox_button_lose_focus", CoD.ServerList.UpdateButtons)

	self:registerEventHandler("server_list_refresh", CoD.ServerList.StoredServerListRefresh)
	self:registerEventHandler("button_prompt_refresh", CoD.ServerList.ButtonPromptRefresh)
	self:registerEventHandler("serverlist_jumpToTop", CoD.ServerList.JumpToTop)

	CoD.ServerList.ServerList = self

	CoD.ServerList.HoveredIndex = nil

	if not CoD.ServerList.OpenedOnce then
		CoD.ServerList.OpenedOnce = true

		if UIExpression.DvarString(nil, "ui_serverbrowser_sortheader") == "" then
			CoD.ServerList.ResetDvars()
		end

		Engine.GetModCount() -- need this for .displayable_mod to work

		self:processEvent( {
			name = "serverlist_jumpToTop"
		} )

		self:processEvent( {
			name = "button_prompt_refresh"
		} )
	end

	self:processEvent( {
		name = "server_list_refresh",
		servers = {}
	} )

	return self
end
