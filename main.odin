package main

import math "core:math"
import rl "vendor:raylib"

WINDOW_WIDTH :: 1000
WINDOW_HEIGHT :: 1000

GRID_COLS :: 500
GRID_ROWS :: 500
AGENT_COUNT :: 25000

main :: proc() {
	rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Slime")
	defer rl.CloseWindow()

	cell_size := f32(min(WINDOW_WIDTH / GRID_COLS, WINDOW_HEIGHT / GRID_ROWS))

	simulation := init_simulation(GRID_COLS, GRID_ROWS, cell_size, AGENT_COUNT)
	defer destroy_simulation(&simulation)

	for !rl.WindowShouldClose() {
		dt := math.min(rl.GetFrameTime(), 0.1)

		if rl.IsMouseButtonDown(.LEFT) {
			deposit_grid(&simulation.grid, rl.GetMousePosition(), dt)
		}

		update_simulation(&simulation, dt)

		rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)

		draw_simulation(&simulation)

		rl.EndDrawing()
	}
}
