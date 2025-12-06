function round(x)
    return math.floor(x + 0.5)
end

function GetPlayerCount(teamMapingTable)
	local count = 0
	
	for i, x in ipairs(teamMapingTable) do
		count = count + (x.playerCount or 0)
	end
	
	return count
end

function GetCircleBorderSPositions(gridSize, playerCount, margin)
    local positions = {}

    margin = margin or 0
    local R = gridSize / 2 - margin
    local cx = gridSize / 2
    local cy = gridSize / 2

    for i = 0, playerCount - 1 do
        local angle = 2 * math.pi * i / playerCount
        local x = cx + R * math.cos(angle)
        local y = cy + R * math.sin(angle)

        table.insert(positions, {x = round(x), y = round(y)})
    end

    return positions
end

function SpawnForestBelt(startPos, endPos)
	local forestPoints1 = DrawStraightLineReturn(startPos.x, startPos.y, endPos.x, endPos.y, false, tt_impasse_trees_plains, gridSize, terrainLayoutResult)
	local forestPoints2 = DrawStraightLineReturn(endPos.x, endPos.y, startPos.x, startPos.y, false, tt_impasse_trees_plains, gridSize, terrainLayoutResult)
	
	for i, forestPoint in ipairs(forestPoints1) do	
		terrainLayoutResult[forestPoint[1]][forestPoint[2]].terrainType = tt_impasse_trees_plains
	end
	
	for i, forestPoint in ipairs(forestPoints2) do	
		terrainLayoutResult[forestPoint[1]][forestPoint[2]].terrainType = tt_impasse_trees_plains
	end
end

-- Given:
-- center = (cx, cy)
-- point on circle = (px, py)
-- square is from 0 to L in both axes
function ExtendToSquareBorder(cx, cy, px, py, L)
    local dx = px - cx
    local dy = py - cy

    local tMin = math.huge
    local resultX, resultY

    -- Check intersection with left border x=0
    if dx ~= 0 then
        local t = (0 - cx) / dx
        if t > 0 then
            local y = cy + t * dy
            if y >= 0 and y <= L and t < tMin then
                tMin = t
                resultX, resultY = 0, y
            end
        end
    end

    -- Right border x=L
    if dx ~= 0 then
        local t = (L - cx) / dx
        if t > 0 then
            local y = cy + t * dy
            if y >= 0 and y <= L and t < tMin then
                tMin = t
                resultX, resultY = L, y
            end
        end
    end

    -- Top border y=0
    if dy ~= 0 then
        local t = (0 - cy) / dy
        if t > 0 then
            local x = cx + t * dx
            if x >= 0 and x <= L and t < tMin then
                tMin = t
                resultX, resultY = x, 0
            end
        end
    end

    -- Bottom border y=L
    if dy ~= 0 then
        local t = (L - cy) / dy
        if t > 0 then
            local x = cx + t * dx
            if x >= 0 and x <= L and t < tMin then
                tMin = t
                resultX, resultY = x, L
            end
        end
    end

    return { x = round(resultX), y = round(resultY) }
end


terrainLayoutResult = {}
gridHeight, gridWidth, gridSize = SetCustomCoarseGrid(10)
terrainLayoutResult = SetUpGrid(gridSize, tt_plains, terrainLayoutResult)

teamsList, playersPerTeam = SetUpTeams()
teamMappingTable = CreateTeamMappingTable()
playerCount = GetPlayerCount(teamMappingTable)

local circlePositions = GetCircleBorderSPositions(gridSize, 2 * playerCount, 1)
local mapCenter = { x = math.ceil(gridSize/2), y = math.ceil(gridSize/2) }

for i, pos in ipairs(circlePositions) do
	if i % 2 == 0 then
		terrainLayoutResult[pos.x][pos.y].playerIndex = i / 2 - 1
	else
		local posOnMapBorder = ExtendToSquareBorder(mapCenter.x, mapCenter.y, pos.x, pos.y, gridSize)
		SpawnForestBelt(mapCenter, posOnMapBorder)
	end
end
