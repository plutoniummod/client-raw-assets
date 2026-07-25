CoD.ServerBrowserFilters = {}

CoD.ServerBrowserFilters.Back = function (self, event)
	CoD.ServerList.ServerListRefresh(CoD.ServerList.ServerList, event)
	self:saveState()
	self:goBack(event.controller)
end

CoD.ServerBrowserFilters.UpdateSearchFilterText = function (self, text)
	if text == nil then
		text = UIExpression.DvarString(0, "ui_serverbrowser_searchfilter")
	end

	self.searchFilterCurrent:setText(text)
	Engine.ExecNow(0, "set ui_serverbrowser_searchfilter \"" .. text .. "\"\n")
end

CoD.ServerBrowserFilters.OpenFilterEditor = function (self, event)
	Engine.Exec(0, "ui_keyboard_new " .. CoD.KEYBOARD_TYPE_TEXT_MESSAGE .. " \"" .. Engine.Localize("MENU_LB_CHANGE_FILTER") .. "\" \"" .. UIExpression.DvarString(0, "ui_serverbrowser_searchfilter") .. "\" " .. 256)
end

CoD.ServerBrowserFilters.FilterChanged = function (self, event)
	if event.type ~= CoD.KEYBOARD_TYPE_TEXT_MESSAGE then
		return
	end

	CoD.ServerBrowserFilters.UpdateSearchFilterText(self, event.input)
end

CoD.ServerBrowserFilters.ResetToDefaults = function (self, event)
	CoD.ServerList.ResetDvars()

	self:processEvent( {
		name = "button_prompt_back"
	} )
end

LUI.createMenu.ServerBrowserFilters = function ( owner )
	local self = CoD.GameOptionsMenu.New( owner, "ServerBrowserFilters" )

	if CoD.isZombie == true then
		self.infoPane:removeElement(self.gametypeIcon)
	end

	self:addTitle( Engine.Localize( "MENU_FILTER_SERVERS_CAPS" ) )

	local searchFilterCurrent = self.buttonList:addText(UIExpression.DvarString(0, "ui_serverbrowser_searchfilter"))

	self.searchFilter = self.buttonList:addDvarLeftRightSelector( owner, UIExpression.ToUpper(0, Engine.Localize("MENU_LB_CHANGE_FILTER")), "", Engine.Localize("MENU_SERVER_BROWSER_SEARCH_FILTER_HINT") )
	self.searchFilter.searchFilterCurrent = searchFilterCurrent
	self.searchFilter:registerEventHandler( "ui_keyboard_input", CoD.ServerBrowserFilters.FilterChanged )
	self.searchFilter:registerEventHandler( "button_action", CoD.ServerBrowserFilters.OpenFilterEditor )
	CoD.ServerBrowserFilters.UpdateSearchFilterText(self.searchFilter, nil)

	self.maxPingButton = self.buttonList:addDvarLeftRightSelector( owner, Engine.Localize("PLATFORM_MAX_PING"), "ui_serverbrowser_searchfilter_maxping", Engine.Localize("MENU_SERVER_BROWSER_MAX_PING_HINT") )
	CoD.GameOptions.Button_AddChoices( owner, self.maxPingButton, { 25, 50, 100, 250, 500, 1000 }, { 25, 50, 100, 250, 500, 1000 } )

	local emptyServerStr = UIExpression.ToUpper(0, Engine.Localize("MENU_VIEW_EMPTY"))
	self.emptyServersButton = self.buttonList:addDvarLeftRightSelector( owner, string.gsub(emptyServerStr, ":", ""), "ui_serverbrowser_searchfilter_emptyservers", Engine.Localize("MENU_SERVER_BROWSER_DISPLAY_EMPTY_HINT") )
	CoD.GameOptions.Button_AddChoices( owner, self.emptyServersButton, { "MENU_NO_CAPS", "MENU_YES_CAPS" }, { 0, 1 } )

	local fullServerStr = UIExpression.ToUpper(0, Engine.Localize("MENU_VIEW_FULL"))
	self.fullServersButton = self.buttonList:addDvarLeftRightSelector( owner, string.gsub(fullServerStr, ":", ""), "ui_serverbrowser_searchfilter_fullservers", Engine.Localize("MENU_SERVER_BROWSER_DISPLAY_FULL_HINT") )
	CoD.GameOptions.Button_AddChoices( owner, self.fullServersButton, { "MENU_NO_CAPS", "MENU_YES_CAPS" }, { 0, 1 } )

	self.passwordProtectedButton = self.buttonList:addDvarLeftRightSelector( owner, UIExpression.ToUpper(0, Engine.Localize("EXE_SV_INFO_PASSWORD")), "ui_serverbrowser_searchfilter_passwordprotected", Engine.Localize("MENU_SERVER_BROWSER_PASSWORD_PROTECTED_HINT") )
	CoD.GameOptions.Button_AddChoices( owner, self.passwordProtectedButton, { "MENU_NO_CAPS", "MENU_YES_CAPS", "CUSTOM_ALL" }, { 0, 1, 2 } )

	self.aimAssistButton = self.buttonList:addDvarLeftRightSelector( owner, Engine.Localize("MENU_AIM_ASSIST_CAPS"), "ui_serverbrowser_searchfilter_aimassist", Engine.Localize("MENU_SERVER_BROWSER_AIM_ASSIST_HINT") )
	CoD.GameOptions.Button_AddChoices( owner, self.aimAssistButton, { "MENU_NO_CAPS", "MENU_YES_CAPS", "CUSTOM_ALL" }, { 0, 1, 2 } )

	self.defaultsButton = CoD.ButtonPrompt.new("alt1", Engine.Localize("PLATFORM_RESET_TO_DEFAULT"), self, "button_prompt_defaults", false, nil, nil, nil, "R", nil)
	self:addRightButtonPrompt(self.defaultsButton)
	self:registerEventHandler( "button_prompt_defaults", CoD.ServerBrowserFilters.ResetToDefaults )

	if not self.buttonList:restoreState() then
		self.buttonList:processEvent( {
			name = "gain_focus"
		} )
	end

	self:registerEventHandler( "button_prompt_back", CoD.ServerBrowserFilters.Back )
	return self
end
