Class = require "class"
push = require "push"

require 'Paddle'
require 'Ball'

WINDOW_HEIGHT = 720
WINDOW_WIDTH = 1200

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLESPEED = 200

function love.load()
  math.randomseed(os.time())

  love.graphics.setDefaultFilter('nearest', 'nearest')

  love.window.setTitle('Jharttech PONG')

  sounds = {
    ['paddle_hit'] = love.audio.newSource('paddle_Hit.wav', 'static'),
    ['wall_hit'] = love.audio.newSource('wall_Hit.wav', 'static'),
    ['score'] = love.audio.newSource('score.wav', 'static'),
    ['win'] = love.audio.newSource('win.wav', 'static')
  }

  push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
    fullscreen = false,
    vsync = true,
    resizable = true
  })

  smallFont = love.graphics.newFont('font.ttf', 8)
  scoreFont = love.graphics.newFont('font.ttf', 14)
  winnerWinner = love.graphics.newFont('font.ttf', 24)
  chickenDinner = love.graphics.newFont('font.ttf', 32)

  numOfPlayers = 0

  difficulty = 0

  playerOneScore = 0
  playerTwoScore = 0

  servingPlayer = 0

  nextY = 0

  paddleOne = Paddle(5, 20, 5, 20)
  paddleTwo = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)

  gameState = 'playerCount'

end

function love.resize(w, h)
  push:resize(w, h)
end

function love.update(dt) -- dt is delta time
  current = love.timer.getTime()

  paddleOne:update(dt)
  paddleTwo:update(dt)

  if love.keyboard.isDown('w') then
    paddleOne.dy = -PADDLESPEED
    if gameState == 'score' and servingPlayer == 1 then
      ball:afterScore(dt)
      ball.dy = -PADDLESPEED
      ball.y = paddleOne.y + (paddleOne.height / 2 - 2)
    end
  elseif love.keyboard.isDown('s') then
    paddleOne.dy = PADDLESPEED
    if gameState == 'score' and servingPlayer == 1 then
      ball:afterScore(dt)
      ball.dy = paddleOne.dy
      ball.y = paddleOne.y + (paddleOne.height / 2 - 2)
    end
  else
    paddleOne.dy = 0
  end

  if numOfPlayers == 1 then
    if gameState == 'play' then
      if ball.y > 0 then
        paddleTwo.y = ball.y
        if paddleTwo.y <= 0 then
          paddleTwo.y = 0
        elseif paddleTwo.y >= VIRTUAL_HEIGHT - paddleTwo.height then
          paddleTwo.y = VIRTUAL_HEIGHT - paddleTwo.height
        end
      end
      if ball.dy > 0 then
        paddleTwo.dy = PADDLESPEED
        if ball.dy == 0 then
          paddleTwo.y = randomServe
          paddleTwo.dy = 0
        end
      elseif ball.dy < 0 then
        paddleTwo.dy = -PADDLESPEED
        if ball.dy == 0 then
          paddleTwo.y = randomServe
          paddleTwo.dy = 0
        end
      end
    elseif gameState == 'score' and servingPlayer == 2 then
      nextY = 0
      if difficulty == 1 then
        ball:afterScore(dt/5)
        paddleTwo:update(dt/5)
      elseif difficulty == 2 then
        ball:afterScore(dt/2)
        paddleTwo:update(dt/2)
      else
        ball:afterScore(dt*2)
        paddleTwo:update(dt)
      end

      if ball.y > randomServe then
        ball.dy = -PADDLESPEED
        if ball.y < randomServe then
          gameState = 'play'
          ball:serve(dt)
        end
      elseif ball.y < randomServe then
        ball.dy = PADDLESPEED
        if ball.y < randomServe then
          gameState = 'play'
          ball:serve(dt)
        end
      end

      if paddleTwo.y < randomServe then
        paddleTwo.dy = PADDLESPEED
      elseif paddleTwo.y > randomServe then
          paddleTwo.dy = -PADDLESPEED
      end
      paddleTwo.y = ((ball.y - paddleTwo.height / 2 + 2)  + nextY)

    elseif gameState == 'score' and servingPlayer == 1 then
      paddleTwo.y = ((ball.y - paddleTwo.height / 2 - 2)  + nextY)
    elseif gameState == 'victory' then
      ball.dy = 0
      paddleTwo.dy = 0
    end
  end

  if numOfPlayers == 2 then
    if love.keyboard.isDown('up') then
      paddleTwo.dy = -PADDLESPEED
      if gameState == 'score' and servingPlayer == 2 then
        ball:afterScore(dt)
        ball.dy = -PADDLESPEED
        ball.y = paddleTwo.y + (paddleTwo.height / 2 - 2)
      end
    elseif love.keyboard.isDown('down') then
      paddleTwo.dy = PADDLESPEED
      if gameState == 'score' and servingPlayer == 2 then
        ball:afterScore(dt)
        ball.dy = PADDLESPEED
        ball.y = paddleTwo.y + (paddleTwo.height / 2 - 2)
      end
    else
      paddleTwo.dy = 0
      if gameState == 'score' and servingPlayer == 2 then
        nextY = 0
        ball.dy = 0
        ball.y = paddleTwo.y + (paddleTwo.height / 2 - 2)
      elseif gameState == 'score' and servingPlayer == 1 then
        nextY = 0
        ball.dy = 0
        ball.y = paddleOne.y + (paddleOne.height /2 -2)
      end
    end
  end

  if gameState == 'play' then
    current = love.timer.getTime()

    ball:update(dt*1.5)

    if ball.x <= 0 then
	if difficulty == 3 then
		gameState = 'victory'
		sounds['win']:play()
	else
      		randomServe = math.random(0, VIRTUAL_HEIGHT - paddleTwo.height)
      		playerTwoScore = playerTwoScore + 1
      		ball:reset()
      		ball.x = paddleTwo.x
      		ball.y = paddleTwo.y + (paddleTwo.height / 2 - 2)
      		gameState = 'score'
      		servingPlayer = 2
      		sounds['score']:play()
	end
    elseif ball.x >= VIRTUAL_WIDTH - 4 then
      if difficulty == 1 then
        nextY = math.random(-25, 25)
      elseif difficulty == 2 then
        nextY = math.random(-20, 20)
      else
        nextY = math.random(-11, 11)
      end

      playerOneScore = playerOneScore + 1
      ball:reset()
      ball.x = paddleOne.x + paddleOne.x
      ball.y = paddleOne.y + (paddleOne.height / 2 - 2)
      gameState = 'score'
      servingPlayer = 1
      sounds['score']:play()
    end

    if ball:collides(paddleOne) then
      ball.dx = -ball.dx + math.random(2, 4)
      ball.dy = -ball.dy + paddleOne.dy
      ball.x = paddleOne.x + 4
      if gameState == 'play' then
        sounds['paddle_hit']:play()
        if ball.dy > 0 then
          if difficulty == 1 then
            nextY = math.random(0, 25)
          elseif difficulty == 2 then
            nextY = math.random(0, 20)
          else
            nextY = math.random(0, 11)
          end
        elseif ball.dy < 0 then
          if difficulty == 1 then
            nextY = math.random(0, -25)
          elseif difficulty == 2 then
            nextY = math.random(0, -20)
          else
            nextY = math.random(0, -11)
          end
        else
          if difficulty == 1 then
            nextY = math.random(-25, 25)
          elseif difficulty == 2 then
            nextY = math.random(-20, 20)
          else
            nextY = math.random(-11, 11)
          end
        end
      end
    elseif ball:collides(paddleTwo) then
      ball.dx = -ball.dx + math.random(2, 4)
      ball.dy = -ball.dy + paddleTwo.dy
      ball.x = paddleTwo.x - 4
      if gameState == 'play' then
        sounds['paddle_hit']:play()
      end
    end

    if ball.y <= 0 then
      ball.dy = math.random(10, 150)
      sounds['wall_hit']:play()
      if difficulty == 1 then
        --nextY = math.random(0, 25)
      elseif difficulty == 2 then
        --nextY = math.random(0, 15)
      else
        nextY = math.random(0, 11)
      end
    elseif ball.y >= VIRTUAL_HEIGHT - 4 then
      ball.dy = -math.random(10, 150)
      ball.y = VIRTUAL_HEIGHT - 4
      sounds['wall_hit']:play()
      if difficulty == 1 then
        --nextY = math.random(-25, 0)
      elseif difficulty == 2 then
        --nextY = math.random(-15, 0)
      else
        nextY = math.random(-11, 0)
      end
    end
  end

  if gameState == 'score' then
    playerWhoScored = servingPlayer == 1 and "Player 1" or "Player 2"
    if playerOneScore == 5 or playerTwoScore == 5 then
      gameState = 'victory'
      sounds['win']:play()
    end
  end
end

function love.keypressed(key)
  if key == 'escape' then
    love.event.quit()
  elseif key == 'enter' or key == 'return' or key == 'space' then
    if gameState == 'start' then
      start = love.timer.getTime()
      gameState = 'play'
    elseif gameState == 'score' and servingPlayer == 1 then
      gameState = 'play'
      ball:serve(dt)
    elseif gameState == 'score' and numOfPlayers == 2 and servingPlayer == 2 then
	gameState = 'play'
	ball:serve(dt)
    elseif gameState == 'victory' then
      love.load()
    end
  elseif gameState == 'playerCount' then
    if key == '1' then
      numOfPlayers = 1
      gameState = 'setDifficult'
    elseif key == '2' then
      numOfPlayers = 2
      ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)
      gameState = 'start'
    end
  elseif gameState == 'setDifficult' then
    if key == '1' then
      difficulty = 1
    elseif key == '2' then
      difficulty = 2
    else
      difficulty = 3
    end
    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)
    gameState = 'start'
  end
end

function love.draw()
  push:apply('start')

  love.graphics.clear(40 / 255, 45 / 255, 52 / 255, 255 / 255) --Devide value out of 255 by 255 to get 0.0 to 1.0 float value used in lua

  paddleOne:render()
  paddleTwo:render()

  if gameState == 'start' or gameState == 'play' or gameState == 'score' then
    ball:render()
    --love.graphics.print(" ballY: " .. tostring(ball.y), 40, 50)
    --love.graphics.setColor(1, 1, 1, 1)
    --love.graphics.setFont(smallFont)
    --love.graphics.print(" ballDY: " .. tostring(ball.dy), 40, 60)
    --love.graphics.setColor(1, 1, 1, 1)
  end

  love.graphics.setFont(smallFont)
  if gameState == 'start' then
    love.graphics.printf("Press 'enter' to play", 0, 30, VIRTUAL_WIDTH, 'center')
  elseif gameState == 'play' then
	  if difficulty == 3 then
    		love.graphics.setColor(0, 1, 0, 1)
    		love.graphics.setFont(scoreFont)
		highScore = math.floor(current - start)
    		love.graphics.print("Time: " .. math.floor(tostring(current - start)), 40, 20)
	else
    		love.graphics.print("Player One", VIRTUAL_WIDTH / 4 - 45, 7)
    		love.graphics.print("Player Two", VIRTUAL_WIDTH - VIRTUAL_WIDTH / 4, 7)
	end
  elseif gameState == 'score' then
    love.graphics.printf("SCORE!!", 0, 0, VIRTUAL_WIDTH, 'center')
    love.graphics.printf(playerWhoScored .."'s Serve!", 0, 25, VIRTUAL_WIDTH, 'center')
  end

  love.graphics.setFont(scoreFont)
  if gameState == 'playerCount' then
    love.graphics.printf("Hello Pong!", 0, 20, VIRTUAL_WIDTH, 'center')
    love.graphics.printf("Press '1' for One Player Game", 0, VIRTUAL_HEIGHT / 2 - 10, VIRTUAL_WIDTH, 'center')
    love.graphics.printf("Press '2' for Two Player Game", 0, VIRTUAL_HEIGHT / 2 + 10, VIRTUAL_WIDTH, 'center')
  end

  if gameState == 'setDifficult' then
    love.graphics.printf("Please Select Difficulty", 0, 20, VIRTUAL_WIDTH, 'center')
    love.graphics.printf("Press '1' for Easy", 0, VIRTUAL_HEIGHT / 2 - 20, VIRTUAL_WIDTH, 'center')
    love.graphics.printf("Press '2' for Medium", 0, VIRTUAL_HEIGHT / 2, VIRTUAL_WIDTH, 'center')
    love.graphics.printf("Press '3' for Impossible", 0, VIRTUAL_HEIGHT / 2 + 20, VIRTUAL_WIDTH, 'center')
  end

  love.graphics.print(playerOneScore, VIRTUAL_WIDTH / 2 - 50, 7)
  love.graphics.print(playerTwoScore, VIRTUAL_WIDTH / 2 + 40, 7)

  if gameState == 'play' then
    love.graphics.printf("VS",0, 7, VIRTUAL_WIDTH, 'center')
  end

  if gameState == 'victory' then
	  if difficulty == 3 then
		love.graphics.setFont(scoreFont)
		love.graphics.printf("You survived " .. tostring(highScore) .. " Seconds !!!", 0, VIRTUAL_HEIGHT / 2 - 50, VIRTUAL_WIDTH, 'center')
		love.graphics.setFont(winnerWinner)
		love.graphics.printf("Computer", 0, VIRTUAL_HEIGHT / 2 - 25, VIRTUAL_WIDTH, 'center')
    		love.graphics.printf("IS THE", 0, VIRTUAL_HEIGHT / 2, VIRTUAL_WIDTH, 'center')
    		love.graphics.setFont(winnerWinner)
    		love.graphics.setFont(chickenDinner)
    		love.graphics.printf("WINNER!!!", 0, VIRTUAL_HEIGHT / 2 + 25, VIRTUAL_WIDTH, 'center')
	  else
    		love.graphics.printf("WINNER!!!", 0, VIRTUAL_HEIGHT / 2 + 25, VIRTUAL_WIDTH, 'center')
    		love.graphics.printf(playerWhoScored, 0, VIRTUAL_HEIGHT / 2 - 25, VIRTUAL_WIDTH, 'center')
    		love.graphics.printf("IS THE", 0, VIRTUAL_HEIGHT / 2, VIRTUAL_WIDTH, 'center')
    		love.graphics.setFont(chickenDinner)
    		love.graphics.printf("WINNER!!!", 0, VIRTUAL_HEIGHT / 2 + 25, VIRTUAL_WIDTH, 'center')
	end
  end

  --displayFPS()

  push:apply('end')

end

--function displayFPS()

  --love.graphics.setColor(1, 1, 1, 1)
  --love.graphics.setFont(smallFont)
  --love.graphics.print("paddle2 y: " .. tostring(paddleTwo.y), 40, 30)
  --love.graphics.setColor(1, 1, 1, 1)
  --love.graphics.setFont(smallFont)
  --love.graphics.print(" nextY: " .. tostring(nextY), 40, 40)
  --love.graphics.setColor(1, 1, 1, 1)
  --love.graphics.setFont(smallFont)

--end
