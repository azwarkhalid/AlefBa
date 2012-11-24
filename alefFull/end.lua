local storyboard = require( "storyboard" )
local scene = storyboard.newScene("end")

local startButton
local background

local startSound
local startChannel

local function onStartButtonTouch( self, event )
		-- go to page1.lua scene
		if event.phase == "ended" or event.phase == "cancelled" then
			storyboard.gotoScene( "home", "slideRight", 800 )		
			return true	-- indicates successful touch
		end
end

function scene:createScene( event )
	local group = self.view
	
	-- load bg
	background = display.newImage("end.png")
	
	group:insert( background )

end

function scene:enterScene( event )
	background.touch = onStartButtonTouch
	background:addEventListener( "touch", background )

	--audio.setMaxVolume( 0.5 )
	--startSound = audio.loadSound("Bird1.mp3")
	--startChannel = audio.play( startSound )
end

function scene:exitScene( event )
	local group = self.view
	
	background:removeEventListener( "touch", background )
	
	--audio.dispose( startChannel )
	--startSound = nil
end

function scene:destroyScene( event )
	local group = self.view	
end


scene:addEventListener( "createScene", scene )
scene:addEventListener( "enterScene", scene )
scene:addEventListener( "exitScene", scene )
scene:addEventListener( "destroyScene", scene )
	
return scene