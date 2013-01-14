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

local function onDownloadButton( self, event) 
	if event.phase == "ended" or event.phase == "cancelled" then
		--system.openURL("https://play.google.com/store/apps/details?id=com.marqoomlabs.alefbafull095")
		system.openURL("https://itunes.apple.com/au/app/alef-ba-arabic-alphabet-for/id590048145#")
		storyboard.gotoScene( "home" )
	end
end

function scene:createScene( event )
	local group = self.view
	
	-- load bg
	background = display.newImage("endBg.png")
	
	elephant = display.newImage("elephant.png")
	elephant.x = display.contentWidth/2 - 120
	elephant.y = display.contentHeight/2 + 210
	
	speech = display.newImage("speech_bubble.png")
	speech.x = display.contentWidth/2 + 50
	speech.y = display.contentHeight/2 - 200	
	
	download = display.newImage("download_button.png")
	download.x = display.contentWidth/2
	download.y = display.contentHeight/2 + 450
	
	group:insert( background )
	group:insert( elephant )
	group:insert( speech )
	group:insert( download )
end

function scene:enterScene( event )
	elephant.touch = onStartButtonTouch
	elephant:addEventListener( "touch", elephant )
	
	speech.touch = onDownloadButton
	speech:addEventListener( "touch", speech )
	
	download.touch = onDownloadButton
	download:addEventListener( "touch", download )
end

function scene:exitScene( event )
	local group = self.view
	
	background:removeEventListener( "touch", elephant )
	background:removeEventListener( "touch", speech )
	background:removeEventListener( "touch", download )
end

function scene:destroyScene( event )
	local group = self.view	
end

scene:addEventListener( "createScene", scene )
scene:addEventListener( "enterScene", scene )
scene:addEventListener( "exitScene", scene )
scene:addEventListener( "destroyScene", scene )
	
return scene