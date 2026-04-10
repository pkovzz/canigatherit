-- CanIGatherIt - Shows if you can gather a node based on your profession skill
-- For TBC Classic (2.5.x)

local addonName, addon = ...

-- ============================================================================
-- Skill requirement data
-- Key: localized node name (enUS), Value: { skill = required_level, type = "herb"|"ore" }
-- ============================================================================

local nodeData = {
    -- ========== HERBS ==========
    -- Vanilla herbs
    ["Peacebloom"]           = { skill = 1,   type = "herb" },
    ["Silverleaf"]           = { skill = 1,   type = "herb" },
    ["Earthroot"]            = { skill = 15,  type = "herb" },
    ["Mageroyal"]            = { skill = 50,  type = "herb" },
    ["Briarthorn"]           = { skill = 70,  type = "herb" },
    ["Stranglekelp"]         = { skill = 85,  type = "herb" },
    ["Bruiseweed"]           = { skill = 100, type = "herb" },
    ["Wild Steelbloom"]      = { skill = 115, type = "herb" },
    ["Grave Moss"]           = { skill = 120, type = "herb" },
    ["Kingsblood"]           = { skill = 125, type = "herb" },
    ["Liferoot"]             = { skill = 150, type = "herb" },
    ["Fadeleaf"]             = { skill = 160, type = "herb" },
    ["Goldthorn"]            = { skill = 170, type = "herb" },
    ["Khadgar's Whisker"]    = { skill = 185, type = "herb" },
    ["Wintersbite"]          = { skill = 195, type = "herb" },
    ["Firebloom"]            = { skill = 205, type = "herb" },
    ["Purple Lotus"]         = { skill = 210, type = "herb" },
    ["Arthas' Tears"]        = { skill = 220, type = "herb" },
    ["Sungrass"]             = { skill = 230, type = "herb" },
    ["Blindweed"]            = { skill = 235, type = "herb" },
    ["Ghost Mushroom"]       = { skill = 245, type = "herb" },
    ["Gromsblood"]           = { skill = 250, type = "herb" },
    ["Golden Sansam"]        = { skill = 260, type = "herb" },
    ["Dreamfoil"]            = { skill = 270, type = "herb" },
    ["Mountain Silversage"]  = { skill = 280, type = "herb" },
    ["Plaguebloom"]          = { skill = 285, type = "herb" },
    ["Icecap"]               = { skill = 290, type = "herb" },
    ["Black Lotus"]          = { skill = 300, type = "herb" },
    -- TBC herbs
    ["Bloodthistle"]         = { skill = 1,   type = "herb" },
    ["Felweed"]              = { skill = 300, type = "herb" },
    ["Dreaming Glory"]       = { skill = 315, type = "herb" },
    ["Ragveil"]              = { skill = 325, type = "herb" },
    ["Flame Cap"]            = { skill = 335, type = "herb" },
    ["Terocone"]             = { skill = 325, type = "herb" },
    ["Ancient Lichen"]       = { skill = 340, type = "herb" },
    ["Netherbloom"]          = { skill = 350, type = "herb" },
    ["Nightmare Vine"]       = { skill = 365, type = "herb" },
    ["Mana Thistle"]         = { skill = 375, type = "herb" },
    ["Fel Lotus"]            = { skill = 300, type = "herb" },

    -- ========== MINING NODES ==========
    -- Vanilla ores
    ["Copper Vein"]              = { skill = 1,   type = "ore" },
    ["Tin Vein"]                 = { skill = 65,  type = "ore" },
    ["Silver Vein"]              = { skill = 75,  type = "ore" },
    ["Incendicite Mineral Vein"] = { skill = 65,  type = "ore" },
    ["Lesser Bloodstone Deposit"]= { skill = 75,  type = "ore" },
    ["Iron Deposit"]             = { skill = 125, type = "ore" },
    ["Gold Vein"]                = { skill = 155, type = "ore" },
    ["Mithril Deposit"]          = { skill = 175, type = "ore" },
    ["Truesilver Deposit"]       = { skill = 230, type = "ore" },
    ["Dark Iron Deposit"]        = { skill = 230, type = "ore" },
    ["Small Thorium Vein"]       = { skill = 245, type = "ore" },
    ["Rich Thorium Vein"]        = { skill = 275, type = "ore" },
    ["Ooze Covered Thorium Vein"]= { skill = 245, type = "ore" },
    ["Ooze Covered Rich Thorium Vein"] = { skill = 275, type = "ore" },
    ["Hakkari Thorium Vein"]     = { skill = 275, type = "ore" },
    -- TBC ores
    ["Fel Iron Deposit"]         = { skill = 300, type = "ore" },
    ["Adamantite Deposit"]       = { skill = 325, type = "ore" },
    ["Rich Adamantite Deposit"]  = { skill = 350, type = "ore" },
    ["Khorium Vein"]             = { skill = 375, type = "ore" },
    ["Nethercite Deposit"]       = { skill = 350, type = "ore" },
}

-- ============================================================================
-- Helper: get player's current skill level for a profession
-- ============================================================================

local function GetProfessionSkill(profName)
    -- In TBC Classic we iterate over the skill lines
    local numSkills = GetNumSkillLines()
    for i = 1, numSkills do
        local name, isHeader, _, skillRank, _, _, skillMaxRank = GetSkillLineInfo(i)
        if not isHeader and name == profName then
            return skillRank, skillMaxRank
        end
    end
    return nil, nil
end

-- ============================================================================
-- Determine color based on skill difference (mimics WoW's node coloring)
-- Orange: can gather, guaranteed skillup | Yellow: can gather, likely skillup
-- Green: can gather, unlikely skillup | Gray: can gather, no skillup
-- Red: cannot gather
-- ============================================================================

local function GetDifficultyColor(playerSkill, requiredSkill)
    if playerSkill < requiredSkill then
        -- Cannot gather
        return 1.0, 0.2, 0.2 -- Red
    end

    local diff = playerSkill - requiredSkill

    if diff < 25 then
        return 1.0, 0.5, 0.25 -- Orange
    elseif diff < 50 then
        return 1.0, 1.0, 0.0 -- Yellow
    elseif diff < 100 then
        return 0.25, 0.75, 0.25 -- Green
    else
        return 0.5, 0.5, 0.5 -- Gray
    end
end

-- ============================================================================
-- Tooltip hooks
-- ============================================================================

local function OnTooltipSetUnit(tooltip)
    -- Some "herb" mobs in TBC (e.g. Bog Lords) might appear here
    -- We skip unit tooltips for now
end

local function AddGatherInfo(tooltip, name)
    local data = nodeData[name]
    if not data then return end

    local profName
    if data.type == "herb" then
        profName = "Herbalism"
    elseif data.type == "ore" then
        profName = "Mining"
    end

    local playerSkill, maxSkill = GetProfessionSkill(profName)

    if not playerSkill then
        tooltip:AddLine(" ")
        tooltip:AddDoubleLine(
            profName .. ":",
            "Not learned",
            1.0, 0.8, 0.0,
            1.0, 0.2, 0.2
        )
        tooltip:Show()
        return
    end

    local r, g, b = GetDifficultyColor(playerSkill, data.skill)
    local canGather = playerSkill >= data.skill

    tooltip:AddLine(" ")
    tooltip:AddDoubleLine(
        "Requires " .. profName .. ":",
        tostring(data.skill),
        1.0, 0.8, 0.0,
        r, g, b
    )
    tooltip:AddDoubleLine(
        "Your skill:",
        playerSkill .. " / " .. maxSkill,
        1.0, 0.8, 0.0,
        r, g, b
    )

    if canGather then
        tooltip:AddLine("You CAN gather this.", 0.25, 1.0, 0.25)
    else
        local deficit = data.skill - playerSkill
        tooltip:AddLine("Need " .. deficit .. " more skill to gather.", 1.0, 0.2, 0.2)
    end

    tooltip:Show()
end

-- ============================================================================
-- Tooltip hooks
-- We hook GameTooltipTextLeft1:SetText via SecureHookScript. This fires
-- whenever the tooltip's first line of text changes — covers world nodes,
-- minimap tracking dots, and any other tooltip source.
-- ============================================================================

local lastProcessedName = nil
local lastProcessedLines = 0
local lastProcessedTime = 0

GameTooltip:HookScript("OnHide", function(self)
    lastProcessedName = nil
    lastProcessedLines = 0
end)

-- Core function that checks if we need to (re-)add gather info
local function TryAddGatherInfo()
    -- Only process tooltips from world objects and minimap, not inventory items
    local owner = GameTooltip:GetOwner()
    if owner then
        local ownerName = owner:GetName() or ""
        -- Skip bag slots, bank slots, mail, AH, trade, merchant, loot frames
        if ownerName:match("ContainerFrame")
            or ownerName:match("Character")
            or ownerName:match("BankFrame")
            or ownerName:match("MailFrame")
            or ownerName:match("AuctionFrame")
            or ownerName:match("TradeFrame")
            or ownerName:match("MerchantFrame")
            or ownerName:match("LootFrame")
            or ownerName:match("LootButton")
            or ownerName:match("GuildBank")
            or ownerName:match("InboxFrame") then
            return
        end
    end

    local text = GameTooltipTextLeft1 and GameTooltipTextLeft1:GetText()
    if not text or text == "" then return end

    if not nodeData[text] then
        lastProcessedName = nil
        lastProcessedLines = 0
        return
    end

    -- Count current tooltip lines to detect if the game has rebuilt it
    local currentLines = GameTooltip:NumLines()

    -- Add info if: new node, OR the tooltip was rebuilt (line count shrunk back)
    if text ~= lastProcessedName or currentLines < lastProcessedLines then
        lastProcessedName = text
        AddGatherInfo(GameTooltip, text)
        lastProcessedLines = GameTooltip:NumLines()
    end
end

-- Primary hook: fires when tooltip text is set (world objects, minimap dots)
hooksecurefunc(GameTooltipTextLeft1, "SetText", function(self, text)
    TryAddGatherInfo()
end)

-- Fallback: OnUpdate catches cases where SetText hook doesn't fire
-- and also re-adds info when the game refreshes the tooltip
GameTooltip:HookScript("OnUpdate", function(self, elapsed)
    lastProcessedTime = lastProcessedTime + elapsed
    if lastProcessedTime < 0.05 then return end
    lastProcessedTime = 0
    TryAddGatherInfo()
end)

-- ============================================================================
-- Slash command
-- ============================================================================

SLASH_CANIGATHERIT1 = "/cigi"
SLASH_CANIGATHERIT2 = "/canigatherit"

SlashCmdList["CANIGATHERIT"] = function(msg)
    local herbSkill = GetProfessionSkill("Herbalism")
    local mineSkill = GetProfessionSkill("Mining")

    print("|cff00ff00[CanIGatherIt]|r Profession skills:")
    if herbSkill then
        print("  Herbalism: " .. herbSkill)
    else
        print("  Herbalism: Not learned")
    end
    if mineSkill then
        print("  Mining: " .. mineSkill)
    else
        print("  Mining: Not learned")
    end
end

-- ============================================================================
-- Load message
-- ============================================================================

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function(self, event)
    print("|cff00ff00[CanIGatherIt]|r v1.0.0 loaded. Type /cigi to check your skills.")
end)
