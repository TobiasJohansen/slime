package main

import math "core:math"
import rand "core:math/rand"
import rl "vendor:raylib"

TAU := f32(math.PI * 2)


Agent :: struct {
	position:        rl.Vector2,
	angle:           f32,
	move_speed:      f32,
	turn_speed:      f32,
	sensor_angle:    f32,
	sensor_distance: f32,
}

get_left_sensor_position :: proc(a: ^Agent) -> rl.Vector2 {
	left_sensor_angle := a.angle - a.sensor_angle
	return rl.Vector2 {
		a.position.x + math.cos(left_sensor_angle) * a.sensor_distance,
		a.position.y + math.sin(left_sensor_angle) * a.sensor_distance,
	}
}

get_front_sensor_position :: proc(a: ^Agent) -> rl.Vector2 {
	return rl.Vector2 {
		a.position.x + math.cos(a.angle) * a.sensor_distance,
		a.position.y + math.sin(a.angle) * a.sensor_distance,
	}
}

get_right_sensor_position :: proc(a: ^Agent) -> rl.Vector2 {
	right_sensor_angle := a.angle + a.sensor_angle
	return rl.Vector2 {
		a.position.x + math.cos(right_sensor_angle) * a.sensor_distance,
		a.position.y + math.sin(right_sensor_angle) * a.sensor_distance,
	}
}

steer_left :: proc(a: ^Agent, dt: f32) {
	a.angle -= a.turn_speed * dt
}

steer_right :: proc(a: ^Agent, dt: f32) {
	a.angle += a.turn_speed * dt
}

update_agent :: proc(a: ^Agent, g: ^Grid, dt: f32) {
	left_sample := sample_grid(g, get_left_sensor_position(a))
	front_sample := sample_grid(g, get_front_sensor_position(a))
	right_sample := sample_grid(g, get_right_sensor_position(a))

	if left_sample > front_sample && left_sample > right_sample {
		steer_left(a, dt)
	} else if right_sample > front_sample && right_sample > left_sample {
		steer_right(a, dt)
	}

	jitter_strength: f32 = 2.0
	a.angle += (rand.float32() * 2.0 - 1.0) * jitter_strength * dt

	next_position := get_next_position(a, dt)

	hit_x := next_position.x < 0 || next_position.x > f32(g.cols) * g.cell_size
	hit_y := next_position.y < 0 || next_position.y > f32(g.rows) * g.cell_size

	if hit_x || hit_y {
		if hit_x && hit_y {
			a.angle = math.mod(a.angle + math.PI, TAU)
		} else if hit_x {
			a.angle = math.mod(3.0 * math.PI - a.angle, TAU)
		} else if hit_y {
			a.angle = math.mod(2.0 * math.PI - a.angle, TAU)
		}
		next_position = get_next_position(a, dt)
	}

	a.position = next_position

	deposit_grid(g, a.position, dt)
}

get_next_position :: proc(a: ^Agent, dt: f32) -> rl.Vector2 {
	return rl.Vector2 {
		a.position.x + a.move_speed * math.cos(a.angle) * dt,
		a.position.y + a.move_speed * math.sin(a.angle) * dt,
	}
}

draw_agent :: proc(a: ^Agent) {
	rl.DrawCircleV(a.position, 5, rl.RED)

	x2 := a.position.x + a.move_speed * 10 * math.cos(a.angle)
	y2 := a.position.y + a.move_speed * 10 * math.sin(a.angle)

	rl.DrawLineV(a.position, {x2, y2}, rl.BLUE)
	rl.DrawLineV(a.position, get_left_sensor_position(a), rl.YELLOW)
	rl.DrawLineV(a.position, get_front_sensor_position(a), rl.YELLOW)
	rl.DrawLineV(a.position, get_right_sensor_position(a), rl.YELLOW)
}
