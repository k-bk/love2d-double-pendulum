-------------------
-- CONFIG FILE
-------------------

function love.conf ( t )
    t.window.width = 800
    t.window.height = 600
    t.modules.physics = false
    t.modules.joystick = false
    t.window.title = "Double pendulum"
    t.window.vsync = 1

end
