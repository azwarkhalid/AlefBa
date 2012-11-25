local storyboard = require( "storyboard" )
local scene = storyboard.newScene("home")
analytics = require ("analytics")
analytics.init( "TY9PTKDM7FBS6CRJVKXG" ) -- Apple versions
-- local androidAnaly = "D4ZC32B9WQNBSDC95YVC" ) -- Android trial analytics key
analytics.logEvent( "HomePage" )

local startButton
local helpButton
local background
local startSound
local startChannel

local function onStartButtonTouch( self, event )
	if event.phase == "ended" or event.phase == "cancelled" then
		media.playVideo( "videoHelpAlef.mp4", false, function() storyboard.gotoScene( "page" ) end )
		return true	-- indicates successful touch
	end
end

local function onHelpButtonTouch( self, event )
	if event.phase == "ended" or event.phase == "cancelled" then
		analytics.logEvent( "Starting Help Video" )
		media.playVideo( "videoHelp.mp4", false, doNothing )
	end
end

local function doNothing()
	analytics.logEvent( "Finished Help Video" )
end

function scene:createScene( event )
	-- load bg
	background = display.newImage("homeBg.png")
	
	-- Add start button
	startButton = display.newImage("start.png")
	startButton.x = display.contentWidth/2
	startButton.y = display.contentHeight/2 + 250

	-- Add start button
	helpButton = display.newImage("help.png")
	helpButton.x = display.contentWidth/2
	helpButton.y = display.contentHeight/2 + 400	
	
	self.view:insert( background )
	self.view:insert( startButton )
	self.view:insert( helpButton )

end

function scene:enterScene( event )

	startButton.touch = onStartButtonTouch
	startButton:addEventListener( "touch", startButton )
	
	helpButton.touch = onHelpButtonTouch
	helpButton:addEventListener( "touch", helpButton )
	
	audio.setMaxVolume( 0.5 )
	
	startSound = audio.loadSound("audioBird1.mp3")
	startChannel = audio.play( startSound ) 
	
	startSound = audio.loadSound("audioBird2.mp3")
	startChannel = audio.play( startSound ) 
	
	startSound = audio.loadSound("audioBird3.mp3")
	startChannel = audio.play( startSound ) 
	
	storyboard.purgeAll()
end

function scene:exitScene( event )
	startButton:removeEventListener( "touch", startButton )
	helpButton:removeEventListener( "touch", helpButton )
	
	audio.dispose( startChannel )
	startSound = nil
end

function scene:destroyScene( event )
		
end


scene:addEventListener( "createScene", scene )
scene:addEventListener( "enterScene", scene )
scene:addEventListener( "exitScene", scene )
scene:addEventListener( "destroyScene", scene )

return scene