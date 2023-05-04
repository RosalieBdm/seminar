
local composer = require( "composer" )

local scene = composer.newScene()
-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Initialize variables
local lives = 3
local dinoState = "walking"
local score = 0
local scoreTimer
local scoreText

local asteroidsTable = {}
local gameLoopTimer
local platform
local dino
local leftButton
local rightButton
local jumpButton
local lowerBound
local hearts
local restartButton
local menuButton
local highScoresButton

local physics = require( "physics" )
physics.start()
physics.setGravity(0, 50)

--local test = display.newImageRect(frontGroup,"images/dino_sprite_resize.png",500,500 )
--test.x = display.contentCenterX
--test.y = display.contentCenterY

local sheetOptionsDinoWalk = {
    frames =
    {
        {   -- 1) walk 1
            x = 0,
            y = 332,
            width = 252,
            height = 180
        },
        {   -- 2) walk 2
            x = 256,
            y = 336,
            width = 252,
            height = 176
        },
        {   -- 3) walk 3
            x = 512,
            y = 328,
            width = 252,
            height = 184
        }, 
        {   -- 4) wlak 4
            x = 768,
            y = 324,
            width = 252,
            height = 188
        },
        {   -- 5) walk 5
            x = 1024,
            y = 328,
            width = 252,
            height = 184
        },
        {   -- 6) repos
            x = 0,
            y = 56,
            width = 196,
            height = 192
        },
        {   -- 7) mort1
            x = 256,
            y = 0,
            width = 216,
            height = 248
        },
        {   -- 8) mort2
            x = 512,
            y = 168,
            width = 248,
            height = 188
        },
        {   -- 9) saut
            x = 768,
            y = 60,
            width = 204,
            height = 188
        },
    }



    --[[{
        {   -- 1) walk 1
            x = 0,
            y = 2656,
            width = 2016,
            height = 1440
        },
        {   -- 2) walk 2
            x = 2048,
            y = 2688,
            width = 2016,
            height = 1408
        },
        {   -- 3) walk 3
            x = 4096,
            y = 2624,
            width = 2016,
            height = 1472
        }, 
        {   -- 4) wlak 4
            x = 6144,
            y = 2592,
            width = 2016,
            height = 1504
        },
        {   -- 5) walk 5
            x = 8192,
            y = 2624,
            width = 2016,
            height = 1472
        },
        {   -- 6) repos
            x = 0,
            y = 448,
            width = 1568,
            height = 1536
        },
        {   -- 7) mort1
            x = 2048,
            y = 0,
            width = 1728,
            height = 1984
        },
        {   -- 8) mort2
            x = 4096,
            y = 1344,
            width = 1984,
            height = 640
        },
        {   -- 9) saut
            x = 6144,
            y = 480,
            width = 1632,
            height = 1504
        },
    }
    ]]
    --width = 2048,
    --height = 2048,
    --numFrames = 9,
    --sheetContentWidth = 18432,
    --sheetContentHeight = 2048
}

sheetOptionsDinoWalk.frames[8].y = 66
local sheetDinoWalk = graphics.newImageSheet("images/dino_sprite_resize.png", sheetOptionsDinoWalk)

local sequenceData = {

    {
        name = "walk",
        start = 1,
        count = 5,
        time = 500,
        loopCount = 0,
        loopDirection = "forward"
    },
    {
        name = "stay",
        start = 6,
        count = 1,
        time = 500,
        loopCount = 0,
        loopDirection = "forward"
    },
    {
        name = "jump",
        start = 9,
        count = 1,
        time = 500,
        loopCount = 0,
        loopDirection = "forward"
    },
    {
        name = "damage",
        start = 7,
        count = 1,
        time = 500,
        loopCount = 0,
        loopDirection = "forward"
    },
    {
        name = "dead",
        start = 8,
        count = 1,
        time = 500,
        loopCount = 0,
        loopDirection = "forward"
    }


}

--local tapText = display.newText(dino.x .. "," .. dino.y, display.contentCenterX, 20, native.systemFont, 40 )
--tapText:setFillColor( 0, 0, 0 )

-- move the platform to the left
local function movePlatform(event)
    --tapText.text = dino.x .. "," .. dino.y
    for i = 1, #platform do
        platform[i].x = platform[i].x - 5  -- adjust the speed by changing the value here
        
        if platform[i].x < -400 then
            -- move the platform to the right of the screen
            platform[i].x = 1900
        end

    end
    -- check if the platform has moved completely off the screen
    
end

-- create the asteroids 
local function createAsteroid()
    --tapText.text = "create"
	local newAsteroid = display.newImageRect( asteroidGroup, "images/asteroide.png",100, 100 )
	
    
	physics.addBody( newAsteroid, "kinematic", { density = 1.0, friction = 0.3, bounce = 0, gravityScale = 0 } )
    newAsteroid.isSensor = true

	newAsteroid.myName = "asteroid"

	local whereFrom = math.random( 30 )

    --tapText.text = "create" .. whereFrom
    newAsteroid.x = 300 + (display.contentWidth/30 * whereFrom) 
	newAsteroid.y = 0
    local speed = math.random( 50, 100 )
	newAsteroid:setLinearVelocity( -speed,  speed )
	table.insert( asteroidsTable, newAsteroid )


end

-- create a function to move the object left
local function moveLeft()
    dino.x = dino.x - 10
end

local function leftButtonHandler(event) 
    if event.phase == "began" then
        Runtime:addEventListener("enterFrame", moveLeft)
    elseif event.phase == "moved" then
        if not (event.x >= leftButton.x and event.x <= leftButton.x + leftButton.contentWidth and event.y >= leftButton.y -  leftButton.contentHeight and event.y <= leftButton.y) then
            Runtime:removeEventListener("enterFrame", moveLeft)
        end
    elseif event.phase == "ended" then
        Runtime:removeEventListener("enterFrame", moveLeft)
        
    end
    
end 




-- create a function to move the object right
local function moveRight()
    dino.x = dino.x + 10
end

local function rightButtonHandler(event) 
    if event.phase == "began" then
        Runtime:addEventListener("enterFrame", moveRight)
    elseif event.phase == "moved" then
        if not (event.x >= rightButton.x and event.x <= rightButton.x + rightButton.contentWidth and event.y >= rightButton.y -  rightButton.contentHeight and event.y <= rightButton.y) then
            Runtime:removeEventListener("enterFrame", moveRight)
            
        end
    elseif event.phase == "ended" then
        Runtime:removeEventListener("enterFrame", moveRight)
    
    end
end

-- stop moving 
local function stopMoving()
    dino:setLinearVelocity(0, 0)
end

-- create a function to make the object jump
local function jump(event)
    dino:setLinearVelocity(0, -800)
end

local function jumpButtonHandler(event) 
    if (dinoState == "walking") then       
        dinoState = "jumping"
        dino:setSequence("jump") -- switch to "jump" animation sequence
        dino:play() -- start playing the animation
        jump()
    end
end



local function endGame()
    dino:setSequence("dead") -- switch to "walk" animation sequence
    dino:play() -- start playing the animation
    Runtime:removeEventListener( "collision", onCollision )
    Runtime:removeEventListener("enterFrame", movePlatform)
    rightButton:removeEventListener("touch", rightButtonHandler)
    leftButton:removeEventListener("touch", leftButtonHandler)
    jumpButton:removeEventListener("tap", jumpButtonHandler)
    Runtime:removeEventListener("enterFrame", moveRight)
    Runtime:removeEventListener("enterFrame", moveLeft)
    highScoresButton.alpha = 1
    highScoresButton:addEventListener("tap", function(event)
        composer.gotoScene( "highscores" )
    end
    )
    restartButton.alpha = 1
    restartButton:addEventListener("tap", function(event)
        composer.gotoScene( "game" )
    end
    )
    composer.setVariable( "finalScore", score )
    timer.cancel( scoreTimer )
end


local function onCollision( event )

	if ( event.phase == "began" ) then
        
		local obj1 = event.object1
		local obj2 = event.object2
        --tapText.text = obj1.myName .. "," .. obj2.myName

		if ( ( obj1.myName == "dino" and obj2.myName == "lowerbound" ) or
			 ( obj1.myName == "lowerbound" and obj2.myName == "dino" ) )
		    then
            if (dinoState == "dead") then 
                endGame()
            else 
                dinoState = "walking"
                dino:setSequence("walk") -- switch to "walk" animation sequence
                dino:play() -- start playing the animation
            end
        elseif 
        ( ( obj1.myName == "dino" and obj2.myName == "asteroid" ) or
            ( obj1.myName == "asteroid" and obj2.myName == "dino" ))
        then
            if ((dinoState ==  "damage")or (dinoState =="dead")) then 
            else 
                if (obj1.myName == "asteroid") then  
                    display.remove(obj1)
                else 
                    display.remove(obj2)
                end 

                dinoState = "damage"
                for i = #asteroidsTable, 1, -1 do
                    if ( asteroidsTable[i] == obj1 or asteroidsTable[i] == obj2 ) then
                        table.remove( asteroidsTable, i )
                        break
                    end
                end
                
                hearts[lives].alpha = 0
                lives = lives-1

                if (lives == 0) then 
                    dinoState = "dead"
                    timer.cancel( gameLoopTimer )
                    dino:setSequence("damage") -- switch to "walk" animation sequence
                    dino:play() -- start playing the animation
                    jump()
        
                else
                    dino:setSequence("damage") -- switch to "walk" animation sequence
                    dino:play() -- start playing the animation
                    jump()
                end
            end 
		end
	end
end

local function gameLoop()

    if (lives > 0) then  
            -- Create new asteroid
        createAsteroid()

        -- Remove asteroids which have drifted off screen
        for i = #asteroidsTable, 1, -1 do
            local thisAsteroid = asteroidsTable[i]

            if ( thisAsteroid.y > display.contentHeight + 100 )
            then
                display.remove( thisAsteroid )
                table.remove( asteroidsTable, i )
            end
        end
    else 
        for i = 1 , #asteroidsTable  do
            table.remove( asteroidsTable, i )
        end
        -- add a runtime listener to move the platform
        Runtime:removeEventListener("enterFrame", movePlatform)

    end 
	
end

local function scoreLoop()
    score = score +1
    scoreText.text = score
end

local function gotoMenu()
    composer.gotoScene( "menu" )
end


-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------


function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen

	physics.pause()  -- Temporarily pause the physics engine

	-- Set up display groups
	backGroup = display.newGroup()  -- Display group for the background image
	sceneGroup:insert( backGroup )  -- Insert into the scene's view group

    asteroidGroup = display.newGroup()    -- Display group for asteroids and dino
	sceneGroup:insert( asteroidGroup )    -- Insert into the scene's view group

	mainGroup = display.newGroup()  -- Display group for the platform,etc.
	sceneGroup:insert( mainGroup )  -- Insert into the scene's view group

	uiGroup = display.newGroup()    -- Display group for UI objects like the hearts and the 
	sceneGroup:insert( uiGroup )    -- Insert into the scene's view group

	-- Load the background
    local background = display.newImageRect(backGroup, "images/background.png", display.contentWidth,display.contentHeight)
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    --create the dino
	dino = display.newSprite(asteroidGroup, sheetDinoWalk, sequenceData)
    dino.xScale = 150/dino.contentWidth
    dino.yScale = 150/dino.contentHeight
    dino.x = display.contentCenterX
    dino.y = display.contentHeight - 350
    physics.addBody( dino, "dynamic", {radius=0, bounce=0 } )
    dino.myName = "dino"
    
    -- Display lives
    local heart1 = display.newImageRect(uiGroup,"images/coeur.png", 50, 80)
    heart1.x = 50
    local heart2 = display.newImageRect(uiGroup,"images/coeur.png", 50, 80)
    heart2.x = heart1.x + 60
    local heart3 = display.newImageRect(uiGroup,"images/coeur.png", 50, 80)
    heart3.x = heart2.x + 60
    hearts = {heart1,heart2,heart3}
    for i = 1, #hearts do
        hearts[i].y = 70
    end

    --Display score
    scoreText = display.newText( uiGroup, "0", display.contentCenterX, 50, native.newFont( "font/pixel.ttf", 44 ) )

    -- display platform
    local image1 = display.newImageRect(mainGroup,"images/sol1.png", 400, 200)
    image1.x = 0
    local image2 = display.newImageRect(mainGroup,"images/sol2.png", 400, 200)
    image2.x = image1.contentWidth 
    local image3 = display.newImageRect(mainGroup,"images/sol3.png", 400, 200)
    image3.x = image2.x + image2.contentWidth
    local image4 = display.newImageRect(mainGroup,"images/sol4.png", 400, 200)
    image4.x = image3.x +image3.contentWidth 
    local image5 = display.newImageRect(mainGroup,"images/sol2.png", 400, 200)
    image5.x = image4.x +image4.contentWidth 
    local image6 = display.newImageRect(mainGroup,"images/sol3.png", 400, 200)
    image6.x = image5.x + image5.contentWidth 
    platform = {image1,image2,image3,image4,image5,image6}
    for i = 1, #platform do
        platform[i].y = display.contentHeight - 50 
    end
    -- add a runtime listener to move the platform
    Runtime:addEventListener("enterFrame", movePlatform)

    --add the bounds
    lowerBound = display.newRect(backGroup, display.contentCenterX, display.contentHeight - 210, display.contentWidth*2 , 0)
    local lowerBoundBody = { bounce = 0 }
    physics.addBody( lowerBound, "static", lowerBoundBody )
    lowerBound.myName = "lowerbound"

    local leftBound = display.newRect(backGroup, - 20, display.contentCenterY, 200 , display.contentHeight)
    physics.addBody( leftBound, "static" )
    leftBound.alpha = 0
    leftBound.myName = "leftBound"

    local rightBound = display.newRect(backGroup, display.contentWidth, display.contentCenterY, 200 , display.contentHeight)
    physics.addBody( rightBound, "static" )
    rightBound.alpha = 0
    rightBound.myName = "rightBound"

    local topBound = display.newRect(backGroup, display.contentCenterX, 0 , display.contentWidth, 1)
    physics.addBody( topBound, "static" )
    topBound.myName = "topBound"

    --add the buttons 
    leftButton = display.newImageRect(uiGroup,"images/left_arrow.png", 60, 70)
    leftButton.x = 100
    leftButton.y = display.contentHeight - 50
    leftButton.alpha = 0.8

    rightButton = display.newImageRect(uiGroup,"images/right_arrow.png", 60, 70)
    rightButton.x = leftButton.x + 100
    rightButton.y = leftButton.y
    rightButton.alpha = 0.8

    jumpButton = display.newImageRect(uiGroup,"images/jump.png", 144, 100)
    jumpButton.x = display.contentWidth - 100
    jumpButton.y = display.contentHeight - 60
    jumpButton.alpha = 0.8

    --add the hidden buttons 
    restartButton = display.newText( uiGroup, "Restart", display.contentCenterX, 300, native.newFont( "font/pixel.ttf", 44 ) )
    restartButton.alpha = 0
    highScoresButton = display.newText( uiGroup, "Highscores", display.contentCenterX, 400, native.newFont( "font/pixel.ttf", 44 ) )
    highScoresButton.alpha = 0

    --add the menu button
    menuButton = display.newText( uiGroup, "Menu", 920, 65, native.newFont( "font/pixel.ttf", 36 ) )
    menuButton:setFillColor(1)
    menuButton:addEventListener( "tap", gotoMenu )

    --reset variables:
    dinoState = "walking"
    lives = 3
    score = 0
    asteroidsTable = {}


end

-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen
		physics.start()
        Runtime:addEventListener( "collision", onCollision )

        -- start animation
        dino:setSequence("walk")
        dino:play()

        -- add touch event listeners to the buttons
        leftButton:addEventListener("touch", leftButtonHandler)

        rightButton:addEventListener("touch", rightButtonHandler)


        jumpButton:addEventListener("tap", jumpButtonHandler)

        gameLoopTimer = timer.performWithDelay( 2000, gameLoop, 0 )
        scoreTimer = timer.performWithDelay( 100, scoreLoop, 0 )
    end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)
		timer.cancel( gameLoopTimer )
	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen
		Runtime:removeEventListener( "collision", onCollision )
        physics.pause()
		composer.removeScene( "game" )
	end
end


-- destroy()
function scene:destroy( event )
    Runtime:removeEventListener("enterFrame", movePlatform)
	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view

end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene




