local _, Addon = ...

--
-- ScrollListDataSource Model
-- Filter our full object graph for the objects we want to present
--

--Addon.selectedTags = {}
Addon.selectedTags = nil

Addon.filter = {}
Addon.filter.tags = {}
Addon.filter.NOT, Addon.filter.AND, Addon.filter.OR = {}, {}, {}
Addon.filter.predicates = {
	exists = function(v) -- ??
		return v ~= nil
	end,
	isEqual = function(v1)
		return v1 == v2	-- v2 must be an upvalue
	end,
	isMember = function(v)
		return tContains(s, v) -- s:tContains(tag) -- s must be an upvalue
	end,

	isTag = function(v2)
		return isEqual
	end,
	isInTags = function(s)
	    return Addon.filter.predicates.isMember
	end,

	isDungeon = function(tag)
		return tag.category == "dungeon"
	end,
	isRaid = function(tag)
		return tag.category == "raid"
	end,
	isBattleground = function(tag)
		return tag.category == "battleground"
	end,
	isInstance = function(tag)
		return tag.category == "dungeon" or
			   tag.category == "raid" or
			   tag.category == "battleground"
	end,
	isLFG = function(tag)
		return tag.category == "lfg"
	end,
	isEmpty = function(tag)
		return #tag.players == 0
	end,
	isLevelAppropriate = function(tag)
		return Addon:IsLevelAppropriate(tag.minLevel, tag.maxLevel, tag.reqLevel)
	end,
	none = function(tag)
		return false
	end,
}

local function bakeFunc()
end

--local tag = TagPredicates -- syntactic sugar:
--TagsWhere(tag.isDungeon, tag.isLFG, tag.isEmpty, tag.isTag(myothertag))


local function getTableSize(t)
    local c = 0
    for _ in pairs(t) do
        c = c + 1
    end
    return c
end
function tFilterWithPredicates(table, NOT, AND, OR)
	local matches = {}
	for _, v in ipairs(table) do -- go through all the elements of the array
		--print("_________", v.title, getTableSize(NOT), getTableSize(AND), getTableSize(OR))
		local match = true
		local continue = false

		if not continue then
			for _, p in pairs(OR) do
				if p(v) then
					--print("passed OR predicate")
					match = true -- passed OR predicate
					continue = true
					break
				end
			end
			if not continue then
				match = false -- failed all OR predicates
			end
		end
		if not continue then
			for _, p in pairs(NOT) do
				if p(v) then
					--print("failed NOT predicate")
					match = false -- failed NOT predicate
					continue = true
					break
				end
			end
			if not continue then
				match = true -- passed all NOT predicates
			end
		end
		if not continue then
			for _, p in pairs(AND) do
				if not p(v) then
					--print("failed AND predicate")
					match = false -- failed AND predicate
					continue = true
					break
				end
			end
			if not continue then
				match = true -- passed all AND predicates
			end
		end

		if match then
			--print("adding", v.title)
			tinsert(matches, v)
		end
	end
	return matches
end

local activePredicates = {
	NOT = {},
	AND = {},
	OR = {},
}

local function AddTagPredicate(predicate, operator) -- operator = 'AND' / 'OR' / 'NOT'

	local filteredTags = Addon.tags

	if not tContains(Addon.filter.NOT, TagPredicates.isEmpty) then
		tinsert(Addon.filter.NOT, TagPredicates.isEmpty)
	end

	filteredTags = tFilterWithPredicates(Addon.tags, Addon.filter.NOT, Addon.filter.AND, Addon.filter.OR)

	SetNeedsUpdate()

	tRemoveItem(Addon.filter.NOT, TagPredicates.isEmpty)

	filteredTags = tFilterWithPredicates(Addon.tags, Addon.filter.NOT, Addon.filter.AND, Addon.filter.OR)




	tinsert(Addon.filter.AND, function(tag) return TagPredicates.isTag(tag, tag2) end) -- tag2 is captured (closure)

	tinsert(Addon.filter.AND, TagPredicates.isTag(tag2)) -- tag2 is captured (closure)

	tinsert(Addon.filter.AND, TagPredicates.isInTags(tags)) -- tag2 is captured (closure)


	activePredicates[operator] = predicate
end
local function RemoveTagPredicate(predicate, operator)

end



local test = Addon.filter.predicates

function Addon:DungeonTags()
	return tFilterWithPredicates(Addon.tags, {}, {test.isDungeon}, {})
end
function Addon:InstanceTags()
	return tFilterWithPredicates(Addon.tags, {}, {test.isInstance}, {})
end
function Addon:PopulatedTags()
	return tFilterWithPredicates(Addon.tags, {test.isEmpty}, {}, {})
end
function Addon:PopulatedDungeonTags()
	return tFilterWithPredicates(Addon.tags, {test.isEmpty}, {test.isDungeon}, {})
end
function Addon:PopulatedInstanceTags()
	return tFilterWithPredicates(Addon.tags, {test.isEmpty}, {test.isInstance}, {})
end
function Addon:PopulatedLevelAppropriateDungeonTags()
	return tFilterWithPredicates(Addon.tags, {test.isEmpty}, {test.isDungeon, test.isLevelAppropriate}, {})
end
function Addon:LevelAppropriateDungeonTags()
	return tFilterWithPredicates(Addon.tags, {}, {test.isDungeon, test.isLevelAppropriate}, {})
end
function Addon:NoTags()
	return {}
  --return tFilterWithPredicates(Addon.tags, {}, {test.none}, {})
end
function Addon:SelectedTags(selectedTags)
	return tFilterWithPredicates(Addon.tags, {}, {test.isInTags(selectedTags)}, {})
end


--predicate.LHS = tag
--predicate.RHS = selectedTags
--predicate.eval = function(self)
	--return tContains(self.RHS, self.LHS)
--end



local function SortedLevelAppropriateDungeonTags()
	local virtualDungeonTags = Addon:LevelAppropriateDungeonTags()
	table.sort(virtualDungeonTags, function(i1, i2)
		local minLevel1 = Addon.tags[i1].minLevel
		local minLevel2 = Addon.tags[i2].minLevel
		if minLevel1 and minLevel2 then
			return minLevel1 < minLevel2
		end
	end)
	return virtualDungeonTags
end



--local previousDataSourceFunc = nil
local defaultDataSourceFunc = Addon.LevelAppropriateDungeonTags
local dataSourceFunc = defaultDataSourceFunc
--local cachedDataSource = nil
function Addon:SetDataSourceFunc(newDataSourceFunc)
	assert(newDataSourceFunc ~= nil, "Setting data source to nil")
	--previousDataSourceFunc = dataSourceFunc
    dataSourceFunc = newDataSourceFunc

    Addon.selectedTags = nil
end
function Addon:GetDataSourceFunc()
    return dataSourceFunc
end

function Addon:GetDataSource()
	-- the data source is cached since it is used tens if not hundreds of thousands of times
	if Addon.selectedTags ~= nil then
		return Addon.selectedTags
	end
	Addon.selectedTags = dataSourceFunc()

	--if #cachedDataSource == 0 then
		--cachedDataSource = Addon:PopulatedDungeonTags()
		--ScrollListDataSource_ClearCache()
	--end

	return Addon.selectedTags
end

