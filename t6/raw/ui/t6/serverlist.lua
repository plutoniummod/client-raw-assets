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
CoD.ServerList.TotalWidth = 860
CoD.ServerList.Servers = {}
CoD.ServerList.StoredServers = {}
CoD.ServerList.HoveredServer = nil
CoD.ServerList.HoveredIndex = nil
CoD.ServerList.SelectedServer = nil
CoD.ServerList.SelectedIndex = nil
CoD.ServerList.OpenedOnce = false
CoD.ServerList.EnterPasswordKeyboardOpen = false
CoD.ServerList.JoinTime = nil

CoD.ServerList.UpdateButtonBorders = function(self)
	local button = self.m_firstButton
	while button ~= nil do
		button.body.m_mutables.serverListButton:updateBorder()
		button = button.nextButton
	end
end

CoD.ServerList.HoverServer = function (self, event)
	if Engine.LastInput_Gamepad() then
		if CoD.ServerList.SelectedServer == nil or self.server == nil or CoD.ServerList.SelectedServer.ip ~= self.server.ip or CoD.ServerList.SelectedServer.port ~= self.server.port then
			CoD.ServerList.HoveredServer = nil
			CoD.ServerList.HoveredIndex = nil
			CoD.ServerList.SelectedServer = self.server
			CoD.ServerList.SelectedIndex = self.index
			CoD.ServerList.UpdateButtonBorders(self.parent)
		end
	else
		if CoD.ServerList.HoveredServer == nil or self.server == nil or CoD.ServerList.HoveredServer.ip ~= self.server.ip or CoD.ServerList.HoveredServer.port ~= self.server.port then
			CoD.ServerList.HoveredServer = self.server
			CoD.ServerList.HoveredIndex = self.index
			CoD.ServerList.UpdateButtonBorders(self.parent)
		end
	end
end

CoD.ServerList.SelectServer = function (self, event)
	if CoD.ServerList.SelectedServer == nil or self.server == nil or CoD.ServerList.SelectedServer.ip ~= self.server.ip or CoD.ServerList.SelectedServer.port ~= self.server.port then
		CoD.ServerList.HoveredServer = nil
		CoD.ServerList.HoveredIndex = nil
		CoD.ServerList.SelectedServer = self.server
		CoD.ServerList.SelectedIndex = self.index
		CoD.ServerList.UpdateButtonBorders(self.parent)
		return
	end

	CoD.ServerList.InitJoinServer(self, event)
end

CoD.ServerList.InitJoinServer = function (self, event)
	CoD.ServerList.EnterPasswordKeyboardOpen = false

	CoD.ServerList.JoinServer(self, event)
end

CoD.ServerList.JoinServer = function (self, event)
	if CoD.ServerList.SelectedServer == nil then
		return
	end

	if CoD.ServerList.SelectedServer.has_password and not CoD.ServerList.EnterPasswordKeyboardOpen then
		CoD.ServerList.EnterPasswordKeyboardOpen = true
		Engine.Exec(0, "ui_keyboard_new " .. CoD.KEYBOARD_TYPE_REGISTRATION_INPUT_PASSWORD .. " \"" .. Engine.Localize("MPUI_ENTER_PASSWORD") .. "\" " .. "n/a" .. " " .. 256 .. " " .. 1)
		return
	end

	local now = UIExpression.milliseconds()
	if CoD.ServerList.JoinTime == nil or (now - CoD.ServerList.JoinTime) > 1000 then
		CoD.ServerList.JoinTime = now

		Engine.Exec(event.controller, "stopRefreshServers\n")
		Engine.Exec(event.controller, "connect \"" .. CoD.ServerList.SelectedServer.ip .. ":" .. CoD.ServerList.SelectedServer.port .. "\"\n")
	end
end

CoD.ServerList.EnterPasswordKeyboardInput = function (self, event)
	if not CoD.ServerList.EnterPasswordKeyboardOpen then
		return
	end

	if event.type ~= CoD.KEYBOARD_TYPE_REGISTRATION_INPUT_PASSWORD then
		return
	end

	if CoD.ServerList.SelectedServer == nil or self.server == nil or CoD.ServerList.SelectedServer.ip ~= self.server.ip or CoD.ServerList.SelectedServer.port ~= self.server.port then
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
	CoD.ServerList.SelectedServer = nil
	CoD.ServerList.SelectedIndex = nil
	self:jumpToTop()
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

CoD.ServerList.FindHoveredIndex = function()
	if CoD.ServerList.HoveredServer ~= nil and CoD.ServerList.HoveredIndex ~= nil and CoD.ServerList.HoveredIndex > 1 then
		for index = 1, #CoD.ServerList.Servers, 1 do
			if CoD.ServerList.HoveredServer.ip == CoD.ServerList.Servers[index].ip and CoD.ServerList.HoveredServer.port == CoD.ServerList.Servers[index].port then
				CoD.ServerList.HoveredIndex = index
				return
			end
		end
	end

	CoD.ServerList.HoveredServer = nil
	CoD.ServerList.HoveredIndex = nil
end

CoD.ServerList.FindSelectedIndex = function()
	if CoD.ServerList.SelectedServer ~= nil and CoD.ServerList.SelectedIndex ~= nil and (not Engine.LastInput_Gamepad() or CoD.ServerList.SelectedIndex > 1) then
		for index = 1, #CoD.ServerList.Servers, 1 do
			if CoD.ServerList.SelectedServer.ip == CoD.ServerList.Servers[index].ip and CoD.ServerList.SelectedServer.port == CoD.ServerList.Servers[index].port then
				CoD.ServerList.SelectedIndex = index
				return
			end
		end
	end

	CoD.ServerList.SelectedServer = nil
	CoD.ServerList.SelectedIndex = nil
end

CoD.ServerList.ServerListRefresh = function(self, event)
	if event.servers == nil then
		CoD.ServerList.StoredServers = {}
	else
		local numServers = #event.servers

		for index = 1, numServers, 1 do
			local server = event.servers[index]

			local numStoredServers = #CoD.ServerList.StoredServers
			local foundIndex = numStoredServers + 1

			for indexStore = 1, numStoredServers, 1 do
				local storeServer = CoD.ServerList.StoredServers[indexStore]

				if storeServer.ip == server.ip and storeServer.port == server.port then
					foundIndex = indexStore
					break
				end
			end

			CoD.ServerList.SetDisplayables(server)

			CoD.ServerList.StoredServers[foundIndex] = server
		end
	end

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

	CoD.ServerList.FindHoveredIndex()
	CoD.ServerList.FindSelectedIndex()

	local index = nil

	if CoD.ServerList.SelectedIndex ~= nil then
		index = CoD.ServerList.SelectedIndex
	elseif CoD.ServerList.HoveredIndex ~= nil then
		index = CoD.ServerList.HoveredIndex
	end

	if not CoD.ServerBrowser.PopupOpen then
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

	element.serverListButton:registerEventHandler("button_over", CoD.ServerList.HoverServer)
	element.serverListButton:registerEventHandler("button_action", CoD.ServerList.SelectServer)
	element.serverListButton:registerEventHandler("ui_keyboard_input", CoD.ServerList.EnterPasswordKeyboardInput)
	element:addElement(element.serverListButton)
end

CoD.ServerList.GetButtonData = function (LocalClientIndex, index, element, parent)
	element.serverListButton.server = CoD.ServerList.Servers[index]
	element.serverListButton.parent = parent
	element.serverListButton.index = index
	element.serverListButton:updateBorder()

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

	self:registerEventHandler("server_list_refresh", CoD.ServerList.ServerListRefresh)
	self:registerEventHandler("button_prompt_refresh", CoD.ServerList.ButtonPromptRefresh)
	self:registerEventHandler("serverlist_jumpToTop", CoD.ServerList.JumpToTop)

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

	CoD.ServerList.ServerList = self

	return self
end
