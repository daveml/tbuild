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

	Refuel(zm)

    turtle.select(2)
--	buildLine(zm)

	jQ = jobQueue.new()
	job = {Q_tposMoveAbs, {tpos, zm, xm, ym}}
	jobQueue.pushright(jQ, job)
	jobQueue.run(jQ)

end

main(zm,ym,xm)