-- tmove

--===================================================
--=  Niklas Frykholm 
-- basically if user tries to create global variable
-- the system will not let them!!
-- call GLOBAL_lock(_G)
--
--===================================================
function GLOBAL_lock(t)
  local mt = getmetatable(t) or {}
  mt.__newindex = lock_new_index
  setmetatable(t, mt)
end

local __LOCK_TABLE = {}
GLOBAL_lock(__LOCK_TABLE)

local __turtleMaxSlot = 16

function usage()

	print("--tmove v1.0")
	print("Helps you move your")
	print(" turtle around! :)")
	print("")
	print("Usage: tmove fwd/back[,left/rt][,up/dwn]")
	print(" 'back', 'left', 'down' are negative")
	print("example: tmove(5)")
	print("         tmove(2,-1,4)")

end

function tposInit()
	tposPrint("tposInit")
	local tpos = {}
	tpos.z=0
	tpos.y=0
	tpos.x=0
	tpos.dir=1
	tpos.canBreakOnMove=true
	tpos.debugPrint=true
	tpos.placeMode=false
	tpos.placeSlot=0
	tpos.placeSlotNext=0
	tpos.PosMemory = {}
	return tpos
end

function tposSavePosition(tpos, Index)
	assert(Index ~= nil, "tpos.error: Index=nil on SavePosition")
	if tpos.PosMemory[Index] ~= nil then
		tpos.PosMemory[Index] = nil
	end
	tpos.PosMemory[Index] = {z=tpos.z, x=tpos.x, y=tpos.y}
	return
end

function tposRecallPosition(tpos, Idx)
--	assert(tpos.PosMemory[Index] ~= nil,
--		"tpos.error - You Indexed an invalid PosMemory location: "..Idx)
	return tpos.PosMemory[Idx]
end

function tposSetPlaceSlot(tpos, slot)
	tpos.placeSlot = slot
	turtle.select(slot)
	tposFindNextPlaceSlot(tpos)
end

function tposFindNextPlaceSlot(tpos)
	for slot=3, __turtleMaxSlot do
 		if slot ~= tpos.placeSlot and turtle.compareTo(slot) then 
			tpos.placeSlotNext = slot
			return true 
		end
	end
	tpos.placeSlotNext = 0
	return false
end

function tposSetNextPlaceSlot(tpos)
	if tpos.placeSlotNext == 0 then
		return false
	end
	tposSetPlaceSlot(tpos, tpos.placeSlotNext)
end

function tposPlaceModeEnable(tpos)
	tpos.placeMode = true
end

function tposPlaceModeDisable(tpos)
	tpos.placeMode = false
end

function tposBreakOnMoveDisable(tpos)
	tpos.canBreakOnMove = false
end

function tposBreakOnMoveEnable(tpos)
	tpos.canBreakOnMove = true
end
	
function tposShow(tpos)
	print("tpos: z=",tpos.z, " x=", tpos.x, " y=", tpos.y, " dir=", tpos.dir)
end

function tposPrint(tpos, str)
	if tpos.debugPrint then 
		print(str)
	end
end

function tposIncZX_get(tpos)
	if tpos.dir == 1 then
		return 1,0
	elseif tpos.dir == 2 then
		return 0,1
	elseif tpos.dir == 3 then
		return -1, 0
	else -- 3
		return 0, -1
	end
end

function tposDecZX_get(tpos)
	if tpos.dir == 1 then
		return -1,0
	elseif tpos.dir == 2 then
		return 0,-1
	elseif tpos.dir == 3 then
		return 1, 0
	else -- 3
		return 0, 1
	end
end

function tposIncZX(tpos)
	z,x = tposIncZX_get(tpos)
	tpos.z = tpos.z + z
	tpos.x = tpos.x + x
end

function tposDecZX(tpos)
	z,x = tposIncZX_get(tpos)
	tpos.z = tpos.z - z
	tpos.x = tpos.x - x
end


function _tposMoveFwd(tpos)
	if turtle.forward() then
		tposIncZX(tpos)
		return true
	else
		tposPrint(tpos,"forward() failed!")
		return false
	end
end

function _tposMoveBack(tpos)
	if turtle.back() then
		tposDecZX(tpos)
		return true
	else
	--	tposPrint(tpos,"back() failed!")
		return false
	end
end

function tposRotateDirLeft(tpos)
	if tpos.dir == 1 then
		tpos.dir = 4
	else
		tpos.dir = tpos.dir - 1
	end
end

function tposRotateDirRight(tpos)
	if tpos.dir == 4 then
		tpos.dir = 1
	else
		tpos.dir = tpos.dir + 1
	end
end

function tposTurnLeft(tpos)
	if turtle.turnLeft() then
		tposRotateDirLeft(tpos)
		return true
	else
		tposPrint(tpos,"turnLeft() failed")
		return false
	end
end

function tposMoveTurnAround(tpos)
	if tposTurnLeft(tpos) == false then return false end
	if tposTurnLeft(tpos) == false then return false end 
	return true
end

function tposTurnRight(tpos)
	if turtle.turnRight() then
		tposRotateDirRight(tpos)
		return true
	else
		tposPrint(tpos,"turnRight() failed")
		return false
	end
end

function _tposMoveUp(tpos)
	if turtle.up() then
		tpos.y = tpos.y + 1
		return true
	else
		tposPrint(tpos,"up() failed")
		return false
	end
end

function _tposMoveDown(tpos)
	if turtle.down() then
		tpos.y = tpos.y - 1
		return true
	else
		tposPrint(tpos,"down() failed")
		return false
	end
end

function tposMoveFwd(tpos,count)
	if tpos.placeMode == false then
		for i=1, count do
			if turtle.detect() == false then
				if _tposMoveFwd(tpos) == false then return false end
			elseif tpos.canBreakOnMove and tposDig() then
				if _tposMoveFwd(tpos)  == false then return false end
			else
				print("Blocked!")
				return false
			end
		end
	else
		-- Place Mode
		print("cant move forward in placeMode")
		return false
	end		
	return true
end

function tposPlace(tpos)
	if turtle.place() == false then
	 	tposSetNextPlaceSlot(tpos)
		if turtle.place() == false then
			tposPrint("place() failed")
			return false 
		end
		return true
	end
	return true
end

function tposDig(tpos)
	if turtle.dig() == false then
		tposPrint("dig() failed")
		return false 
	end
	return true
end
		
function tposDigUp(tpos)
	if turtle.digUp() == false then
		tposPrint("digUp() failed")
		return false 
	end
	return true
end
		
function tposDigDown(tpos)
	if turtle.digDown() == false then
		tposPrint("dig() failed")
		return false 
	end
	return true
end
		
function tposMoveBack(tpos,count)
	for i=1, count do
		if tpos.placeMode == false then
			if turtle.detect() == false then
				_tposMoveBack(tpos)
			elseif tpos.canBreakOnMove then
				if tposDig() == false then return false end
				tposMoveTurnAround(tpos)
				if _tposMoveBack(tpos) == false then return false end
			else
				print("Blocked!")
				return false
			end
		else
			-- Place Mode
			if _tposMoveBack(tpos) == false then
				tposMoveTurnAround(tpos)
				if tposDig() == false then return false end
				tposMoveTurnAround(tpos)
				if _tposMoveBack(tpos) == false then return false end
			end
			if tposPlace(tpos) == false then return false end
		end
	end
	return true
end

function tposMoveUp(tpos,count)
	for i=1, count do
		if tpos.placeMode == false then
			if turtle.detectUp() == false then
				_tposMoveUp(tpos)
			elseif tpos.canBreakOnMove and turtle.digUp() then
				_tposMoveUp(tpos)
			else			
				print("Blocked!")
				return false
			end
		else
			-- Place Mode
			if _tposMoveUp(tpos) == false then
				if turtle.digUp() == false then return false end
				if _tposMoveUp(tpos) == false then return false end
			end
			if turtle.placeDown() == false then return false end
		end
	end
	return true
end

function tposMoveDown(tpos, count)
	for i=1, count do
		if tpos.placeMode == false then
			if turtle.detectDown() == false then
				_tposMoveDown(tpos)
			elseif tpos.canBreakOnMove and turtle.digDown() then
				_tposMoveDown(tpos)
			else			
				print("Blocked-", tpos.canBreakOnMove)
				return false
			end
		else
			-- Place Mode
			if _tposMoveDown(tpos) == false then
				if turtle.digDown() == false then return false end
				if _tposMoveDown(tpos) == false then return false end
			end
			if turtle.placeUp() == false then return false end
		end
	end
	return true
end

function tposDirSubtract(a,b)
	local rval = a - b
	if rval < 0 then
		rval = rval + 4
	end
	return rval
end

function tposSetDir(tpos, dir)
	local newdir = tposDirSubtract(dir, tpos.dir)
	for count = 1, newdir do
		tposTurnRight(tpos,newdir)
	end
end

function ___tposMoveSlideLeft(tpos, count)
	if count > 0 then
		if tposTurnLeft(tpos) == false then return false end
		if tposMoveFwdw == false then return false end
		if tposTurnRight(tpos) == false then return false end
	end
	return true
end

function ___tposMoveSlideRight(tpos, count)
	if count > 0 then
		if tposTurnRight(tpos) == false then return false end
		if tposMoveFwd(tpos,count) == false then return false end
		if tposTurnLeft(tpos) == false then return false end
	end
	return true
end

--function tposGetDistance(tpos, z,x,y)
--	return = math.abs(tpos.z - z) + math.abs(tpos.x - x) + math.abs(tpos.y - y)
--end

function tposMoveZ(tpos, count)
	if count == 0 then return true end
	if tpos.placeMode == false then
		if count > 0 then
			tposSetDir(tpos,1)
		else
			tposSetDir(tpos,3)
		end
		return tposMoveFwd(tpos, math.abs(count))
	else
		if count > 0 then
			tposSetDir(tpos,3)
		else
			tposSetDir(tpos,1)
		end
		return tposMoveBack(tpos, math.abs(count))
	end
end

function tposMoveX(tpos, count)
	if count == 0 then return true end
	if tpos.placeMode == false then
		if count > 0 then
			tposSetDir(tpos, 2)
		else
			tposSetDir(tpos, 4)
		end
		return tposMoveFwd(tpos, math.abs(count))
	else
		if count > 0 then
			tposSetDir(tpos, 4)
		else
			tposSetDir(tpos, 2)
		end
		return tposMoveBack(tpos, math.abs(count))
	end	 
end
	
function tposMoveY(tpos, count)
	if count == 0 then return true end
	if count > 0 then
		return tposMoveUp(tpos, math.abs(count))
	else
		return tposMoveDown(tpos, math.abs(count))
	end
end

function tposCheckPosZ(tpos, ExpectedZ)
	if tpos.z == ExpectedZ then
		return true
	else
		return false
	end
end

function tposCheckPosX(tpos, ExpectedX)
	if tpos.x == ExpectedX then
		return true
	else
		return false
	end
end

function tposCheckPosY(tpos, ExpectedY)
	if tpos.y == ExpectedY then
		return true
	else
		return false
	end
end

function tposPerformMovement(tpos, MoveF, CheckF, str, curpos, nextpos)
	MoveF(tpos, nextpos-curpos)
	if CheckF(tpos, nextpos) == false then
		tposShow(tpos)
		print("nextpos=",nextpos, " curpos=", curpos)
		print("Move", str, " failed: check fuel, inventory, clear obstacles")
		print("press [enter] to continue")
		read()
		return false
	else
		return true
	end		
end

function tposMoveAbs(tpos,z,x,y)
	while tposPerformMovement(tpos, tposMoveZ, tposCheckPosZ, "Z", tpos.z, z) == false do end
	while tposPerformMovement(tpos, tposMoveX, tposCheckPosX, "X", tpos.x, x) == false do end
	while tposPerformMovement(tpos, tposMoveY, tposCheckPosY, "Y", tpos.y, y) == false do end
	return true
end

function tposRecallMoveAbs(tpos, MemIdx)
	pos = tposRecallPosition(tpos, MemIdx)
	tposMoveAbs(tpos,pos.z,pos.x,pos.y)
end

function tposRecallMoveRel(tpos, MemIdx, z,x,y)
	lpos = tposRecallPosition(tpos, MemIdx)
	tposMoveAbs(tpos,lpos.z+z,lpos.x+x,lpos.y+y)
end

function tposMoveRel(tpos,z,x,y)
	local nextz = tpos.z+z
	local nextx = tpos.x+x
	local nexty = tpos.y+y
	while tposPerformMovement(tpos, tposMoveZ, tposCheckPosZ, "Z", tpos.z, nextz) == false do end
	while tposPerformMovement(tpos, tposMoveX, tposCheckPosX, "X", tpos.x, nextx) == false do end
	while tposPerformMovement(tpos, tposMoveY, tposCheckPosY, "Y", tpos.y, nexty) == false do end
	return true
end

function Q_tposMoveAbs(params)
	tposMoveAbs(params[1],params[2],params[3],params[4])
end

function Q_tposMoveRel(params)
	tposMoveRel(params[1],params[2],params[3],params[4])
end

function Q_tposPlaceModeEnable(params)
	tposPlaceModeEnable(params[1])
end

function Q_tposPlaceModeDisable(params)
	tposPlaceModeDisable(params[1])
end

function Q_tposBreakOnMoveEnable(params)
	tposBreakOnMoveEnable(params[1])
end

function Q_tposBreakOnMoveDisable(params)
	tposBreakOnMoveDisable(params[1])
end

function Q_tposSavePosition(params)
	return tposSavePosition(params[1],params[2])
end

function Q_tposRecallMoveAbs(params)
	return tposRecallMoveAbs(params[1], params[2])
end

function Q_tposRecallMoveRel(params)
	return tposRecallMoveRel(params[1], params[2], params[3], params[4], params[5])
end

function Refuel(slot,count)
	print("Refueling...to travel: ", count, " blocks")
    print("  using slot: ", slot)
    turtle.select(1)
	local fuelLevel = turtle.getFuelLevel()
	while fuelLevel < count do
		if turtle.refuel(1) == false then
			print("Insufficuent fuel onboard!")
			return false
		end
		fuelLevel = fuelLevel + turtle.getFuelLevel()
	end
	print("Fuel - OK!")
	return true
end

-- Argh this has to be in Global space for api?
jobQueue = {}

function jobQueue.new()
	return {first = 0, last = -1}
end

function jobQueue.pushleft (list, value)
    local first = list.first - 1
    list.first = first
	list[first] = value
end
    
function jobQueue.pushright (list, value)
    local last = list.last + 1
    list.last = last
	list[last] = value
end
    
function jobQueue.popleft (list)
    local first = list.first
    if first > list.last then return nil end
    local value = list[first]
    list[first] = nil        -- to allow garbage collection
    list.first = first + 1
	return value
end
    
function jobQueue.popright (list)
    local last = list.last
    if list.first > last then return nil end
    local value = list[last]
    list[last] = nil         -- to allow garbage collection
    list.last = last - 1
	return value
end

function jobQueue.run (list)
	while true do
		job = jobQueue.popleft(list)
		if job == nil then
			return true
		end
		assert(type(job[1]) == "function",
			"tpos.error - no Q_fcn: "..job[1])
		
		if job[1](job[2]) == false then
			return false
		end
	end
end

		
		

