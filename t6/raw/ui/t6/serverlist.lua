require("T6.ServerListButton")

CoD.ServerList = {}
CoD.ServerList.Columns = {}
CoD.ServerList.Columns[1] = {}
CoD.ServerList.Columns[1].Width = 30
CoD.ServerList.Columns[1].Sortable = 0
CoD.ServerList.Columns[1].Text = ""
CoD.ServerList.Columns[1].Icon = "hud_server_locked"
CoD.ServerList.Columns[2] = {}
CoD.ServerList.Columns[2].Width = 300
CoD.ServerList.Columns[2].Sortable = 1
CoD.ServerList.Columns[2].Text = UIExpression.ToUpper(nil, Engine.Localize("MENU_SERVERNAME"))
CoD.ServerList.Columns[2].Icon = ""
CoD.ServerList.Columns[3] = {}
CoD.ServerList.Columns[3].Width = 165
CoD.ServerList.Columns[3].Sortable = 1
CoD.ServerList.Columns[3].Text = Engine.Localize("MENU_MAP_NAME_CAPS")
CoD.ServerList.Columns[3].Icon = ""
CoD.ServerList.Columns[4] = {}
CoD.ServerList.Columns[4].Width = 165
CoD.ServerList.Columns[4].Sortable = 1
CoD.ServerList.Columns[4].Text = Engine.Localize("MENU_GAME_MODE_CAPS")
CoD.ServerList.Columns[4].Icon = ""
CoD.ServerList.Columns[5] = {}
CoD.ServerList.Columns[5].Width = 105
CoD.ServerList.Columns[5].Sortable = 1
CoD.ServerList.Columns[5].Text = Engine.Localize("MENU_PLAYERS_CAPS")
CoD.ServerList.Columns[5].Icon = ""
CoD.ServerList.Columns[6] = {}
CoD.ServerList.Columns[6].Width = 75
CoD.ServerList.Columns[6].Sortable = 1
CoD.ServerList.Columns[6].Text = Engine.Localize("MENU_PING_CAPS")
CoD.ServerList.Columns[6].Icon = ""
CoD.ServerList.RowHeight = CoD.CoD9Button.Height
CoD.ServerList.ColumnSpacing = 5
CoD.ServerList.NumElements = 18
CoD.ServerList.TotalWidth = 860
CoD.ServerList.Servers = {}
CoD.ServerList.HoveredServer = nil
CoD.ServerList.HoveredIndex = nil
CoD.ServerList.SelectedServer = nil
CoD.ServerList.SelectedIndex = nil

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
	if not CoD.ServerList.SelectedFromServerInfo then
		if CoD.ServerList.SelectedServer == nil or self.server == nil or CoD.ServerList.SelectedServer.ip ~= self.server.ip or CoD.ServerList.SelectedServer.port ~= self.server.port then
			CoD.ServerList.HoveredServer = nil
			CoD.ServerList.HoveredIndex = nil
			CoD.ServerList.SelectedServer = self.server
			CoD.ServerList.SelectedIndex = self.index
			CoD.ServerList.UpdateButtonBorders(self.parent)
			return
		end
	end

	if CoD.ServerList.SelectedServer.has_password then
		CoD.ServerList.EnteringPassword = true
		Engine.Exec(0, "ui_keyboard_new " .. CoD.KEYBOARD_TYPE_TEXT_MESSAGE .. " \"" .. Engine.Localize("MPUI_ENTER_PASSWORD") .. "\" \"\" " .. 256)
	else
		CoD.ServerList.JoinServer(self, event)
	end
end

CoD.ServerList.JoinServer = function (self, event)
	if not CoD.ServerList.SelectedFromServerInfo then
		if CoD.ServerList.SelectedServer == nil or self.server == nil or CoD.ServerList.SelectedServer.ip ~= self.server.ip or CoD.ServerList.SelectedServer.port ~= self.server.port then
			return
		end
	end

	if event.type == CoD.KEYBOARD_TYPE_TEXT_MESSAGE and not CoD.ServerList.EnteringPassword then
		return
	end

	if CoD.ServerList.SelectedServer.has_password then
		if event.type ~= CoD.KEYBOARD_TYPE_TEXT_MESSAGE then
			return
		end

		CoD.ServerList.EnteringPassword = nil

		if event.input ~= nil then
			Engine.ExecNow(event.controller, "set password \"" .. event.input .. "\"\n")
		end
	end

	if not CoD.ServerList.Joining then
		CoD.ServerList.Joining = true

		Engine.Exec(event.controller, "stopRefreshServers\n")
		Engine.Exec(event.controller, "connect \"" .. CoD.ServerList.SelectedServer.ip .. ":" .. CoD.ServerList.SelectedServer.port .. "\"\n")
	end
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

			if string.find(server.displayable_map, reference_map) then
				server.displayable_map = server.map
			end
		else
			local reference_gametype = UIExpression.TableLookup(nil, CoD.gametypesTable, 0, 0, 1, server.gametype, 7)

			if reference_gametype == "" then
				server.displayable_gametype = server.gametype
			else
				server.displayable_gametype = Engine.Localize(reference_gametype)

				if string.find(server.displayable_gametype, reference_gametype) then
					server.displayable_gametype = server.gametype
				end
			end

			local reference_map = UIExpression.TableLookup(nil, CoD.gametypesTable, 0, 5, 3, server.location, 16)

			if reference_map == "" then
				server.displayable_map = server.location
			else
				server.displayable_map = Engine.Localize(reference_map)

				if string.find(server.displayable_map, reference_map) then
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

					if string.find(server.displayable_map, reference_map) then
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

			if string.find(server.displayable_gametype, reference_gametype) then
				server.displayable_gametype = server.gametype
			end
		end

		local reference_map = UIExpression.TableLookup(nil, CoD.mapsTable, 0, server.map, 3)

		if reference_map == "" then
			server.displayable_map = server.map
		else
			server.displayable_map = Engine.Localize(reference_map)

			if string.find(server.displayable_map, reference_map) then
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
		local foundSearchFilter = false
		local hostname = string.lower(server.hostname)
		local displayable_map = string.lower(server.displayable_map)
		local displayable_gametype = string.lower(server.displayable_gametype)

		if string.find(hostname, searchFilter) then
			foundSearchFilter = true
		elseif string.find(displayable_map, searchFilter) then
			foundSearchFilter = true
		elseif string.find(displayable_gametype, searchFilter) then
			foundSearchFilter = true
		end

		if not foundSearchFilter then
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

	if UIExpression.DvarInt(0, "ui_serverbrowser_searchfilter_passwordprotected") == 0 then
		if server.has_password then
			return false
		end
	elseif UIExpression.DvarInt(0, "ui_serverbrowser_searchfilter_passwordprotected") == 1 then
		if not server.has_password then
			return false
		end
	end

	if UIExpression.DvarInt(0, "ui_serverbrowser_searchfilter_aimassist") == 0 then
		if server.aim_assist then
			return false
		end
	elseif UIExpression.DvarInt(0, "ui_serverbrowser_searchfilter_aimassist") == 1 then
		if not server.aim_assist then
			return false
		end
	end

	return true
end

CoD.ServerList.SortFunc = function(server1, server2)
	local val1, val2

    if UIExpression.DvarInt(0, "ui_serverbrowser_sortheader") == 2 then
        val1, val2 = string.lower(server1.hostname), string.lower(server2.hostname)
    elseif UIExpression.DvarInt(0, "ui_serverbrowser_sortheader") == 3 then
        val1, val2 = string.lower(server1.displayable_map), string.lower(server2.displayable_map)
    elseif UIExpression.DvarInt(0, "ui_serverbrowser_sortheader") == 4 then
        val1, val2 = string.lower(server1.displayable_gametype), string.lower(server2.displayable_gametype)
    elseif UIExpression.DvarInt(0, "ui_serverbrowser_sortheader") == 5 then
        val1, val2 = tonumber(#server1.players), tonumber(#server2.players)
    else
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
	local foundServer = false

	for index = 1, #CoD.ServerList.Servers, 1 do
		if CoD.ServerList.HoveredServer ~= nil and CoD.ServerList.HoveredIndex ~= nil and CoD.ServerList.HoveredIndex > 1 then
			if CoD.ServerList.HoveredServer.ip == CoD.ServerList.Servers[index].ip and CoD.ServerList.HoveredServer.port == CoD.ServerList.Servers[index].port then
				foundServer = true
				CoD.ServerList.HoveredIndex = index
				break
			end
		end
	end

	if not foundServer then
		CoD.ServerList.HoveredServer = nil
		CoD.ServerList.HoveredIndex = nil
	end
end

CoD.ServerList.FindSelectedIndex = function()
	local foundServer = false

	for index = 1, #CoD.ServerList.Servers, 1 do
		if CoD.ServerList.SelectedServer ~= nil and CoD.ServerList.SelectedIndex ~= nil and CoD.ServerList.SelectedIndex > 1 then
			if CoD.ServerList.SelectedServer.ip == CoD.ServerList.Servers[index].ip and CoD.ServerList.SelectedServer.port == CoD.ServerList.Servers[index].port then
				foundServer = true
				CoD.ServerList.SelectedIndex = index
				break
			end
		end
	end

	if not foundServer then
		CoD.ServerList.SelectedServer = nil
		CoD.ServerList.SelectedIndex = nil
	end
end

CoD.ServerList.ServerListRefresh = function(self, event)
	CoD.ServerList.Servers = {}
	local numServers = Engine.ServerListGetNumServers(event.controller)

	for index = 1, numServers, 1 do
		local server = Engine.ServerListGetServer(event.controller, index)

		CoD.ServerList.SetDisplayables(server)

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

	self:setTotalItems(#CoD.ServerList.Servers, index)
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
	element.serverListButton:registerEventHandler("ui_keyboard_input", CoD.ServerList.JoinServer)
	element:addElement(element.serverListButton)
end

CoD.ServerList.GetButtonData = function (LocalClientIndex, index, element, parent)
	element.serverListButton.server = CoD.ServerList.Servers[index]
	element.serverListButton.parent = parent
	element.serverListButton.index = index
	element.serverListButton:updateBorder()

	local ColumnValues = {}
	ColumnValues[1] = element.serverListButton.server.has_password
	ColumnValues[2] = element.serverListButton.server.hostname
	ColumnValues[3] = element.serverListButton.server.displayable_map
	ColumnValues[4] = element.serverListButton.server.displayable_gametype

	if element.serverListButton.server.bots > 0 then
		ColumnValues[5] = #element.serverListButton.server.players .. "/" .. element.serverListButton.server.maxplayers .. " (" .. element.serverListButton.server.bots .. ")"
	else
		ColumnValues[5] = #element.serverListButton.server.players .. "/" .. element.serverListButton.server.maxplayers
	end

	ColumnValues[6] = element.serverListButton.server.ping

	for Column = 1, #CoD.ServerList.Columns, 1 do
		if element.serverListButton.Columns[Column].Icon ~= nil then
			if ColumnValues[Column] then
				element.serverListButton.Columns[1].Icon:setImage(RegisterMaterial(CoD.ServerList.Columns[1].Icon))
				element.serverListButton.Columns[1].Icon:setAlpha(1)
			else
				element.serverListButton.Columns[1].Icon:setAlpha(0)
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
	Engine.ExecNow(0, "set ui_serverbrowser_searchfilter_aimassist 2\n")

	Engine.ExecNow(0, "set ui_serverbrowser_sortheader 6\n")
	Engine.ExecNow(0, "set ui_serverbrowser_sortheader_reverse 0\n")
end

CoD.ServerList.OpenedOnce = false
CoD.ServerList.new = function (defaultAnimationState, LocalClientIndex)
	local self = CoD.ListBox.new(defaultAnimationState, LocalClientIndex, CoD.ServerList.NumElements, CoD.ServerList.RowHeight, CoD.ServerList.TotalWidth, CoD.ServerList.CreateButtonMutables, CoD.ServerList.GetButtonData)

	self.id = "ServerList"
	self:addScrollBar()

	self:registerEventHandler("server_list_refresh", CoD.ServerList.ServerListRefresh)
	self:registerEventHandler("button_prompt_refresh", CoD.ServerList.ButtonPromptRefresh)
	self:registerEventHandler("serverlist_jumpToTop", CoD.ServerList.JumpToTop)

	if not CoD.ServerList.OpenedOnce then
		CoD.ServerList.OpenedOnce = true

		CoD.ServerList.ResetDvars()

		Engine.GetModCount() -- need this for .displayable_mod to work

		self:processEvent( {
			name = "serverlist_jumpToTop"
		} )

		self:processEvent( {
			name = "button_prompt_refresh"
		} )
	end

	self:processEvent( {
		name = "server_list_refresh"
	} )

	CoD.ServerList.ServerList = self

	return self
end
