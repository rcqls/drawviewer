module drawviewer

import ui
import larpon.sgldraw as draw
import sokol.sapp
import sokol.gfx
import sokol.sgl
import gx

type DrawViewerFn = fn (d ui.DrawDevice, dv &DrawViewerComponent)

struct DrawViewerComponent {
pub mut:
	id        string
	layout    &ui.CanvasLayout
	alpha_pip sgl.Pipeline
	pipdesc   C.sg_pipeline_desc
	shapes    []Shape
	// devices
	dsc     &DeviceShapeContext
	dss     &DeviceShapeSVG
	on_draw DrawViewerFn
	// shortcuts
	shortcuts ui.Shortcuts
}

pub struct DrawViewerParams {
	id          string
	bg_color    gx.Color
	shapes      []Shape
	shape_style map[string]draw.Shape
	style       string
	on_draw     DrawViewerFn = DrawViewerFn(0)
}

pub fn drawviewer_canvaslayout(p DrawViewerParams) &ui.CanvasLayout {
	mut layout := ui.canvas_layout(
		id: ui.component_id(p.id, 'layout')
		on_draw: dv_draw
		on_key_down: dv_key_down
		scrollview: true
		full_size_fn: dv_full_size
		bg_color: p.bg_color
	)
	dsc := device_shape_context(
		shape_style: p.shape_style
		style: p.style
	)
	mut dss := device_shape_svg(
		dsc: dsc
	)
	mut dvc := &DrawViewerComponent{
		id: p.id
		layout: layout
		on_draw: p.on_draw
		shapes: p.shapes
		dsc: dsc
		dss: dss
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
	mut dvc := drawviewer_component(c)
	dvc.dsc.dd = c.ui.gg // only in init since ui not yet allocated
	dvc.dss.dd = c.ui.svg

	dvc.pipdesc = dv_init_alpha()
	dvc.alpha_pip = sgl.make_pipeline(&dvc.pipdesc)
}

fn dv_init_alpha() C.sg_pipeline_desc {
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
	return pipdesc
}

fn dv_key_down(e ui.KeyEvent, c &ui.CanvasLayout) {
	mut dv := drawviewer_component(c)
	if e.key == .up && ui.shift_key(e.mods) {
		dv.dss.svg_screenshot_drawviewer('screenshot.svg', dv)
	}
}

fn dv_draw(d ui.DrawDevice, c &ui.CanvasLayout, state voidptr) {
	dvc := drawviewer_component(c)
	// println("dv_draw $c.id $c.x, $c.y $dvc.layout.x, $dvc.layout.y")
	sgl.load_pipeline(dvc.alpha_pip)
	for s in dvc.shapes {
		s.draw(dvc)
	}
	if dvc.on_draw != DrawViewerFn(0) {
		dvc.on_draw(d, dvc)
	}
}

fn dv_full_size(c &ui.CanvasLayout) (int, int) {
	dvc := drawviewer_component(c)
	b := shapes_bounds(dvc.shapes)
	return int(dvc.layout.rel_pos_x(b.x) + b.width), int(dvc.layout.rel_pos_y(b.y) + b.height)
}
