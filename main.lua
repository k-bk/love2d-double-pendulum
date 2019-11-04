local RK = require "RungeKutta"
local UI = require "UI"

function dydt(t, y) 
    local dydt = {}
    local a1, a2, p1, p2 = y.a1, y.a2, y.p1, y.p2
    local sin = math.sin(a1-a2)
    local cos = math.cos(a1-a2)

    local denom = m1 * l^2 * ( 1 + u * sin^2 )
    local A1 = ( p1 * p2 * sin ) / denom
    local A2 = ( p1^2 * u - 2 * p1 * p2 * u * cos + p2^2 * (1 + u) )
             * math.sin(2 * (a1-a2))
             / ( 2 * m1 * l^2 * ( 1 + u * sin^2 )^2 )

    dydt.a1 = ( p1 - p2 * cos ) / denom
    dydt.a2 = ( p2 * (1 + u) - p1 * u * cos ) / denom
    dydt.p1 = -m1 * (1 + u) * g * l * math.sin(a1) - A1 + A2
    dydt.p2 = -m1 * u * g * l * math.sin(a2) + A1 - A2

    return dydt
end

function init ()
    u = initU[1]
    m1 = 1
    m2 = u
    return 
        { a1 = a1[1] / 360 * 2 * math.pi
        , a2 = a2[1] / 360 * 2 * math.pi
        , p1 = 0
        , p2 = 0
        }
end

function findPositions( a1, a2 )
    x1 = x0 + l * scale * math.sin(y.a1)
    x2 = x1 + l * scale * math.sin(y.a2)
    y1 = y0 + l * scale * math.cos(y.a1)
    y2 = y1 + l * scale * math.cos(y.a2)
end

function newCanvas ( canvas )
    return love.graphics.newCanvas( love.graphics.getDimensions() )
end

function love.load ()

    a1 = { 90 }
    a2 = { 90 }
    initSpeed = { 1 }
    initU = { 1 }

    l = 1
    t = 0
    g = 9.80665
    y = init()

    radius = 10
    scale = 100
    x0 = love.graphics.getWidth() * 0.6
    y0 = love.graphics.getHeight() / 2
    last = {}

    startSimulation = function () pause = false end 
    pauseSimulation = function () pause = true end 
    resetSimulation = function () 
        y = init()
        findPositions( a1, a2 )
        last.x2 = x2
        last.y2 = y2
        trace = newCanvas() 
        pause = true
    end

    resetSimulation()

    love.graphics.setBackgroundColor(1,1,1)

end


function love.update ( dt )

    if not pause then
        dt = dt * initSpeed[1]
        t, y = RK.rk4( y, dydt, t, dt )
    end

end

function love.draw ()

    UI.draw { x = 20, y = 20,
        UI.horizontal {
            UI.button( "Start", startSimulation ),
            UI.button( "Pause", pauseSimulation ),
            UI.button( "Reset", resetSimulation ),
        },
        UI.label {"alpha 1"},
        UI.slider( 0, 360, a1 ),
        UI.label {"alpha 2"},
        UI.slider( 0, 360, a2 ),
        UI.label {"mass"},
        UI.slider( 0.1, 3, initU ),
        UI.label {"animation speed"},
        UI.slider( 0.5, 3, initSpeed ),
    }

    local r,g,b,a = love.graphics.getColor()

    findPositions( a1, a2 )

    local newtrace = newCanvas()
    love.graphics.setCanvas(newtrace)
        love.graphics.setColor(0,0,0,0.98)
        love.graphics.draw(trace)
        love.graphics.setColor(0,0,0,1)
        love.graphics.line( last.x2 or x2, last.y2 or y2, x2, y2 )
        trace = newtrace
    love.graphics.setColor(r,g,b,a)

    animation = newCanvas()
    love.graphics.setCanvas(animation)

    last.x2 = x2
    last.y2 = y2

    love.graphics.setColor(.5,.5,.5)
    love.graphics.line( x0, y0, x1, y1 )
    love.graphics.line( x1, y1, x2, y2 )

    local u = initU[1]
    love.graphics.setColor(0.5,0.5,0.5)
    love.graphics.circle( "fill", x0, y0, 5 )
    love.graphics.circle( "fill", x1, y1, radius * 1 )
    love.graphics.setColor(0,0,0)
    love.graphics.circle( "line", x1, y1, radius * 1 )
    love.graphics.setColor(0.5,0.5,0.5)
    love.graphics.circle( "fill", x2, y2, radius * u ^ (1/3) )
    love.graphics.setColor(0,0,0)
    love.graphics.circle( "line", x2, y2, radius * u ^ (1/3) )

    love.graphics.setCanvas()
    love.graphics.draw(trace)
    love.graphics.draw(animation)
    love.graphics.setColor(r,g,b,a)
end

function love.keypressed ( key )
    if key == "escape" then
        love.event.quit()
    end
end

function love.mousepressed ( x, y, button )
    if button == 1 then
        UI.mousepressed {x = x, y = y}
    end
end

function love.mousereleased ( x, y, button )
    if button == 1 then
        UI.mousereleased {x = x, y = y}
    end
end

function love.mousemoved ( x, y )
    UI.mousemoved {x = x, y = y}
end
