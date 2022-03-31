module drawviewer

import ui
import sgldraw as draw
import sokol.sapp
import sokol.gfx
import sokol.sgl
import gx

struct DrawViewerComponent {
mut:
	id        string
	layout    ui.CanvasLayout
	alpha_pip sgl.Pipeline
}

pub struct DrawViewerParams {
	id       string
	bg_color gx.Color
}

pub fn drawviewer_canvaslayout(p DrawViewerParams) &ui.CanvasLayout {
	mut layout := ui.canvas_layout(
		id: ui.component_id(p.id, 'layout')
		on_draw: dv_draw
		bg_color: p.bg_color
	)
	dvc := &DrawViewerComponent{
		id: p.id
		layout: layout
	}
	ui.component_connect(dvc, layout)
	layout.on_init = dv_init
	return layout
}

// component access
pub fn drawviewer_component(w ui.ComponentChild) &DrawViewerComponent {
	return &DrawViewerComponent(w.component)
}

pub fn drawviewer_component_from_id(w ui.Window, id string) &DrawViewerComponent {
	return drawviewer_component(w.canvas_layout(ui.component_id(id, 'layout')))
}

fn dv_init(c &ui.CanvasLayout) {
	desc := sapp.create_desc()
	gfx.setup(&desc)
	sgl_desc := C.sgl_desc_t{
		max_vertices: 50 * 65536
	}
	sgl.setup(&sgl_desc)
	mut pipdesc := C.sg_pipeline_desc{}
	unsafe { C.memset(&pipdesc, 0, sizeof(pipdesc)) }

	color_state := C.sg_color_state{
		blend: C.sg_blend_state{
			enabled: true
			src_factor_rgb: gfx.BlendFactor(C.SG_BLENDFACTOR_SRC_ALPHA)
			dst_factor_rgb: gfx.BlendFactor(C.SG_BLENDFACTOR_ONE_MINUS_SRC_ALPHA)
		}
	}
	pipdesc.colors[0] = color_state
	mut dvc := drawviewer_component(c)
	dvc.alpha_pip = sgl.make_pipeline(&pipdesc)
}

fn dv_draw(c &ui.CanvasLayout, state voidptr) {
	bs := f32(1)
	size_w := f32(100)
	size_h := f32(100)
	dvc := drawviewer_component(c)
	sgl.load_pipeline(dvc.alpha_pip)

	wb := draw.Shape{
		scale: bs
		// connect: .round
	}
	mut wbr := draw.Shape{
		scale: bs
		connect: .round //.miter //.round //.bevel
		radius: 4.5
		colors: draw.Colors{draw.rgba(0, 0, 0, 127), draw.rgba(255, 255, 255, 127)}
	}

	grey_blue := draw.Shape{
		scale: bs
		colors: draw.Colors{draw.rgb(127, 127, 127), draw.rgb(0, 0, 127)}
	}

	thick_line := draw.Shape{
		scale: bs
		radius: 4
		colors: draw.Colors{draw.rgba(0, 127, 25, 127), draw.rgba(0, 127, 25, 127)}
	}

	// dbgf := if a.d.all(.draw) { draw.Fill.debug } else { draw.Fill.invisible }
	dbgf := draw.Fill.debug
	debug_brush := draw.Shape{
		scale: bs
		fill: dbgf
		colors: draw.Colors{draw.rgba(0, 0, 125, 25), draw.rgba(0, 0, 125, 25)}
	}

	arx := f32(0.0)
	ary := f32(0.0)

	grey_blue.rectangle(arx, ary, size_w, size_h)

	wbr.rounded_rectangle(arx * 1.1 + 50, ary * 1.1 + 50, size_w, size_h, 20)

	circle_x := arx * 0.8 + 200
	circle_y := ary * 0.8 + 70
	wbr.colors.solid = draw.rgba(225, 120, 0, 127)
	wbr.circle(circle_x, circle_y, 20, 40)

	wbr.colors.solid = draw.rgba(0, 0, 0, 127)
	wbr.ellipse(arx * 0.8 + 400, ary * 0.8 + 60, 40, 80, 50)

	wbr.arc(600, 500, 50, 0 * draw.deg2rad, 90 * draw.deg2rad)

	wbr.triangle(20, 20, 50, 30, 25, 65)

	wbr.rectangle(100 + arx * 1.1, 400 + ary * 1.1, size_w * 0.5, size_h * 0.5)
	wbr.line(arx + 280, ary + 200, arx + 500, ary + 200 + 200)

	wbr.poly([f32(0), 0, 100, 0, 150, 50, 110, 70, 80, 50, 40, 60, 0, 10], []int{}, arx + 150,
		ary + 100 * 1.1)

	wbr.poly([f32(0), 0, 40, -40, 100, 0, 150, 50, 110, 70, 80, 50, 40, 60, 0, 10 /* h */, 20,
		5, 40, -2, 70, 32, 32, 20], [8], arx + 150, ary + 300)

	wbr.convex_poly([f32(0), 0, 100, 0, 150, 50, 150, 80, 80, 100, 0, 50], arx + 400 * 1.1,
		ary + 400 * 1.1)

	wbr.uniform_segment_poly(800, 500, 60, 5)

	wbr.segment_poly(200, 550, 40, 60, 8)

	thick_line.line(arx + 200, ary + 200, arx + 400, ary + 200 + 200 * ary * 0.051)
	wb.line(arx + 200, ary + 200, arx + 400, ary + 200 + 200 * ary * 0.051)

	thick_line.line(arx + 200, ary + 200, arx + 600, ary + 200)
	wb.line(arx + 200, ary + 200, arx + 600, ary + 200)
}
