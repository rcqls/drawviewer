module drawviewer

import ui

interface DeviceShape {
	rectangle(x f32, y f32, w f32, h f32, style string)
	line(x1 f32, y1 f32, x2 f32, y2 f32, style string)
	uniform_segment_poly(x f32, y f32, radius f32, steps u32, style string)
	segment_poly(x f32, y f32, radius_x f32, radius_y f32, steps u32, style string)
	uniform_line_segment_poly(x f32, y f32, radius f32, steps u32, style string)
	line_segment_poly(x f32, y f32, radius_x f32, radius_y f32, steps u32, style string)
	circle(x f32, y f32, radius f32, steps u32, style string)
	ellipse(x f32, y f32, radius_x f32, radius_y f32, steps u32, style string)
	convex_poly(points []f32, offset_x f32, offset_y f32, style string)
	poly(points []f32, holes []int, offset_x f32, offset_y f32, style string)
	arc(x f32, y f32, radius f32, start_angle_in_rad f32, angle_in_rad f32, style string)
	rounded_rectangle(x f32, y f32, w f32, h f32, radius f32, style string)
	triangle(x1 f32, y1 f32, x2 f32, y2 f32, x3 f32, y3 f32, style string)
	image(x f32, y f32, w f32, h f32, path string, style string)
mut:
	dd ui.DrawDevice
}
