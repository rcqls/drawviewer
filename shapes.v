module drawviewer

import sgldraw as draw
import gg
import math
import ui

interface Shape {
	shape_style string
	draw(dv &DrawViewerComponent)
	bounds() gg.Rect
}

fn (s &Shape) shape_style(dv &DrawViewerComponent) draw.Shape {
	return dv.shape_style(s.shape_style)
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
	style  string = '_'
	x      f32
	y      f32
	width  f32 = 1
	height f32 = 1
}

pub fn rectangle(p RectangleParams) &Rectangle {
	return &Rectangle{p.style, p.x, p.y, p.width, p.height}
}

pub fn (s &Rectangle) draw(dv &DrawViewerComponent) {
	Shape(s).shape_style(dv).rectangle(dv.layout.rel_pos_x(s.x), dv.layout.rel_pos_y(s.y),
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
	style  string = '_'
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
	Shape(s).shape_style(dv).rounded_rectangle(dv.layout.rel_pos_x(s.x), dv.layout.rel_pos_y(s.y),
		s.w, s.h, s.radius)
}

pub fn (s &RoundedRectangle) bounds() gg.Rect {
	return gg.Rect{s.x, s.y, s.w, s.h}
}

struct Line {
	shape_style string
	x1          f32
	y1          f32
	x2          f32
	y2          f32
}

[params]
pub struct LineParams {
	style string = '_'
	x1    f32
	y1    f32
	x2    f32
	y2    f32
}

pub fn line(p LineParams) &Line {
	return &Line{p.style, p.x1, p.y1, p.x2, p.y2}
}

pub fn (s &Line) draw(dv &DrawViewerComponent) {
	Shape(s).shape_style(dv).line(dv.layout.rel_pos_x(s.x1), dv.layout.rel_pos_y(s.y1),
		dv.layout.rel_pos_x(s.x2), dv.layout.rel_pos_y(s.y2))
}

pub fn (s &Line) bounds() gg.Rect {
	return gg.Rect{math.min(s.x1, s.x2), math.min(s.y1, s.y2), math.abs(s.x1 - s.x2), math.abs(s.y1 - s.y2)}
}

struct Lines {
	shape_style string
	x1          []f32
	y1          []f32
	x2          []f32
	y2          []f32
}

[params]
pub struct LinesParams {
	style string = '_'
	x1    []f32
	y1    []f32
	x2    []f32
	y2    []f32
}

pub fn lines(p LinesParams) &Lines {
	return &Lines{p.style, p.x1, p.y1, p.x2, p.y2}
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
	style    string = '_'
	points   []f32
	holes    []int
	offset_x f32
	offset_y f32
}

pub fn poly(p PolyParams) &Poly {
	return &Poly{p.style, p.points, p.holes, p.offset_x, p.offset_y}
}

pub fn (s &Poly) draw(dv &DrawViewerComponent) {
	Shape(s).shape_style(dv).poly(s.points, s.holes, dv.layout.rel_pos_x(s.offset_x),
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
	style  string = '_'
	x      f32
	y      f32
	radius f32
	steps  u32
}

pub fn uniform_segment_poly(p UniformSegmentPolyParams) &UniformSegmentPoly {
	return &UniformSegmentPoly{p.style, p.x, p.y, p.radius, p.steps}
}

pub fn (s &UniformSegmentPoly) draw(dv &DrawViewerComponent) {
	Shape(s).shape_style(dv).uniform_segment_poly(dv.layout.rel_pos_x(s.x), dv.layout.rel_pos_y(s.y),
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
	style    string = '_'
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
	Shape(s).shape_style(dv).segment_poly(dv.layout.rel_pos_x(s.x), dv.layout.rel_pos_y(s.y),
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
	Shape(s).shape_style(dv).uniform_line_segment_poly(dv.layout.rel_pos_x(s.x), dv.layout.rel_pos_y(s.y),
		s.radius, s.steps)
}

pub fn (s &UniformLineSegmentPoly) bounds() gg.Rect {
	return points_bounds(poly_points(s.x, s.y, s.radius, s.radius, s.steps))
}

struct LineSegmentPoly {
	shape_style string = '_'
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
	Shape(s).shape_style(dv).line_segment_poly(dv.layout.rel_pos_x(s.x), dv.layout.rel_pos_y(s.y),
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
	style  string = '_'
	x      f32
	y      f32
	radius f32 = 1
	steps  u32 = 30
}

pub fn circle(p CircleParams) &Circle {
	return &Circle{p.style, p.x, p.y, p.radius, p.steps}
}

pub fn (s &Circle) draw(dv &DrawViewerComponent) {
	Shape(s).shape_style(dv).circle(dv.layout.rel_pos_x(s.x), dv.layout.rel_pos_y(s.y),
		s.radius, s.steps)
}

pub fn (s &Circle) bounds() gg.Rect {
	return gg.Rect{s.x - s.radius, s.y - s.radius, s.radius * 2, s.radius * 2}
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
	style    string = '_'
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
	Shape(s).shape_style(dv).ellipse(dv.layout.rel_pos_x(s.x), dv.layout.rel_pos_y(s.y),
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
	style    string = '_'
	points   []f32
	offset_x f32
	offset_y f32
}

pub fn convex_poly(p ConvexPolyParams) &ConvexPoly {
	return &ConvexPoly{p.style, p.points, p.offset_x, p.offset_y}
}

pub fn (s &ConvexPoly) draw(dv &DrawViewerComponent) {
	Shape(s).shape_style(dv).convex_poly(s.points, dv.layout.rel_pos_x(s.offset_x), dv.layout.rel_pos_y(s.offset_y))
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
	style       string = '_'
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
	Shape(s).shape_style(dv).arc(dv.layout.rel_pos_x(s.x), dv.layout.rel_pos_y(s.y), s.radius,
		s.start_angle_in_rad, s.angle_in_rad)
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
	style string = '_'
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
	Shape(s).shape_style(dv).triangle(dv.layout.rel_pos_x(s.x1), dv.layout.rel_pos_y(s.y1),
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
	style  string = '_'
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
	Shape(s).shape_style(dv).image(dv.layout.rel_pos_x(s.x), dv.layout.rel_pos_y(s.y),
		s.w, s.h, s.path)
}

pub fn (s &Image) bounds() gg.Rect {
	return gg.Rect{s.x, s.y, s.w, s.h}
}

// utility function for bounds

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

fn poly_points(x f32, y f32, radius_x f32, radius_y f32, steps u32) []f32 {
	theta := 2.0 * f32(math.pi) / f32(steps)
	mut pts := []f32{}
	for i := 0; i < steps + 1; i++ {
		pts << x + radius_x * math.cosf(theta * i)
		pts << y + radius_y * math.sinf(theta * i)
	}
	return pts
}
