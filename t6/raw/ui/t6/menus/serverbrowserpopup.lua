require("T6.ServerList")
require("T6.Menus.ServerBrowserFiltersPopup")
require("T6.Menus.ServerBrowserServerInfoPopup")

CoD.ServerBrowser = {}

CoD.ServerBrowser.PopupOpen = false

CoD.ServerBrowser.UpdateHeader = function(headerButton)
	local sortHeader = UIExpression.DvarInt(0, "ui_serverbrowser_sortheader")

	if headerButton.headerIcon ~= nil then
		if sortHeader == headerButton.column then
			headerButton.headerIcon:setAlpha(0)
		else
			headerButton.headerIcon:setAlpha(1)
		end
	end

	if headerButton.headerArrow ~= nil then
		if sortHeader == headerButton.column then
			headerButton.headerArrow:setAlpha(1)

			if UIExpression.DvarBool(0, "ui_serverbrowser_sortheader_reverse") == 1 then
				headerButton.headerArrow:setZRot(-90)
			else
				headerButton.headerArrow:setZRot(90)
			end
		else
			headerButton.headerArrow:setAlpha(0)
		end
	end
end

CoD.ServerBrowser.ButtonPromptFilters = function (self, event)
	self:openPopup( "ServerBrowserFilters", event.controller )
end

CoD.ServerBrowser.ButtonPromptServerInfo = function (self, event)
	if CoD.ServerList.SelectedServer ~= nil then
		self:openPopup( "ServerBrowserServerInfo", event.controller )
	end
end

CoD.ServerBrowser.OcclusionChange = function (self, event)
	CoD.ServerBrowser.PopupOpen = event.occluded

	if not CoD.ServerBrowser.PopupOpen then
		event.servers = {}
		CoD.ServerList.ServerListRefresh(CoD.ServerList.ServerList, event)
	end

	CoD.Menu.OcclusionChange(self, event)
end

CoD.ServerBrowser.ClickHeader = function(headerButton, event)
	if UIExpression.DvarInt(0, "ui_serverbrowser_sortheader") == headerButton.column then
		local reverse = 1
		if UIExpression.DvarBool(0, "ui_serverbrowser_sortheader_reverse") == 1 then
			reverse = 0
		end

		Engine.ExecNow(0, "set ui_serverbrowser_sortheader_reverse " .. reverse .. "\n")
	else
		Engine.ExecNow(0, "set ui_serverbrowser_sortheader_reverse 0\n")
		Engine.ExecNow(0, "set ui_serverbrowser_sortheader " .. headerButton.column .. "\n")
	end

	for Column = 1, #headerButton.parent.headers, 1 do
		headerButton.parent.headers[Column]:updateHeader()
	end

	event.servers = {}
	CoD.ServerList.ServerListRefresh(CoD.ServerList.ServerList, event)
end

CoD.ServerBrowser.Close = function (self, f3_arg1)
	Engine.Exec(self.m_ownerController, "stopRefreshServers\n")

	CoD.Menu.close(self, f3_arg1)
end

LUI.createMenu.ServerBrowser = function (LocalClientIndex)
	local self = CoD.Menu.New("ServerBrowser")

	self.close = CoD.ServerBrowser.Close
	self.m_ownerController = LocalClientIndex
	self:addTitle(Engine.Localize("MENU_SERVER_BROWSER_CAPS"))

	local TitleHeight = CoD.Menu.TitleHeight
	local HeaderTop = TitleHeight + CoD.CoD9Button.Height

	self.header = LUI.UIHorizontalList.new({
		left = 0,
		top = TitleHeight,
		right = 0,
		bottom = CoD.textSize.Condensed,
		leftAnchor = true,
		topAnchor = true,
		rightAnchor = true,
		bottomAnchor = false,
		spacing = CoD.ServerList.ColumnSpacing
	})
	self:addElement(self.header)

	self.backgroundGroup = LUI.UIHorizontalList.new({
		left = 0,
		top = HeaderTop,
		right = 0,
		bottom = -CoD.CoD9Button.Height,
		leftAnchor = true,
		topAnchor = true,
		rightAnchor = true,
		bottomAnchor = true,
		spacing = CoD.ServerList.ColumnSpacing,
		alpha = 0.03
	})
	self:addElement(self.backgroundGroup)

	for Column = 1, #CoD.ServerList.Columns, 1 do
		local BackGroundImage = LUI.UIImage.new({
			left = 0,
			top = 0,
			right = CoD.ServerList.Columns[Column].Width,
			bottom = 0,
			leftAnchor = true,
			topAnchor = true,
			rightAnchor = false,
			bottomAnchor = true
		})

		self.backgroundGroup:addElement(BackGroundImage)
	end

	self.serverList = CoD.ServerList.new({
		left = 0,
		top = HeaderTop,
		right = 0,
		bottom = -CoD.CoD9Button.Height - 10,
		leftAnchor = true,
		topAnchor = true,
		rightAnchor = true,
		bottomAnchor = true,
		spacing = 10
	}, LocalClientIndex)
	self:addElement(self.serverList)

	self.headers = {}
	for Column = 1, #CoD.ServerList.Columns, 1 do
		local HeaderButton = LUI.UIButton.new({
			left = 0,
			top = 0,
			right = CoD.ServerList.Columns[Column].Width,
			bottom = CoD.textSize.Condensed,
			leftAnchor = true,
			topAnchor = true,
			rightAnchor = false,
			bottomAnchor = false
		})

		HeaderButton.column = Column
		HeaderButton.parent = self
		HeaderButton.updateHeader = CoD.ServerBrowser.UpdateHeader
		HeaderButton:registerEventHandler("button_action", CoD.ServerBrowser.ClickHeader)
		HeaderButton:registerEventHandler("button_up", HeaderButton.updateHeader)

		if CoD.ServerList.Columns[Column].Icon ~= nil then
			local HeaderIcon = LUI.UIImage.new({
				left = -CoD.textSize.Condensed / 2,
				top = -CoD.textSize.Condensed / 2,
				right = CoD.textSize.Condensed / 2,
				bottom = CoD.textSize.Condensed / 2,
				leftAnchor = false,
				topAnchor = false,
				rightAnchor = false,
				bottomAnchor = false
			})

			HeaderIcon:setImage(RegisterMaterial(CoD.ServerList.Columns[Column].Icon))

			HeaderButton.headerIcon = HeaderIcon
			HeaderButton:addElement(HeaderIcon)
		elseif CoD.ServerList.Columns[Column].Text ~= nil then
			local HeaderText = LUI.UIText.new({
				left = CoD.ServerListButton.TextOffset,
				top = 0,
				right = CoD.ServerList.Columns[Column].Width - CoD.ServerListButton.TextOffset,
				bottom = CoD.textSize.Condensed,
				leftAnchor = true,
				topAnchor = true,
				rightAnchor = false,
				bottomAnchor = false,
				font = CoD.fonts.Condensed
			})

			HeaderText:setText(CoD.ServerList.Columns[Column].Text)
			HeaderButton.headerText = HeaderText
			HeaderButton:addElement(HeaderText)
		end

		local HeaderArrow = LUI.UIImage.new()

		if CoD.ServerList.Columns[Column].Icon ~= nil then
			HeaderArrow:setLeftRight(false, false, -CoD.textSize.Condensed / 2, CoD.textSize.Condensed / 2)
			HeaderArrow:setTopBottom(false, false, -CoD.textSize.Condensed / 2, CoD.textSize.Condensed / 2)
		elseif CoD.ServerList.Columns[Column].Text ~= nil then
			local _, __, textWidth, ___ = GetTextDimensions(CoD.ServerList.Columns[Column].Text, CoD.fonts.Condensed, CoD.textSize.Condensed)

			HeaderArrow:setLeftRight(true, false, CoD.ServerListButton.TextOffset + textWidth, CoD.ServerListButton.TextOffset + textWidth + CoD.textSize.Condensed)
			HeaderArrow:setTopBottom(false, false, -CoD.textSize.Condensed / 2, CoD.textSize.Condensed / 2)
		end

		HeaderArrow:setImage(RegisterMaterial("ui_arrow_right"))
		HeaderArrow:setZRot(90)
		HeaderArrow:setAlpha(0)
		HeaderButton.headerArrow = HeaderArrow
		HeaderButton:addElement(HeaderArrow)

		self.header:addElement(HeaderButton)
		self.headers[Column] = HeaderButton

		HeaderButton:updateHeader()
	end

	self:addSelectButton()
	self:addBackButton()

	self.refreshButton = CoD.ButtonPrompt.new("alt2", Engine.Localize("MENU_REFRESH"), self.serverList, "button_prompt_refresh", false, nil, nil, nil, "R", nil)
	self:addRightButtonPrompt(self.refreshButton)

	self.filtersButton = CoD.ButtonPrompt.new("start", Engine.Localize("MENU_FILTER_SERVERS"), self, "button_prompt_filters", false, nil, nil, nil, "E", nil)
	self:addRightButtonPrompt(self.filtersButton)
	self:registerEventHandler("button_prompt_filters", CoD.ServerBrowser.ButtonPromptFilters)

	self.serverInfoButton = CoD.ButtonPrompt.new("select", Engine.Localize("MENU_SERVER_INFO"), self, "button_prompt_server_info", false, nil, nil, nil, "S", nil)
	self:addRightButtonPrompt(self.serverInfoButton)
	self:registerEventHandler("button_prompt_server_info", CoD.ServerBrowser.ButtonPromptServerInfo)

	self.jumpToTopButton = CoD.ButtonPrompt.new("alt1", Engine.Localize("MENU_LB_TOP_OF_LIST"), self.serverList, "serverlist_jumpToTop", false, nil, nil, nil, "T", nil)
	self:addRightButtonPrompt(self.jumpToTopButton)

	self:registerEventHandler("occlusion_change", CoD.ServerBrowser.OcclusionChange)

	return self
end
