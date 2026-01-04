import day01
import day02
import day02_clean
import day03
import day04
import gleam/int
import gleam/result
import util

// simple perf check:
// gleam build && gleam run -m gleescript && time ./aoc2025_gleam
pub fn main() {
  let _ = echo solve(day01.solve, "day01")
  let _ = echo solve(day02.solve, "day02")
  let _ = echo solve(day02_clean.solve, "day02")
  let _ = echo solve(day03.solve, "day03")
  let _ = echo solve(day04.solve, "day04")
}

fn solve(
  f: fn(List(String)) -> Result(#(Int, Int), Nil),
  day: String,
) -> Result(String, Nil) {
  use lines <- result.try(util.read_lines("input/" <> day <> ".txt"))
  use #(part1, part2) <- result.try(f(lines))
  Ok(day <> ": " <> int.to_string(part1) <> ", " <> int.to_string(part2))
}
