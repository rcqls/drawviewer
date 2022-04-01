module drawviewer

import ui
import sgldraw as draw
import sokol.sapp
import sokol.gfx
import sokol.sgl
import gx
import gg

type DrawViewerFn = fn (dv &DrawViewerComponent)

struct DrawViewerComponent {
pub mut:
	id          string
	layout      &ui.CanvasLayout
	alpha_pip   sgl.Pipeline
	pipdesc     C.sg_pipeline_desc
	shapes      []Shape
	shape_style map[string]draw.Shape
	on_draw     DrawViewerFn
}

pub struct DrawViewerParams {
	id          string
	bg_color    gx.Color
	shapes      []Shape
	shape_style map[string]draw.Shape
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
	dvc := &DrawViewerComponent{
		id: p.id
		layout: layout
		on_draw: p.on_draw
		shape_style: p.shape_style
		shapes: p.shapes
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
	return int(b.x + b.width), int(b.y + b.height)
}

// // drawing shapes

// pub fn (dv &DrawViewerComponent) rectangle(shape string, x f32, y f32, w f32, h f32) {
// 	dv.shapes[shape].rectangle(dv.layout.rel_pos_x(x), dv.layout.rel_pos_y(y), w, h)
// }

// pub fn (dv &DrawViewerComponent) rounded_rectangle(shape string, x f32, y f32, w f32, h f32, radius f32) {
// 	dv.shapes[shape].rounded_rectangle(dv.layout.rel_pos_x(x), dv.layout.rel_pos_y(y), w, h, radius)
// }

// pub fn (dv &DrawViewerComponent) line(shape string, x1 f32, y1 f32, x2 f32, y2 f32) {
// 	dv.shapes[shape].line(dv.layout.rel_pos_x(x1), dv.layout.rel_pos_y(y1), dv.layout.rel_pos_x(x2), dv.layout.rel_pos_y(y2))
// }

// pub fn (dv &DrawViewerComponent) poly(shape string, points []f32, holes []int, offset_x f32, offset_y f32) {
// 	dv.shapes[shape].poly(points, holes, dv.layout.rel_pos_x(offset_x), dv.layout.rel_pos_y(offset_y))
// }

// pub fn (dv &DrawViewerComponent) uniform_segment_poly(shape string, x f32, y f32, radius f32, steps u32) {
// 	dv.shapes[shape].uniform_segment_poly(dv.layout.rel_pos_x(x), dv.layout.rel_pos_y(y), radius, steps)
// }

// pub fn (dv &DrawViewerComponent) segment_poly(shape string, x f32, y f32, radius_x f32, radius_y f32, steps u32) {
// 	dv.shapes[shape].segment_poly(dv.layout.rel_pos_x(x), dv.layout.rel_pos_y(y), radius_x, radius_y, steps)
// }

// pub fn (dv &DrawViewerComponent) uniform_line_segment_poly(shape string, x f32, y f32, radius f32, steps u32) {
// 	dv.shapes[shape].uniform_line_segment_poly(dv.layout.rel_pos_x(x), dv.layout.rel_pos_y(y), radius, steps)
// }

// pub fn (dv &DrawViewerComponent) line_segment_poly(shape string, x f32, y f32, radius_x f32, radius_y f32, steps u32) {
// 	dv.shapes[shape].line_segment_poly(dv.layout.rel_pos_x(x), dv.layout.rel_pos_y(y), radius_x, radius_y, steps)
// }

// pub fn (dv &DrawViewerComponent) circle(shape string, x f32, y f32, radius f32, steps u32) {
// 	dv.shapes[shape].circle(dv.layout.rel_pos_x(x), dv.layout.rel_pos_y(y), radius, steps)
// }

// pub fn (dv &DrawViewerComponent) ellipse(shape string, x f32, y f32, radius_x f32, radius_y f32, steps u32) {
// 	dv.shapes[shape].ellipse(dv.layout.rel_pos_x(x), dv.layout.rel_pos_y(y), radius_x, radius_y, steps)
// }

// pub fn (dv &DrawViewerComponent) convex_poly(shape string, points []f32, offset_x f32, offset_y f32) {
// 	dv.shapes[shape].convex_poly(points, dv.layout.rel_pos_x(offset_x), dv.layout.rel_pos_y(offset_y))
// }

// pub fn (dv &DrawViewerComponent) arc(shape string, x f32, y f32, radius f32, start_angle_in_rad f32, angle_in_rad f32) {
// 	dv.shapes[shape].arc(dv.layout.rel_pos_x(x), dv.layout.rel_pos_y(y), radius, start_angle_in_rad, angle_in_rad)
// }

// pub fn (dv &DrawViewerComponent) triangle(shape string, x1 f32, y1 f32, x2 f32, y2 f32, x3 f32, y3 f32) {
// 	dv.shapes[shape].triangle(dv.layout.rel_pos_x(x1), dv.layout.rel_pos_y(y1), dv.layout.rel_pos_x(x2), dv.layout.rel_pos_y(y2), dv.layout.rel_pos_x(x3), dv.layout.rel_pos_y(y3))
// }

// pub fn (dv &DrawViewerComponent) image(shape string, x f32, y f32, w f32, h f32, path string) {
// 	dv.shapes[shape].image(dv.layout.rel_pos_x(x), dv.layout.rel_pos_y(y), w, h, path)
// }
