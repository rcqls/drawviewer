module drawviewer

import larpon.sgldraw as draw
import ui

// DeviceShape Context

struct DeviceShapeContext {
	id string
mut:
	current_style string
	shape_style   map[string]draw.Shape
	dd            ui.DrawDevice = ui.draw_device_print()
}

pub struct DeviceShapeContextParams {
	id          string
	style       string
	shape_style map[string]draw.Shape
}

pub fn device_shape_context(p DeviceShapeContextParams) &DeviceShapeContext {
	return &DeviceShapeContext{
		id: p.id
		current_style: p.style
		shape_style: p.shape_style
	}
}

pub fn (mut d DeviceShapeContext) set_style(style string) {
	d.current_style = style
}

pub fn (d &DeviceShapeContext) shape_style(style string) draw.Shape {
	return d.shape_style[if style == '' {
		d.current_style
	} else {
		style
	}]
}

pub fn (mut d DeviceShapeContext) add_shape_style(style string, shape_style draw.Shape) {
	d.shape_style[style] = shape_style
}

// DeviceShapeContext as a DeviceShape interface
pub fn (d &DeviceShapeContext) rectangle(x f32, y f32, w f32, h f32, style string) {
	d.shape_style(style).rectangle(x, y, w, h)
}

pub fn (d &DeviceShapeContext) rounded_rectangle(x f32, y f32, w f32, h f32, radius f32, style string) {
	d.shape_style(style).rounded_rectangle(x, y, w, h, radius)
}

pub fn (d &DeviceShapeContext) line(x1 f32, y1 f32, x2 f32, y2 f32, style string) {
	d.shape_style(style).line(x1, y1, x2, y2)
}

pub fn (d &DeviceShapeContext) uniform_segment_poly(x f32, y f32, radius f32, steps u32, style string) {
	d.shape_style(style).uniform_segment_poly(x, y, radius, steps)
}

pub fn (d &DeviceShapeContext) segment_poly(x f32, y f32, radius_x f32, radius_y f32, steps u32, style string) {
	d.shape_style(style).segment_poly(x, y, radius_x, radius_y, steps)
}

pub fn (d &DeviceShapeContext) uniform_line_segment_poly(x f32, y f32, radius f32, steps u32, style string) {
	d.shape_style(style).uniform_line_segment_poly(x, y, radius, steps)
}

pub fn (d &DeviceShapeContext) line_segment_poly(x f32, y f32, radius_x f32, radius_y f32, steps u32, style string) {
	d.shape_style(style).line_segment_poly(x, y, radius_x, radius_y, steps)
}

pub fn (d &DeviceShapeContext) circle(x f32, y f32, radius f32, steps u32, style string) {
	d.shape_style(style).circle(x, y, radius, steps)
}

pub fn (d &DeviceShapeContext) ellipse(x f32, y f32, radius_x f32, radius_y f32, steps u32, style string) {
	d.shape_style(style).ellipse(x, y, radius_x, radius_y, steps)
}

pub fn (d &DeviceShapeContext) convex_poly(points []f32, offset_x f32, offset_y f32, style string) {
	d.shape_style(style).convex_poly(points, offset_x, offset_y)
}

pub fn (d &DeviceShapeContext) poly(points []f32, holes []int, offset_x f32, offset_y f32, style string) {
	d.shape_style(style).poly(points, holes, offset_x, offset_y)
}

pub fn (d &DeviceShapeContext) arc(x f32, y f32, radius f32, start_angle_in_rad f32, angle_in_rad f32, style string) {
	d.shape_style(style).arc(x, y, radius, start_angle_in_rad, angle_in_rad)
}

pub fn (d &DeviceShapeContext) triangle(x1 f32, y1 f32, x2 f32, y2 f32, x3 f32, y3 f32, style string) {
	d.shape_style(style).triangle(x1, y1, x2, y2, x3, y3)
}

pub fn (d &DeviceShapeContext) image(x f32, y f32, w f32, h f32, path string, style string) {
	d.shape_style(style).image(x, y, w, h, path)
}
