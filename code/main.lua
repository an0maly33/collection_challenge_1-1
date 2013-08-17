---[ **** hide status bar ****
display.setStatusBar( display.HiddenStatusBar )

---[ **** use timer as seed for random generator
math.randomseed(os.time())
local dummy = math.random(0,255)

---[ **** setup common screen variables
local screenWidth = display.viewableContentWidth
local screenHeight = display.viewableContentHeight
local screenCenterX = screenWidth * 0.5
local screenCenterY = screenHeight * 0.5

---[ sscale the background according to screen dimensions (largest difference between image and screen sizes determines the multiplier)
local bgScale = 1
tempyScale = screenHeight / 128
tempxScale = screenWidth / 256
if (tempxScale < tempyScale) then
	bgScale = tempyScale
else
	bgScale = tempxScale
end

---[ setup background
local bg = display.newImage("bg.png")
bg.xScale = bgScale
bg.yScale = bgScale
bg:setReferencePoint(display.CenterReferencePoint)
bg.x = screenCenterX
bg.y = screenCenterY
bg:toBack()

---[ **** setup image objects
local characterGroup = display.newGroup()

local collectorGuy = {}
collectorGuy.torso = display.newImage("character_torso.png")
collectorGuy.torso:setReferencePoint(display.TopCenterReferencePoint)
collectorGuy.torso.x = screenCenterX
collectorGuy.torso.y = screenCenterY
characterGroup:insert(collectorGuy.torso)

collectorGuy.head = display.newImage("character_head.png")
collectorGuy.head:setReferencePoint(display.BottomCenterReferencePoint)
collectorGuy.head.x = collectorGuy.torso.x
collectorGuy.head.y = collectorGuy.torso.y
characterGroup:insert(collectorGuy.head)

collectorGuy.legs = display.newImage("character_legs.png")
collectorGuy.legs:setReferencePoint(display.TopCenterReferencePoint)
collectorGuy.legs.x = collectorGuy.torso.x
collectorGuy.legs.y = collectorGuy.torso.y + 64
collectorGuy.legs.xScale = 1.5
collectorGuy.legs.yScale = 1.5
characterGroup:insert(collectorGuy.legs)

characterGroup:setReferencePoint(display.CenterReferencePoint)
characterGroup.x = screenCenterX
characterGroup.y = screenCenterY + 64

local basket = {}
basket.filename = "basket.png"
basket = display.newImage(basket.filename)
basket:setReferencePoint(display.TopCenterReferencePoint)
basket.x = characterGroup.x
basket.y = collectorGuy.torso.y + 32
basket.facingLeft = true

local faller = {}
faller.spawnInterval = 300
faller.spawnMinInterval = 1000
faller.spawnMaxInterval = 3000
faller.lastSpawn = 0

local fallerList = {}
local score = display.newText("0", screenWidth - 30, 20, "Arial", 32)

txtDebug = display.newText("", screenCenterX, 0, "Arial", 14)

local xInstant = 0
local xGrav = 0

local function tilted(event)
	---[ Landscape, so we need to make sure we use the "wrong" axis (hence x = y) and invert the value
	xInstant = 0 - (event.yInstant)
	xGrav = 0 - (event.yGravity * 6)
end

local function touched(event)

end

local function frameupdate(event)
	collectorGuy.legs.xScale = 0 - collectorGuy.legs.xScale

	txtDebug.text = xGrav
	
	---[ move character
	characterGroup.x = characterGroup.x + xGrav * 3
	if characterGroup.x < (characterGroup.contentWidth / 2) then
		characterGroup.x = (characterGroup.contentWidth / 2)
	elseif characterGroup.x > screenWidth - (characterGroup.contentWidth / 2) then
		characterGroup.x = screenWidth - (characterGroup.contentWidth / 2)
	end

	---[ sway basket
	basket.swayOffset = xInstant * 100
	basket.x = characterGroup.x + basket.swayOffset

	---[ sway head
	collectorGuy.head.rotation = 0 - xInstant * 100
	
	local newFaller
	---[ Check to see if it's time to spawn a new falling object
	if(system.getTimer() >= faller.lastSpawn + faller.spawnInterval) then
		faller.lastSpawn = system.getTimer()
		faller.spawnInterval = math.random(faller.spawnMinInterval, faller.spawnMaxInterval)
		print("spawn! next spawn in " .. faller.spawnInterval .. "ms")
		newFaller = #fallerList + 1
		print("spawning in slot[" .. newFaller .. "]")
		fallerList[newFaller] = display.newImage("apple.png")
		fallerList[newFaller]:setReferencePoint(display.BottomCenterReferencePoint)
		fallerList[newFaller].x = math.random(fallerList[newFaller].contentWidth, screenWidth - fallerList[newFaller].contentWidth)
		fallerList[newFaller].y = 10
		fallerList[newFaller].facingLeft = true
		fallerList[newFaller].spawnInterval = 300
		fallerList[newFaller].spawnMinInterval = 1000
		fallerList[newFaller].spawnMaxInterval = 3000
		fallerList[newFaller].lastSpawn = 0
		fallerList[newFaller].active = 1
		fallerList[newFaller].velocity = 4
	end
	
	---[ iterate the object array and...
	for i = 1, #fallerList do
		if (fallerList[i] ~= nil) then
			---[ update y-pos
			fallerList[i].y = fallerList[i].y + fallerList[i].velocity
			
			---[ remove the object from the array when it hits the bottom of the screen
			if fallerList[i].y > screenHeight then
				fallerList[i].alpha = 0
				table.remove(fallerList, i)
			end
			
			---[ check for basket collision
			if fallerList[i] ~= nil and fallerList[i].y > basket.y + 2 and fallerList[i].y < basket.y + 25 then
				if fallerList[i].x > basket.x - (basket.contentWidth / 2) and fallerList[i].x < basket.x + (basket.contentWidth / 2)then
					fallerList[i].alpha = 0
					table.remove(fallerList, i)
					score.text = score.text + 1
				end
			end
		end
	end
end

---[ **** event listeners
Runtime:addEventListener( "touch", touched )
Runtime:addEventListener( "accelerometer", tilted )
Runtime:addEventListener( "enterFrame", frameupdate )