-- CONSTANTS
SCREEN_WIDTH = 640
SCREEN_HEIGHT = 480
MAX_ENEMIES = 8
SCORE = 0
NUM_ENEMIES_DESTROYEDS = 10
GAME_ACTIVE = true

-- PLAYER 
car = {
    src = 'imagens/car.png',
    height = 54,
    width = 34,
    x = SCREEN_WIDTH/2 - 44/2, 
    y = SCREEN_HEIGHT - 70,
    shoots = {}
}

function destroyCar()
    colisionSound:play()
    car.src = "imagens/explosion.png";
    car.image = love.graphics.newImage(car.src)
    car.width = 67
    car.height = 67
end

function moveCar() 
    if love.keyboard.isDown('up') then
        if  car.y > 0 then
            car.y = car.y-2
        end
    end
    if love.keyboard.isDown('down') then
        if  car.y < SCREEN_HEIGHT - 70 then
            car.y = car.y+2
        end
    end
    if love.keyboard.isDown('left') then
        if  car.x > 150 then
            car.x = car.x-2
        end
    end
    if love.keyboard.isDown('right') then
        if  car.x < 450 then
            car.x = car.x+2
        end
        
    end
end

-- SHOOT
function shooter() 
    local shoot = {
        x = car.x+car.width/2,
        y = car.y,
        height = 16,
        width = 16
    }
    table.insert(car.shoots, shoot)
    playShootSong()
end

function moveShot()
    for i = #car.shoots, 1, -1 do
        if car.shoots[i].y > 0 then
            car.shoots[i].y = car.shoots[i].y -1
        else
            table.remove(car.shoots, i)
        end
    end
end

-- ENEMIES

enemies = {}

function newEnemies()
    enemy = {
        x = math.random(150, 450),
        y = -70,
        height = 54,
        width = 34,
        weight = math.random(3),
        horizontal_moviment = math.random(-1, 1)
    }

    table.insert(enemies, enemy)
end

function moveEnemies()
    for k,enemy in pairs(enemies) do
        enemy.y = enemy.y+enemy.weight
        if (enemy.x + enemy.horizontal_moviment < 450) and (enemy.x + enemy.horizontal_moviment > 150) then
            enemy.x = enemy.x + enemy.horizontal_moviment
        end
    end
end

function removeEnemies()
    for i = #enemies, 1, -1 do
        if enemies[i].y > SCREEN_HEIGHT then
            table.remove(enemies, i)
        end
    end
end

-- COLISION

function hasColision(X1, Y1, W1, H1, X2, Y2, W2, H2)
    return X2 < X1+W1 
           and X1 < X2+W2 
           and Y1 < Y2+H2 
           and Y2 < Y1+H1
end

function carColision()
    for k,enemy in pairs(enemies) do
        if hasColision(enemy.x, enemy.y, enemy.width, enemy.height, car.x, car.y, car.width, car.height) then
            updateSong()
            destroyCar()
            END_GAME = true
        end
    end
end

function shootColision()
    for i = #car.shoots, 1, -1 do
        for j = #enemies, 1, -1 do
            if hasColision(car.shoots[i].x, car.shoots[i].y,car.shoots[i].width, car.shoots[i].height, enemies[j].x, enemies[j].y, enemies[j].width, enemies[j].height) then
                table.remove(car.shoots, i)
                table.remove(enemies, j)
                SCORE = SCORE +1
                break
            end
        end
    end
end

function handleColisions()
    carColision()
    shootColision()
end

function hasPlayerWon()
    if SCORE >= NUM_ENEMIES_DESTROYEDS then
        WINNER = true
    end
end

-- SONG

function updateSong()
    songTheme:stop()
    gameOverSong = love.audio.newSource("audios/game_over.wav", "stream")
    gameOverSong:play()
end

function playShootSong()
    shootSound = love.audio.newSource("audios/disparo.wav", "stream")
    shootSound:play()
end

-- CALLBACKS

function love.load()
    math.randomseed(os.time())
    
    -- window
    love.window.setMode(SCREEN_WIDTH, SCREEN_HEIGHT, {resizable = true})
    love.window.setTitle('Relâmpago Marquinhos')
    
    -- images
    background = love.graphics.newImage('imagens/background.jpg')
    car.image = love.graphics.newImage(car.src)
    enemy_image = love.graphics.newImage("imagens/enemies.png")
    shoot_img = love.graphics.newImage("imagens/tiro.png")
    win_img = love.graphics.newImage("imagens/vencedor.png")
    gameover_img = love.graphics.newImage("imagens/gameover.png")
    winner_img = love.graphics.newImage("imagens/winner.jpg")

    -- sounds
    songTheme = love.audio.newSource("audios/ambiente.wav", "stream")
    colisionSound = love.audio.newSource("audios/destruicao.wav", "stream")
    winnerSong = love.audio.newSource("audios/winner.wav", "stream")

    songTheme:setLooping(true)
    songTheme:play()
end

function love.update(dt)
    if not END_GAME and not WINNER and GAME_ACTIVE then
        if love.keyboard.isDown('up', 'left', 'down', 'right') then
            moveCar() 
        end
        removeEnemies()
        if #enemies < MAX_ENEMIES then
            newEnemies()
        end
        moveEnemies()
        moveShot()
        handleColisions()
        hasPlayerWon()
    end
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end

    if key == 'return' then
        GAME_ACTIVE = not GAME_ACTIVE
    end

    if key == 'space' then
        shooter()
    end
end

function love.draw()
    love.graphics.draw(background, 0,0)
    love.graphics.draw(car.image, car.x, car.y)

    love.graphics.print('PONTUAÇÃO: '..SCORE, 0, 0)
    
    for k,enemy in pairs(enemies) do
        love.graphics.draw(enemy_image, enemy.x, enemy.y)
    end

    for k,shoot in pairs(car.shoots) do
        love.graphics.draw(shoot_img, shoot.x, shoot.y)
    end

    if END_GAME then
        love.graphics.scale(0.5, 0.5);
        love.graphics.draw(gameover_img, SCREEN_WIDTH/2, SCREEN_HEIGHT/2)
    end

    if WINNER then
        songTheme:stop()
        winnerSong:setLooping(false)
        winnerSong:play()
        love.graphics.draw(winner_img, SCREEN_WIDTH/2 - winner_img:getWidth()/2, SCREEN_HEIGHT/2 - winner_img:getHeight()/2)
    end
end