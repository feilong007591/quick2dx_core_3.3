AStarInfo = class("AStarInfo", function(self, parent, g, h, f, openIndex)
	local this = {}
	this.parent = parent
	this.g = g
	this.h = h
	this.f = f
	this.openIndex = openIndex
	return this
end)


function AStarInfo:reset()
	self.parent = nil
	self.g = 0
	self.h = 0
	self.f = 0
	self.openIndex = 0
end

function AStarInfo:init(parent, g, h, f, openIndex)
	self.parent = parent
	self.g = g
	self.h = h
	self.f = f
	self.openIndex = openIndex
end

AStar = class("AStar", function(self)
	local this = {}
	this.MAX_COUNT = 50000
	this.G_COST = 10
	this.H_COST = 10

	this._infoList = {} 

	this._data = {}
	--vector<vector<AStarInfo>>
	this._mapStatus = {}
	--vector<Point>
	this._openList = {}
	this._checkCount = 0

	this._rlen = 0
	this._clen = 0

	this._startPos = nil
	this._endPos = nil
	this.endIndex = nil

	return this
end)

function AStar:getAStarInfo(parent, g, h, f, openIndex)
	if(table.getn(self._infoList) > 0) then
		local info = table.remove(self._infoList, 1)
		info:init(parent, g, h, f, openIndex)
		return info
	else
		return AStarInfo:new(parent, g, h, f, openIndex)
	end
end

function AStar:removeAStarInfo(info)
	if(info ~= nil) then
		info:reset()
		table.insert(self._infoList, info)
	end
end  

function AStar:isEmpty(row, col)
	--self._data[0]-->self._data[1]
	-- print(row,col,table.getn(self._data),table.getn(self._data[1]))
	if(row < 0 or row >= table.getn(self._data) or col >= table.getn(self._data[1])  or col < 0 or col >= 120) then 
--		return false
		return true
	else
		--_data[row][col] --> _data[row + 1][col + 1]
		return self._data[row + 1][col + 1] == globalData.allStaticTypes.mapBlockType.empty
	end
end

function AStar:init()
	for _,v in pairs(self._mapStatus) do
		for _,k in pairs(v) do
			self:removeAStarInfo(k)
		end
	end  
	self._mapStatus = {}
	self._openList = nil
	self._openList = {}
	self._startPos = nil
	self._endPos = nil
	self.endIndex = nil
end

function AStar:getInfo(row, col)
	--self._mapStatus[row][col] --> self._mapStatus[row + 1][col + 1]
	return self._mapStatus[row + 1][col + 1]
end

--当放入openlist中时就进行排序(二分法)
function AStar:sortOpenList(index)
	local middle = 0
	local firstP, middleP
	local firstInfo
	local middleInfo
	while(index > 1) do 
		middle = math.floor( index * 0.5 )
		--self._openList[index - 1]-->self._openList[index]
		firstP = self._openList[index]
		--middleP = self._openList[middle - 1]-->middleP = self._openList[middle]
		middleP = self._openList[middle]
		firstInfo = self:getInfo(firstP.y, firstP.x)
		middleInfo = self:getInfo(middleP.y, middleP.x)
		if(firstInfo.f < middleInfo.f) then
			--开放列表交换位置
			--self._openList[index - 1]-->self._openList[index]
			self._openList[index] = middleP
			--self._openList[middle - 1]-->self._openList[middle]
			self._openList[middle] = firstP
			middleInfo.openIndex = index - 1
			firstInfo.openIndex = middle - 1
			index = middle
		else
			break
		end
	end
end

function AStar:setSource(data)
	self._data = data
	self._rlen = table.getn(data)
	--table.getn(data[0])-->table.getn(data[1])
	self._clen = table.getn(data[1])
end

function AStar:isOpen(row, col)
	--self._mapStatus[row]-->self._mapStatus[row + 1]
	local t = self._mapStatus[row + 1]
	if(t ~= nil) then
		--t[col]-->t[col + 1]
		local info = t[col + 1]
		return (info ~= nil and info.openIndex ~= -1)
	end
	return false;
end

function AStar:isClose(row, col)
	--self._mapStatus[row] --> self._mapStatus[row + 1]
	local t = self._mapStatus[row + 1]
	if(t ~= nil) then
		--t[col] --> t[col + 1]
		local info = t[col + 1]
		return (info ~= nil and info.openIndex == -1)
	end
	return false
end

--二叉树排序
function AStar:shiftOpenList()
	if(table.getn(self._openList) == 1) then
		self._openList = nil
		self._openList = {}
		return
	end
	--self._openList[0]-->self._openList[1]
	-- self:removePoint(self._openList[1])
	self._openList[1] = table.remove(self._openList, table.getn(self._openList))
	--self._mapStatus[self._openList[0].y][self._openList[0].x] -->self._mapStatus[self._openList[1].y + 1][self._openList[1].x + 1]
	self._mapStatus[self._openList[1].y + 1][self._openList[1].x + 1].openIndex = 0

	local first = 1
	local tFirst = 0
	local middle = 0


	while (true) do
		tFirst = first
		middle = first * 2
		if (middle <= table.getn(self._openList)) then
			--self._mapStatus[self._openList[first - 1].y][self._openList[first - 1].x].f > self._mapStatus[self._openList[middle - 1].y][self._openList[middle - 1].x].f-->self._mapStatus[self._openList[first].y + 1][self._openList[first].x + 1].f > self._mapStatus[self._openList[middle].y + 1][self._openList[middle].x + 1].f
			if (self._mapStatus[self._openList[first].y + 1][self._openList[first].x + 1].f > self._mapStatus[self._openList[middle].y + 1][self._openList[middle].x + 1].f) then 
				first = middle
			end
			--middle + 1 <= table.getn(self._openList) && self._mapStatus[self._openList[first - 1].y][self._openList[first - 1].x].f > self._mapStatus[self._openList[middle].y][self._openList[middle].x].f-->middle + 1 <= table.getn(self._openList) && self._mapStatus[self._openList[first].y + 1][self._openList[first].x + 1].f > self._mapStatus[self._openList[middle + 1].y + 1][self._openList[middle + 1].x + 1].f
			if (middle + 1 <= table.getn(self._openList) and self._mapStatus[self._openList[first].y + 1][self._openList[first].x + 1].f > self._mapStatus[self._openList[middle + 1].y + 1][self._openList[middle + 1].x + 1].f) then 
				first = middle + 1
			end
		end
		if (tFirst == first) then 
			break
		end
		--self._openList[tFirst - 1]-->self._openList[tFirst]
		local t = self._openList[tFirst]
		--self._openList[tFirst - 1] = self._openList[first - 1]-->self._openList[tFirst] = self._openList[first]
		self._openList[tFirst] = self._openList[first]
		--self._openList[first - 1]-->self._openList[first]
		self._openList[first] = t
		--self._mapStatus[self._openList[tFirst - 1].y][self._openList[tFirst - 1].x]-->self._mapStatus[self._openList[tFirst].y + 1][self._openList[tFirst].x + 1]
		self._mapStatus[self._openList[tFirst].y + 1][self._openList[tFirst].x + 1].openIndex = tFirst - 1
		--self._mapStatus[self._openList[first - 1].y][self._openList[first - 1].x]-->self._mapStatus[self._openList[first].y + 1][self._openList[first].x + 1]
		self._mapStatus[self._openList[first].y + 1][self._openList[first].x + 1].openIndex = first - 1
	end
end

function AStar:trans(data)
	local len = table.getn(data)
	local a = nil
	for i = 1, len, 1 do
		a = data[i]
		a.x = globalData.GRID_SIZE * (a.x + 0.5)
		a.y = globalData.GRID_SIZE * (a.y + 0.5)
	end
end

function AStar:posToIndex(pos)
	pos.x = math.floor(pos.x / globalData.GRID_SIZE)
	pos.y = math.floor(pos.y / globalData.GRID_SIZE)
	return pos
end

function AStar:indexToPos(index)
	index.x = (index.x + 0.5) * globalData.GRID_SIZE
	index.y = (index.y + 0.5) * globalData.GRID_SIZE
	return index
end

function AStar:findPath(start, endp, stopAtDispatch, maxCount)
	if(stopAtDispatch == nil) then stopAtDispatch = 0 end
	if(maxCount == nil) then maxCount = 8000 end
	if(stopAtDispatch > 0) then
		if(globalManager.commonUtils:getPointDistance(start, endp) <= stopAtDispatch) then
			local tmp = {}
			table.insert(tmp,start)
			return tmp
		end
	end

	self._startPos = globalManager.ccCreator:newPoint(start.x, start.y)
	self._endPos = globalManager.ccCreator:newPoint(endp.x, endp.y)
	start = globalManager.ccCreator:newPoint(start.x, start.y)
	start = self:posToIndex(start)
	self.endIndex = self:posToIndex(endp)

	if(self:isEmpty(self.endIndex.y , self.endIndex.x)) then
		stopAtDispatch = 0
		self.endIndex = self:getAroundIndex()
		self._endPos = self:indexToPos(globalManager.ccCreator:newPoint(self.endIndex.x, self.endIndex.y))
	end

	-- self:init()
	

	local row = 0
	local col = 0
	local tg = 0
	local th = 0
	local len = 0
	table.insert(self._openList, start)
	--self._mapStatus[start.y]-->self._mapStatus[start.y + 1]
	self._mapStatus[start.y + 1] = {}
	--self._mapStatus[start.y][start.x]-->self._mapStatus[start.y + 1][start.x + 1]
	self._mapStatus[start.y + 1][start.x + 1] = self:getAStarInfo(nil, 0, 0, 0, 0)
	-- AStarInfo:new(null, 0, 0, 0, 0)
	self._checkCount = 1
	local current = nil
	local minRow = 0
	local maxRow = 0
	local minCol = 0
	local maxCol = 0

	while( table.getn(self._openList) > 0 and (not self:isClose(self.endIndex.y, self.endIndex.x)) ) do
		--self._openList[0]-->self._openList[1]
		current = self._openList[1]
		--self._mapStatus[current.y][current.x].openIndex-->self._mapStatus[current.y + 1][current.x + 1].openIndex
		self._mapStatus[current.y + 1][current.x + 1].openIndex = -1
		self:shiftOpenList()
		minRow = math.max(0, current.y - 1)
		maxRow = math.min(current.y + 1, self._rlen - 1)
		--row = minRow

		minCol = math.max(0, current.x - 1)
		maxCol = math.min(current.x + 1, self._clen - 1)
		row = minRow

		while(row <= maxRow) do
			col = minCol
			while(col <= maxCol) do
				if(  not ( row == current.y and col == current.x ) and ( row == current.y or col == current.x or not(self:isEmpty(row, current.x)) and not(self:isEmpty(current.y, col)) ) ) then
					if(not self:isEmpty(row, col) and not(self:isClose(row, col)) ) then
						--self._mapStatus[current.y][current.x]-->self._mapStatus[current.y + 1][current.x + 1]
						tg = self._mapStatus[current.y + 1][current.x + 1].g + self.G_COST
						if(self:isOpen(row, col)) then
							--self._mapStatus[row][col]-->self._mapStatus[row + 1][col + 1]
							if(tg < self._mapStatus[row + 1][col + 1].g) then
								--self._mapStatus[row][col]-->self._mapStatus[row + 1][col + 1]
								self._mapStatus[row + 1][col + 1].parent = current
								--self._mapStatus[row][col].f = tg + self._mapStatus[row][col].h-->self._mapStatus[row + 1][col + 1].f = tg + self._mapStatus[row + 1][col + 1].h
								self._mapStatus[row + 1][col + 1].f = tg + self._mapStatus[row + 1][col + 1].h
								--self._mapStatus[row][col]-->self._mapStatus[row + 1][col + 1]
								self:sortOpenList(self._mapStatus[row + 1][col + 1].openIndex + 1)
							end
						else
							th = (math.abs(row - self.endIndex.y) + math.abs(col - self.endIndex.x)) * self.H_COST
							--table.insert(self._openList, globalManager.ccCreator:newPoint(col, row))
							table.insert(self._openList, globalManager.ccCreator:newPoint(col, row))
							--self._mapStatus[row]-->self._mapStatus[row + 1]
							if(self._mapStatus[row + 1] == nil) then
								--_mapStatus[row]-->_mapStatus[row + 1]
								self._mapStatus[row + 1] = {}
							end
							--self._mapStatus[row][col]-->self._mapStatus[row + 1][col + 1]
							if(self._mapStatus[row + 1][col + 1] ~= nil) then
								self._mapStatus[row + 1][col + 1]:init(current, tg, th, tg+th, table.getn(self._openList) - 1)
							else
								self._mapStatus[row + 1][col + 1] = self:getAStarInfo(current, tg, th, tg+th, table.getn(self._openList) - 1)
							end
							--AStarInfo:new(current, tg, th, tg+th, table.getn(self._openList) - 1 )
							self:sortOpenList(table.getn(self._openList))
						end
					end
				end
				col = col + 1
			end
			row = row + 1
		end
		self._checkCount = self._checkCount + 1
		if(self._checkCount > maxCount) then
			break
		end
	end
	-- print(self._checkCount,"+++++++++")
	if(self:isClose(self.endIndex.y, self.endIndex.x)) then
		local result = {}
		local tp = self.endIndex
		while( not(tp.y == start.y) or not(tp.x == start.x) ) do
			table.insert(result, tp)
			--_mapStatus[tp.y][tp.x]-->_mapStatus[tp.y + 1][tp.x + 1]
			tp = self._mapStatus[tp.y + 1][tp.x + 1].parent
		end
		tp.x = start.x
		tp.y = start.y
		table.insert(result, tp)

		--翻转result
		len = table.getn(result)
		if(len > 1) then
			local reverse = {}
			for idx = len, 1, -1 do
				table.insert(reverse, result[idx])
			end
			result = reverse
		end


		--优化result
		result = self:optimizePath(result)
		--去掉相同点
		len = table.getn(result)
		for idx = len, 2, -1 do
			if(result[idx] == result[idx - 1]) then
				table.remove(result, idx)
			end
		end
		self:trans(result)
		--result[0]-->result[1]
		result[1] = self._startPos
		-- --如果停止距离大于0，那么最后一点和结束点的距离如果小于停止距离，就直接忽略结束点，否则添加结束点再切线
		-- if(table.getn(result) > 0) then
		-- 	result[table.getn(result)] = self._endPos
		-- else
		-- 	table.insert(result, self._endPos)
		-- end
		-- return self.module.walkTester:cutPathEnd(result, stopAtDispatch)
		self:init()
		return result
	end
	self:init()
	return nil
end

function AStar:getAroundIndex2(target,i,max)
	local tmp = globalManager.ccCreator:newPoint(target.x, target.y)
	local p = self:posToIndex(globalManager.ccCreator:newPoint(target.x, target.y))
	if(self:isEmpty(p.y, p.x) == false)then return tmp end
	p = self:doGetAroundIndex2(p,i,max)
	
	if(p ~= nil)then
		p = self:indexToPos(p)
	end
	return p
end
function AStar:doGetAroundIndex2(target,i,max)
	if(i == nil)then i = 1 end
	if(max == nil)then max = 5 end
	if(i > max)then return nil end
	local startRow = math.max(target.y - i,0)
	local endRow = math.min(target.y + i,self._rlen - 1)
	local startCol = math.max(target.x - i,0)
	local endCol = math.min(target.x + i,self._clen - 1)
	local result = nil
	for j = startCol, endCol, 1 do
		if(self:isEmpty(startRow, j) == false) then
			result = globalManager.ccCreator:newPoint(j, startRow)
			return result
		end
	end

	for j = startCol, endCol, 1 do
		if(self:isEmpty(endRow, j) == false) then
			result = globalManager.ccCreator:newPoint(j, endRow)
			return result
		end
	end

	for j = startRow, endRow, 1 do
		if(self:isEmpty(j, startCol) == false) then
			result = globalManager.ccCreator:newPoint(startCol, j)
			return result
		end
	end

	for j = startRow, endRow, 1 do
		if(self:isEmpty(j, endCol) == false) then
			result = globalManager.ccCreator:newPoint(endCol, j)
			return result
		end
	end

	if(result == nil) then 
		return self:doGetAroundIndex2(target,i + 1,max)
	end 
	return result
end

--递归找到非可行点的最近的可行点
--@param i 目标点的前后i个网格范围
--* @return 最近的点
function AStar:getAroundIndex(i)  

	if(i == nil) then i = 1 end
	local startRow = math.max(self.endIndex.y - i, 0)
	local endRow = math.min(self.endIndex.y + i, self._rlen - 1)
	local startCol = math.max(self.endIndex.x - i, 0)
	local endCol = math.min(self.endIndex.x + i, self._clen - 1)

	local result = nil
	for j = startCol, endCol, 1 do
		if(self:isEmpty(startRow, j) == false) then
			result = globalManager.ccCreator:newPoint(j, startRow)
			return result
		end
	end

	for j = startCol, endCol, 1 do
		if(self:isEmpty(endRow, j) == false) then
			result = globalManager.ccCreator:newPoint(j, endRow)
			return result
		end
	end

	for j = startRow, endRow, 1 do
		if(self:isEmpty(j, startCol) == false) then
			result = globalManager.ccCreator:newPoint(startCol, j)
			return result
		end
	end

	for j = startRow, endRow, 1 do
		if(self:isEmpty(j, endCol) == false) then
			result = globalManager.ccCreator:newPoint(endCol, j)
			return result
		end
	end

	if(result == nil) then 
		return self:getAroundIndex(i + 1)
	end 
	return result
end

function AStar:optimizePath(path)
	if(table.getn(path) == 0) then
		return path
	end

	local __len = table.getn(path)
	local __path = {}
	local _diagonal = {}
	local __dLen
	local __cross = true
	--path[0]-->path[1]
	local __currentNode = path[1]
	--path[0]-->path[1]
	table.insert(__path, path[1])
	for i = 1, __len - 1, 1 do 
		--path[i]-->path[i + 1]
		_diagonal = self:diagonalFind(__currentNode, path[i + 1])
		__dLen = table.getn(_diagonal)
		__cross = true
		for j = 0, __dLen - 1,1 do 
			--_data[_diagonal[j].y][_diagonal[j].x]-->_data[_diagonal[j + 1].y + 1][_diagonal[j + 1].x + 1]
			if(self._data[_diagonal[j + 1].y + 1][_diagonal[j + 1].x + 1] == 0) then
				__cross = false
				break
			end
		end
		if(not __cross) then
			if(i > 1) then
				--path[(i-1)] --> path[i]
				__currentNode = path[i]
				--path[(i-1)]-->path[i]
				table.insert(__path, path[i])
			end
		end
	end 
	_diagonal = nil
	--path[(__len-1)]-->path[__len]
	table.insert(__path, path[__len])
	path = __path;
	return path;
end

function AStar:diagonalFind( start_point, end_point )
	local w = 0
	local h = 0
	local __ox = 0
	local __oy = 0
	local __value = {}
	local __r = 0
	local __n1 = 0
	local __n2 = 0
	local __b1 = false
	local __b2 = false
	local __m = 0
	local __n = 0
	local __d = (start_point.x < end_point.x)==(start_point.y < end_point.y)

	local function three(v1, v2)
		if(__d) then
			table.insert(__value, v1)
		else
			table.insert(__value, v2)
		end
	end
	local function cpp(x, y)
		return globalManager.ccCreator:newPoint(x, y)
	end

	if (start_point.x < end_point.x) then
		__ox = start_point.x
		__oy = start_point.y
		w = end_point.x - __ox
		h = math.abs(end_point.y - __oy)
	else
		__ox = end_point.x
		__oy = end_point.y
		w = start_point.x - __ox
		h = math.abs(start_point.y - __oy)
	end


	if (w == h) then
		for __m = 0, w, 1 do 	--#? for (__m=0; __m<=w; __m++) {
			three(cpp(__ox + __m, __oy + __m), cpp(__ox + __m, __oy - __m))
			if(__m > 0) then
				three(cpp(__ox + __m - 1, __oy + __m), cpp(__ox + __m - 1, __oy - __m))
			end
			if(__m < w) then
				three(cpp(__ox + __m + 1, __oy + __m), cpp(__ox + __m + 1, __oy - __m))
			end
		end
	elseif (w > h) then
		__r = h / w
		table.insert(__value, cpp(__ox, __oy))
		for __m = 1, w, 1 do 	--#? for (__m=1; __m<=w; __m++) {
			__n1 = (__m - 0.5) * __r
			__n2 = (__m + 0.5) * __r
			__b1 = __n1 > __n - 0.5 and __n1 < __n + 0.5
			__b2 = __n2 > __n - 0.5 and __n2 < __n + 0.5
			if(__b1 or __b2) then
				three(cpp(__ox + __m, __oy + __n), cpp(__ox + __m, __oy - __n))
				if ( not __b2 ) then
					__n = __n + 1
					three(cpp(__ox + __m, __oy + __n), cpp(__ox + __m, __oy - __n))
				end
			end
		end
	elseif (w < h) then
		__r = w / h
		table.insert(__value, cpp(__ox, __oy))
		for __m = 1, h, 1 do 	-- for (__m=1; __m<=h; __m++) {
			__n1 = (__m - 0.5) * __r
			__n2 = (__m + 0.5) * __r
			__b1 = __n1 > __n - 0.5 and __n1 < __n + 0.5
			__b2 = __n2 > __n - 0.5 and __n2 < __n + 0.5
			if(__b1 or __b2) then
				three(cpp(__ox + __n, __oy + __m), cpp(__ox + __n, __oy - __m))
				if (not __b2) then
					__n = __n + 1
					three(cpp(__ox + __n, __oy + __m), cpp(__ox + __n, __oy - __m))
				end
			end
		end
	end

	return __value
end