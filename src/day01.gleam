import gleam/int
import gleam/list
import gleam/result

pub fn solve(input: List(String)) -> Result(#(Int, Int), Nil) {
  use rotations <- result.try(input |> list.try_map(parse_line))
  let positions =
    rotations
    |> list.scan(50, fn(dial, rotation) {
      case rotation {
        R(d) -> dial + d
        L(d) -> dial - d
      }
    })

  let part1 =
    positions
    |> list.map(fn(x) { x % 100 })
    |> list.count(fn(x) { x == 0 })

  let part2 = {
    [50, ..positions]
    |> list.map2(positions, fn(p1, p2) {
      int.absolute_value(
        {
          { p1 }
          |> int.floor_divide(100)
          |> result.unwrap(0)
        }
        - {
          { p2 }
          |> int.floor_divide(100)
          |> result.unwrap(0)
        },
      )
      - case p1 % 100 {
        0 if p1 > p2 -> 1
        _ -> 0
      }
      + case p2 % 100 {
        0 if p1 > p2 -> 1
        _ -> 0
      }
    })
    |> int.sum()
  }

  Ok(#(part1, part2))
}

// I'm aware that +/- would have been simpler
type Rotation {
  R(deg: Int)
  L(deg: Int)
}

fn parse_line(line: String) -> Result(Rotation, Nil) {
  case line {
    "R" <> deg -> deg |> int.parse |> result.map(fn(deg) { R(deg) })
    "L" <> deg -> deg |> int.parse |> result.map(fn(deg) { L(deg) })
    _ -> Error(Nil)
  }
}
