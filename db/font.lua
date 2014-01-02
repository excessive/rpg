local small, medium, large = 12, 16, 20

FontDB = {
	roboto = {
		small = {
			regular 	= love.graphics.newFont("assets/fonts/roboto-regular.ttf", small),
			condensed	= love.graphics.newFont("assets/fonts/roboto-condensed.ttf", small),
			bold		= love.graphics.newFont("assets/fonts/roboto-bold.ttf", small),
			medium		= love.graphics.newFont("assets/fonts/roboto-medium.ttf", small),
			light		= love.graphics.newFont("assets/fonts/roboto-light.ttf", small),
			thin		= love.graphics.newFont("assets/fonts/roboto-thin.ttf", small),
		},
		medium = {
			regular 	= love.graphics.newFont("assets/fonts/roboto-regular.ttf", medium),
			condensed	= love.graphics.newFont("assets/fonts/roboto-condensed.ttf", medium),
			bold		= love.graphics.newFont("assets/fonts/roboto-bold.ttf", medium),
			medium		= love.graphics.newFont("assets/fonts/roboto-medium.ttf", medium),
			light		= love.graphics.newFont("assets/fonts/roboto-light.ttf", medium),
			thin		= love.graphics.newFont("assets/fonts/roboto-thin.ttf", medium),
		},
		large = {
			regular 	= love.graphics.newFont("assets/fonts/roboto-regular.ttf", large),
			condensed	= love.graphics.newFont("assets/fonts/roboto-condensed.ttf", large),
			bold		= love.graphics.newFont("assets/fonts/roboto-bold.ttf", large),
			medium		= love.graphics.newFont("assets/fonts/roboto-medium.ttf", large),
			light		= love.graphics.newFont("assets/fonts/roboto-light.ttf", large),
			thin		= love.graphics.newFont("assets/fonts/roboto-thin.ttf", large),
		}
	}
}
