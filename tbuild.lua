-- tbuild

local args = {...}

local zm = tonumber(args[1])
local xm = tonumber(args[2])
local ym = tonumber(args[3])

function usage()
	print("--tbuild")
	print("usage: tbuild z y x")

end

function movefwd(count)
	for i=1, count do
		if turtle.detect() == false then
			turtle.forward()
		else
			print("Blocked!")
			return false
		end
	end
	return true
end

function moveUp(count)
	for i=1, count do
		if turtle.detectUp() == false then
			turtle.up()
		else
			print("Blocked!")
			return false
		end
	end
	return true
end

function moveDown(count)
	for i=1, count do
		if turtle.detectDown() == false then
			turtle.down()
		else
			print("Blocked")
			return false
		end
	end
	return true
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

function clearBlock()
	turtle.turnLeft()
	turtle.turnLeft()
	turtle.dig()
	turtle.turnLeft()
	turtle.turnLeft()
end

function moveBack()
	if turtle.back() == false then
		clearBlock()
		if turtle.back() == false then
			return false
		end
	else
		return true
	end
end

function buildLine(count)
	for i=1, count do
		if moveBack() == true then
			turtle.place()
		else
			return false
		end
	end
	return true
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
	
	Refuel(zm)
		
	buildLine(zm)

end

main(zm,ym,xm)