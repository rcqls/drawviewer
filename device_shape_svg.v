module drawviewer

import ui.libvg
import larpon.sgldraw as draw
import gx
import ui
import math

struct DeviceShapeSVG {
	id string
mut:
	dsc      &DeviceShapeContext = 0
	dd       ui.DrawDevice       = ui.draw_device_print()
	s        &libvg.Svg = 0
	offset_x int
	offset_y int
}

[params]
struct DeviceShapeSVGParams {
	id  string = 'dss'
	dsc &DeviceShapeContext = 0
}

pub fn device_shape_svg(p DeviceShapeSVGParams) &DeviceShapeSVG {
	return &DeviceShapeSVG{
		id: p.id
		dsc: p.dsc
	}
}

[manualfree]
pub fn (mut d DeviceShapeSVG) screenshot_drawviewer(filename string, dvc &DrawViewerComponent) {
	// println("svg device $filename")
	w, h := dvc.layout.adj_size()
	d.s = libvg.svg(width: w, height: h)
	d.s.offset_x, d.s.offset_y = -dvc.layout.x, -dvc.layout.y
	mut dds := d.dd
	if mut dds is ui.DrawDeviceSVG {
		dds.s = d.s
	}

	d.begin(dvc.layout.style.bg_color)

	for s in dvc.shapes {
		s.draw_device(d, dvc)
	}
	if dvc.on_draw != DrawViewerFn(0) {
		dvc.on_draw(d.dd, dvc)
	}

	d.end()
	d.save(filename)
	unsafe { d.s.free() }
}

[manualfree]
pub fn (mut d DeviceShapeSVG) screenshot_drawviewer_plot(filename string, w int, h int, dvc &DrawViewerComponent, p &Plot) {
	// wd, hd := dvc.layout.adj_size()
	// println("svg device $filename")
	wp, hp := p.full_size()
	d.s = libvg.svg(width: wp, height: hp)
	d.s.offset_x, d.s.offset_y = p.marg[.left] - p.x - dvc.layout.x, p.marg[.top] - p.y - dvc.layout.y
	mut dds := d.dd
	if mut dds is ui.DrawDeviceSVG {
		dds.s = d.s
	}

	d.begin(dvc.layout.style.bg_color)

	p.draw_device(d, dvc)

	d.end()
	d.save(filename)
	unsafe { d.s.free() }
}

// methods

pub fn (d &DeviceShapeSVG) begin(bg_color gx.Color) {
	mut s := d.s
	s.begin()
	s.fill(ui.hex_color(bg_color))
	// s.rectangle(0, 0, d.s.width, d.s.height, ui.hex_color(win_bg_color), 'none', 0, 0, 0)
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
	s.rectangle(int(x), int(y), int(w), int(h), d.svg_params(style))
}

pub fn (d &DeviceShapeSVG) rounded_rectangle(x f32, y f32, w f32, h f32, radius f32, style string) {
	mut s := d.s
	s.rectangle(int(x), int(y), int(w), int(h), d.svg_params(style, radius: int(radius)))
}

pub fn (d &DeviceShapeSVG) line(x1 f32, y1 f32, x2 f32, y2 f32, style string) {
	mut s := d.s
	s.line(int(x1), int(y1), int(x2), int(y2), d.svg_params(style))
}

pub fn (d &DeviceShapeSVG) uniform_segment_poly(x f32, y f32, radius f32, steps u32, style string) {
	d.segment_poly(x, y, radius, radius, steps, style)
}

pub fn (d &DeviceShapeSVG) segment_poly(x f32, y f32, radius_x f32, radius_y f32, steps u32, style string) {
	mut s := d.s
	s.polygon(segment_poly_str(x + s.offset_x, y + s.offset_y, radius_x, radius_y, steps),
		d.svg_params(style))
}

pub fn (d &DeviceShapeSVG) uniform_line_segment_poly(x f32, y f32, radius f32, steps u32, style string) {
	d.line_segment_poly(x, y, radius, radius, steps, style)
}

pub fn (d &DeviceShapeSVG) line_segment_poly(x f32, y f32, radius_x f32, radius_y f32, steps u32, style string) {
	mut s := d.s
	s.polyline(segment_poly_str(x + s.offset_x, y + s.offset_y, radius_x, radius_y, steps),
		d.svg_params(style))
}

pub fn (d &DeviceShapeSVG) circle(x f32, y f32, radius f32, steps u32, style string) {
	mut s := d.s
	s.circle(int(x), int(y), int(radius), d.svg_params(style))
}

pub fn (d &DeviceShapeSVG) ellipse(x f32, y f32, radius_x f32, radius_y f32, steps u32, style string) {
	mut s := d.s
	s.ellipse(int(x), int(y), int(radius_x), int(radius_y), d.svg_params(style))
}

pub fn (d &DeviceShapeSVG) convex_poly(points []f32, offset_x f32, offset_y f32, style string) {
	mut s := d.s
	s.polygon('${points_str(points, offset_x + s.offset_x, offset_y + s.offset_y)}', d.svg_params(style))
}

pub fn (d &DeviceShapeSVG) poly(points []f32, holes []int, offset_x f32, offset_y f32, style string) {
	mut s := d.s
	s.path('${path_with_holes(points, holes, offset_x + s.offset_x, offset_y + s.offset_y)}',
		d.svg_params(style))
}

pub fn (d &DeviceShapeSVG) arc(x f32, y f32, radius f32, start_angle_in_rad f32, angle_in_rad f32, style string) {
	mut s := d.s
	pg, pl := arc_str(x + s.offset_x, y + s.offset_y, radius, start_angle_in_rad, angle_in_rad)
	s.polygon(pg, d.svg_params(style, strokewidth: 0))
	s.polyline(pl, d.svg_params(style, fill: 'none'))
}

pub fn (d &DeviceShapeSVG) triangle(x1 f32, y1 f32, x2 f32, y2 f32, x3 f32, y3 f32, style string) {
	mut s := d.s
	s.polygon('${int(x1) + s.offset_x},${int(y1) + s.offset_y} ${int(x2) + s.offset_x},${int(y2) +
		s.offset_y} ${int(x3) + s.offset_x},${int(y3) + s.offset_y} ${int(x1) + s.offset_x},${
		int(y1) + s.offset_y}', d.svg_params(style))
}

pub fn (d &DeviceShapeSVG) image(x f32, y f32, w f32, h f32, path string, style string) {
}

[params]
struct SvgParamsParams {
	radius      int = -1
	strokewidth int = -1
	fill        string
	stroke      string
	linecap     string
	linejoin    string
}

pub fn (d &DeviceShapeSVG) svg_params(style string, p SvgParamsParams) libvg.Params {
	sty := d.dsc.shape_style(style)
	r := if p.radius > 0 { p.radius } else { 0 }
	sw := if p.strokewidth >= 0 { p.strokewidth } else { int(sty.radius) * 2 }
	return libvg.Params{
		fill: if p.fill.len > 0 {
			p.fill
		} else if sty.fill.has(.solid) {
			shape_color(sty.colors.solid)
		} else {
			'none'
		}
		stroke: if p.stroke.len > 0 {
			p.stroke
		} else if sty.fill.has(.outline) {
			shape_color(sty.colors.outline)
		} else {
			'none'
		}
		strokewidth: if sty.fill.has(.outline) { sw } else { 0 }
		rx: r
		ry: r
		linecap: if p.linecap.len > 0 {
			p.linecap
		} else {
			match sty.cap {
				.butt { 'butt' }
				.square { 'square' }
				.round { 'round' }
			}
		}
		linejoin: if p.linejoin.len > 0 {
			p.linejoin
		} else {
			match sty.connect {
				.miter { 'miter' }
				.bevel { 'bevel' }
				.round { 'round' }
			}
		}
	}
}

pub fn shape_color(c draw.Color) string {
	return ui.hex_rgba(c.r, c.g, c.b, c.a)
}

pub fn points_str(points []f32, offset_x f32, offset_y f32) string {
	mut pts := ''
	for i, pt in points {
		pts += if i % 2 == 0 { '${int(pt + offset_x)},' } else { '${int(pt + offset_y)} ' }
	}
	pts += ' ${int(points[0] + offset_x)},${int(points[1] + offset_y)}'
	return pts
}

pub fn path_with_holes(points []f32, holes []int, off_x f32, off_y f32) string {
	mut d := ''
	mut x, mut y, dim := f32(0), f32(0), 2
	mut hole_start := points.len
	if holes.len > 0 {
		hole_start = holes[0] * dim
	}
	x = off_x + points[0]
	y = off_y + points[1]
	d += 'M ${int(x)},${int(y)} '
	for i := dim; i < hole_start; i += dim {
		x = off_x + points[i]
		y = off_y + points[i + 1]
		d += 'L ${int(x)},${int(y)} '
		// m12x, m12y := midpoint(x1, y1, x2, y2)
		// m23x, m23y := midpoint(x2, y2, x3, y3)

		// b.anchor(m12x, m12y, x2, y2, m23x, m23y)
	}
	d += 'Z '

	for i := 0; i < holes.len; i++ {
		from := holes[i] * dim
		mut to := points.len
		if i + 1 < holes.len {
			to = holes[i + 1] * dim
		}
		println('$i -> $from : $to')
		// counter clockwise for holes
		x = off_x + points[from]
		y = off_y + points[from + 1]
		d += 'M $x,$y '
		for j := to - dim; j > from; j -= dim {
			x = off_x + points[j]
			y = off_y + points[j + 1]
			d += 'L $x,$y '

			// m12x, m12y := midpoint(x1, y1, x2, y2)
			// m23x, m23y := midpoint(x2, y2, x3, y3)

			// b.anchor(m12x, m12y, x2, y2, m23x, m23y)
		}
		d += 'Z '
	}
	return d
}

pub fn segment_poly_str(x f32, y f32, radius_x f32, radius_y f32, steps u32) string {
	mut s := ''
	mut theta, mut xx, mut yy := f32(0), f32(0), f32(0)
	for i := 0; i < steps + 1; i++ {
		theta = 2.0 * f32(math.pi) * f32(i) / f32(steps)
		xx = radius_x * math.cosf(theta)
		yy = radius_y * math.sinf(theta)
		s += '${int(xx + x)},${int(yy + y)} '
	}
	return s
}

pub fn arc_str(x f32, y f32, radius f32, start_angle_in_rad f32, angle_in_rad f32) (string, string) {
	mut s_polygon := '${int(x)},${int(y)} '
	mut s_polyline := ''

	sair := draw.loopf(start_angle_in_rad - (90 * draw.deg2rad), 0, draw.rad_max)
	steps := (sair - angle_in_rad) * radius
	segdiv := u32(steps) // 4

	theta := f32(angle_in_rad / steps)
	tan_factor := math.tanf(theta)
	rad_factor := math.cosf(theta)
	mut x1 := f32(radius * math.cosf(sair))
	mut y1 := f32(radius * math.sinf(sair))
	s_polygon += '${int(x1 + x)},${int(y1 + y)} '
	s_polyline += '${int(x1 + x)},${int(y1 + y)} '
	for i := 0; i < segdiv + 1; i++ {
		tx := -y1
		ty := x1
		x1 += tx * tan_factor
		y1 += ty * tan_factor
		x1 *= rad_factor
		y1 *= rad_factor
		s_polygon += '${int(x1 + x)},${int(y1 + y)} '
		s_polyline += '${int(x1 + x)},${int(y1 + y)} '
	}
	return s_polygon, s_polyline
}
