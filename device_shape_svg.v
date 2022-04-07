module drawviewer

import vsvg
import larpon.sgldraw as draw
import gx
import ui

struct DeviceShapeSVG {
	id string
mut:
	dsc      &DeviceShapeContext = 0
	dd       ui.DrawDevice       = ui.draw_device_print()
	s        &vsvg.Svg
	offset_x int
	offset_y int
}

[params]
struct DeviceShapeSVGParams {
	id       string = 'dss'
	width    int
	height   int
	offset_x int
	offset_y int
	dsc      &DeviceShapeContext = 0
}

pub fn device_shape_svg(p DeviceShapeSVGParams) &DeviceShapeSVG {
	s := vsvg.svg(width: p.width, height: p.height)
	return &DeviceShapeSVG{
		id: p.id
		s: s
		dsc: p.dsc
		offset_x: p.offset_x
		offset_y: p.offset_y
	}
}

// radius   f32     = 1.0
// scale    f32     = 1.0
// fill     Fill    = .solid | .outline
// cap      Cap     = .butt
// connect  Connect = .bevel
// offset_x f32     = 0.0
// offset_y f32     = 0.0
// colors   Colors

pub fn device_shape_drawviewer(filename string, dvc &DrawViewerComponent) {
	// println("svg device $filename")
	w, h := dvc.layout.adj_size()
	mut d := device_shape_svg(
		width: w
		height: h
		dsc: dvc.dsc
		// offset_x: -dvc.layout.x
		// offset_y: -dvc.layout.y
	)
	d.dd = dvc.layout.ui.svg
	d.s.content = dvc.layout.ui.svg.s.content
	d.begin(dvc.layout.bg_color)

	for s in dvc.shapes {
		s.draw_device(d, dvc)
	}
	if dvc.on_draw != DrawViewerFn(0) {
		dvc.on_draw(d.dd, dvc)
	}

	d.end()
	d.save(filename)
}

// methods

pub fn (d &DeviceShapeSVG) begin(bg_color gx.Color) {
	mut s := d.s
	s.begin()
	s.fill(vsvg.color(bg_color))
	// s.rectangle(0, 0, d.s.width, d.s.height, vsvg.color(win_bg_color), 'none', 0, 0, 0)
}

pub fn (d &DeviceShapeSVG) end() {
	mut s := d.s
	s.end()
}

pub fn (d &DeviceShapeSVG) save(filepath string) {
	mut s := d.s
	// println("save $filepath")
	s.save(filepath) or {}
}

pub fn (d &DeviceShapeSVG) rectangle(x f32, y f32, w f32, h f32, style string) {
	mut s := d.s
	s.rectangle(int(x) + d.offset_x, int(y) + d.offset_y, int(w), int(h), d.svg_params(style))
}

pub fn (d &DeviceShapeSVG) rounded_rectangle(x f32, y f32, w f32, h f32, radius f32, style string) {
	mut s := d.s
	s.rectangle(int(x) + d.offset_x, int(y) + d.offset_y, int(w), int(h), d.svg_params(style,
		radius: int(radius)))
}

pub fn (d &DeviceShapeSVG) line(x1 f32, y1 f32, x2 f32, y2 f32, style string) {
	mut s := d.s
	s.line(int(x1) + d.offset_x, int(y1) + d.offset_y, int(x2) + d.offset_x, int(y2) + d.offset_y,
		d.svg_params(style))
}

pub fn (d &DeviceShapeSVG) uniform_segment_poly(x f32, y f32, radius f32, steps u32, style string) {
}

pub fn (d &DeviceShapeSVG) segment_poly(x f32, y f32, radius_x f32, radius_y f32, steps u32, style string) {
}

pub fn (d &DeviceShapeSVG) uniform_line_segment_poly(x f32, y f32, radius f32, steps u32, style string) {
}

pub fn (d &DeviceShapeSVG) line_segment_poly(x f32, y f32, radius_x f32, radius_y f32, steps u32, style string) {
}

pub fn (d &DeviceShapeSVG) circle(x f32, y f32, radius f32, steps u32, style string) {
	mut s := d.s
	s.circle(int(x) + d.offset_x, int(y) + d.offset_y, int(radius), d.svg_params(style))
}

pub fn (d &DeviceShapeSVG) ellipse(x f32, y f32, radius_x f32, radius_y f32, steps u32, style string) {
	mut s := d.s
	s.ellipse(int(x) + d.offset_x, int(y) + d.offset_y, int(radius_x), int(radius_y),
		d.svg_params(style))
}

pub fn (d &DeviceShapeSVG) convex_poly(points []f32, offset_x f32, offset_y f32, style string) {
}

pub fn (d &DeviceShapeSVG) poly(points []f32, holes []int, offset_x f32, offset_y f32, style string) {
}

pub fn (d &DeviceShapeSVG) arc(x f32, y f32, radius f32, start_angle_in_rad f32, angle_in_rad f32, style string) {
}

pub fn (d &DeviceShapeSVG) triangle(x1 f32, y1 f32, x2 f32, y2 f32, x3 f32, y3 f32, style string) {
	mut s := d.s
	s.polygon('${int(x1) + d.offset_x},${int(y1) + d.offset_y} ${int(x2) + d.offset_x},${int(y2) +
		d.offset_y} ${int(x3) + d.offset_x},${int(y3) + d.offset_y} ${int(x1) + d.offset_x},${
		int(y1) + d.offset_y}', d.svg_params(style))
}

pub fn (d &DeviceShapeSVG) image(x f32, y f32, w f32, h f32, path string, style string) {
}

[params]
struct SvgParamsParams {
	radius int = -1
}

pub fn (d &DeviceShapeSVG) svg_params(style string, p SvgParamsParams) vsvg.Params {
	sty := d.dsc.shape_style(style)
	r := if p.radius > 0 { p.radius } else { 0 }
	return vsvg.Params{
		fill: if sty.fill.has(.solid) { shape_color(sty.colors.solid) } else { 'none' }
		stroke: if sty.fill.has(.outline) { shape_color(sty.colors.outline) } else { 'none' }
		strokewidth: if sty.fill.has(.outline) { int(sty.radius) * 2 } else { 0 }
		rx: r
		ry: r
	}
}

pub fn shape_color(c draw.Color) string {
	return vsvg.rgba(c.r, c.g, c.b, c.a)
}
