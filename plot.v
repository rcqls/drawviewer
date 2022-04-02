module drawviewer

import gg

enum MargPlot {
	bottom
	top
	left
	right
}

interface PlotShape {
	draw(dv &DrawViewerComponent)
	bounds() gg.Rect
mut:
	plot &Plot
	update()
}

struct Plot {
	id string
mut:
	marg   map[MargPlot]int
	xy     PlotCoordTransfrom
	shapes []PlotShape
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
}

pub fn plot(p PlotParams) &Plot {
	mut xy := PlotCoordTransfrom{
		x: p.x
		y: p.y
		width: p.width
		height: p.height
		from_x: p.xlim[0]
		to_x: p.xlim[1]
		from_y: p.ylim[0]
		to_y: p.ylim[1]
	}
	xy.update()
	mut pl := &Plot{
		id: p.id
		xy: xy
		marg: p.marg
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

pub fn (s &Plot) draw(dv &DrawViewerComponent) {
	for sh in s.shapes {
		sh.draw(dv)
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
	s.lines.draw(dv)
}

pub fn (s &Axis) bounds() gg.Rect {
	return s.lines.bounds()
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
	s.path.draw(dv)
}

pub fn (s &Curve) bounds() gg.Rect {
	mut x, mut y, dx := [s.from], [f32(s.f(s.from))], (s.to - s.from) / s.steps
	for i in 1 .. s.steps + 1 {
		x << s.from + dx * i
		y << f32(s.f(s.from + dx * i))
	}
	return xy_bounds(x, y)
}

fn (mut s Curve) update() {
	p := s.plot
	// auto-adjustment from plot.xy
	if s.from == s.to {
		s.from = f32(p.xy.from_x)
		s.to = f32(p.xy.to_x)
		// println("curve range: $s.from, $s.to")
	}
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
