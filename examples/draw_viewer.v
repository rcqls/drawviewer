import drawviewer as dv
import ui
import gx

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
					dv.drawviewer_canvaslayout(id: 'plot', bg_color: gx.rgb(153,
					127, 102))]
			),
		]
	)
	app.window = window
	ui.run(window)
}
