function love.conf(t)
	t.version = "0.9.0"
	t.identity = "GrinD"
	t.window.icon = "assets/icon.png"
	t.window.title = "UI Test"
	t.window.width = 1280
	t.window.height = 720
	t.window.resizable = true
	t.window.fullscreen = false
	t.window.fullscreentype = "desktop"

	t.modules.event		= true
	t.modules.keyboard	= true
	t.modules.mouse		= true
	t.modules.timer		= true
	t.modules.joystick	= true
	t.modules.image		= true
	t.modules.graphics	= true
	t.modules.audio		= true
	t.modules.math		= true
	t.modules.physics	= false -- we don't use Box2D at all
	t.modules.sound		= true
	t.modules.system	= true
	t.modules.font		= true
	t.modules.thread	= true
	t.modules.window	= true
end