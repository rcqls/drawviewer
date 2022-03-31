module drawviewer

import ui
import sgldraw as draw
import sokol.sapp
import sokol.gfx
import sokol.sgl
import gx

type DrawViewerFn = fn (dv &DrawViewerComponent)

struct DrawViewerComponent {
pub mut:
	id        string
	layout    ui.CanvasLayout
	alpha_pip sgl.Pipeline
	pipdesc   C.sg_pipeline_desc
	shapes    map[string]draw.Shape
	on_draw   DrawViewerFn
}

pub struct DrawViewerParams {
	id       string
	bg_color gx.Color
	shapes   map[string]draw.Shape
	on_draw  DrawViewerFn = DrawViewerFn(0)
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
		on_draw: p.on_draw
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
	sgl.load_pipeline(dvc.alpha_pip)
	if dvc.on_draw != DrawViewerFn(0) {
		dvc.on_draw(dvc)
	}
}

// drawing shapes

pub fn (dv &DrawViewerComponent) rectangle(shape string, x f32, y f32, w f32, h f32) {
	dv.shapes[shape].rectangle(x, y, w, h)
}

pub fn (dv &DrawViewerComponent) rounded_rectangle(shape string, x f32, y f32, w f32, h f32, radius f32) {
	dv.shapes[shape].rounded_rectangle(x, y, w, h, radius)
}

pub fn (dv &DrawViewerComponent) line(shape string, x1 f32, y1 f32, x2 f32, y2 f32) {
	dv.shapes[shape].line(x1, y1, x2, y2)
}

pub fn (dv &DrawViewerComponent) poly(shape string, points []f32, holes []int, offset_x f32, offset_y f32) {
	dv.shapes[shape].poly(points, holes, offset_x, offset_y)
}

pub fn (dv &DrawViewerComponent) uniform_segment_poly(shape string, x f32, y f32, radius f32, steps u32) {
	dv.shapes[shape].uniform_segment_poly(x, y, radius, steps)
}

pub fn (dv &DrawViewerComponent) segment_poly(shape string, x f32, y f32, radius_x f32, radius_y f32, steps u32) {
	dv.shapes[shape].segment_poly(x, y, radius_x, radius_y, steps)
}

// fn (b Shape) uniform_line_segment_poly(x f32, y f32, radius f32, steps u32)

// fn (b Shape) line_segment_poly(x f32, y f32, radius_x f32, radius_y f32, steps u32)

// pub fn (b Shape) circle(x f32, y f32, radius f32, steps u32)

// pub fn (b Shape) ellipse(x f32, y f32, radius_x f32, radius_y f32, steps u32)

// pub fn (b Shape) convex_poly(points []f32, offset_x f32, offset_y f32)

// pub fn (b Shape) arc(x f32, y f32, radius f32, start_angle_in_rad f32, angle_in_rad f32)

// pub fn (b Shape) triangle(x1 f32, y1 f32, x2 f32, y2 f32, x3 f32, y3 f32)

// pub fn (b Shape) image(x f32, y f32, w f32, h f32, path string)
