module drawviewer

import ui
import larpon.sgldraw as draw
import sokol.sapp
import sokol.gfx
import sokol.sgl
import gx

type DrawViewerFn = fn (dv &DrawViewerComponent)

struct DrawViewerComponent {
pub mut:
	id            string
	layout        &ui.CanvasLayout
	alpha_pip     sgl.Pipeline
	pipdesc       C.sg_pipeline_desc
	shapes        []Shape
	current_style string
	shape_style   map[string]draw.Shape
	on_draw       DrawViewerFn
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
		scrollview: true
		full_size_fn: dv_full_size
		bg_color: p.bg_color
	)
	mut dvc := &DrawViewerComponent{
		id: p.id
		layout: layout
		on_draw: p.on_draw
		shape_style: p.shape_style
		shapes: p.shapes
		current_style: p.style
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

fn dv_draw(c &ui.CanvasLayout, state voidptr) {
	dvc := drawviewer_component(c)
	// println("dv_draw $c.id $c.x, $c.y $dvc.layout.x, $dvc.layout.y")
	sgl.load_pipeline(dvc.alpha_pip)
	for s in dvc.shapes {
		s.draw(dvc)
	}
	if dvc.on_draw != DrawViewerFn(0) {
		dvc.on_draw(dvc)
	}
}

fn dv_full_size(c &ui.CanvasLayout) (int, int) {
	dvc := drawviewer_component(c)
	b := shapes_bounds(dvc.shapes)
	return int(dvc.layout.rel_pos_x(b.x) + b.width), int(dvc.layout.rel_pos_y(b.y) + b.height)
}

pub fn (mut dv DrawViewerComponent) set_style(style string) {
	dv.current_style = style
}

pub fn (dv &DrawViewerComponent) shape_style(style string) draw.Shape {
	return dv.shape_style[if style == '' {
		dv.current_style
	} else {
		style
	}]
}

pub fn (mut dv DrawViewerComponent) add_shape_style(style string, shape_style draw.Shape) {
	dv.shape_style[style] = shape_style
}
