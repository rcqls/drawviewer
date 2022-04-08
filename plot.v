module drawviewer

import gg
import gx
import ui

enum MargPlot {
	bottom
	top
	left
	right
}

interface PlotShape {
	draw(dv &DrawViewerComponent)
	draw_device(d DeviceShape, dv &DrawViewerComponent)
	bounds() gg.Rect
mut:
	plot &Plot
	update()
}

struct Plot {
	id string
mut:
	x        int
	y        int
	width    int
	height   int
	marg     map[MargPlot]int
	xy       PlotCoordTransfrom
	shapes   []PlotShape
	bg_color gx.Color
}

[params]
pub struct PlotParams {
	id     string
	x      int
	y      int
	width  int
	height int
	xlim   [2]f64
	ylim   [2]f64
	shapes []PlotShape
	marg   map[MargPlot]int = {
		.top:    10,
		.bottom: 10,
		.left:   10,
		.right:  10,
	}
	bg_color gx.Color = ui.no_color
}

pub fn plot(p PlotParams) &Plot {
	// println(p.marg[.left])
	mut xy := PlotCoordTransfrom{
		x: p.x + p.marg[.left]
		y: p.y + p.marg[.top]
		width: p.width - p.marg[.left] - p.marg[.right]
		height: p.height - p.marg[.top] - p.marg[.bottom]
		from_x: p.xlim[0]
		to_x: p.xlim[1]
		from_y: p.ylim[0]
		to_y: p.ylim[1]
	}
	xy.update()
	mut pl := &Plot{
		id: p.id
		x: p.x
		y: p.y
		width: p.width
		height: p.height
		xy: xy
		marg: p.marg
		bg_color: p.bg_color
	}
	mut a := axis(
		from_x: f32(xy.from_x)
		to_x: f32(xy.to_x)
		from_y: f32(xy.from_y)
		to_y: f32(xy.to_y)
	)
	pl.shapes = [a]
	pl.shapes << p.shapes
	pl.connect_plot()
	return pl
}

pub fn (s &Plot) full_size() (int, int) {
	return s.width + s.marg[.left] + s.marg[.right], s.height + s.marg[.top] + s.marg[.bottom]
}

pub fn (s &Plot) draw(dv &DrawViewerComponent) {
	s.draw_device(dv.dsc, dv)
}

pub fn (s &Plot) draw_device(d DeviceShape, dv &DrawViewerComponent) {
	if s.bg_color != ui.no_color {
		dv.layout.draw_device_rect_filled(d.dd, s.x, s.y, s.width, s.height, s.bg_color)
	}
	for sh in s.shapes {
		sh.draw_device(d, dv)
	}
}

pub fn (s &Plot) bounds() gg.Rect {
	return union_bounds(s.shapes.map(it.bounds()))
}

pub fn (mut s Plot) connect_plot() {
	for mut s2 in s.shapes {
		s2.plot = unsafe { s }
		s2.update()
	}
}

pub fn (mut s Plot) add_shapes(shapes []PlotShape) {
	s.shapes << shapes
	s.connect_plot()
}

// Plot Coordinates Transformation

struct PlotCoordTransfrom {
mut:
	s_x f64 // slope
	i_x f64 // intercept
	s_y f64
	i_y f64
	// absolute
	x      int
	y      int
	width  int
	height int
	// relative
	from_x f64
	to_x   f64
	from_y f64
	to_y   f64
}

fn (mut p PlotCoordTransfrom) update() {
	p.s_x = f64(p.width) / (p.to_x - p.from_x)
	p.i_x = p.x - p.s_x * p.from_x
	p.s_y = f64(p.height) / (p.from_y - p.to_y)
	p.i_y = p.y - p.s_y * p.to_y
	// println("update $p.s_x $p.i_x and $p.s_y $p.i_y")
}

pub fn (p PlotCoordTransfrom) x(x f32) int {
	return int(p.s_x * x + p.i_x)
}

pub fn (p PlotCoordTransfrom) y(y f32) int {
	return int(p.s_y * y + p.i_y)
}

pub fn (p PlotCoordTransfrom) rel_x(x int) f32 {
	return f32((x - p.i_x) / p.s_x)
}

pub fn (p PlotCoordTransfrom) rel_y(y int) f32 {
	return f32((y - p.i_y) / p.s_y)
}

// Plot Shape

struct Axis {
mut:
	plot   &Plot = 0
	from_x f32
	x      f32
	to_x   f32
	from_y f32
	y      f32
	to_y   f32
	lines  Lines
}

[params]
pub struct AxisParams {
	style  string
	from_x f32
	x      f32 // default to 0 except if not in [from_x, to_x]
	to_x   f32
	from_y f32
	y      f32 // default to 0 except if not in [from_y, to_y]
	to_y   f32
}

pub fn axis(p AxisParams) &Axis {
	mut s := &Axis{
		from_x: p.from_x
		x: p.x
		to_x: p.to_x
		from_y: p.from_y
		y: p.y
		to_y: p.to_y
	}
	s.lines = lines(style: p.style)
	return s
}

pub fn (mut s Axis) update() {
	p := s.plot
	s.lines.x1 = [f32(p.xy.x(s.from_x)), p.xy.x(0)]
	s.lines.y1 = [f32(p.xy.y(0)), p.xy.y(s.from_y)]
	s.lines.x2 = [f32(p.xy.x(s.to_x)), p.xy.x(0)]
	s.lines.y2 = [f32(p.xy.y(0)), p.xy.y(s.to_y)]
	// println(s.lines)
}

pub fn (s &Axis) draw(dv &DrawViewerComponent) {
}

pub fn (s &Axis) draw_device(d DeviceShape, dv &DrawViewerComponent) {
	s.lines.draw_device(d, dv)
}

pub fn (s &Axis) bounds() gg.Rect {
	return s.lines.bounds()
}

struct ScatterPlot {
mut:
	plot        &Plot = 0
	shape_style string
	x           []f32
	y           []f32
	radii       []f32
	radius      f32
	points      Circles
}

[params]
pub struct ScatterPlotParams {
	style       string
	shape_style string
	x           []f32
	y           []f32
	radii       []f32
	radius      f32 = 1
}

pub fn scatterplot(p ScatterPlotParams) &ScatterPlot {
	return &ScatterPlot{
		shape_style: p.style
		x: p.x
		y: p.y
		radius: p.radius
		radii: p.radii
	}
}

pub fn (s &ScatterPlot) draw(dv &DrawViewerComponent) {
	s.draw_device(dv.dsc, dv)
}

pub fn (s &ScatterPlot) draw_device(d DeviceShape, dv &DrawViewerComponent) {
	s.points.draw_device(d, dv)
}

pub fn (s &ScatterPlot) bounds() gg.Rect {
	return s.points.bounds()
}

fn (mut s ScatterPlot) update() {
	p := s.plot
	s.points.shape_style = s.shape_style
	for i in 0 .. s.x.len {
		s.points.x << f32(p.xy.x(s.x[i]))
		s.points.y << f32(p.xy.y(s.y[i]))
	}
	s.points.radius = if s.radii.len > 0 { s.radii } else { [s.radius].repeat(s.x.len) }
}

pub type CurveFn = fn (x f64) f64

struct Curve {
mut:
	plot        &Plot = 0
	shape_style string
	f           CurveFn
	from        f32
	to          f32
	steps       u32
	path        Path
}

[params]
pub struct CurveParams {
	style string
	f     CurveFn
	from  f32
	to    f32
	steps u32 = 100
}

pub fn curve(p CurveParams) &Curve {
	return &Curve{
		shape_style: p.style
		f: p.f
		from: p.from
		to: p.to
		steps: p.steps
	}
}

pub fn (s &Curve) draw(dv &DrawViewerComponent) {
	s.draw_device(dv.dsc, dv)
}

pub fn (s &Curve) draw_device(d DeviceShape, dv &DrawViewerComponent) {
	s.path.draw_device(d, dv)
}

pub fn (s &Curve) bounds() gg.Rect {
	return s.path.bounds()
}

fn (mut s Curve) update() {
	p := s.plot
	// auto-adjustment from plot.xy
	if s.from == s.to {
		s.from = f32(p.xy.from_x)
		s.to = f32(p.xy.to_x)
		// println("curve range: $s.from, $s.to")
	}
	s.path.shape_style = s.shape_style
	// suppose first x, y same length
	mut x, dx := s.from, (s.to - s.from) / s.steps
	mut y := f32(s.f(x))
	s.path.x << f32(p.xy.x(x))
	s.path.y << f32(p.xy.y(y))
	for _ in 0 .. s.steps + 1 {
		x += dx
		y = f32(s.f(x))
		s.path.x << f32(p.xy.x(x))
		s.path.y << f32(p.xy.y(y))
	}
}
