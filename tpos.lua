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
	tpos = {}
	tpos.z=0
	tpos.y=0
	tpos.x=0
	tpos.dir=1
	tpos.canBreakOnMove=true
	tpos.debugPrint=true
	return tpos
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
		tposPrint(tpos,"back() failed!")
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
	for i=1, count do
		if turtle.detect() == false then
			_tposMoveFwd(tpos)
		elseif tpos.canBreakOnMove and turtle.dig() then
			_tposMoveFwd(tpos)
		else
			print("Blocked!")
			return false
		end
	end
	return true
end

function tposMoveBack(tpos,count)
	for i=1, count do
		if turtle.detect() == false then
			_tposMoveBack(tpos)
		elseif tpos.canBreakOnMove and turtle.dig() then
			tposMoveTurnAround(tpos)
			tposMoveTurnAround(tpos)
			_tposMoveBack(tpos)
		else
			print("Blocked!")
			return false
		end
	end
	return true
end

function tposMoveUp(tpos,count)
	for i=1, count do
		if turtle.detectUp() == false then
			_tposMoveUp(tpos)
		elseif tpos.canBreakOnMove and turtle.digUp() then
			_tposMoveUp(tpos)
		else			
			print("Blocked!")
			return false
		end
	end
	return true
end

function tposMoveDown(tpos, count)
	for i=1, count do
		if turtle.detectDown() == false then
			_tposMoveDown(tpos)
		elseif tpos.canBreakOnMove and turtle.digDown() then
			_tposMoveDown(tpos)
		else			
			print("Blocked-", tpos.canBreakOnMove)
			return false
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

function tposMoveSlideLeft(tpos, count)
	if count > 0 then
		if tposTurnLeft(tpos) == false then return false end
		if tposMoveFwd(tpos,count) == false then return false end
		if tposTurnRight(tpos) == false then return false end
	end
	return true
end

function tposMoveSlideRight(tpos, count)
	if count > 0 then
		if tposTurnRight(tpos) == false then return false end
		if tposMoveFwd(tpos,count) == false then return false end
		if tposTurnLeft(tpos) == false then return false end
	end
	return true
end

function tposMoveZ(tpos, count)
	if count > 0 then
		return tposMoveFwd(tpos, count)
	else
		return tposMoveBack(tpos, -count)
	end
end

function tposMoveX(tpos, count)
	if count > 0 then
		return tposMoveSlideRight(tpos, count)
	else
		return tposMoveSlideLeft(tpos, -count)
 	end
end
	
function tposMoveY(tpos, count)
	if count > 0 then
		return tposMoveUp(tpos, count)
	else
		return tposMoveDown(tpos, -count)
	end
end

function tposMoveAbs(tpos,z,x,y)
	if tposMoveZ(tpos, z - tpos.z) == false then return false end
	if tposMoveX(tpos, x - tpos.x) == false then return false end
	if tposMoveY(tpos, y - tpos.y) == false then return false end
	return true
end

function tposMoveRel(tpos,z,x,y)
	if tposMoveZ(tpos, z) == false then return false end
	if tposMoveX(tpos, x) == false then return false end
	if tposMoveY(tpos, y) == false then return false end
	return true
end


function Q_tposMoveAbs(params)
	tposMoveAbs(params[1],params[2],params[3],params[4])
end

function Q_tposMoveRel(params)
	tposMoveRel(parans[1],params[2],params[3],params[4])
end

function Refuel(count)
	print("Refueling...")
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
		if job[1](job[2]) == false then
			return false
		end
	end
end

		
		

