CoD.ServerListButton = {}
CoD.ServerListButton.TextOffset = 5
CoD.ServerListButton.TextHeight = CoD.textSize.Default
CoD.ServerListButton.Font = CoD.fonts.Default

CoD.ServerListButton.ServerListButtonGainFocus = function (self, ClientInstance)
	Engine.PlaySound("uin_navigation_click")
end

CoD.ServerListButton.UpdateBorder = function (self)
	if CoD.ServerList.SelectedServer ~= nil and self.server ~= nil and CoD.ServerList.SelectedServer.ip == self.server.ip and CoD.ServerList.SelectedServer.port == self.server.port then
		self.border:setRGB(CoD.BOIIOrange.r, CoD.BOIIOrange.g, CoD.BOIIOrange.b)
		self.border:show()
	elseif CoD.ServerList.HoveredServer ~= nil and self.server ~= nil and CoD.ServerList.HoveredServer.ip == self.server.ip and CoD.ServerList.HoveredServer.port == self.server.port then
		self.border:setRGB(CoD.yellowGlow.r, CoD.yellowGlow.g, CoD.yellowGlow.b)
		self.border:show()
	else
		self.border:hide()
	end
end

CoD.ServerListButton.new = function (defaultAnimationState, LocalClientIndex, actionName)
	local ServerListButton = LUI.UIButton.new(defaultAnimationState, actionName)

	local ButtonColumns = LUI.UIHorizontalList.new({
		left = 0,
		top = 0,
		right = 0,
		bottom = 0,
		leftAnchor = true,
		topAnchor = true,
		rightAnchor = true,
		bottomAnchor = true,
		spacing = CoD.ServerList.ColumnSpacing
	})

	ServerListButton.Columns = {}
	for Column = 1, #CoD.ServerList.Columns, 1 do
		ServerListButton.Columns[Column] = LUI.UIElement.new({
            left = 0,
            top = -CoD.ServerListButton.TextHeight / 2,
            right = CoD.ServerList.Columns[Column].Width,
            bottom = CoD.ServerListButton.TextHeight / 2,
            leftAnchor = true,
            topAnchor = false,
            rightAnchor = false,
            bottomAnchor = false
        })

		if CoD.ServerList.Columns[Column].Icon ~= "" then
			ServerListButton.Columns[Column].Icon = LUI.UIImage.new({
				left = -CoD.ServerListButton.TextHeight / 2,
				top = -CoD.ServerListButton.TextHeight / 2,
				right = CoD.ServerListButton.TextHeight / 2,
				bottom = CoD.ServerListButton.TextHeight / 2,
				leftAnchor = false,
				topAnchor = false,
				rightAnchor = false,
				bottomAnchor = false
			})

			ServerListButton.Columns[Column]:addElement(ServerListButton.Columns[Column].Icon)
		else
			ServerListButton.Columns[Column].Text = LUI.UIText.new({
				left = CoD.ServerListButton.TextOffset,
				top = -CoD.ServerListButton.TextHeight / 2,
				right = CoD.ServerList.Columns[Column].Width - CoD.ServerListButton.TextOffset,
				bottom = CoD.ServerListButton.TextHeight / 2,
				leftAnchor = true,
				topAnchor = false,
				rightAnchor = false,
				bottomAnchor = false,
				font = CoD.ServerListButton.Font
			})

			ServerListButton.Columns[Column]:addElement(ServerListButton.Columns[Column].Text)
		end

		ButtonColumns:addElement(ServerListButton.Columns[Column])
	end

	ServerListButton:addElement(ButtonColumns)

	local Border = CoD.Border.new(2)
	Border:setRGB(CoD.BOIIOrange.r, CoD.BOIIOrange.g, CoD.BOIIOrange.b)
	Border:hide()
	ServerListButton.border = Border
	ServerListButton.updateBorder = CoD.ServerListButton.UpdateBorder
	ServerListButton:addElement(Border)

	local Widget = LUI.UIElement.new()
	ServerListButton:addElement(Widget)
	Widget:registerEventHandler("gain_focus", CoD.ServerListButton.ServerListButtonGainFocus)

	return ServerListButton
end
