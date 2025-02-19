--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Rokmora", 1458, 1662)
if not mod then return end
mod:RegisterEnableMob(91003) -- Rokmora
mod:SetEncounterID(1790)
mod:SetRespawnTime(15)

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.warmup_text = "Rokmora Active"
	L.warmup_trigger = "Navarrogg?! Betrayer! You would lead these intruders against us?!"
	L.warmup_trigger_2 = "Either way, I will enjoy every moment of it. Rokmora, crush them!"
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		"warmup",
		188169, -- Razor Shards
		188114, -- Shatter
		192800, -- Choking Dust
	}
end

function mod:OnBossEnable()
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL", "Warmup")
	self:Log("SPELL_CAST_START", "RazorShards", 188169)
	self:Log("SPELL_CAST_START", "Shatter", 188114)

	self:Log("SPELL_AURA_APPLIED", "ChokingDustDamage", 192800)
	self:Log("SPELL_PERIODIC_DAMAGE", "ChokingDustDamage", 192800)
	self:Log("SPELL_PERIODIC_MISSED", "ChokingDustDamage", 192800)
end

function mod:OnEngage()
	self:Bar(188114, 20.7) -- Shatter
	self:Bar(188169, 25.6) -- Razor Shards
end

--------------------------------------------------------------------------------
-- Event Handlers
--

-- TODO trigger this from trash for higher reliability
function mod:Warmup(event, msg)
	if msg == L.warmup_trigger then
		self:UnregisterEvent(event)
		self:Bar("warmup", 18.9, L.warmup_text, "achievement_dungeon_neltharionslair")
	elseif msg == L.warmup_trigger_2 then
		self:UnregisterEvent(event)
		self:Bar("warmup", 4.95, L.warmup_text, "achievement_dungeon_neltharionslair")
	end
end

function mod:RazorShards(args)
	self:Message(args.spellId, "orange")
	self:PlaySound(args.spellId, "alarm")
	self:CDBar(args.spellId, 29.2) -- pull:25.6, 29.2, 29.2, 29.2, 34.1
	-- correct timers
	if self:BarTimeLeft(188114) < 4.87 then -- Shatter
		self:Bar(188114, {4.87, 24.3})
	end
end

function mod:Shatter(args)
	self:Message(args.spellId, "yellow")
	self:PlaySound(args.spellId, "alert")
	self:Bar(args.spellId, 24.3) -- pull:20.7, 24.4, 24.3, 24.4, 24.3
	-- correct timers
	if self:BarTimeLeft(188169) < 4.87 then -- Razor Shards
		self:Bar(188169, {4.87, 29.2})
	end
end

do
	local prev = 0
	function mod:ChokingDustDamage(args)
		if self:Me(args.destGUID) then
			local t = args.time
			if t - prev > 2 then
				prev = t
				self:PersonalMessage(args.spellId, "underyou")
				self:PlaySound(args.spellId, "underyou")
			end
		end
	end
end
