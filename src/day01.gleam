import gleam/int
import gleam/list
import gleam/result

pub fn solve(input: List(String)) -> Result(#(Int, Int), Nil) {
  use rotations <- result.try(input |> list.try_map(parse_line))
  let positions =
    rotations
    |> list.scan(50, int.add)

  let part1 =
    positions
    |> list.count(fn(x) { x % 100 == 0 })

  let part2 =
    list.map2([50, ..positions], positions, fn(p1, p2) {
      let revolution_diff =
        int.absolute_value(full_revolutions(p1) - full_revolutions(p2))
      // prevent counting too late when we
      // end at 0 and came from the right
      let corr1 = case p2 % 100 {
        0 if p1 > p2 -> 1
        _ -> 0
      }
      // prevent double-counting when we
      // started at 0 and go left
      let corr2 = case p1 % 100 {
        0 if p1 > p2 -> -1
        _ -> 0
      }
      revolution_diff + corr1 + corr2
    })
    |> int.sum()

  Ok(#(part1, part2))
}

fn full_revolutions(p: Int) -> Int {
  p
  // int.floor_divide(-3, 100) == -1
  |> int.floor_divide(100)
  |> result.lazy_unwrap(fn() { panic as "Cloudflare" })
}

fn parse_line(line: String) -> Result(Int, Nil) {
  case line {
    "R" <> deg -> deg |> int.parse
    "L" <> deg -> deg |> int.parse |> result.map(int.negate)
    _ -> Error(Nil)
  }
}
