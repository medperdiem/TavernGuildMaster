--!nonstrict
-- Screens.luau — every Slice 1 screen (spec §5), built in code.
-- 1 Tavern hub (3D — handled by prompts) · 2 Job Board · 3 Interview · 4 Hero Sheet
-- 5 Party Picker · 6 Raven Popup · 7 Welcome-Back · 8 Quest Return Report
-- Plus: HUD (gold, quest tracker), toasts, and the FTUE letter.

local Theme = require(script.Parent:WaitForChild("Theme"))
local UI = require(script.Parent:WaitForChild("UI"))

local Screens = {}

function Screens.create(playerGui, callbacks)
	local controller = { callbacks = callbacks, state = {} }

	local gui = Instance.new("ScreenGui")
	gui.Name = "TavernUI"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.Parent = playerGui

	-- ========================= HUD =========================
	local goldLabel = UI.label({
		Name = "Gold",
		Size = UDim2.fromOffset(180, 34),
		Position = UDim2.fromOffset(16, 16),
		Font = Theme.FontBold,
		TextSize = 22,
		TextColor3 = Theme.Warn,
		Text = "0 g",
	})
	goldLabel.Parent = gui

	local questTracker = UI.frame({
		Name = "QuestTracker",
		Size = UDim2.fromOffset(260, 200),
		Position = UDim2.new(1, -276, 0, 16),
		BackgroundTransparency = 1,
	})
	UI.vlist(questTracker, 6)
	questTracker.Parent = gui

	local rosterButton = UI.button({
		Size = UDim2.fromOffset(120, 36),
		Position = UDim2.fromOffset(16, 58),
		Text = "Roster",
	}, function()
		controller:toggleRoster()
	end)
	rosterButton.Parent = gui

	local toastArea = UI.frame({
		Name = "Toasts",
		Size = UDim2.fromOffset(420, 220),
		Position = UDim2.new(0.5, -210, 1, -240),
		BackgroundTransparency = 1,
	})
	local toastLayout = UI.vlist(toastArea, 6)
	toastLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
	toastArea.Parent = gui

	function controller:setGold(gold)
		goldLabel.Text = tostring(gold) .. " g"
	end

	function controller:setQuests(quests)
		for _, child in ipairs(questTracker:GetChildren()) do
			if child:IsA("Frame") then
				child:Destroy()
			end
		end
		for i, quest in ipairs(quests) do
			local card = UI.frame({ Size = UDim2.new(1, 0, 0, 52), LayoutOrder = i, BackgroundTransparency = 0.25 })
			UI.corner(card)
			UI.padding(card, 6)
			local remaining = math.max(0, quest.endsAt - os.time())
			UI.label({
				Size = UDim2.fromScale(1, 1),
				TextSize = 14,
				Text = string.format(
					"%s\n%s · %d:%02d%s",
					quest.text:sub(1, 60),
					table.concat(quest.heroNames, ", "),
					math.floor(remaining / 60),
					remaining % 60,
					quest.hasRaven and "  🐦 RAVEN WAITS" or ""
				),
			}).Parent = card
			card.Parent = questTracker
		end
	end

	function controller:toast(text, color)
		local toast = UI.frame({ Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = Theme.Panel, BackgroundTransparency = 0.1 })
		UI.corner(toast)
		UI.padding(toast, 8)
		UI.label({
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			TextSize = 16,
			TextColor3 = color or Theme.Text,
			Text = text,
		}).Parent = toast
		toast.Parent = toastArea
		task.delay(6, function()
			toast:Destroy()
		end)
	end

	-- ========================= Job Board (screen 2) =========================
	local boardOverlay, boardPanel = UI.modal(gui, UDim2.fromOffset(520, 480), "JobBoard")
	UI.label({ Size = UDim2.new(1, 0, 0, 32), Font = Theme.FontBold, TextSize = 24, Text = "Job Board" }).Parent = boardPanel
	local boardList = UI.scroll({ Size = UDim2.new(1, 0, 1, -76), Position = UDim2.fromOffset(0, 40) })
	UI.vlist(boardList, 8)
	boardList.Parent = boardPanel
	UI.button({ Size = UDim2.new(0, 120, 0, 32), Position = UDim2.new(1, -120, 1, -32), Text = "Close" }, function()
		boardOverlay.Visible = false
	end).Parent = boardPanel

	function controller:showBoard(postings)
		for _, child in ipairs(boardList:GetChildren()) do
			if child:IsA("Frame") then
				child:Destroy()
			end
		end
		for i, posting in ipairs(postings) do
			local card = UI.frame({ Size = UDim2.new(1, -8, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = i, BackgroundColor3 = Theme.PanelLight })
			UI.corner(card)
			UI.padding(card, 10)
			UI.vlist(card, 4)
			UI.label({
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				TextSize = 17,
				Text = posting.text,
			}).Parent = card
			UI.label({
				Size = UDim2.new(1, 0, 0, 20),
				TextSize = 14,
				TextColor3 = Theme.TextDim,
				Text = string.format(
					"%s · %s · %d–%d g · posted by %s",
					string.rep("★", math.min(posting.difficulty, 5)),
					posting.scripted and "SEALED" or "Thornwood",
					posting.rewardMin,
					posting.rewardMax,
					posting.giver
				),
			}).Parent = card
			UI.button({ Size = UDim2.fromOffset(150, 30), Text = "Assemble party" }, function()
				boardOverlay.Visible = false
				controller:showPartyPicker(posting)
			end).Parent = card
			card.Parent = boardList
		end
		boardOverlay.Visible = true
	end

	-- ========================= Party Picker (screen 5) =========================
	local pickerOverlay, pickerPanel = UI.modal(gui, UDim2.fromOffset(560, 520), "PartyPicker")
	local pickerTitle = UI.label({ Size = UDim2.new(1, 0, 0, 56), Font = Theme.FontBold, TextSize = 18, Text = "" })
	pickerTitle.Parent = pickerPanel
	local pickerRoster = UI.scroll({ Size = UDim2.new(1, 0, 1, -170), Position = UDim2.fromOffset(0, 64) })
	UI.vlist(pickerRoster, 6)
	pickerRoster.Parent = pickerPanel
	local oddsLabel = UI.label({
		Size = UDim2.new(1, 0, 0, 30),
		Position = UDim2.new(0, 0, 1, -76),
		Font = Theme.FontBold,
		TextSize = 22,
		Text = "Odds: —",
	})
	oddsLabel.Parent = pickerPanel
	local launchButton = UI.button({
		Size = UDim2.new(0, 180, 0, 40),
		Position = UDim2.new(1, -180, 1, -40),
		BackgroundColor3 = Theme.Ember,
		TextColor3 = Theme.Ink,
		Text = "LAUNCH",
	}, function()
		local picking = controller.state.picking
		if picking and #picking.selected > 0 then
			pickerOverlay.Visible = false
			callbacks.onLaunch(picking.posting.id, picking.selected)
		end
	end)
	launchButton.Parent = pickerPanel
	UI.button({ Size = UDim2.fromOffset(120, 40), Position = UDim2.new(0, 0, 1, -40), Text = "Back" }, function()
		pickerOverlay.Visible = false
	end).Parent = pickerPanel

	local function refreshOdds()
		local picking = controller.state.picking
		if not picking then
			return
		end
		if #picking.selected == 0 then
			oddsLabel.Text = "Odds: —"
			return
		end
		task.spawn(function()
			local band = callbacks.onRequestOdds(picking.posting.id, picking.selected)
			local colors = { Favored = Theme.Good, Even = Theme.Warn, Risky = Theme.Bad }
			oddsLabel.Text = "Odds: " .. tostring(band)
			oddsLabel.TextColor3 = colors[band] or Theme.Text
		end)
	end

	function controller:showPartyPicker(posting)
		controller.state.picking = { posting = posting, selected = {} }
		pickerTitle.Text = posting.text .. (posting.hint and ("\nHint: " .. posting.hint) or "")
		for _, child in ipairs(pickerRoster:GetChildren()) do
			if child:IsA("TextButton") then
				child:Destroy()
			end
		end
		local order = 0
		for heroId, hero in pairs(controller.state.heroes or {}) do
			order += 1
			local available = hero.state == "idle"
			local row
			row = UI.button({
				Size = UDim2.new(1, -8, 0, 44),
				LayoutOrder = order,
				BackgroundColor3 = available and Theme.PanelLight or Theme.Bg,
				TextColor3 = available and Theme.Text or Theme.TextDim,
				Text = string.format("%s — %s (%s)%s", hero.name, hero.tierName, table.concat(hero.axes, "/"), available and "" or " · " .. hero.state),
			}, function()
				if not available then
					return
				end
				local selected = controller.state.picking.selected
				local index = table.find(selected, heroId)
				if index then
					table.remove(selected, index)
					row.BackgroundColor3 = Theme.PanelLight
				elseif #selected < 3 then
					table.insert(selected, heroId)
					row.BackgroundColor3 = Theme.Ember
					row.TextColor3 = Theme.Ink
				end
				if not table.find(controller.state.picking.selected, heroId) then
					row.TextColor3 = Theme.Text
				end
				refreshOdds()
			end)
			row.Parent = pickerRoster
		end
		oddsLabel.Text = "Odds: —"
		pickerOverlay.Visible = true
	end

	-- ========================= Interview (screen 3) =========================
	local interviewOverlay, interviewPanel = UI.modal(gui, UDim2.fromOffset(520, 460), "Interview")
	local interviewName = UI.label({ Size = UDim2.new(1, 0, 0, 28), Font = Theme.FontBold, TextSize = 22, Text = "" })
	interviewName.Parent = interviewPanel
	local interviewMeta = UI.label({ Size = UDim2.new(1, 0, 0, 22), Position = UDim2.fromOffset(0, 28), TextSize = 14, TextColor3 = Theme.TextDim, Text = "" })
	interviewMeta.Parent = interviewPanel
	local interviewText = UI.label({ Size = UDim2.new(1, 0, 0, 120), Position = UDim2.fromOffset(0, 54), TextSize = 18, Text = "" })
	interviewText.Parent = interviewPanel
	local interviewChoices = UI.frame({ Size = UDim2.new(1, 0, 0, 150), Position = UDim2.fromOffset(0, 180), BackgroundTransparency = 1 })
	UI.vlist(interviewChoices, 6)
	interviewChoices.Parent = interviewPanel
	local interviewFooter = UI.frame({ Size = UDim2.new(1, 0, 0, 44), Position = UDim2.new(0, 0, 1, -44), BackgroundTransparency = 1 })
	interviewFooter.Parent = interviewPanel
	local footerLayout = Instance.new("UIListLayout")
	footerLayout.FillDirection = Enum.FillDirection.Horizontal
	footerLayout.Padding = UDim.new(0, 8)
	footerLayout.Parent = interviewFooter

	local function clearChoices()
		for _, child in ipairs(interviewChoices:GetChildren()) do
			if child:IsA("TextButton") then
				child:Destroy()
			end
		end
		for _, child in ipairs(interviewFooter:GetChildren()) do
			if child:IsA("TextButton") then
				child:Destroy()
			end
		end
	end

	local function addChoice(text, onClick)
		UI.button({ Size = UDim2.new(1, -8, 0, 40), Text = text }, onClick).Parent = interviewChoices
	end

	local function showAskPhase()
		clearChoices()
		interviewChoices.Visible = true
		addChoice("“What do you want?”", function()
			callbacks.onInterviewAsk("want")
		end)
		addChoice("“Where have you worked?”", function()
			callbacks.onInterviewAsk("worked")
		end)
		addChoice("“Anything I should know?”", function()
			callbacks.onInterviewAsk("know")
		end)
		UI.button({ Size = UDim2.fromOffset(140, 40), BackgroundColor3 = Theme.Good, TextColor3 = Theme.Ink, Text = "Sign" }, function()
			callbacks.onInterviewDecide("sign")
		end).Parent = interviewFooter
		UI.button({ Size = UDim2.fromOffset(170, 40), Text = "Let them think" }, function()
			callbacks.onInterviewDecide("wait")
		end).Parent = interviewFooter
	end

	function controller:interviewUpdate(update)
		if update.phase == "open" then
			local payload = update.payload
			controller.state.interviewCost = payload.cost
			interviewName.Text = payload.name
			interviewMeta.Text = string.format(
				"%s · wants: %s · signing cost: %d g",
				payload.rarity,
				payload.revealedPref,
				payload.cost
			)
			interviewText.Text = payload.approach .. "\n\n" .. payload.node.prompt
			clearChoices()
			for i, option in ipairs(payload.node.options) do
				addChoice(option.text, function()
					callbacks.onInterviewChoice(i)
				end)
			end
			interviewOverlay.Visible = true
		elseif update.phase == "questions" then
			interviewText.Text = "“" .. (update.reply or "") .. "”\n\n" .. update.node.prompt
			clearChoices()
			for i, option in ipairs(update.node.options) do
				addChoice(option.text, function()
					callbacks.onInterviewChoice(i)
				end)
			end
		elseif update.phase == "ask" then
			interviewText.Text = "“" .. (update.reply or "") .. "”"
			showAskPhase()
			if update.asksLeft == 0 then
				for _, child in ipairs(interviewChoices:GetChildren()) do
					if child:IsA("TextButton") then
						child.Active = false
						child.TextColor3 = Theme.TextDim
					end
				end
			end
		elseif update.phase == "closed" then
			interviewText.Text = "“" .. (update.reply or "") .. "”"
			clearChoices()
			UI.button({ Size = UDim2.fromOffset(140, 40), Text = "Done" }, function()
				interviewOverlay.Visible = false
			end).Parent = interviewFooter
		end
	end

	-- ========================= Raven Popup (screen 6) =========================
	local ravenOverlay, ravenPanel = UI.modal(gui, UDim2.fromOffset(480, 320), "Raven")
	UI.label({ Size = UDim2.new(1, 0, 0, 26), Font = Theme.FontBold, TextSize = 20, TextColor3 = Theme.Ember, Text = "🐦 A raven arrives" }).Parent = ravenPanel
	local ravenText = UI.label({ Size = UDim2.new(1, 0, 0, 110), Position = UDim2.fromOffset(0, 32), TextSize = 18, Text = "" })
	ravenText.Parent = ravenPanel
	local ravenChoices = UI.frame({ Size = UDim2.new(1, 0, 0, 100), Position = UDim2.fromOffset(0, 150), BackgroundTransparency = 1 })
	UI.vlist(ravenChoices, 6)
	ravenChoices.Parent = ravenPanel
	local ravenTimer = UI.frame({ Size = UDim2.new(1, 0, 0, 6), Position = UDim2.new(0, 0, 1, -6), BackgroundColor3 = Theme.Ember })
	ravenTimer.Parent = ravenPanel

	function controller:showRaven(raven)
		ravenText.Text = raven.text
		for _, child in ipairs(ravenChoices:GetChildren()) do
			if child:IsA("TextButton") then
				child:Destroy()
			end
		end
		for i, option in ipairs(raven.options) do
			UI.button({ Size = UDim2.new(1, -8, 0, 40), Text = option.text }, function()
				ravenOverlay.Visible = false
				callbacks.onRavenChoice(raven.questId, i)
			end).Parent = ravenChoices
		end
		ravenOverlay.Visible = true
		task.spawn(function()
			while ravenOverlay.Visible do
				local remaining = raven.expiresAt - os.time()
				if remaining <= 0 then
					ravenOverlay.Visible = false
					break
				end
				ravenTimer.Size = UDim2.new(math.clamp(remaining / 90, 0, 1), 0, 0, 6)
				task.wait(0.25)
			end
		end)
	end

	-- ========================= Quest Report (screen 8) =========================
	local reportOverlay, reportPanel = UI.modal(gui, UDim2.fromOffset(540, 520), "QuestReport")
	local reportBanner = UI.label({ Size = UDim2.new(1, 0, 0, 36), Font = Theme.FontBold, TextSize = 28, Text = "" })
	reportBanner.Parent = reportPanel
	local reportBody = UI.scroll({ Size = UDim2.new(1, 0, 1, -96), Position = UDim2.fromOffset(0, 44) })
	UI.vlist(reportBody, 6)
	reportBody.Parent = reportPanel
	UI.button({ Size = UDim2.fromOffset(150, 38), Position = UDim2.new(0.5, -75, 1, -38), Text = "Continue" }, function()
		reportOverlay.Visible = false
	end).Parent = reportPanel

	function controller:showReport(report)
		local colors = { Triumph = Theme.Good, Success = Theme.Good, Setback = Theme.Warn, Disaster = Theme.Bad }
		reportBanner.Text = report.outcome
		reportBanner.TextColor3 = colors[report.outcome] or Theme.Text
		for _, child in ipairs(reportBody:GetChildren()) do
			if child:IsA("TextLabel") then
				child:Destroy()
			end
		end
		local order = 0
		local function line(text, color, size)
			order += 1
			UI.label({
				Size = UDim2.new(1, -8, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				LayoutOrder = order,
				TextSize = size or 16,
				TextColor3 = color or Theme.Text,
				Text = text,
			}).Parent = reportBody
		end
		line(report.posting, Theme.TextDim)
		for _, beat in ipairs(report.beats or {}) do
			line(beat.narration, beat.won and Theme.Good or Theme.Bad)
		end
		if report.gold > 0 then
			line("Payment: " .. report.gold .. " g", Theme.Warn, 18)
		end
		if #(report.injuries or {}) > 0 then
			line("Injured: " .. table.concat(report.injuries, ", "), Theme.Bad, 18)
		end
		for _, heroLine in ipairs(report.heroLines or {}) do
			if heroLine.line then
				line(heroLine.name .. ": “" .. heroLine.line .. "”", Theme.Parchment, 17)
			end
		end
		reportOverlay.Visible = true
	end

	-- ========================= Welcome-Back (screen 7) =========================
	local wbOverlay, wbPanel = UI.modal(gui, UDim2.fromOffset(480, 420), "WelcomeBack")
	UI.label({ Size = UDim2.new(1, 0, 0, 30), Font = Theme.FontBold, TextSize = 24, Text = "While you were away…" }).Parent = wbPanel
	local wbBody = UI.scroll({ Size = UDim2.new(1, 0, 1, -128), Position = UDim2.fromOffset(0, 38) })
	UI.vlist(wbBody, 6)
	wbBody.Parent = wbPanel
	-- Doubler slot exists but is DISABLED in Slice 1 (spec §5).
	local doubler = UI.button({
		Size = UDim2.new(1, 0, 0, 36),
		Position = UDim2.new(0, 0, 1, -84),
		BackgroundColor3 = Theme.Bg,
		TextColor3 = Theme.TextDim,
		Text = "Double the haul (coming soon)",
	}, nil)
	doubler.Active = false
	doubler.Parent = wbPanel
	UI.button({ Size = UDim2.new(1, 0, 0, 40), Position = UDim2.new(0, 0, 1, -40), BackgroundColor3 = Theme.Ember, TextColor3 = Theme.Ink, Text = "CONTINUE" }, function()
		wbOverlay.Visible = false
	end).Parent = wbPanel

	function controller:showWelcomeBack(haul)
		for _, child in ipairs(wbBody:GetChildren()) do
			if child:IsA("TextLabel") then
				child:Destroy()
			end
		end
		local order = 0
		local function line(text, color)
			order += 1
			UI.label({
				Size = UDim2.new(1, -8, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				LayoutOrder = order,
				TextSize = 16,
				TextColor3 = color or Theme.Text,
				Text = text,
			}).Parent = wbBody
		end
		line("The fire held. The till filled.", Theme.TextDim)
		if haul.gold > 0 then
			line("Till: +" .. haul.gold .. " g", Theme.Warn)
		end
		for _, questLine in ipairs(haul.questLines or {}) do
			line(questLine)
		end
		if (haul.newProspects or 0) > 0 then
			line(haul.newProspects .. " traveler(s) are asking after the owner…", Theme.Ember)
		end
		wbOverlay.Visible = true
	end

	-- ========================= Roster / Hero Sheet (screen 4) =========================
	local rosterOverlay, rosterPanel = UI.modal(gui, UDim2.fromOffset(540, 480), "Roster")
	UI.label({ Size = UDim2.new(1, 0, 0, 30), Font = Theme.FontBold, TextSize = 24, Text = "The Roster" }).Parent = rosterPanel
	local rosterList = UI.scroll({ Size = UDim2.new(1, 0, 1, -76), Position = UDim2.fromOffset(0, 38) })
	UI.vlist(rosterList, 8)
	rosterList.Parent = rosterPanel
	UI.button({ Size = UDim2.fromOffset(120, 32), Position = UDim2.new(1, -120, 1, -32), Text = "Close" }, function()
		rosterOverlay.Visible = false
	end).Parent = rosterPanel

	function controller:toggleRoster()
		if rosterOverlay.Visible then
			rosterOverlay.Visible = false
			return
		end
		for _, child in ipairs(rosterList:GetChildren()) do
			if child:IsA("Frame") then
				child:Destroy()
			end
		end
		local order = 0
		for heroId, hero in pairs(controller.state.heroes or {}) do
			order += 1
			local card = UI.frame({ Size = UDim2.new(1, -8, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = order, BackgroundColor3 = Theme.PanelLight })
			UI.corner(card)
			UI.padding(card, 10)
			UI.vlist(card, 4)
			UI.label({
				Size = UDim2.new(1, 0, 0, 22),
				Font = Theme.FontBold,
				TextSize = 18,
				Text = string.format("%s — %s", hero.name, hero.tierName),
			}).Parent = card
			UI.label({
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				TextSize = 14,
				TextColor3 = Theme.TextDim,
				Text = string.format(
					"%s · loyalty %d (%s) · axes %s\nquirk: %s",
					hero.state,
					hero.loyalty,
					hero.register,
					table.concat(hero.axes, "/"),
					hero.quirkKnown and hero.quirkHint or "?"
				),
			}).Parent = card
			local bar = UI.frame({ Size = UDim2.new(1, 0, 0, 6), BackgroundColor3 = Theme.Bg })
			UI.corner(bar, UDim.new(0, 3))
			UI.frame({ Size = UDim2.fromScale(hero.loyalty / 100, 1), BackgroundColor3 = Theme.Ember }).Parent = bar
			bar.Parent = card
			if hero.state == "injured" then
				UI.button({ Size = UDim2.fromOffset(200, 30), BackgroundColor3 = Theme.Good, TextColor3 = Theme.Ink, Text = "Heal (" .. hero.healCost .. " g)" }, function()
					callbacks.onHeal(heroId)
				end).Parent = card
			end
			card.Parent = rosterList
		end
		rosterOverlay.Visible = true
	end

	-- ========================= FTUE letter =========================
	local letterOverlay, letterPanel = UI.modal(gui, UDim2.fromOffset(520, 460), "Letter")
	letterPanel.BackgroundColor3 = Theme.Parchment
	local letterText = UI.label({ Size = UDim2.new(1, 0, 1, -56), TextSize = 17, TextColor3 = Theme.Ink, Text = "" })
	letterText.Parent = letterPanel
	UI.button({
		Size = UDim2.new(0, 200, 0, 40),
		Position = UDim2.new(0.5, -100, 1, -40),
		BackgroundColor3 = Theme.Ink,
		Text = "Bank the fire. Begin.",
	}, function()
		letterOverlay.Visible = false
		callbacks.onFtueAdvance()
	end).Parent = letterPanel

	function controller:showLetter(text)
		letterText.Text = text
		letterOverlay.Visible = true
	end

	return controller
end

return Screens
