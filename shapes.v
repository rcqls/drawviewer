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

pub struct Rectangle {
	shape_style string
	x           f32
	y           f32
	w           f32
	h           f32
}

pub fn (s &Rectangle) draw(dv &DrawViewerComponent) {
	dv.shape_style[s.shape_style].rectangle(dv.layout.rel_pos_x(s.x), dv.layout.rel_pos_y(s.y),
		s.w, s.h)
}

pub fn (s &Rectangle) bounds() gg.Rect {
	return gg.Rect{s.x, s.y, s.w, s.h}
}

pub struct RoundedRectangle {
	shape_style string
	x           f32
	y           f32
	w           f32
	h           f32
	radius      f32
}

pub fn (s &RoundedRectangle) draw(dv &DrawViewerComponent) {
	dv.shape_style[s.shape_style].rounded_rectangle(dv.layout.rel_pos_x(s.x), dv.layout.rel_pos_y(s.y),
		s.w, s.h, s.radius)
}

pub fn (s &RoundedRectangle) bounds() gg.Rect {
	return gg.Rect{s.x, s.y, s.w, s.h}
}

pub struct Line {
	shape_style string
	x1          f32
	y1          f32
	x2          f32
	y2          f32
}

pub fn (s &Line) draw(dv &DrawViewerComponent) {
	dv.shape_style[s.shape_style].line(dv.layout.rel_pos_x(s.x1), dv.layout.rel_pos_y(s.y1),
		dv.layout.rel_pos_x(s.x2), dv.layout.rel_pos_y(s.y2))
}

pub fn (s &Line) bounds() gg.Rect {
	return gg.Rect{math.min(s.x1, s.x2), math.min(s.y1, s.y2), math.abs(s.x1 - s.x2), math.abs(s.y1 - s.y2)}
}

pub struct Poly {
	shape_style string
	points      []f32
	holes       []int
	offset_x    f32
	offset_y    f32
}

pub fn (s &Poly) draw(dv &DrawViewerComponent) {
	dv.shape_style[s.shape_style].poly(s.points, s.holes, dv.layout.rel_pos_x(s.offset_x),
		dv.layout.rel_pos_y(s.offset_y))
}

pub fn (s &Poly) bounds() gg.Rect {
	return points_bounds(s.points)
}

pub struct UniformSegmentPoly {
	shape_style string
	x           f32
	y           f32
	radius      f32
	steps       u32
}

pub fn (s &UniformSegmentPoly) draw(dv &DrawViewerComponent) {
	dv.shape_style[s.shape_style].uniform_segment_poly(dv.layout.rel_pos_x(s.x), dv.layout.rel_pos_y(s.y),
		s.radius, s.steps)
}

pub fn (s &UniformSegmentPoly) bounds() gg.Rect {
	return gg.Rect{} // s.x, s.y, s.w, s.h}
}

pub struct SegmentPoly {
	shape_style string
	x           f32
	y           f32
	radius_x    f32
	radius_y    f32
	steps       u32
}

pub fn (s &SegmentPoly) draw(dv &DrawViewerComponent) {
	dv.shape_style[s.shape_style].segment_poly(dv.layout.rel_pos_x(s.x), dv.layout.rel_pos_y(s.y),
		s.radius_x, s.radius_y, s.steps)
}

pub fn (s &SegmentPoly) bounds() gg.Rect {
	return gg.Rect{} // s.x, s.y, s.w, s.h}
}

pub struct UniformLineSegmentPoly {
	shape_style string
	x           f32
	y           f32
	radius      f32
	steps       u32
}

pub fn (s &UniformLineSegmentPoly) draw(dv &DrawViewerComponent) {
	dv.shape_style[s.shape_style].uniform_line_segment_poly(dv.layout.rel_pos_x(s.x),
		dv.layout.rel_pos_y(s.y), s.radius, s.steps)
}

pub fn (s &UniformLineSegmentPoly) bounds() gg.Rect {
	return gg.Rect{} // s.x, s.y, s.w, s.h}
}

pub struct LineSegmentPoly {
	shape_style string
	x           f32
	y           f32
	radius_x    f32
	radius_y    f32
	steps       u32
}

pub fn (s &LineSegmentPoly) draw(dv &DrawViewerComponent) {
	dv.shape_style[s.shape_style].line_segment_poly(dv.layout.rel_pos_x(s.x), dv.layout.rel_pos_y(s.y),
		s.radius_x, s.radius_y, s.steps)
}

pub fn (s &LineSegmentPoly) bounds() gg.Rect {
	return gg.Rect{} // s.x, s.y, s.w, s.h}
}

pub struct Circle {
	shape_style string
	x           f32
	y           f32
	radius      f32
	steps       u32
}

pub fn (s &Circle) draw(dv &DrawViewerComponent) {
	dv.shape_style[s.shape_style].circle(dv.layout.rel_pos_x(s.x), dv.layout.rel_pos_y(s.y),
		s.radius, s.steps)
}

pub fn (s &Circle) bounds() gg.Rect {
	return gg.Rect{s.x - s.radius, s.y - s.radius, s.radius * 2, s.radius * 2}
}

pub struct Ellipse {
	shape_style string
	x           f32
	y           f32
	radius_x    f32
	radius_y    f32
	steps       u32
}

pub fn (s &Ellipse) draw(dv &DrawViewerComponent) {
	dv.shape_style[s.shape_style].ellipse(dv.layout.rel_pos_x(s.x), dv.layout.rel_pos_y(s.y),
		s.radius_x, s.radius_y, s.steps)
}

pub fn (s &Ellipse) bounds() gg.Rect {
	return gg.Rect{s.x - s.radius_x, s.y - s.radius_y, s.radius_x * 2, s.radius_y * 2}
}

pub struct ConvexPoly {
	shape_style string
	points      []f32
	offset_x    f32
	offset_y    f32
}

pub fn (s &ConvexPoly) draw(dv &DrawViewerComponent) {
	dv.shape_style[s.shape_style].convex_poly(s.points, dv.layout.rel_pos_x(s.offset_x),
		dv.layout.rel_pos_y(s.offset_y))
}

pub fn (s &ConvexPoly) bounds() gg.Rect {
	return points_bounds(s.points)
}

pub struct Arc {
	shape_style        string
	x                  f32
	y                  f32
	radius             f32
	start_angle_in_rad f32
	angle_in_rad       f32
}

pub fn (s &Arc) draw(dv &DrawViewerComponent) {
	dv.shape_style[s.shape_style].arc(dv.layout.rel_pos_x(s.x), dv.layout.rel_pos_y(s.y),
		s.radius, s.start_angle_in_rad, s.angle_in_rad)
}

pub fn (s &Arc) bounds() gg.Rect {
	// TODO: currently same as circle
	return gg.Rect{s.x - s.radius, s.y - s.radius, s.radius * 2, s.radius * 2}
}

pub struct Triangle {
	shape_style string
	x1          f32
	y1          f32
	x2          f32
	y2          f32
	x3          f32
	y3          f32
}

pub fn (s &Triangle) draw(dv &DrawViewerComponent) {
	dv.shape_style[s.shape_style].triangle(dv.layout.rel_pos_x(s.x1), dv.layout.rel_pos_y(s.y1),
		dv.layout.rel_pos_x(s.x2), dv.layout.rel_pos_y(s.y2), dv.layout.rel_pos_x(s.x3),
		dv.layout.rel_pos_y(s.y3))
}

pub fn (s &Triangle) bounds() gg.Rect {
	return points_bounds([s.x1, s.y1, s.x2, s.y2, s.x3, s.y3])
}

pub struct Image {
	shape_style string
	x           f32
	y           f32
	w           f32
	h           f32
	path        string
}

pub fn (s &Image) draw(dv &DrawViewerComponent) {
	dv.shape_style[s.shape_style].image(dv.layout.rel_pos_x(s.x), dv.layout.rel_pos_y(s.y),
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
		for s in shapes[1..] {
			b = ui.union_rect(b, s.bounds())
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
