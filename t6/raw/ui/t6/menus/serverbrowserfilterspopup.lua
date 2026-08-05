CoD.ServerBrowserFilters = {}

CoD.ServerBrowserFilters.Back = function (self, event)
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

	self.modsButton = self.buttonList:addDvarLeftRightSelector( owner, Engine.Localize("MENU_MODS_CAPS"), "ui_serverbrowser_searchfilter_mods", Engine.Localize("MENU_SERVER_BROWSER_MODS_HINT") )
	CoD.GameOptions.Button_AddChoices( owner, self.modsButton, { "MENU_NO_CAPS", "MENU_YES_CAPS", "CUSTOM_ALL" }, { 0, 1, 2 } )

	if not CoD.isZombie then
		self.hardcoreButton = self.buttonList:addDvarLeftRightSelector( owner, UIExpression.ToUpper(0, Engine.Localize("MENU_RULES_HARDCORE")), "ui_serverbrowser_searchfilter_hardcore", Engine.Localize("SERVERBROWSER_HARDCORE_HINT") )
		CoD.GameOptions.Button_AddChoices( owner, self.hardcoreButton, { "MENU_NO_CAPS", "MENU_YES_CAPS", "CUSTOM_ALL" }, { 0, 1, 2 } )
	end

	self.aimAssistButton = self.buttonList:addDvarLeftRightSelector( owner, Engine.Localize("MENU_AIM_ASSIST_CAPS"), "ui_serverbrowser_searchfilter_aimassist", Engine.Localize("MENU_SERVER_BROWSER_AIM_ASSIST_HINT") )
	CoD.GameOptions.Button_AddChoices( owner, self.aimAssistButton, { "MENU_NO_CAPS", "MENU_YES_CAPS", "CUSTOM_ALL" }, { 0, 1, 2 } )

	local hideBrainrotStr = CoD.MPZM(Engine.Localize("SERVERBROWSER_HIDEBRAINROT_MP"), Engine.Localize("SERVERBROWSER_HIDEBRAINROT_ZM"))
	local hideBrainrotHintStr = CoD.MPZM(Engine.Localize("SERVERBROWSER_HIDEBRAINROT_HINT_MP"), Engine.Localize("SERVERBROWSER_HIDEBRAINROT_HINT_ZM"))
	self.brainRotButton = self.buttonList:addDvarLeftRightSelector( owner, hideBrainrotStr, "ui_serverbrowser_searchfilter_hidebrainrot", hideBrainrotHintStr )
	CoD.GameOptions.Button_AddChoices( owner, self.brainRotButton, { "MENU_NO_CAPS", "MENU_YES_CAPS" }, { 0, 1 } )

	local mapsDisplays = {"CUSTOM_ALL"}
	local mapsValues = {""}

	local mapsRow = 0
	while true do
		local mapsColVal = UIExpression.TableLookupGetColumnValueForRow(0, CoD.mapsTable, mapsRow, 0)

		if mapsColVal == "" then
			break
		end

		if mapsColVal == "maxnum_map" then
			local numMaps = tonumber(UIExpression.TableLookupGetColumnValueForRow(nil, CoD.mapsTable, mapsRow, 1))

			for i = 1, numMaps, 1 do
				local map = UIExpression.TableLookupGetColumnValueForRow(nil, CoD.mapsTable, mapsRow + i, 0)
				local mapRef = UIExpression.TableLookupGetColumnValueForRow(nil, CoD.mapsTable, mapsRow + i, 3)

				if CoD.isZombie then
					mapRef = UIExpression.TableLookup(nil, CoD.gametypesTable, 0, 0, 1, "zclassic", 7)

					if map ~= "zm_transit" then
						mapRef = UIExpression.ToUpper(nil, mapRef .. "_" .. map)
					end

					if string.find(Engine.Localize(mapRef), mapRef, 1, true) then
						mapRef = UIExpression.TableLookup(nil, CoD.gametypesTable, 0, 5, 2, map, 16)
					end
				end

				mapRef = mapRef .. "_CAPS"

				if map ~= "zm_transit_dr" then
					mapsValues[#mapsValues + 1] = map
					mapsDisplays[#mapsDisplays + 1] = mapRef
				end
			end

			break
		end

		mapsRow = mapsRow + 1
	end

	self.mapButton = self.buttonList:addDvarLeftRightSelector( owner, Engine.Localize("MENU_MAP_NAME_CAPS"), "ui_serverbrowser_searchfilter_map", Engine.Localize("SERVERBROWSER_MAP_HINT") )
	CoD.GameOptions.Button_AddChoices( owner, self.mapButton, mapsDisplays, mapsValues )

	local gametypesDisplays = {"CUSTOM_ALL"}
	local gametypesValues = {""}

	local gametypesRow = 0
	while true do
		local gametypesColVal = UIExpression.TableLookupGetColumnValueForRow(0, CoD.gametypesTable, gametypesRow, 0)

		if gametypesColVal == "" then
			break
		end

		if gametypesColVal == "0" then
			local gametype = UIExpression.TableLookupGetColumnValueForRow(0, CoD.gametypesTable, gametypesRow, 1)
			local gametypeRef = UIExpression.TableLookupGetColumnValueForRow(0, CoD.gametypesTable, gametypesRow, 2)

			if gametype == "zclassic" then
				gametypeRef = "MENU_DEFAULT_XENON_CAPS"
			end

			gametypesValues[#gametypesValues + 1] = gametype
			gametypesDisplays[#gametypesDisplays + 1] = gametypeRef
		end

		gametypesRow = gametypesRow + 1
	end

	self.gametypeButton = self.buttonList:addDvarLeftRightSelector( owner, Engine.Localize("MENU_GAME_MODE_CAPS"), "ui_serverbrowser_searchfilter_gamemode", Engine.Localize("SERVERBROWSER_GAMETYPE_HINT") )
	CoD.GameOptions.Button_AddChoices( owner, self.gametypeButton, gametypesDisplays, gametypesValues )

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
