package main

import math "core:math"
import rand "core:math/rand"
import rl "vendor:raylib"

Simulation :: struct {
	grid:   Grid,
	agents: []Agent,
}

init_simulation :: proc(cols, rows: i32, cell_size: f32, agent_count: i32) -> Simulation {
	agents := make([]Agent, agent_count)

	for idx in 0 ..< agent_count {
		agents[idx] = Agent {
			position        = {
				rand.float32_range(0, f32(cols) * cell_size),
				rand.float32_range(0, f32(rows) * cell_size),
			},
			angle           = rand.float32_range(0, math.TAU),
			move_speed      = rand.float32_range(40, 80),
			turn_speed      = rand.float32_range(15, 20),
			sensor_angle    = 20.0 * (math.PI / 180.0),
			sensor_distance = rand.float32_range(15, 20),
		}
	}

	return Simulation{grid = init_grid(cols, rows, cell_size), agents = agents}
}

update_simulation :: proc(simulation: ^Simulation, dt: f32) {
	for &agent in simulation.agents {
		update_agent(&agent, &simulation.grid, dt)
	}

	diffuse_grid(&simulation.grid, dt)
}

draw_simulation :: proc(simulation: ^Simulation) {
	draw_grid(&simulation.grid, rl.GREEN)

	for &agent in simulation.agents {
		//draw_agent(&agent)
	}
}

destroy_simulation :: proc(simulation: ^Simulation) {
	destroy_grid(&simulation.grid)
}
