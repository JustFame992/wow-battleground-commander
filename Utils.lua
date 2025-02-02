local _, Namespace = ...

Namespace.Utils = {}

local IsInRaid = IsInRaid
local IsInGroup = IsInGroup
local UnitIsGroupLeader = UnitIsGroupLeader
local LE_PARTY_CATEGORY_HOME = LE_PARTY_CATEGORY_HOME
local LE_PARTY_CATEGORY_INSTANCE = LE_PARTY_CATEGORY_INSTANCE
local floor = math.floor
local ceil = math.ceil
local format = string.format
local pairs = pairs

local GroupType = {
    Solo = 1,
    Party = 2,
    Raid = 3,
    InstanceParty = 4,
    InstanceRaid = 5,
}
Namespace.Utils.GroupType = GroupType

local UnitSet = {
    Party = { 'player', 'party1', 'party2', 'party3', 'party4' },
    Raid = {
        'raid1', 'raid2', 'raid3', 'raid4', 'raid5', 'raid6', 'raid7', 'raid8', 'raid9', 'raid10',
        'raid11', 'raid12', 'raid13', 'raid14', 'raid15', 'raid16', 'raid17', 'raid18', 'raid19', 'raid20',
        'raid21', 'raid22', 'raid23', 'raid24', 'raid25', 'raid26', 'raid27', 'raid28', 'raid29', 'raid30',
        'raid31', 'raid32', 'raid33', 'raid34', 'raid35', 'raid36', 'raid37', 'raid38', 'raid39', 'raid40',
    },
}

function Namespace.Utils.TimeDiff(a, b)
    local secondsDiff = a - b
    local fullSeconds = secondsDiff

    local rounder = secondsDiff > 0 and floor or ceil
    local minutesDiff = rounder(secondsDiff / 60)
    local hoursDiff = rounder(minutesDiff / 60)

    local fullHours, fullMinutes = hoursDiff, minutesDiff
    minutesDiff = minutesDiff - hoursDiff * 60
    secondsDiff = secondsDiff - (minutesDiff * 60 + hoursDiff * 60 * 60)

    return {
        fullSeconds = fullSeconds,
        fullMinutes = fullMinutes,
        fullHours = fullHours,
        seconds = secondsDiff,
        minutes = minutesDiff,
        hours = hoursDiff,
        format = function()
            if hoursDiff > 0 then
                return format('%dh %dm %ds', hoursDiff, minutesDiff, secondsDiff)
            end

            if minutesDiff > 0 then
                return format('%dm %ds', minutesDiff, secondsDiff)
            end

            return format('%ds', secondsDiff)
        end,
    }
end

function Namespace.Utils.GetGroupType()
    if IsInRaid() then
        return (not IsInRaid(LE_PARTY_CATEGORY_HOME) and IsInRaid(LE_PARTY_CATEGORY_INSTANCE)) and GroupType.InstanceRaid or GroupType.Raid
    end

    if IsInGroup() then
        return (not IsInGroup(LE_PARTY_CATEGORY_HOME) and IsInGroup(LE_PARTY_CATEGORY_INSTANCE)) and GroupType.InstanceParty or GroupType.Party
    end

    return GroupType.solo
end

function Namespace.Utils.GetGroupLeaderUnit()
    local currentType = Namespace.Utils.GetGroupType()
    local units

    if currentType == GroupType.Raid or currentType == GroupType.InstanceRaid then
        units = UnitSet.Raid
    elseif currentType == GroupType.Party or currentType == GroupType.InstanceParty then
        units = UnitSet.Party
    else
        return nil
    end

    for _, unit in pairs(units) do
        if UnitIsGroupLeader(unit) then
            return unit
        end
    end

    return nil
end
