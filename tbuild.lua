-- tbuild
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

function buildHollow(jQ, tpos, z, x, y)
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
		job = {Q_tposMoveRel, {tpos, z, x, h}}
		jobQueue.pushright(jQ, job)
	end
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

    if tpos == nil then
		tpos = tposInit()
	end
	
	tposShow(tpos)
	
	Refuel(1,math.abs(zm)+math.abs(ym)+math.abs(xm))
    turtle.select(2)

   	tpos.placeMode = true

	jQ = jobQueue.new()

	buildHollow(jQ, tpos, zm, xm, ym)

	jobQueue.run(jQ)

	tposShow(tpos)

end

main(zm,ym,xm)