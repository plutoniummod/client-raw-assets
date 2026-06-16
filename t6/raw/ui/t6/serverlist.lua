require("T6.ServerListButton")

CoD.ServerList = {}
CoD.ServerList.Columns = {}
CoD.ServerList.Columns[1] = {}
CoD.ServerList.Columns[1].Width = 300
CoD.ServerList.Columns[1].Sortable = 1
CoD.ServerList.Columns[1].Text = UIExpression.ToUpper(nil, Engine.Localize("MENU_SERVERNAME"))
CoD.ServerList.Columns[2] = {}
CoD.ServerList.Columns[2].Width = 175
CoD.ServerList.Columns[2].Sortable = 1
CoD.ServerList.Columns[2].Text = Engine.Localize("MENU_MAP_NAME_CAPS")
CoD.ServerList.Columns[3] = {}
CoD.ServerList.Columns[3].Width = 175
CoD.ServerList.Columns[3].Sortable = 1
CoD.ServerList.Columns[3].Text = Engine.Localize("MENU_GAME_MODE_CAPS")
CoD.ServerList.Columns[4] = {}
CoD.ServerList.Columns[4].Width = 110
CoD.ServerList.Columns[4].Sortable = 1
CoD.ServerList.Columns[4].Text = Engine.Localize("MENU_NUMPLAYERS_CAPS")
CoD.ServerList.Columns[5] = {}
CoD.ServerList.Columns[5].Width = 80
CoD.ServerList.Columns[5].Sortable = 1
CoD.ServerList.Columns[5].Text = Engine.Localize("MENU_PING_CAPS")
CoD.ServerList.RowHeight = CoD.CoD9Button.Height
CoD.ServerList.ColumnSpacing = 5
CoD.ServerList.NumElements = 18
CoD.ServerList.TotalWidth = 860
CoD.ServerList.Servers = {}
CoD.ServerList.HoveredServer = nil
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
			CoD.ServerList.SelectedServer = self.server
			CoD.ServerList.SelectedIndex = self.index
			CoD.ServerList.UpdateButtonBorders(self.parent)
		end
	else
		if CoD.ServerList.HoveredServer == nil or self.server == nil or CoD.ServerList.HoveredServer.ip ~= self.server.ip or CoD.ServerList.HoveredServer.port ~= self.server.port then
			CoD.ServerList.HoveredServer = self.server
			CoD.ServerList.UpdateButtonBorders(self.parent)
		end
	end
end

CoD.ServerList.SelectServer = function (self, event)
	if not CoD.ServerList.SelectedFromServerInfo then
		if CoD.ServerList.SelectedServer == nil or self.server == nil or CoD.ServerList.SelectedServer.ip ~= self.server.ip or CoD.ServerList.SelectedServer.port ~= self.server.port then
			CoD.ServerList.HoveredServer = nil
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

	Engine.Exec(event.controller, "stopRefreshServers\n")
	Engine.Exec(event.controller, "connect \"" .. CoD.ServerList.SelectedServer.ip .. ":" .. CoD.ServerList.SelectedServer.port .. "\"\n")
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

CoD.ServerList.ServerListFilterFunc = function(Server)
	local searchFilter = string.lower(UIExpression.DvarString(0, "ui_serverbrowser_searchfilter"))

	if searchFilter ~= "" then
		local foundSearchFilter = false
		local hostname = string.lower(Server.hostname)
		local displayable_map = string.lower(Server.displayable_map)
		local displayable_gametype = string.lower(Server.displayable_gametype)

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

	if tonumber(Server.ping) > UIExpression.DvarInt(0, "ui_serverbrowser_searchfilter_maxping") then
		return false
	end

	if UIExpression.DvarBool(0, "ui_serverbrowser_searchfilter_emptyservers") == 0 then
		if #Server.players == 0 then
			return false
		end
	end

	if UIExpression.DvarBool(0, "ui_serverbrowser_searchfilter_fullservers") == 0 then
		if #Server.players == Server.maxplayers then
			return false
		end
	end

	if UIExpression.DvarInt(0, "ui_serverbrowser_searchfilter_passwordprotected") == 0 then
		if Server.has_password then
			return false
		end
	elseif UIExpression.DvarInt(0, "ui_serverbrowser_searchfilter_passwordprotected") == 1 then
		if not Server.has_password then
			return false
		end
	end

	if UIExpression.DvarInt(0, "ui_serverbrowser_searchfilter_aimassist") == 0 then
		if Server.aim_assist then
			return false
		end
	elseif UIExpression.DvarInt(0, "ui_serverbrowser_searchfilter_aimassist") == 1 then
		if not Server.aim_assist then
			return false
		end
	end

	return true
end

CoD.ServerList.ServerListSortFunc = function(Server1, Server2)
	if UIExpression.DvarInt(0, "ui_serverbrowser_sortheader") == 1 then
		if UIExpression.DvarBool(0, "ui_serverbrowser_sortheader_reverse") == 1 then
			return string.lower(Server1.hostname) > string.lower(Server2.hostname)
		else
			return string.lower(Server1.hostname) < string.lower(Server2.hostname)
		end
	elseif UIExpression.DvarInt(0, "ui_serverbrowser_sortheader") == 2 then
		if UIExpression.DvarBool(0, "ui_serverbrowser_sortheader_reverse") == 1 then
			return string.lower(Server1.displayable_map) > string.lower(Server2.displayable_map)
		else
			return string.lower(Server1.displayable_map) < string.lower(Server2.displayable_map)
		end
	elseif UIExpression.DvarInt(0, "ui_serverbrowser_sortheader") == 3 then
		if UIExpression.DvarBool(0, "ui_serverbrowser_sortheader_reverse") == 1 then
			return string.lower(Server1.displayable_gametype) > string.lower(Server2.displayable_gametype)
		else
			return string.lower(Server1.displayable_gametype) < string.lower(Server2.displayable_gametype)
		end
	elseif UIExpression.DvarInt(0, "ui_serverbrowser_sortheader") == 4 then
		if UIExpression.DvarBool(0, "ui_serverbrowser_sortheader_reverse") == 1 then
			return tonumber(#Server1.players) > tonumber(#Server2.players)
		else
			return tonumber(#Server1.players) < tonumber(#Server2.players)
		end
	else
		if UIExpression.DvarBool(0, "ui_serverbrowser_sortheader_reverse") == 1 then
			return tonumber(Server1.ping) > tonumber(Server2.ping)
		else
			return tonumber(Server1.ping) < tonumber(Server2.ping)
		end
	end
end

CoD.ServerList.ServerListRefresh = function(self, event)
	CoD.ServerList.Servers = {}
	local numServers = Engine.ServerListGetNumServers(event.controller)

	for index = 1, numServers, 1 do
		local server = Engine.ServerListGetServer(event.controller, index)
		local matchesFilter = CoD.ServerList.ServerListFilterFunc(server)

		if matchesFilter then
			CoD.ServerList.Servers[#CoD.ServerList.Servers + 1] = server
		end
	end

	table.sort(CoD.ServerList.Servers, CoD.ServerList.ServerListSortFunc)

	if CoD.ServerList.SelectedIndex ~= nil and CoD.ServerList.SelectedIndex > #CoD.ServerList.Servers then
		CoD.ServerList.SelectedIndex = #CoD.ServerList.Servers
	end

	self:setTotalItems(#CoD.ServerList.Servers, CoD.ServerList.SelectedIndex)
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

	local ColumnsText = {}
	ColumnsText[1] = element.serverListButton.server.hostname
	ColumnsText[2] = element.serverListButton.server.displayable_map
	ColumnsText[3] = element.serverListButton.server.displayable_gametype
	ColumnsText[4] = #element.serverListButton.server.players .. "/" .. element.serverListButton.server.maxplayers
	ColumnsText[5] = element.serverListButton.server.ping

	for Column = 1, #CoD.ServerList.Columns, 1 do
		element.serverListButton.Columns[Column]:setText(ColumnsText[Column])

		local _, __, textWidth, ___ = GetTextDimensions(ColumnsText[Column], CoD.ServerListButton.Font, CoD.ServerListButton.TextHeight)

		local scale = 0.5
		if textWidth > CoD.ServerList.Columns[Column].Width - 15 then
			scale = scale * ((CoD.ServerList.Columns[Column].Width - 15) / textWidth)
		end

		element.serverListButton.Columns[Column]:setTopBottom(false, false, -CoD.ServerListButton.TextHeight * scale, CoD.ServerListButton.TextHeight * scale)
	end
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
