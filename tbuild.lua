-- tbuild
--local tposLib = assert(loadfile('/rom/apis/tpos'))
local tposLib = assert(loadfile('/downloads/tbuild/tpos.lua'))
tposLib()

local args = {...}

local zm = tonumber(args[1])
local xm = tonumber(args[2])
local ym = tonumber(args[3])

function usage()
	print("--tbuild")
	print("usage: tbuild z y x")

end

function clearBlock()
	turtle.turnLeft()
	turtle.turnLeft()
	turtle.dig()
	turtle.turnLeft()
	turtle.turnLeft()
end

function buildYHollow(jQ, tpos, z, x, y)
	cz = tpos.z
	cx = tpos.x
	cy = tpos.y
	h=1
	if y < 0 then
		y = -y
		h=-1
	end
	for height=1, y do
		job = {Q_tposMoveRel, {tpos, z, x, 0}}
		jobQueue.pushright(jQ, job)
		job = {Q_tposMoveRel, {tpos, -z, -x, 0}}
		jobQueue.pushright(jQ, job)
		job = {Q_tposMoveRel, {tpos, 0, 0, h}}
		jobQueue.pushright(jQ, job)
	end
	return ((z+1)*(x+1)*(y))
end

function buildZFill(jQ, tpos, z, x, y)
	cz = tpos.z
	cx = tpos.x
	cy = tpos.y
	if y < 0 then
		y = -y
		local h=-1
	end
	local dir = 1
	for height=1, y do
		for width=1, x do
			job = {Q_tposMoveRel, {tpos, z*dir, 0, height-1}}
			jobQueue.pushright(jQ, job)
			job = {Q_tposMoveRel, {tpos, 0, 1, height-1}}
			jobQueue.pushright(jQ, job)
			if dir==1 then 
				dir = -1 
			else
				dir = 1
			end
		end
	end
	job = {Q_tposPlaceModeDisable, {tpos}}
	jobQueue.pushright(jQ, job)
	job = {Q_tposMoveRel, {tpos, 0, 0, 1}}
	jobQueue.pushright(jQ, job)
	job = {Q_tposMoveAbs, {tpos, cz, cx, cy+1}}
	jobQueue.pushright(jQ, job)
	job = {Q_tposPlaceModeEnable, {tpos}}
	jobQueue.pushright(jQ, job)
--	return ((z+1)*(x+1)*(y)+(x+1) + tposGetDistance(tpos,cz,cx,cy+1))
	return ((z+1)*(x+1)*(y)+(x+1)
end

function buildReturn(jQ, tpos, CanBreak)
	if CanBreak == false then
		jobQueue.pushright(jQ, {Q_tposBreanOnMoveDisable, {tpos}} )
	end
	jobQueue.pushright(jQ, {Q_tposMoveAbs, {tpos, 0, 0, 0}} )
	if CanBreak == false then
		jobQueue.pushright(jQ, {Q_tposBreanOnMoveEnable, {tpos}} )
	end
--	return tposGetDistance(tpos,0,0,0)
end

function buildBegin(jQ, tpos)
	jobQueue.pushright(jQ, {Q_tposBreanOnMoveEnable, {tpos}} )
	jobQueue.pushright(jQ, {Q_tposPlaceModeDisable, {tpos}} )
	jobQueue.pushright(jQ, {Q_tposMoveRel, {tpos, 1, 0, 0}} )
	jobQueue.pushright(jQ, {Q_tposPlaceModeEnable, {tpos}} )
	return 1
end

function main(zm,ym,xm)
	
	if zm == nil then
		usage()
		return
	end
	
	if ym == nil then
		ym = 0
	end
	if xm == nil then
		xm = 0
	end

    if myTpos == nil then
		myTpos = tposInit()
	end
	
	tposShow(myTpos)
	
 	tposSetPlaceSlot(myTpos,2)

	jQ = jobQueue.new()

	fuelReq1 = buildBegin(jQ, myTpos)
	fuelReq2 = buildZFill(jQ, myTpos, zm, xm, 1)
	fuelReq3 = buildYHollow(jQ, myTpos, zm, xm, ym)
	fuelReq4 = buildZFill(jQ, myTpos, zm, xm, 1)
	fuelReq5 = buldReturn(jQ, myTpos)

	if Refuel(1,fuelReq1+fuelReq2+fuelReq3+fuelReq4) == false then
		exit(0)
	end

	tposSetPlaceSlot(myTpos, 2)

	jobQueue.run(jQ)

end

main(zm,ym,xm)