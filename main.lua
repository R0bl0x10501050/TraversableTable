--// Written by: R0bl0x10501050

--// Filename: TraversableTable.lua

----

local function checkDictionary(tbl)
	local isDict = true
	for i, v in pairs(tbl) do -- accurately get the "first" element to check
		if i == 1 then
			isDict = false
		end
		break
	end
	return isDict
end

local function safeGetLength(tbl)
	if typeof(tbl) == "table" then
		local isDict = checkDictionary(tbl)
		local length = 0
		if isDict then
			for _, _ in pairs(tbl) do
				length += 1
			end
		else
			length = #tbl
		end
		return length
	else
		return 0
	end
end

local Node
Node = {
	__newindex = function(t, k, v)
		local isDict
		if not rawget(t, '_children') then
			rawset(t, '_children', {})
			isDict = (k == 1)
		else
			isDict = checkDictionary(rawget(t, '_children'))
		end
		
		local newNode = Node.new(v)
		rawset(newNode, 'Parent', t)
		
		if isDict then
			rawset(t, '_idx', k)
			rawset(rawget(t, '_children'), k, newNode)
		else
			rawset(t, '_idx', #rawget(t, '_children') + 1)
			table.insert(rawget(t, '_children'), newNode)
		end
	end,
	__index = function(t, k)
		return rawget(rawget(t, '_children'), k)
		--if checkDictionary(t._children) then
		--	return rawget(t._children, k)
		--else
		--	return rawget(t._children, k)
		--end
	end,
}

function Node.new(value)
	local self = setmetatable({
		_raw = value
	}, Node)
	
	if typeof(value) == "string" or typeof(value) == "number" or typeof(value) == "boolean" or typeof(value) == "userdata" or typeof(value) == "function" then
		rawset(self, '_type', 'primitive')
	elseif typeof(value) == "table" then
		rawset(self, '_type', 'complex')
		
		local isDict = checkDictionary(value)
		
		rawset(self, '_children', {})
		
		if isDict then
			for k, v in pairs(value) do
				local newNode = Node.new(v)
				rawset(newNode, 'Parent', self)
				rawset(newNode, '_idx', k)
				rawset(rawget(self, '_children'), k, newNode)
			end
		else
			for _, v in ipairs(value) do
				local newNode = Node.new(v)
				rawset(newNode, 'Parent', self)
				rawset(newNode, '_idx', safeGetLength(rawget(self, '_children')) + 1)
				table.insert(self._children, newNode)
			end
		end
	end
	
	rawset(self, "Any", function()
		return {
			ForEach = function(f)
				for _, v in ipairs(self._children) do
					f(v)
				end
			end,
			Connect = function(f)
				for _, v in ipairs(self._children) do
					if v.Connect then
						v:Connect(f)
					end
				end
			end,
		}
	end)
	
	rawset(self, "Construct", function()
		local function _construct(n)
			if rawget(n, '_type') == "primitive" then
				return rawget(n, '_raw')
			elseif rawget(n, '_type') == "complex" then
				
				local tbl = {}
				for k, v in pairs(rawget(n, '_children')) do
					if typeof(v) == "table" then
						tbl[k] = _construct(v)
					else
						tbl[k] = rawget(v, '_raw')
					end
				end
				return tbl
			end
		end
		
		return _construct(self)
	end)
	
	rawset(self, "Get", function()
		return rawget(self, '_raw')
	end)
	
	rawset(self, "List", function()
		local isDict = checkDictionary(rawget(self, '_children'))
		local keys = {}
		for k, _ in pairs(rawget(self, '_children')) do
			table.insert(keys, k)
		end
		return keys
	end)
	
	rawset(self, "Set", function(self2, new)
		if rawget(self, 'Parent') then
			local newNode = Node.new(new)
			local oldIdx = rawget(self, '_idx')
			rawset(rawget(rawget(self, 'Parent'), '_children'), rawget(self, '_idx'), newNode)
			--self.Parent._children[self._idx] = newNode
			self = nil
			--local isDict = checkDictionary(self.Parent._children)
			--if isDict then
			--	rawe
			--else
			
			--end
		end
	end)
	
	return self
end

--function Node:Get()
--	return self._raw
--end

--function Node:List()
--	local isDict = checkDictionary(self._children)
--	local keys = {}
--	if isDict then
--		for k, _ in pairs(self._children) do
--			table.insert(keys, k)
--		end
--	end
--	return keys
--end



local TraversableTable = {}

function TraversableTable.new(tbl)
	--local self = setmetatable({
	--	_raw = tbl,
	--	_tbl = Node.new(tbl)
	--}, TraversableTable)
	
	--return self
	return Node.new(tbl)
end

return TraversableTable
