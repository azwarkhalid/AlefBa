-- MarqoomLetterScene is a factory class that extends the storyboard scene class
-- and creates our custom scene class that draws each alphabet letters

MarqoomLetterScene = { }

function MarqoomLetterScene:new(letterIndex)
	analytics = analytics or require ("analytics")

	local storyboard = require( "storyboard" )
	local json = require( "json" )
	
	local oScene = storyboard.newScene("page")
	letterIndex = letterIndex or 1
	
	totalLetters = totalLetters or 4
	
	group = display.newGroup()
	
	sensorDotFlag = sensorDotFlag or 1
	sensorsTotal = 7
	
	sensorDot1 = sensorDot1 or display.newImage("sensorDot.png")
	sensorDot2 = sensorDot2 or display.newImage("sensorDot.png")
	sensorDot3 = sensorDot3 or display.newImage("sensorDot.png")
	sensorDot4 = sensorDot4 or display.newImage("sensorDot.png")
	sensorDot5 = sensorDot5 or display.newImage("sensorDot.png")
	sensorDot6 = sensorDot6 or display.newImage("sensorDot.png")
	sensorDot7 = sensorDot7 or display.newImage("sensorDot.png")

	-- Starts physics
	local physics = require ("physics")
	physics.start(true)
	physics.setGravity(10, 0)
	
	-- Draw a line declarations
	local i = 1
	local tempLine
	local ractgangle_hit = {}
	local prevX , prevY
	
	local drawingCircles = display.newGroup()
	
	local jsonFile = function( filename, base )
		-- set default base dir if none specified
		if not base then base = system.ResourceDirectory; end
	
		-- create a file path for corona i/o
		local path = system.pathForFile( filename, base )
	
		-- will hold contents of file
		local contents
	
		-- io.open opens a file at path. returns nil if no file found
		local file = io.open( path, "r" )
		if file then
		   -- read all contents of file into a string
		   contents = file:read( "*a" )
		   io.close( file )	-- close the file after using it
		end
	
		return contents
	end
	myLettersArray = json.decode( jsonFile("lettersData.json") )
	letter = letter or display.newImage("letter" .. myLettersArray[letterIndex]["letter"] .. ".png")
	
	function oScene:drawTouch( event )
		if event.phase == "began" then
			-- Random Colors for line	 
			r = 255
			g = 255
			b = 0
			prevX = event.x
			prevY = event.y		
		elseif ( event.phase=="moved" or event.phase=="cancelled" ) then
			ractgangle_hit[i] = display.newLine(prevX, prevY, event.x, event.y)
			ractgangle_hit[i]:setColor(r,g, b)
			ractgangle_hit[i].width = 24
			prevX = event.x
			prevY = event.y
			i = i + 1
		end
		
		local myCircle = display.newCircle(prevX, prevY, 12)
	    myCircle:setFillColor(255,255,0)
	    drawingCircles:insert(myCircle)
	end
	
	local flagAudio = function(flagNumber)
		local startSound = audio.loadSound("audioBird1.mp3")
		local startChannel = audio.play( startSound )
	end
	
	function checkAnimateReady( self, event )
		sensorDotFlag = sensorDotFlag + 1
		
		self:removeEventListener( "touch", self )
		-- flagAudio(1)
	
		if sensorDotFlag > sensorsTotal then
			sensorDotFlag = 0
			media.playVideo( "video" .. myLettersArray[letterIndex]["letter"] .. ".mp4", false, oScene.successDrawing )
		end
	end
	
	function playSound( event , audioSoundFile )
		local letterSound = audio.loadSound(audioSoundFile)
		local letterChannel = audio.play( letterSound )
	end
	
	function oScene:eraseBoard( event )
		-- Reset the sensors
		sensorDotFlag = 1
		oScene:recreateSensors( event )
		oScene:enableSensors( event )
		
		-- Erase the board
		for k,v in pairs(ractgangle_hit) do 
			v:removeSelf()
		end
		ractgangle_hit = {}
	
		while drawingCircles.numChildren > 0 do
			drawingCircles[1]:removeSelf()
		end
		timer.performWithDelay(100, eraseEraser )
	end
	
	function oScene:playAudioSound( event )
		if event.phase=="began" then
			playSound( event , "audio" .. myLettersArray[letterIndex]["letter"] .. ".mp3" )
		end
	end
	
	function oScene:goHome( event ) 
		if event.phase == "ended" then
			letterIndex = 1
			storyboard.gotoScene( "home" )
		end
	end
	
	function oScene:successDrawing( event ) 
		-- Play ahsant audio
		playSound(event, "audioAhsant.mp3")
		analytics.logEvent( "Successfully Completed Drawing Letter" .. myLettersArray[letterIndex]["letter"] )
		oScene:moveToNextLetter( event )
	end
	
	function oScene:moveToNextLetter( event )
		if totalLetters > letterIndex then
			letterIndex = letterIndex + 1

			display.remove( letter )
			oScene.eraseBoard( event )
	
			letter = display.newImage("letter" .. myLettersArray[letterIndex]["letter"] .. ".png")
			letter.x = display.contentWidth/2 + myLettersArray[letterIndex]["letterXY"][1]
			letter.y = display.contentHeight/2 + myLettersArray[letterIndex]["letterXY"][2]
			group:insert(letter)
			
			analytics.logEvent( "Moving to Letter " .. myLettersArray[letterIndex]["letter"] )
		else
			analytics.logEvent( "Completed letters and moving back to home page")
			letterIndex = 1
			storyboard.gotoScene( "end" )
		end
	end

	function oScene:nextLetter( event )
		if event.phase == "ended" then
			oScene.moveToNextLetter( event )
		end
	end

	function oScene:moveToPrevLetter( event )
		if letterIndex > 1 then
			letterIndex = letterIndex - 1

			display.remove( letter )
			self.eraseBoard( event )
	
			letter = display.newImage("letter" .. myLettersArray[letterIndex]["letter"] .. ".png")
			letter.x = display.contentWidth/2 + myLettersArray[letterIndex]["letterXY"][1]
			letter.y = display.contentHeight/2 + myLettersArray[letterIndex]["letterXY"][2]
			group:insert(letter)
			analytics.logEvent( "Moving to Letter " .. myLettersArray[letterIndex]["letter"] )
		else 
			analytics.logEvent( "Moving back to home page")
			oScene.eraseBoard( event )
			storyboard.gotoScene( "home" )
		end

	end
	
	function oScene:prevLetter( event )
		if event.phase == "ended" then
			oScene:moveToPrevLetter( event )
		end
	end
	
	function oScene:createScene( event )
		analytics.logEvent( "Created Drawing Scene with Letter" .. myLettersArray[letterIndex]["letter"] )
		
		self.background = display.newImage("drawingBoardBg.png")

		self.eraseButton = display.newImage("eraser.png")
		self.eraseButton.x = display.contentWidth - 100
		self.eraseButton.y = 100

		self.audioButton = display.newImage("audio.png")
		self.audioButton.x = 100
		self.audioButton.y = 100

		self.homeButton = display.newImage("home.png")	
		self.homeButton.x = display.contentWidth/2
		self.homeButton.y = display.contentHeight - 100

		self.prevButton = display.newImage("back.png")
		self.prevButton.x = display.contentWidth/2 + 125
		self.prevButton.y = display.contentHeight - 100

		self.nextButton = display.newImage("next.png")
		self.nextButton.x = display.contentWidth/2 + 255
		self.nextButton.y = display.contentHeight - 100

		self.board = display.newImage("board.png")
		self.board.x = display.contentWidth/2 + 10
		self.board.y = display.contentHeight/2 - 100

		self.bear = display.newImage("bear.png")
		self.bear.x = display.contentWidth/2 - 170
		self.bear.y = display.contentHeight/2 + 250
		
		group = self.view
		group:insert(self.background)
		group:insert(self.eraseButton)
		group:insert(self.audioButton)
		group:insert(self.homeButton)
		group:insert(self.prevButton)
		group:insert(self.nextButton)
		group:insert(self.board)
		group:insert(self.bear)

	end

	function oScene:enterScene( event )		
		analytics.logEvent( "Entering scene for letter " .. myLettersArray[letterIndex]["letter"])
		display.remove( letter )
		letter = display.newImage("letter" .. myLettersArray[letterIndex]["letter"] .. ".png")
		letter.x = display.contentWidth/2 + myLettersArray[letterIndex]["letterXY"][1]
		letter.y = display.contentHeight/2 + myLettersArray[letterIndex]["letterXY"][2]
		group:insert(letter)
		
		self.homeButton.touch = self.goHome
		self.homeButton:addEventListener( "touch", self.homeButton )
		
		self.nextButton.touch = self.nextLetter
		self.nextButton:addEventListener( "touch", self.nextButton )

		self.prevButton.touch = self.prevLetter
		self.prevButton:addEventListener( "touch", self.prevButton )

		self.audioButton.touch = self.playAudioSound
		self.audioButton:addEventListener( "touch", self.audioButton )
		
		-- drawing function
		self.board.touch = self.drawTouch
		self.board:addEventListener( "touch", self.board )
		
		-- erasing function
		self.eraseButton.touch = self.eraseBoard
		self.eraseButton:addEventListener( "touch", self.eraseButton )
		
		-- Sensors creation
		self:recreateSensors( event )
		self:enableSensors( event )
	end

	function oScene:recreateSensors( event ) 
		display.remove( sensorDot1 )
		display.remove( sensorDot2 )
		display.remove( sensorDot3 )
		display.remove( sensorDot4 )
		display.remove( sensorDot5 )
		display.remove( sensorDot6 )
		display.remove( sensorDot7 )

		-- Creat Sensor Dots
		sensorDot1 = display.newImage("sensorDot.png")
		sensorDot1.x = display.contentWidth/2 + myLettersArray[letterIndex]["xCoords"][1]
		sensorDot1.y = display.contentHeight/2 + myLettersArray[letterIndex]["yCoords"][1]
		group:insert( sensorDot1 )
	
		sensorDot2 = display.newImage("sensorDot.png")
		sensorDot2.x = display.contentWidth/2 + myLettersArray[letterIndex]["xCoords"][2]
		sensorDot2.y = display.contentHeight/2 + myLettersArray[letterIndex]["yCoords"][2]
		group:insert( sensorDot2 )
		
		sensorDot3 = display.newImage("sensorDot.png")
		sensorDot3.x = display.contentWidth/2 + myLettersArray[letterIndex]["xCoords"][3]
		sensorDot3.y = display.contentHeight/2 + myLettersArray[letterIndex]["yCoords"][3]
		group:insert( sensorDot3 )
	
		sensorDot4 = display.newImage("sensorDot.png")
		sensorDot4.x = display.contentWidth/2 + myLettersArray[letterIndex]["xCoords"][4]
		sensorDot4.y = display.contentHeight/2 + myLettersArray[letterIndex]["yCoords"][4]
		group:insert( sensorDot4 )
		
		sensorDot5 = display.newImage("sensorDot.png")
		sensorDot5.x = display.contentWidth/2 + myLettersArray[letterIndex]["xCoords"][5]
		sensorDot5.y = display.contentHeight/2 + myLettersArray[letterIndex]["yCoords"][5]
		group:insert( sensorDot5 )
	
		sensorDot6 = display.newImage("sensorDot.png")
		sensorDot6.x = display.contentWidth/2 + myLettersArray[letterIndex]["xCoords"][6]
		sensorDot6.y = display.contentHeight/2 + myLettersArray[letterIndex]["yCoords"][6]
		group:insert( sensorDot6 )
		
		sensorDot7 = display.newImage("sensorDot.png")
		sensorDot7.x = display.contentWidth/2 + myLettersArray[letterIndex]["xCoords"][7]
		sensorDot7.y = display.contentHeight/2 + myLettersArray[letterIndex]["yCoords"][7]
		group:insert( sensorDot7 )
	end

	function oScene:enableSensors( event ) 
		sensorDotFlag = 1
		sensorsTotal = sensorsTotal or 6
	
		-- add score sensing details
		sensorDot1.touch = checkAnimateReady
		sensorDot1:addEventListener( "touch", sensorDot1 )
		
		sensorDot2.touch = checkAnimateReady
		sensorDot2:addEventListener( "touch", sensorDot2 )
		
		sensorDot3.touch = checkAnimateReady
		sensorDot3:addEventListener( "touch", sensorDot3 )
	
		sensorDot4.touch = checkAnimateReady
		sensorDot4:addEventListener( "touch", sensorDot4 )
		
		sensorDot5.touch = checkAnimateReady
		sensorDot5:addEventListener( "touch", sensorDot5 )
		
		sensorDot6.touch = checkAnimateReady
		sensorDot6:addEventListener( "touch", sensorDot6 )
		
		sensorDot7.touch = checkAnimateReady
		sensorDot7:addEventListener( "touch", sensorDot7 )
	end
	
	function oScene:exitScene( event )
		self.eraseBoard( event )
	end

	function oScene:destroyScene( event )
		self.homeButton:removeEventListener( "touch", self.homeButton )
		self.nextButton:removeEventListener( "touch", self.nextButton )
		self.prevButton:removeEventListener( "touch", self.prevButton )
		self.board:removeEventListener( "touch", self.board )
		self.audioButton:removeEventListener( "touch", self.audioButton )
		self.eraseButton:removeEventListener( "touch", self.eraseButton )
	end

	oScene:addEventListener( "createScene", oScene )
	oScene:addEventListener( "enterScene", oScene )
	oScene:addEventListener( "exitScene", oScene )
	oScene:addEventListener( "destroyScene", oScene )

	return oScene
end

return MarqoomLetterScene