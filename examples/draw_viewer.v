import drawviewer as dv
import ui
import gx
import sgldraw as draw
import sokol.sgl

struct App {
mut:
	window &ui.Window
}

fn main() {
	mut app := &App{
		window: 0
	}
	window := ui.window(
		width: 800
		height: 600
		title: 'DrawViewer'
		state: app
		native_message: false
		children: [
			ui.column(
				heights: [ui.compact, ui.compact]
				children: [
					// ui.rectangle(color: gx.cyan)
					dv.drawviewer_canvaslayout(
					id: 'plot'
					bg_color: gx.rgb(153, 127, 102)
					on_draw: on_draw
					shapes: {
						'wb':         draw.Shape{
							scale: f32(1)
							// connect: .round
						}
						'wbr':        draw.Shape{
							scale: f32(1)
							connect: .round //.miter //.round //.bevel
							radius: 4.5
							colors: draw.Colors{draw.rgba(0, 0, 0, 127), draw.rgba(255,
								255, 255, 127)}
						}
						'grey_blue':  draw.Shape{
							scale: f32(1)
							colors: draw.Colors{draw.rgb(127, 127, 127), draw.rgb(0, 0,
								127)}
						}
						'thick_line': draw.Shape{
							scale: f32(1)
							radius: 4
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

fn on_draw(dvc &dv.DrawViewerComponent) {
	sgl.load_pipeline(dvc.alpha_pip)
	// bs := f32(1)
	size_w := f32(100)
	size_h := f32(100)

	arx := f32(0.0)
	ary := f32(0.0)

	dvc.rectangle('grey_blue', arx, ary, size_w, size_h)

	dvc.rounded_rectangle('wbr', arx * 1.1 + 50, ary * 1.1 + 50, size_w, size_h, 20)

	circle_x := arx * 0.8 + 200
	circle_y := ary * 0.8 + 70
	// wbr.colors.solid = draw.rgba(225, 120, 0, 127)
	// wbr.circle(circle_x, circle_y, 20, 40)

	// wbr.colors.solid = draw.rgba(0, 0, 0, 127)
	// wbr.ellipse(arx * 0.8 + 400, ary * 0.8 + 60, 40, 80, 50)

	// wbr.arc(600, 500, 50, 0 * draw.deg2rad, 90 * draw.deg2rad)

	// wbr.triangle(20, 20, 50, 30, 25, 65)

	//
	dvc.shapes['wbr'].rectangle(100 + arx * 1.1, 400 + ary * 1.1, size_w * 0.5, size_h * 0.5)
	dvc.line('wbr', arx + 280, ary + 200, arx + 500, ary + 200 + 200)

	dvc.poly('wbr', [f32(0), 0, 100, 0, 150, 50, 110, 70, 80, 50, 40, 60, 0, 10], []int{},
		arx + 150, ary + 100 * 1.1)

	dvc.poly('wbr', [f32(0), 0, 40, -40, 100, 0, 150, 50, 110, 70, 80, 50, 40, 60, 0, 10 /* h */,
		20, 5, 40, -2, 70, 32, 32, 20], [8], arx + 150, ary + 300)

	// wbr.convex_poly([f32(0), 0, 100, 0, 150, 50, 150, 80, 80, 100, 0, 50], arx + 400 * 1.1,
	// 	ary + 400 * 1.1)

	dvc.uniform_segment_poly('wbr', 800, 500, 60, 5)

	dvc.segment_poly('wbr', 200, 550, 40, 60, 8)

	dvc.line('thick_line', arx + 200, ary + 200, arx + 400, ary + 200 + 200 * ary * 0.051)
	dvc.line('wb', arx + 200, ary + 200, arx + 400, ary + 200 + 200 * ary * 0.051)

	dvc.line('thick_line', arx + 200, ary + 200, arx + 600, ary + 200)
	dvc.line('wb', arx + 200, ary + 200, arx + 600, ary + 200)
}
