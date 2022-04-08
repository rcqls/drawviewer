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
	size_w := f32(100)
	size_h := f32(100)

	arx := f32(0.0)
	ary := f32(0.0)
	circle_x := arx * 0.8 + 200
	circle_y := ary * 0.8 + 70

	window := ui.window(
		width: 1000
		height: 600
		title: 'DrawViewer'
		state: app
		native_message: false
		mode: .resizable
		// on_init: fn(w &ui.Window) {
		// 	dvc := dv.drawviewer_component_from_id(w, "plot")
		// 	mut found, mut sh := dvc.plot("plot")
		// 	println("plot $found")
		// 	found, sh = dvc.plot("plot2")
		// 	println("plot2 $found")
		// }
		children: [
			ui.column(
				heights: [ui.stretch, 3 * ui.stretch]
				children: [ui.rectangle(color: gx.cyan),
					dv.drawviewer_canvaslayout(
					id: 'plot'
					bg_color: gx.rgb(153, 127, 102)
					shapes: [
						dv.plot(
							id: 'plot'
							x: 650
							y: 100
							width: 300
							height: 300
							bg_color: gx.black
							xlim: [-3.0, 3]!
							ylim: [-1.0, 1]!
							shapes: [dv.curve(style: 'thick_line', f: math.sin),
								dv.scatterplot(x: runif(30, -3, 3), y: runif(30, -1, 1), radius: 5)]
						),
						dv.path(
							style: 'thin_line'
							x: [f32(300), 200, 400]
							y: [f32(150), 200, 400]
						),
						dv.rectangle(
							style: 'grey_blue'
							x: arx
							y: ary
							width: size_w
							height: size_h
						),
						dv.rounded_rectangle(
							style: 'wbr'
							x: arx * 1.1 + 50
							y: ary * 1.1 + 50
							width: size_w
							height: size_h
							radius: 20
						),
						dv.circle(style: 'wb', x: circle_x, y: circle_y, radius: 20),
						dv.ellipse(x: arx * 0.8 + 400, y: ary * 0.8 + 60, radius_x: 40, radius_y: 80),
						dv.arc(x: 600, y: 500, radius: 50, start_angle: 45, angle: 90),
						dv.triangle(x1: 20, y1: 20, x2: 50, y2: 30, x3: 25, y3: 65),
						dv.rectangle(
							x: 100 + arx * 1.1
							y: 400 + ary * 1.1
							width: size_w * 0.5
							height: size_h * 0.5
						),
						dv.line(x1: arx + 280, y1: ary + 200, x2: arx + 500, y2: ary + 200 + 200),
						dv.poly(
							points: [f32(0), 0, 100, 0, 150, 50, 110, 70, 80, 50, 40, 60, 0, 10]
							offset_x: arx + 150
							offset_y: ary + 100 * 1.1
						),
						dv.poly(
							points: [f32(0), 0, 40, -40, 100, 0, 150, 50, 110, 70, 80, 50, 40,
								60, 0, 10, 20, 5, 40, -2, 70, 32, 32, 20]
							holes: [8]
							offset_x: arx + 150
							offset_y: ary + 300
						),
						dv.convex_poly(
							points: [f32(0), 0, 100, 0, 150, 50, 150, 80, 80, 100, 0, 50]
							offset_x: arx + 400 * 1.1
							offset_y: ary + 400 * 1.1
						),
						dv.uniform_segment_poly(x: 800, y: 500, radius: 60, steps: 5),
						dv.segment_poly(x: 200, y: 550, radius_x: 40, radius_y: 60, steps: 8),
						dv.lines(
							style: 'thick_line'
							x1: [arx + 500, arx + 300]
							y1: [ary + 500, ary + 300]
							x2: [arx + 400].repeat(2)
							y2: [ary + 200 + 200 * ary * 0.051].repeat(2)
						),
						dv.line(
							style: 'thick_line'
							x1: arx + 200
							y1: ary + 200
							x2: arx + 600
							y2: ary + 200
						),
						dv.line(
							style: 'wb'
							x1: arx + 200
							y1: ary + 200
							x2: arx + 600
							y2: ary + 200
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
