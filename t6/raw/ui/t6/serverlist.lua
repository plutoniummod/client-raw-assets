require("T6.ServerListButton")

CoD.ServerList = {}
CoD.ServerList.Columns = {}
CoD.ServerList.Columns[1] = {}
CoD.ServerList.Columns[1].Width = 30
CoD.ServerList.Columns[1].Sortable = 0
CoD.ServerList.Columns[1].Text = ""
CoD.ServerList.Columns[2] = {}
CoD.ServerList.Columns[2].Width = 250
CoD.ServerList.Columns[2].Sortable = 0
CoD.ServerList.Columns[2].Text = Engine.Localize("MENU_HOST_CAPS")
CoD.ServerList.Columns[3] = {}
CoD.ServerList.Columns[3].Width = 200
CoD.ServerList.Columns[3].Sortable = 0
CoD.ServerList.Columns[3].Text = Engine.Localize("MENU_MAP_NAME_CAPS")
CoD.ServerList.Columns[4] = {}
CoD.ServerList.Columns[4].Width = 100
CoD.ServerList.Columns[4].Sortable = 1
CoD.ServerList.Columns[4].Text = Engine.Localize("MENU_NUMPLAYERS_CAPS")
CoD.ServerList.Columns[5] = {}
CoD.ServerList.Columns[5].Width = 200
CoD.ServerList.Columns[5].Sortable = 0
CoD.ServerList.Columns[5].Text = Engine.Localize("MENU_GAME_MODE_CAPS")
CoD.ServerList.Columns[6] = {}
CoD.ServerList.Columns[6].Width = 63
CoD.ServerList.Columns[6].Sortable = 1
CoD.ServerList.Columns[6].Text = Engine.Localize("MENU_PING_CAPS")
CoD.ServerList.RowHeight = CoD.CoD9Button.Height
CoD.ServerList.ColumnSpacing = 5
CoD.ServerList.NumElements = 18
CoD.ServerList.TotalWidth = 868

CoD.ServerList.GetPingColor = function(ping)
    ping = tonumber(ping) or 999
    
    if ping <= 60 then
        return { 0, 1, 0 }
    elseif ping <= 120 then
        return { 1, 1, 0 }
    elseif ping <= 200 then
        return { 1, 0.5, 0 }
    else
        return { 1, 0, 0 }
    end
end

CoD.ServerList.UpdateButtonHeaders = function(self)
	local button = self.m_firstButton
	while button ~= nil do
		button.body.m_mutables.serverListButton:updateBorder()
		button = button.nextButton
	end
end

CoD.ServerList.SelectedServer = nil
CoD.ServerList.JoinServer = function (self, event)
	if CoD.ServerList.SelectedServer == nil or self.server == nil or CoD.ServerList.SelectedServer.ip ~= self.server.ip or CoD.ServerList.SelectedServer.port ~= self.server.port then
		CoD.ServerList.SelectedServer = self.server
		CoD.ServerList.UpdateButtonHeaders(self.parent)
		return
	end

	Engine.Exec(event.controller, "stopRefreshServers\n")
	Engine.Exec(event.controller, "connect \"" .. CoD.ServerList.SelectedServer.ip .. ":" .. CoD.ServerList.SelectedServer.port .. "\"\n")
end

CoD.ServerList.ButtonPromptRefresh = function (self, event)
	Engine.PlaySound("cac_grid_equip_item")
	Engine.Exec(event.controller, "refreshServers\n")
end

CoD.ServerList.LastIndex = nil
CoD.ServerList.JumpToTop = function (self, event)
	CoD.ServerList.SelectedServer = nil
	CoD.ServerList.LastIndex = nil
	self:jumpToTop()
end

CoD.ServerList.ServerListRefresh = function(self, event)
	local numServers = Engine.ServerListGetNumServers(event.controller)
	if numServers < self:getTotalItems() then
		CoD.ServerList.LastIndex = nil
	end
	
	self:setTotalItems(numServers, CoD.ServerList.LastIndex)
end

CoD.ServerList.Generate = function(self, index)
	CoD.ServerList.LastIndex = index
	self:oldGenerate(index)
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

	element.serverListButton:registerEventHandler("button_action", CoD.ServerList.JoinServer)
	element:addElement(element.serverListButton)
end

CoD.ServerList.LockedIcon = RegisterMaterial("hud_server_locked")

CoD.ServerList.GetButtonData = function (LocalClientIndex, index, element, parent)
	element.serverListButton.server = Engine.ServerListGetServer(LocalClientIndex, index)
	element.serverListButton.parent = parent
	element.serverListButton:updateBorder()

	if element.serverListButton.server.has_password then
		element.serverListButton.Columns[1]:setImage(CoD.ServerList.LockedIcon)
		element.serverListButton.Columns[1]:setAlpha(1)
	else
		element.serverListButton.Columns[1]:setAlpha(0)
	end

	element.serverListButton.Columns[3]:setText(element.serverListButton.server.displayable_map)
	element.serverListButton.Columns[4]:setText(#element.serverListButton.server.players .. "/" .. element.serverListButton.server.maxplayers .. " (" .. element.serverListButton.server.bots .. ")")
	element.serverListButton.Columns[5]:setText(element.serverListButton.server.displayable_gametype)

	local ping = element.serverListButton.server.ping
    local pingColor = CoD.ServerList.GetPingColor(ping)

	element.serverListButton.Columns[6]:setText(ping)
    element.serverListButton.Columns[6]:setRGB(pingColor[1], pingColor[2], pingColor[3])

	element.serverListButton.Columns[2]:setText(element.serverListButton.server.hostname)
	local _, __, textWidth, ___ = GetTextDimensions(element.serverListButton.server.hostname, CoD.ServerListButton.Font, CoD.ServerListButton.TextHeight)

	local scale = 0.5
	if textWidth > CoD.ServerList.Columns[2].Width - 15 then
		scale = scale * ((CoD.ServerList.Columns[2].Width - 15) / textWidth)
	end

	element.serverListButton.Columns[2]:setTopBottom(false, false, -CoD.ServerListButton.TextHeight * scale, CoD.ServerListButton.TextHeight * scale)
end

CoD.ServerList.new = function (defaultAnimationState, LocalClientIndex)
	local self = CoD.ListBox.new(defaultAnimationState, LocalClientIndex, CoD.ServerList.NumElements, CoD.ServerList.RowHeight, CoD.ServerList.TotalWidth, CoD.ServerList.CreateButtonMutables, CoD.ServerList.GetButtonData)

	self.id = "ServerList"
	self:addScrollBar(2, 2)

	self:registerEventHandler("server_list_refresh", CoD.ServerList.ServerListRefresh)
	self:registerEventHandler("button_prompt_refresh", CoD.ServerList.ButtonPromptRefresh)
	self:registerEventHandler("serverlist_jumpToTop", CoD.ServerList.JumpToTop)

	self.oldGenerate = self.generate
	self.generate = CoD.ServerList.Generate

	if CoD.ServerList.LastIndex ~= nil then
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

	return self
end