import drawviewer as dv
import larpon.sgldraw as draw
import ui
import gx
import math
import rand

struct App {
mut:
	window &ui.Window
}

fn main() {
	mut app := &App{
		window: 0
	}

	window := ui.window(
		width: 1000
		height: 600
		title: 'DrawViewer'
		state: app
		native_message: false
		mode: .resizable
		children: [
			ui.column(
				heights: [ui.stretch, 9 * ui.stretch]
				children: [ui.rectangle(color: gx.cyan),
					dv.drawviewer_canvaslayout(
					id: 'plot'
					bg_color: gx.rgb(153, 127, 102)
					shapes: [
						dv.plot(
							id: 'plot'
							x: 50
							y: 50
							width: 800
							height: 500
							bg_color: gx.black
							xlim: [-3.0, 3]!
							ylim: [-1.0, 1]!
							shapes: [dv.curve(style: 'thick_line', f: math.sin),
								dv.scatterplot(x: runif(30, -3, 3), y: runif(30, -1, 1), radius: 5)]
						),
					]
					style: 'wbr'
					shape_style: {
						'wb':         draw.Shape{
							connect: .bevel
							cap: .square
							colors: draw.Colors{draw.rgba(0, 0, 0, 127), draw.rgba(255,
								255, 255, 127)}
						}
						'wbr':        draw.Shape{
							// fill: .outline
							connect: .round //.miter //.round //.bevel
							radius: 4.5
							colors: draw.Colors{draw.rgba(0, 0, 0, 127), draw.rgba(255,
								255, 255, 127)}
						}
						'grey_blue':  draw.Shape{
							colors: draw.Colors{draw.rgb(127, 127, 127), draw.rgb(0, 0,
								127)}
						}
						'thick_line': draw.Shape{
							radius: 3
							colors: draw.Colors{draw.rgba(0, 127, 25, 127), draw.rgba(0,
								127, 25, 127)}
						}
						'thin_line':  draw.Shape{
							radius: 1.1
							colors: draw.Colors{draw.rgba(0, 127, 25, 127), draw.rgba(0,
								127, 25, 127)}
						}
					}
				)]
			),
		]
	)
	app.window = window
	ui.run(window)
}

fn runif(n int, from f32, to f32) []f32 {
	mut r := [from + rand.f32() * (to - from)]
	for _ in 0 .. (n - 1) {
		r << from + rand.f32() * (to - from)
	}
	return r
}
