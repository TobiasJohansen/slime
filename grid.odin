package main

import math "core:math"
import rl "vendor:raylib"

Grid :: struct {
	cols:         i32,
	rows:         i32,
	cell_size:    f32,
	read_buffer:  []f32,
	write_buffer: []f32,
}

init_grid :: proc(cols, rows: i32, cell_size: f32) -> Grid {
	total_cells := cols * rows
	return Grid {
		cols = cols,
		rows = rows,
		cell_size = cell_size,
		read_buffer = make([]f32, total_cells),
		write_buffer = make([]f32, total_cells),
	}
}

draw_grid :: proc(grid: ^Grid, color: rl.Color) {
	for row in 0 ..< grid.rows {
		for col in 0 ..< grid.cols {
			rectangle := rl.Rectangle {
				x      = f32(col) * grid.cell_size,
				y      = f32(row) * grid.cell_size,
				width  = grid.cell_size,
				height = grid.cell_size,
			}

			sample := grid.read_buffer[row * grid.cols + col]

			if sample > 0 {
				intensity := math.clamp(sample, 0.0, 1.0)

				color_start := rl.BLACK
				color_end := rl.Color{80, 255, 120, 255}

				r := u8(math.lerp(f32(color_start.r), f32(color_end.r), intensity))
				g := u8(math.lerp(f32(color_start.g), f32(color_end.g), intensity))
				b := u8(math.lerp(f32(color_start.b), f32(color_end.b), intensity))

				rl.DrawRectangleRec(rectangle, rl.Color{r, g, b, 255})
			}
		}
	}
}

sample_grid :: proc(g: ^Grid, pos: rl.Vector2) -> f32 {
	col := i32(math.floor(f32(pos.x / g.cell_size)))
	row := i32(math.floor(f32(pos.y / g.cell_size)))

	if col < 0 || col >= g.cols || row < 0 || row >= g.rows {
		return 0.0
	}

	return g.read_buffer[row * g.cols + col]
}

deposit_grid :: proc(g: ^Grid, pos: rl.Vector2, dt: f32) {
	col := i32(math.floor(f32(pos.x / g.cell_size)))
	row := i32(math.floor(f32(pos.y / g.cell_size)))

	if col < 0 || col >= g.cols || row < 0 || row >= g.rows {
		return
	}

	idx := row * g.cols + col
	new_val := g.read_buffer[idx] + (60 * dt)
	g.read_buffer[idx] = math.min(new_val, 1.0)
}

diffuse_grid :: proc(g: ^Grid, dt: f32) {
	diffuse_speed: f32 = 10.0
	evaporate_speed: f32 = 1.5

	diffuse_factor := math.clamp(diffuse_speed * dt, 0.0, 1.0)
	evaporate_factor := math.exp(-evaporate_speed * dt)

	for row in 0 ..< g.rows {
		for col in 0 ..< g.cols {
			sum: f32 = 0.0
			count: i32 = 0

			for d_row in i32(-1) ..= 1 {
				for d_col in i32(-1) ..= 1 {
					n_col, n_row := col + d_col, row + d_row
					if (n_col >= 0 && n_col < g.cols && n_row >= 0 && n_row < g.rows) {
						sum += g.read_buffer[n_row * g.cols + n_col]
						count += 1
					}
				}
			}

			index := row * g.cols + col
			current_value := g.read_buffer[index]
			blur := math.lerp(current_value, sum / f32(count), diffuse_factor)
			new_value := blur * evaporate_factor

			if new_value > 0.01 {
				g.write_buffer[index] = new_value
			} else {
				g.write_buffer[index] = 0
			}
		}
	}

	g.read_buffer, g.write_buffer = g.write_buffer, g.read_buffer
}

destroy_grid :: proc(grid: ^Grid) {
	delete(grid.read_buffer)
	delete(grid.write_buffer)
}
