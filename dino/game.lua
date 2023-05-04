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
local gamePhase = "asteroid"
local buttonPressed = false
--timers
local scoreTimer
local gameLoopTimer
local asteroidLoopTimer

local scoreText

local asteroidsTable = {}

local platform
local dino
local hearts
local pterodactyl
local egg
local flyState = "down"
local eggState = false 

--Buttons
local leftButton
local rightButton
local jumpButton
local restartButton
local pauseButton
local menuButton
local highScoresButton
local resumeButton

--bounds
local lowerBound



local physics = require( "physics" )
physics.start()
physics.setGravity(0, 50)

local sheetOptionsDino = {
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
}

local sheetOptionsPterodactyl = {
    frames =
    {
        {   -- 1) walk 1
            x = 0,
            y = 0,
            width = 1024,
            height = 1024
        },
        {   -- 2) walk 2
            x = 1024,
            y = 0,
            width = 1024,
            height = 1024
        },
        {   -- 3) walk 3
            x = 2048,
            y = 0,
            width = 1024,
            height = 1024
        }, 
    }
}

local sheetOptionsEgg = {
    frames =
    {
        {   -- 1) walk 1
            x = 0,
            y = 0,
            width = 276,
            height = 342
        },
        {   -- 2) walk 2
            x = 276,
            y = 0,
            width = 276,
            height = 342
        },
        {   -- 3) walk 3
            x = 554,
            y = 0,
            width = 276,
            height = 342
        }, 
    }
}


sheetOptionsDino.frames[8].y = 66
local sheetDinoWalk = graphics.newImageSheet("images/dino_sprite_resize.png", sheetOptionsDino)
local sheetPterodactyl = graphics.newImageSheet("images/pterodactyl_sprite.png", sheetOptionsPterodactyl)
local sheetEgg = graphics.newImageSheet("images/egg_sprite.png", sheetOptionsEgg)


local sequenceDataDino = {
    {
        name = "walk",
        start = 1,
        count = 5,
        time = 500,
        loopCount = 0,
        loopDirection = "forward"
    },
    {
        name = "stand",
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

local sequenceDataPterodactyl = {
    {
        name = "fly",
        start = 1,
        count = 3,
        time = 500,
        loopCount = 0,
        loopDirection = "forward"
    },
    {
        name = "fall",
        start = 1,
        count = 1,
        time = 700,
        loopCount = 0,
        loopDirection = "forward"
    },
}

local sequenceDataEgg = {
    {
        name = "fly",
        start = 1,
        count = 3,
        time = 500,
        loopCount = 0,
        loopDirection = "forward"
    },
    {
        name = "fall",
        start = 1,
        count = 1,
        time = 700,
        loopCount = 0,
        loopDirection = "forward"
    },
}

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

local function stopAsteroid()
    
    timer.cancel( asteroidLoopTimer )
    gamePhase = "to_pterodactyl"


end

local function launchAsteroid()
    asteroidLoopTimer = timer.performWithDelay( 2000, asteroidLoop, 0 )
end

local function fly() 
    if (flyState == "down") then      
        pterodactyl.y = pterodactyl.y + 1
        pterodactyl.x = pterodactyl.x - 2
    end 
    if (flyState == "up") then      
        pterodactyl.y = pterodactyl.y - 1
        pterodactyl.x = pterodactyl.x - 2
    end 
    if (pterodactyl.y < 50) then      
        flyState = "down"
        pterodactyl:setSequence("fall")
        egg:setSequence("fall")
    end 
    if (pterodactyl.y > 150 ) then      
        flyState = "up"
        pterodactyl:setSequence("fly")
        egg:setSequence("fly")
        pterodactyl:play()
        egg:play()
    end 
    if (pterodactyl.x < 0 ) then      
        pterodactyl.x = display.contentWidth
    end 

    egg.x = pterodactyl.x + 20
    egg.y = pterodactyl.y + 101

end

local function launchPterodactyl()
    pterodactyl.isVisible = true
    egg.isVisible = true
    pterodactyl:setSequence("fly")
    pterodactyl:play()
    egg:play()
    Runtime:addEventListener("enterFrame", fly)
    gamePhase = "pterodactyl"
end
-- create the asteroids 
local function createAsteroid()
    --tapText.text = "create"
	local newAsteroid = display.newImageRect( backGroup, "images/asteroide.png",100, 120 )
	
    
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

local function dinoStanding() 
    dino.x = dino.x - 5
end

-- create a function to move the object left
local function moveLeft()
    dino.x = dino.x - 10
    buttonPressed = true
end

local function leftButtonHandler(event) 
    if event.phase == "began" then
        buttonPressed = true
        Runtime:addEventListener("enterFrame", moveLeft)
    elseif event.phase == "moved" then
        buttonPressed = false
        Runtime:removeEventListener("enterFrame", moveLeft)
    elseif event.phase == "ended" then
        buttonPressed = false
        Runtime:removeEventListener("enterFrame", moveLeft)
        
    end
    
end 

-- create a function to move the object right
local function moveRight(event)
    dino.x = dino.x + 10
    buttonPressed = true
end

local function rightButtonHandler(event) 
    if event.phase == "began" then
        buttonPressed = true
        Runtime:addEventListener("enterFrame", moveRight)
    elseif event.phase == "moved" then
        buttonPressed = false
         Runtime:removeEventListener("enterFrame", moveRight)
            
        
    elseif event.phase == "ended" then
        buttonPressed = false
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

    pauseButton.isVisible = false

    highScoresButton.isVisible = true
    highScoresButton:addEventListener("tap", function(event)
        composer.gotoScene( "highscores" )
    end
    )
    restartButton.isVisible = true
    restartButton:addEventListener("tap", function(event)
        composer.gotoScene( "game" )
    end
    )
    

    menuButton.isVisible = true
    menuButton:addEventListener("tap", function(event) 
        composer.gotoScene( "menu" )
    end)

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
                dinoState = "standing"
                dino:setSequence("stand") -- switch to "walk" animation sequence
                dino:play() -- start playing the animation
            end
        elseif ( ( obj1.myName == "dino" and obj2.myName == "leftBound" ) or
			 ( obj1.myName == "leftBound" and obj2.myName == "dino" ) )
		    then
                if dinoState == "standing" then  
                    Runtime:removeEventListener("enterFrame", dinoStanding)     
                    buttonPressed = true          
                    dinoState = "walking"
                    dino:setSequence("walk")
                    dino:play()  
                end
            Runtime:removeEventListener("enterFrame", moveLeft)
        elseif ( ( obj1.myName == "dino" and obj2.myName == "rightBound" ) or
        ( obj1.myName == "rightBound" and obj2.myName == "dino" ) )
        then
            Runtime:removeEventListener("enterFrame", moveRight)
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


local function asteroidLoop()
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
end

local function gameLoop()
    if ((buttonPressed == false) and (dinoState == "walking")) then      
        dinoState = "standing"
        dino:setSequence("stand")
        dino:play()
        Runtime:addEventListener("enterFrame", dinoStanding)
        
    elseif ((buttonPressed == true) and (dinoState == "standing")) then         
        Runtime:removeEventListener("enterFrame", dinoStanding)
        dinoState = "walking"
        dino:setSequence("walk")
        dino:play()
    end 
    if (lives == 0 ) then 

        stopAsteroid()
        -- add a runtime listener to move the platform
        Runtime:removeEventListener("enterFrame", movePlatform)
    elseif (score > 100) then   
        if (gamePhase == "to_pterodactyl") then      
            launchPterodactyl()
        elseif (gamePhase == "asteroid") then 
            stopAsteroid()
        end
    end

end

function pauseGame()
    physics.pause() -- pause physics engine
    timer.pauseAll() -- pause all timers
    timer.pause(gameLoopTimer)
    
    transition.pause() -- pause all transitions
    audio.pause() -- pause all audio
    dino:pause()
    egg:pause()
    pterodactyl:pause()
    Runtime:removeEventListener("enterFrame", fly)
    Runtime:removeEventListener("enterFrame", movePlatform) -- remove the game loop listener
    pauseButton.isVisible = false -- hide the pause button
    resumeButton.isVisible = true -- show the resume button
    highScoresButton.isVisible = true
    highScoresButton:addEventListener("tap", function(event)
        composer.gotoScene( "highscores" )
    end
    )
    restartButton.isVisible = true
    restartButton:addEventListener("tap", function(event)
        composer.gotoScene( "game" )
    end
    )
    resumeButton.isVisible = true
    resumeButton:addEventListener("tap", resumeGame)

    menuButton.isVisible = true
    menuButton:addEventListener("tap", function(event) 
        composer.gotoScene( "menu" )
    end)

end

function resumeGame()
    physics.start() -- resume physics engine
    timer.resume(gameLoopTimer)
    timer.resume(scoreTimer)
    if (gamePhase == "asteroid") then 
        timer.resume(asteroidLoopTimer)
    elseif (gamePhase == "pterodactyl") then       
        Runtime:addEventListener("enterFrame", fly) 
        pterodactyl:play()
        egg:play()
    end
    Runtime:addEventListener("enterFrame", movePlatform) 
    
    dino:play()
    
    transition.resume() -- resume all transitions
    audio.resume() -- resume all audio
    --Runtime:addEventListener("enterFrame", gameLoop) -- add the game loop listener
    pauseButton.isVisible = true -- show the pause button
    resumeButton.isVisible = false -- hide the resume button
    restartButton.isVisible = false
    menuButton.isVisible = false
    highScoresButton.isVisible = false

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
	dino = display.newSprite(asteroidGroup, sheetDinoWalk, sequenceDataDino)
    dino.xScale = 150/dino.contentWidth
    dino.yScale = 150/dino.contentHeight
    dino.x = display.contentCenterX
    dino.y = display.contentHeight - 350
    physics.addBody( dino, "dynamic", {radius=0, bounce=0 } )
    dino.myName = "dino"
    
    --create the pterodactyl
    pterodactyl = display.newSprite(mainGroup, sheetPterodactyl, sequenceDataPterodactyl)
    pterodactyl.xScale = 200/pterodactyl.contentWidth
    pterodactyl.yScale = 300/pterodactyl.contentHeight
    pterodactyl.x = display.contentWidth + pterodactyl.contentWidth
    pterodactyl.y = 100
    pterodactyl.myName = "pterodactyl"
    pterodactyl.isVisible = false

    egg = display.newSprite(asteroidGroup, sheetEgg, sequenceDataEgg)
    egg.x = pterodactyl.x + 20
    egg.y = pterodactyl.y + 101
    egg.xScale = 40/208
    egg.yScale = 80/288
    egg.myName = "egg"
    egg.isVisible = false

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
    restartButton = display.newText( uiGroup, "Restart", display.contentCenterX, 350, native.newFont( "font/pixel.ttf", 44 ) )
    restartButton.isVisible = false
    highScoresButton = display.newText( uiGroup, "Highscores", display.contentCenterX, 550, native.newFont( "font/pixel.ttf", 44 ) )
    highScoresButton.isVisible = false
    menuButton = display.newText( uiGroup, "Menu", display.contentCenterX, 450, native.newFont( "font/pixel.ttf", 44 ) )
    menuButton.isVisible = false

    --add the resume button
    resumeButton = display.newText( uiGroup, "Resume", display.contentCenterX, 250, native.newFont( "font/pixel.ttf", 44 ) )
    resumeButton.isVisible = false

    --add the pause button
    pauseButton = display.newText( uiGroup, "ii", 950, 65, native.newFont( "font/funky.ttf", 44 ) )
    pauseButton:setFillColor(1)
    pauseButton:addEventListener( "tap", pauseGame )

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
        --dino:setSequence("walk")
        --dino:play()

        -- add touch event listeners to the buttons
        leftButton:addEventListener("touch", leftButtonHandler)

        rightButton:addEventListener("touch", rightButtonHandler)

        jumpButton:addEventListener("tap", jumpButtonHandler)

        asteroidLoopTimer = timer.performWithDelay( 2000, asteroidLoop, 0 )
        gameLoopTimer = timer.performWithDelay( 100, gameLoop, 0 )
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