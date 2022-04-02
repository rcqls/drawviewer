module drawviewer

import larpon.sgldraw as draw
import gg
import math
import ui

interface Shape {
	draw(dv &DrawViewerComponent)
	bounds() gg.Rect
}

fn (s &Shape) rel_bounds(dv &DrawViewerComponent) gg.Rect {
	b := s.bounds()
	return gg.Rect{dv.layout.rel_pos_x(b.x), dv.layout.rel_pos_y(b.y), b.width, b.height}
}

struct Rectangle {
	shape_style string
	x           f32
	y           f32
	w           f32
	h           f32
}

[params]
pub struct RectangleParams {
	style  string
	x      f32
	y      f32
	width  f32 = 1
	height f32 = 1
}

pub fn rectangle(p RectangleParams) &Rectangle {
	return &Rectangle{p.style, p.x, p.y, p.width, p.height}
}

pub fn (s &Rectangle) draw(dv &DrawViewerComponent) {
	dv.shape_style(s.shape_style).rectangle(dv.layout.rel_pos_x(s.x), dv.layout.rel_pos_y(s.y),
		s.w, s.h)
}

pub fn (s &Rectangle) bounds() gg.Rect {
	return gg.Rect{s.x, s.y, s.w, s.h}
}

struct RoundedRectangle {
	shape_style string
	x           f32
	y           f32
	w           f32
	h           f32
	radius      f32
}

[params]
pub struct RoundedRectangleParams {
	style  string
	x      f32
	y      f32
	width  f32
	height f32
	radius f32
}

pub fn rounded_rectangle(p RoundedRectangleParams) &RoundedRectangle {
	return &RoundedRectangle{p.style, p.x, p.y, p.width, p.height, p.radius}
}

pub fn (s &RoundedRectangle) draw(dv &DrawViewerComponent) {
	dv.shape_style(s.shape_style).rounded_rectangle(dv.layout.rel_pos_x(s.x), dv.layout.rel_pos_y(s.y),
		s.w, s.h, s.radius)
}

pub fn (s &RoundedRectangle) bounds() gg.Rect {
	return gg.Rect{s.x, s.y, s.w, s.h}
}

struct Line {
mut:
	shape_style string
	x1          f32
	y1          f32
	x2          f32
	y2          f32
}

[params]
pub struct LineParams {
	style string
	x1    f32
	y1    f32
	x2    f32
	y2    f32
}

pub fn line(p LineParams) &Line {
	return &Line{p.style, p.x1, p.y1, p.x2, p.y2}
}

pub fn (s &Line) draw(dv &DrawViewerComponent) {
	dv.shape_style(s.shape_style).line(dv.layout.rel_pos_x(s.x1), dv.layout.rel_pos_y(s.y1),
		dv.layout.rel_pos_x(s.x2), dv.layout.rel_pos_y(s.y2))
}

pub fn (s &Line) bounds() gg.Rect {
	return gg.Rect{math.min(s.x1, s.x2), math.min(s.y1, s.y2), math.abs(s.x1 - s.x2), math.abs(s.y1 - s.y2)}
}

struct Lines {
mut:
	shape_style string
	x1          []f32
	y1          []f32
	x2          []f32
	y2          []f32
}

[params]
pub struct LinesParams {
	style string
	x1    []f32
	y1    []f32
	x2    []f32
	y2    []f32
}

pub fn lines(p LinesParams) &Lines {
	return &Lines{p.style, p.x1, p.y1, p.x2, p.y2}
}

pub fn (s &Lines) draw(dv &DrawViewerComponent) {
	shape := dv.shape_style(s.shape_style)
	// suppose first x1, y1, x2, y2 same length
	for i, _ in s.x1 {
		shape.line(dv.layout.rel_pos_x(s.x1[i]), dv.layout.rel_pos_y(s.y1[i]), dv.layout.rel_pos_x(s.x2[i]),
			dv.layout.rel_pos_y(s.y2[i]))
	}
}

pub fn (s &Lines) bounds() gg.Rect {
	mut x, mut y := s.x1.clone(), s.y1.clone()
	x << s.x2.clone()
	y << s.y2.clone()
	return xy_bounds(x, y)
}

struct Path {
mut:
	shape_style string
	x           []f32
	y           []f32
	closed      bool
}

[params]
pub struct PathParams {
	style  string
	x      []f32
	y      []f32
	closed bool
}

pub fn path(p PathParams) &Path {
	return &Path{p.style, p.x, p.y, p.closed}
}

pub fn (s &Path) draw(dv &DrawViewerComponent) {
	shape := dv.shape_style(s.shape_style)
	// suppose first x, y same length
	for i in 0 .. (s.x.len - 1) {
		shape.line(dv.layout.rel_pos_x(s.x[i]), dv.layout.rel_pos_y(s.y[i]), dv.layout.rel_pos_x(s.x[
			i + 1]), dv.layout.rel_pos_y(s.y[i + 1]))
	}
	if s.closed {
		shape.line(dv.layout.rel_pos_x(s.x[s.x.len - 1]), dv.layout.rel_pos_y(s.y[s.x.len - 1]),
			dv.layout.rel_pos_x(s.x[0]), dv.layout.rel_pos_y(s.y[0]))
	}
}

pub fn (s &Path) bounds() gg.Rect {
	return xy_bounds(s.x, s.y)
}

struct Poly {
	shape_style string
	points      []f32
	holes       []int
	offset_x    f32
	offset_y    f32
}

[params]
pub struct PolyParams {
	style    string
	points   []f32
	holes    []int
	offset_x f32
	offset_y f32
}

pub fn poly(p PolyParams) &Poly {
	return &Poly{p.style, p.points, p.holes, p.offset_x, p.offset_y}
}

pub fn (s &Poly) draw(dv &DrawViewerComponent) {
	dv.shape_style(s.shape_style).poly(s.points, s.holes, dv.layout.rel_pos_x(s.offset_x),
		dv.layout.rel_pos_y(s.offset_y))
}

pub fn (s &Poly) bounds() gg.Rect {
	b := points_bounds(s.points)
	return gg.Rect{b.x + s.offset_x, b.y + s.offset_y, b.width, b.height}
}

struct UniformSegmentPoly {
	shape_style string
	x           f32
	y           f32
	radius      f32
	steps       u32
}

[params]
pub struct UniformSegmentPolyParams {
	style  string
	x      f32
	y      f32
	radius f32
	steps  u32
}

pub fn uniform_segment_poly(p UniformSegmentPolyParams) &UniformSegmentPoly {
	return &UniformSegmentPoly{p.style, p.x, p.y, p.radius, p.steps}
}

pub fn (s &UniformSegmentPoly) draw(dv &DrawViewerComponent) {
	dv.shape_style(s.shape_style).uniform_segment_poly(dv.layout.rel_pos_x(s.x), dv.layout.rel_pos_y(s.y),
		s.radius, s.steps)
}

pub fn (s &UniformSegmentPoly) bounds() gg.Rect {
	return points_bounds(poly_points(s.x, s.y, s.radius, s.radius, s.steps))
}

struct SegmentPoly {
	shape_style string
	x           f32
	y           f32
	radius_x    f32
	radius_y    f32
	steps       u32
}

[params]
pub struct SegmentPolyParams {
	style    string
	x        f32
	y        f32
	radius_x f32
	radius_y f32
	steps    u32
}

pub fn segment_poly(p SegmentPolyParams) &SegmentPoly {
	return &SegmentPoly{p.style, p.x, p.y, p.radius_x, p.radius_y, p.steps}
}

pub fn (s &SegmentPoly) draw(dv &DrawViewerComponent) {
	dv.shape_style(s.shape_style).segment_poly(dv.layout.rel_pos_x(s.x), dv.layout.rel_pos_y(s.y),
		s.radius_x, s.radius_y, s.steps)
}

pub fn (s &SegmentPoly) bounds() gg.Rect {
	return points_bounds(poly_points(s.x, s.y, s.radius_x, s.radius_y, s.steps))
}

struct UniformLineSegmentPoly {
	shape_style string
	x           f32
	y           f32
	radius      f32
	steps       u32
}

pub fn uniform_line_segment_poly(p UniformSegmentPolyParams) &UniformLineSegmentPoly {
	return &UniformLineSegmentPoly{p.style, p.x, p.y, p.radius, p.steps}
}

pub fn (s &UniformLineSegmentPoly) draw(dv &DrawViewerComponent) {
	dv.shape_style(s.shape_style).uniform_line_segment_poly(dv.layout.rel_pos_x(s.x),
		dv.layout.rel_pos_y(s.y), s.radius, s.steps)
}

pub fn (s &UniformLineSegmentPoly) bounds() gg.Rect {
	return points_bounds(poly_points(s.x, s.y, s.radius, s.radius, s.steps))
}

struct LineSegmentPoly {
	shape_style string
	x           f32
	y           f32
	radius_x    f32
	radius_y    f32
	steps       u32
}

pub fn line_segment_poly(p SegmentPolyParams) &LineSegmentPoly {
	return &LineSegmentPoly{p.style, p.x, p.y, p.radius_x, p.radius_y, p.steps}
}

pub fn (s &LineSegmentPoly) draw(dv &DrawViewerComponent) {
	dv.shape_style(s.shape_style).line_segment_poly(dv.layout.rel_pos_x(s.x), dv.layout.rel_pos_y(s.y),
		s.radius_x, s.radius_y, s.steps)
}

pub fn (s &LineSegmentPoly) bounds() gg.Rect {
	return gg.Rect{} // s.x, s.y, s.w, s.h}
}

struct Circle {
	shape_style string
	x           f32
	y           f32
	radius      f32
	steps       u32
}

[params]
pub struct CircleParams {
	style  string
	x      f32
	y      f32
	radius f32 = 1
	steps  u32 = 30
}

pub fn circle(p CircleParams) &Circle {
	return &Circle{p.style, p.x, p.y, p.radius, p.steps}
}

pub fn (s &Circle) draw(dv &DrawViewerComponent) {
	dv.shape_style(s.shape_style).circle(dv.layout.rel_pos_x(s.x), dv.layout.rel_pos_y(s.y),
		s.radius, s.steps)
}

pub fn (s &Circle) bounds() gg.Rect {
	return gg.Rect{s.x - s.radius, s.y - s.radius, s.radius * 2, s.radius * 2}
}

struct Circles {
mut:
	shape_style string
	x           []f32
	y           []f32
	radius      []f32
	steps       u32
}

[params]
pub struct CirclesParams {
	style  string
	x      []f32
	y      []f32
	radii  []f32
	radius f32 = 1.0
	steps  u32 = 30
}

pub fn circles(p CirclesParams) &Circles {
	r := if p.radii.len == p.x.len { p.radii } else { [p.radius].repeat(p.x.len) }
	return &Circles{p.style, p.x, p.y, r, p.steps}
}

pub fn (s &Circles) draw(dv &DrawViewerComponent) {
	// suppose first that s.x, s.y and s.radius
	for i, _ in s.x {
		dv.shape_style(s.shape_style).circle(dv.layout.rel_pos_x(s.x[i]), dv.layout.rel_pos_y(s.y[i]),
			s.radius[i], s.steps)
	}
}

pub fn (s &Circles) bounds() gg.Rect {
	return xy_bounds(s.x, s.y)
}

struct Ellipse {
	shape_style string
	x           f32
	y           f32
	radius_x    f32
	radius_y    f32
	steps       u32
}

[params]
pub struct EllipseParams {
	style    string
	x        f32
	y        f32
	radius_x f32 = 1
	radius_y f32 = 1
	steps    u32 = 30
}

pub fn ellipse(p EllipseParams) &Ellipse {
	return &Ellipse{p.style, p.x, p.y, p.radius_x, p.radius_y, p.steps}
}

pub fn (s &Ellipse) draw(dv &DrawViewerComponent) {
	dv.shape_style(s.shape_style).ellipse(dv.layout.rel_pos_x(s.x), dv.layout.rel_pos_y(s.y),
		s.radius_x, s.radius_y, s.steps)
}

pub fn (s &Ellipse) bounds() gg.Rect {
	return gg.Rect{s.x - s.radius_x, s.y - s.radius_y, s.radius_x * 2, s.radius_y * 2}
}

struct ConvexPoly {
	shape_style string
	points      []f32
	offset_x    f32
	offset_y    f32
}

[params]
pub struct ConvexPolyParams {
	style    string
	points   []f32
	offset_x f32
	offset_y f32
}

pub fn convex_poly(p ConvexPolyParams) &ConvexPoly {
	return &ConvexPoly{p.style, p.points, p.offset_x, p.offset_y}
}

pub fn (s &ConvexPoly) draw(dv &DrawViewerComponent) {
	dv.shape_style(s.shape_style).convex_poly(s.points, dv.layout.rel_pos_x(s.offset_x),
		dv.layout.rel_pos_y(s.offset_y))
}

pub fn (s &ConvexPoly) bounds() gg.Rect {
	b := points_bounds(s.points)
	return gg.Rect{b.x + s.offset_x, b.y + s.offset_y, b.width, b.height}
}

struct Arc {
	shape_style        string
	x                  f32
	y                  f32
	radius             f32
	start_angle_in_rad f32
	angle_in_rad       f32
}

pub struct ArcParams {
	style       string
	x           f32
	y           f32
	radius      f32
	start_angle f32
	angle       f32
}

pub fn arc(p ArcParams) &Arc {
	return &Arc{p.style, p.x, p.y, p.radius, p.start_angle * draw.deg2rad, p.angle * draw.deg2rad}
}

pub fn (s &Arc) draw(dv &DrawViewerComponent) {
	dv.shape_style(s.shape_style).arc(dv.layout.rel_pos_x(s.x), dv.layout.rel_pos_y(s.y),
		s.radius, s.start_angle_in_rad, s.angle_in_rad)
}

pub fn (s &Arc) bounds() gg.Rect {
	// TODO: currently same as circle
	return gg.Rect{s.x - s.radius, s.y - s.radius, s.radius * 2, s.radius * 2}
}

struct Triangle {
	shape_style string
	x1          f32
	y1          f32
	x2          f32
	y2          f32
	x3          f32
	y3          f32
}

[params]
pub struct TriangleParams {
	style string
	x1    f32
	y1    f32
	x2    f32
	y2    f32
	x3    f32
	y3    f32
}

pub fn triangle(p TriangleParams) &Triangle {
	return &Triangle{p.style, p.x1, p.y1, p.x2, p.y2, p.x3, p.y3}
}

pub fn (s &Triangle) draw(dv &DrawViewerComponent) {
	dv.shape_style(s.shape_style).triangle(dv.layout.rel_pos_x(s.x1), dv.layout.rel_pos_y(s.y1),
		dv.layout.rel_pos_x(s.x2), dv.layout.rel_pos_y(s.y2), dv.layout.rel_pos_x(s.x3),
		dv.layout.rel_pos_y(s.y3))
}

pub fn (s &Triangle) bounds() gg.Rect {
	return points_bounds([s.x1, s.y1, s.x2, s.y2, s.x3, s.y3])
}

struct Image {
	shape_style string
	x           f32
	y           f32
	w           f32
	h           f32
	path        string
}

pub struct ImageParams {
	style  string
	x      f32
	y      f32
	width  f32
	height f32
	path   string
}

pub fn image(p ImageParams) &Image {
	return &Image{p.style, p.x, p.y, p.width, p.height, p.path}
}

pub fn (s &Image) draw(dv &DrawViewerComponent) {
	dv.shape_style(s.shape_style).image(dv.layout.rel_pos_x(s.x), dv.layout.rel_pos_y(s.y),
		s.w, s.h, s.path)
}

pub fn (s &Image) bounds() gg.Rect {
	return gg.Rect{s.x, s.y, s.w, s.h}
}

// utility function for bounds

fn union_bounds(bounds []gg.Rect) gg.Rect {
	if bounds.len == 0 {
		return gg.Rect{}
	} else {
		mut b := bounds[0]
		// println("b init: $b")
		for b2 in bounds[1..] {
			b = ui.union_rect(b, b2)
		}
		return b
	}
}

fn shapes_bounds(shapes []Shape) gg.Rect {
	if shapes.len == 0 {
		return gg.Rect{}
	} else {
		mut b := shapes[0].bounds()
		// println("b init: $b")
		for s in shapes[1..] {
			b = ui.union_rect(b, s.bounds())
			// println("s: $s $s.bounds() -> $b")
		}
		return b
	}
}

fn points_bounds(points []f32) gg.Rect {
	mut x_mi, mut x_ma, mut y_mi, mut y_ma := points[0], points[0], points[1], points[1]
	for i := 2; i < points.len; i += 2 {
		if points[i] < x_mi {
			x_mi = points[i]
		} else if points[i] > x_ma {
			x_ma = points[i]
		}
		if points[i + 1] < y_mi {
			y_mi = points[i + 1]
		} else if points[i + 1] > y_ma {
			y_ma = points[i + 1]
		}
	}
	return gg.Rect{x_mi, y_mi, x_ma - x_mi, y_ma - y_mi}
}

fn xy_bounds(x []f32, y []f32) gg.Rect {
	mut x_mi, mut x_ma, mut y_mi, mut y_ma := x[0], x[0], y[0], y[0]
	for i in 1 .. x.len {
		if x[i] < x_mi {
			x_mi = x[i]
		} else if x[i] > x_ma {
			x_ma = x[i]
		}
		if y[i] < y_mi {
			y_mi = y[i]
		} else if y[i] > y_ma {
			y_ma = y[i]
		}
	}
	return gg.Rect{x_mi, y_mi, x_ma - x_mi, y_ma - y_mi}
}

fn poly_points(x f32, y f32, radius_x f32, radius_y f32, steps u32) []f32 {
	theta := 2.0 * f32(math.pi) / f32(steps)
	mut pts := []f32{}
	for i := 0; i < steps + 1; i++ {
		pts << x + radius_x * math.cosf(theta * i)
		pts << y + radius_y * math.sinf(theta * i)
	}
	return pts
}
