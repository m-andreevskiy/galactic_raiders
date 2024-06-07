package main

import "core:fmt"
import "core:math/rand"
import rl "vendor:raylib"
// import "vendor:raylib"





WINDOW_WIDTH : i32 = 1024
WINDOW_HEIGHT : i32 = 768

// #define MAX_SOUNDS 10
MAX_SOUNDS :: 10
// Sound deathSoundArray[MAX_SOUNDS] = { 0 }
deathSoundArray : [MAX_SOUNDS]rl.Sound
currentDeathSound: i32


NUMBER_OF_ENEMIES : i32 = 24

GameState :: struct {
    numberOfEnemies : i32
}

gameState : GameState = {NUMBER_OF_ENEMIES}


Vector2 :: struct {
    x : f32,
    y : f32,
}

Bullet :: struct {
    position : Vector2,
    velocity : f32,
    sprite : rl.Texture2D,
    visible : bool,
    // rec : rl.Rectangle,
}

DEFAULT_BULLET_SPEED : f32 = 200

GLOBAL_PLAYER_BULLETS : [dynamic]Bullet
GLOBAL_ENEMY_BULLETS : [dynamic]Bullet

randomGenerator := rand.create(1)

// shoot :: proc(x: f32, y: f32) {
shoot :: proc(position: Vector2, velocity: f32, sprite: rl.Texture2D) {
    bullet := Bullet{position, velocity, sprite, true}
    append(&GLOBAL_PLAYER_BULLETS, bullet)
}

enemyShoot :: proc(position: Vector2, velocity: f32, sprite: rl.Texture2D) {
    bullet := Bullet{position, velocity, sprite, true}
    append(&GLOBAL_ENEMY_BULLETS, bullet)
}





Enemy :: struct {
    position : Vector2,
    velocity : f32,
    sprite : rl.Texture2D,
    reward : i32,
    visible : bool,
}

initEnemies :: proc(enemies: ^[dynamic]Enemy, num: i32) {
    gameState.numberOfEnemies = num
    sprite := rl.LoadTexture("resources/img/enemy.png")
    defaultVelocity : f32 = 50
    defaultReward : i32 = 10

    enemiesInRow : i32 = 8
    numRows := num / enemiesInRow
    startPos : Vector2 = {f32(WINDOW_WIDTH/4), f32(WINDOW_HEIGHT/8)}
    currentPos := startPos

    for i:i32 = 0; i < (numRows); i += 1 {
        for j:i32 = 0; j < enemiesInRow; j += 1 {
            append(enemies, Enemy{{startPos.x + f32(j * sprite.width * 2), startPos.y + f32(i * sprite.height*2)}, defaultVelocity, sprite, defaultReward, true})
        }
    }

    // last row
    for i:i32 = 0; i < (num % enemiesInRow); i += 1 {
        append(enemies, Enemy{{startPos.x + f32(i * sprite.width * 2), startPos.y + f32(numRows * sprite.width * 2)}, defaultVelocity, sprite, defaultReward, true})
    }
}

drawEnemies :: proc(enemies: [dynamic]Enemy) {
    // for i := 0; i < len(enemies); i += 1 {
    for enemy in enemies{
        if enemy.visible{
            drawTextureCentered(enemy.sprite, enemy.position)
        }
    }
}

moveEnemies :: proc(enemies: [dynamic]Enemy) {
    for i := 0; i < len(enemies); i += 1 {
        if enemies[i].position.x < 0 + f32(enemies[i].sprite.width) || enemies[i].position.x > f32(WINDOW_WIDTH) - f32(enemies[i].sprite.width) {
            enemies[i].velocity *= -1
        }
        enemies[i].position.x += enemies[i].velocity * rl.GetFrameTime()
    }
}

enemiesShoot :: proc(enemies: [dynamic]Enemy, randomGenerator: rand.Rand, bulletSprite: rl.Texture2D) {
    number: u32
    for enemy in enemies{
        if !enemy.visible{
            continue
        }
        number = rand.uint32() % 600    // huge kostyl'
        if number > 598 {
            enemyShoot(enemy.position, DEFAULT_BULLET_SPEED, bulletSprite)
        }
    }
    
}


Player :: struct {
    position : Vector2,
    sprite : rl.Texture2D,
    velocity : f32,
    leaves : int,
}

initPlayer :: proc (player: ^Player) {
    player^.position = {f32(WINDOW_WIDTH) / 2, f32(WINDOW_HEIGHT) - f32(WINDOW_HEIGHT) / 7}
    player^.sprite = rl.LoadTexture("resources/img/spacecraft_sprite.png")
    player^.velocity = 100
    player.leaves = 3
}

drawTextureCentered :: proc (sprite: rl.Texture2D, pos: Vector2) {
    rl.DrawTexture(sprite, i32(pos.x) - i32(sprite.width/2), i32(pos.y) - i32(sprite.height/2), rl.WHITE)
}

drawTextureCenteredEx :: proc (sprite: rl.Texture2D, pos: Vector2, scale: f32) {
    rl.DrawTextureEx(sprite, {(pos.x) - f32(sprite.width/2), (pos.y) - f32(sprite.height/2)}, 0, scale, rl.WHITE)
}




spritesOverlap :: proc(s1, s2: rl.Texture2D, p1, p2 : Vector2) -> bool {
    // if p1.x + s1.width > p2 - s2.width && p1.x + s1.width < p2 + s2.width{

    // }

    if abs(p1.x - p2.x) < f32(s1.width/2 + s2.width/2) {
        if abs(p1.y - p2.y) < f32(s1.height/2 + s2.height/2) {
            return true
        }
    } 
    return false
}

enemyDie :: proc(enemy: Enemy){

}



checkEnemyDeath :: proc(enemies: ^[dynamic]Enemy, bulletArray: ^[dynamic]Bullet) {
    bulletRectangle : rl.Rectangle
    // enemyRadius : f32
    enemyRadius : f32 = 15
    enemiesToKill : [dynamic]int
    for i := 0; i < len(enemies); i += 1 {
    // for enemy in enemies {

        if !enemies[i].visible{
            continue
        }

        for bullet in bulletArray {
            if !bullet.visible{
                continue
            }

            // bulletRectangle = rl.Rectangle{bullet.position.x, bullet.position.y, f32(bullet.sprite.width), f32(bullet.sprite.height)}
            bulletRectangle = rl.Rectangle{bullet.position.x - f32(bullet.sprite.width)/2, bullet.position.y - f32(bullet.sprite.height)/2, f32(bullet.sprite.width), f32(bullet.sprite.height)}

            // if spritesOverlap(bullet.sprite, enemies[i].sprite, bullet.position, enemies[i].position) {
            // if rl.CheckCollisionCircleRec({enemies[i].position.x + f32(enemies[i].sprite.width/2), enemies[i].position.y + f32(enemies[i].sprite.height/2)}, enemyRadius, bulletRectangle) {
            if rl.CheckCollisionCircleRec({enemies[i].position.x, enemies[i].position.y}, enemyRadius, bulletRectangle) {
                fmt.println("gonna kill sb")
                // append(&enemiesToKill, i)
                // unordered_remove(enemies, i)
                bullet.visible = false
                enemies[i].visible = false
                gameState.numberOfEnemies -= 1

                // sound
                // rl.PlaySound(deathSound)
                rl.PlaySound(deathSoundArray[currentDeathSound])
                currentDeathSound += 1
                if currentDeathSound >= len(deathSoundArray) {
                    currentDeathSound = 0
                }
            }
        }
    } 

    if len(enemiesToKill) > 0{
        fmt.println(len(enemiesToKill))
        fmt.println("[0] = ", enemiesToKill[0])

    }
    
    for i := len(enemiesToKill)-1; i >= 0; i -= 1 {
        ordered_remove(enemies, i)
    }

}


checkFenceDamage :: proc(fenceArray: ^[dynamic]Fence, bulletArray: ^[dynamic]Bullet) {
    for fence in fenceArray {
        if fence.lives > 0{
            for bullet in bulletArray {
                if bullet.visible{
                    // bulletRectangle := rl.Rectangle{bullet.position.x - f32(bullet.sprite.width)/2, bullet.position.y - f32(bullet.sprite.height)/2, f32(bullet.sprite.width), f32(bullet.sprite.height)}
                    // fenceRectangle := rl.Rectangle{fence.position.x - f32(fence.sprite.width)/2, fence.position.y - f32(fence.sprite.height), f32(fence.sprite.width), f32(fence.sprite.height)}
                    if spritesOverlap(fence.sprite, bullet.sprite, fence.position, bullet.position){
                    // if spritesOverlap(fence.sprite, bullet.sprite, fence.position - {f32(fence.sprite.width/2), f32(fence.sprite.height/2)}, bullet.position - {f32(bullet.sprite.width/2), f32(bullet.sprite.height/2)}){
                    // if spritesOverlap(fence.sprite, bullet.sprite, Vector2{fence.position.x - f32(fence.sprite.width/2), fence.position.x - f32(fence.sprite.height/2)}, Vector2{bullet.position.x - f32(bullet.sprite.width/2), bullet.position.x - f32(bullet.sprite.height/2)}){
                    // if rl.CheckCollisionRecs(bulletRectangle, fenceRectangle){
                        fence.lives -= 1
                        fence.sprite.width = i32(fence.sprite.width * 8/10)
                        fence.sprite.height = i32(fence.sprite.height * 8/10)
                        bullet.visible = false
                    }
                }
            }
        }
        
    }
}



checkPlayerDamage :: proc(player: ^Player) {
    if player.leaves <= 0 {
        rl.DrawText("wasted", WINDOW_WIDTH/2 - 60, WINDOW_HEIGHT/2 - 30, 30,rl.RED)
    }

    for &bullet in GLOBAL_ENEMY_BULLETS {
        if bullet.visible {
            if spritesOverlap(player.sprite, bullet.sprite, player.position, bullet.position){
                bullet.visible = false
                player.leaves -= 1
            }
            if player.leaves <= 0 {
                rl.DrawText("wasted", WINDOW_WIDTH/2 - 60, WINDOW_HEIGHT/2 - 30, 30,rl.RED)
            }
        }
    }
}


clearCorpses :: proc(enemies: [dynamic]Enemy) {
    for i := 0; i < len(enemies); i += 1 {
        if !enemies[i].visible {

        }
    }
}




Fence :: struct {
    lives: i32,
    position: Vector2,
    sprite: rl.Texture2D,
}


initFence :: proc(fenceArray: ^[dynamic]Fence, num: i32){
    // fenceArray : [dynamic]Fence
    fenceSprite := rl.LoadTexture("resources/img/fence.png")

    for i :i32 = 0; i < num; i += 1 {
        append(fenceArray, Fence{3, {f32(WINDOW_WIDTH/8) + f32(i * fenceSprite.width * 2), f32(WINDOW_HEIGHT) - f32(WINDOW_HEIGHT) / 3}, fenceSprite})
    }

    // return fenceArray
}

drawFence :: proc(fenceArray: [dynamic]Fence){
    for fence in fenceArray {
        if fence.lives > 0 {
            drawTextureCentered(fence.sprite, fence.position)
            // rl.DrawRectangle(i32(fence.position.x - f32(fence.sprite.width)/2), i32(fence.position.y - f32(fence.sprite.height)/2), fence.sprite.width, fence.sprite.height, rl.WHITE)
        }
    }
}


drawBullets :: proc() {
    for bullet in GLOBAL_PLAYER_BULLETS{
        if bullet.visible{
            drawTextureCentered(bullet.sprite, bullet.position)
        }
    }


    for bullet in GLOBAL_ENEMY_BULLETS{
        if bullet.visible{
            drawTextureCentered(bullet.sprite, bullet.position)
        }
    }
}


moveBullets :: proc() {
    for i := 0; i < len(GLOBAL_PLAYER_BULLETS); i += 1 {
        GLOBAL_PLAYER_BULLETS[i].position.y += rl.GetFrameTime() * GLOBAL_PLAYER_BULLETS[i].velocity
    }

    for &bullet in GLOBAL_ENEMY_BULLETS{
        bullet.position.y += rl.GetFrameTime() * bullet.velocity
    }
}



initAll :: proc(player: ^Player, enemies : ^[dynamic]Enemy, fenceArray : ^[dynamic]Fence) {
    initPlayer(player)
    initEnemies(enemies, 24)
    initFence(fenceArray, 5)
}



main :: proc() {
    fmt.println("entered 'main'")

    rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Хочу играть на пианино   :..{")
    // if window wasn't created ...

    defer rl.CloseWindow()

    rl.SetTargetFPS(60)

    rl.InitAudioDevice()
    if !rl.IsAudioDeviceReady() {
        fmt.println("no sound, sry")
    }
    defer rl.CloseAudioDevice()

    backgroundMusic := rl.LoadMusicStream("resources/audio/Irish_music.mp3")
    rl.PlayMusicStream(backgroundMusic)
    defer rl.StopMusicStream(backgroundMusic)


    // deathSound : rl.Sound = rl.LoadSound("resources/audio/stormtrooper-death.mp3")
    deathSoundArray[0] = rl.LoadSound("resources/audio/stormtrooper-death.mp3")
    
    for i := 1; i < len(deathSoundArray); i += 1 {
        deathSoundArray[i] = rl.LoadSoundAlias(deathSoundArray[0])        // Load an alias of the sound into slots 1-9. These do not own the sound data, but can be played
    }
    currentDeathSound = 0 
    // defer rl.UnloadSound(deathSound)
    defer {
        for i := 1; i < len(deathSoundArray); i += 1 {
            rl.UnloadSound(deathSoundArray[i])
        }
    }

    playerBulletSprite := rl.LoadTexture("resources/img/bullet.png")
    enemyBulletSprite := rl.LoadTexture("resources/img/bullet_enemy.png")
    leafSprite := rl.LoadTexture("resources/img/leaf.png")
    leafSprite.width = leafSprite.width / 14
    leafSprite.height = leafSprite.height / 14
    
    defer rl.UnloadTexture(playerBulletSprite)
    defer rl.UnloadTexture(enemyBulletSprite)
    defer rl.UnloadTexture(leafSprite)

    leafPos : Vector2
    player : Player
    initPlayer(&player)

    enemies : [dynamic]Enemy
    initEnemies(&enemies, NUMBER_OF_ENEMIES)
    
    fenceArray : [dynamic]Fence
    // fenceArray = initFence(5)
    initFence(&fenceArray, 5)
    defer {
        for fence in fenceArray {
            rl.UnloadTexture(fence.sprite)
        }
    }

    

    for (!rl.WindowShouldClose()){
        rl.UpdateMusicStream(backgroundMusic)

        rl.BeginDrawing()

            // rl.ClearBackground(rl.RAYWHITE)
            rl.ClearBackground(rl.Color{83, 55, 122, 255})
            // rl.DrawCircle(i32(player.position.x), i32(player.position.y), 10, rl.RED)
            drawTextureCentered(player.sprite, player.position)
            // rl.DrawCircle(i32(player.position.x), i32(player.position.y), 10, rl.RED)


            drawEnemies(enemies)
            drawFence(fenceArray)



            // draw bullets
            drawBullets()

            // draw leaves
            leafPos = Vector2{50, f32(WINDOW_HEIGHT) - 50}
            for i := 0; i < player.leaves; i += 1 {
                drawTextureCentered(leafSprite, leafPos)
                leafPos.x += f32(leafSprite.width) + 10
            }
            
            
        // rl.EndMode2D()
        rl.EndDrawing()


        if player.leaves <= 0 {
            rl.DrawText("wasted\n\npress R to restart", WINDOW_WIDTH/2 - 60, WINDOW_HEIGHT/2 - 30, 30, rl.RED)
            for len(enemies) != 0 {
                pop(&enemies)
            }
            for len(fenceArray) != 0 {
                pop(&fenceArray)
            }
        }
        else if gameState.numberOfEnemies <= 0 {
            rl.DrawText("gained\n\npress R to restart", WINDOW_WIDTH/2 - 60, WINDOW_HEIGHT/2 - 30, 30, rl.WHITE)
            for len(enemies) != 0 {
                pop(&enemies)
            }
            for len(fenceArray) != 0 {
                pop(&fenceArray)
            }
        }

        checkPlayerDamage(&player)

        // move bullets
        moveBullets()

        moveEnemies(enemies)
        enemiesShoot(enemies, randomGenerator, enemyBulletSprite)

        checkEnemyDeath(&enemies, &GLOBAL_PLAYER_BULLETS)
        checkFenceDamage(&fenceArray, &GLOBAL_PLAYER_BULLETS)
        checkFenceDamage(&fenceArray, &GLOBAL_ENEMY_BULLETS)


        // if rl.IsKeyDown(rl.KeyboardKey.SPACE) {
        //     shoot(playerPosX, playerPosY)
        // }
        #partial switch rl.GetKeyPressed() {
            case rl.KeyboardKey.SPACE:
                shoot(player.position, -DEFAULT_BULLET_SPEED, playerBulletSprite)
            
            case rl.KeyboardKey.R:
                if player.leaves <= 0 || gameState.numberOfEnemies <= 0{
                    initAll(&player, &enemies, &fenceArray)
                    // rl.DrawText("restarted", WINDOW_WIDTH/4, WINDOW_HEIGHT/4, 30, rl.WHITE)
                }
        }


        if rl.IsKeyDown(rl.KeyboardKey.LEFT) {
            player.position.x -= rl.GetFrameTime() * player.velocity

        }
        if rl.IsKeyDown(rl.KeyboardKey.RIGHT) {
            player.position.x += rl.GetFrameTime() * player.velocity

        }
        // if rl.IsKeyDown(rl.KeyboardKey.UP) {
        //     playerPosY -= rl.GetFrameTime() * playerVelY

        // }
        // if rl.IsKeyDown(rl.KeyboardKey.DOWN) {
        //     playerPosY += rl.GetFrameTime() * playerVelY

        // }




        // #partial switch rl.GetKeyPressed() {
        //     case rl.KeyboardKey.LEFT:
        //         playerPosX -= rl.GetFrameTime() * playerVelX

        //     case rl.KeyboardKey.RIGHT:
        //         playerPosX += rl.GetFrameTime() * playerVelX
            
        //     case rl.KeyboardKey.UP:
        //         playerPosY -= rl.GetFrameTime() * playerVelY
                
        //     case:
        //         continue
        // }

        
        // playerPosX += rl.GetFrameTime() * playerVelX

    }


    

}