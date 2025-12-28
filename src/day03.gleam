// Notes
// - nice generalization from Part 1 to Part 2
// - max_by_key sucks because there are no generics/typeclasses

import gleam/int
import gleam/list
import gleam/pair
import gleam/result
import gleam/string
import util.{max_by_key, undigits}

pub fn solve(input: List(String)) -> Result(#(Int, Int), Nil) {
  use batteries <- result.try(input |> list.try_map(parse))
  let part1 =
    batteries
    |> list.map(highest_jolt1)
    |> int.sum()
  let part2 =
    batteries
    |> list.map(highest_jolt2)
    |> int.sum()
  Ok(#(part1, part2))
}

fn parse(line: String) -> Result(List(Int), Nil) {
  line |> string.to_graphemes() |> list.try_map(int.parse)
}

fn highest_jolt1(batteries: List(Int)) -> Int {
  // We know we always have at least one battery
  let assert [b0, ..batteries] = list.reverse(batteries)
  batteries
  |> list.fold(#(0, b0), fn(acc, bat) {
    let #(current, biggest) = acc
    #(int.max(current, to_int(bat, biggest)), int.max(bat, biggest))
  })
  |> pair.first
}

fn to_int(a: Int, b: Int) -> Int {
  a * 10 + b
}

fn highest_jolt2(batteries: List(Int)) -> Int {
  let #(on0, rest) = batteries |> list.reverse() |> list.split(11)
  rest
  |> list.fold(#(0, list.reverse(on0)), fn(acc, bat) {
    let #(current, biggest) = acc
    let biggest_n =
      max_by_key(
        biggest,
        [bat, ..drop_first_increasing(biggest)],
        undigits,
        int.compare,
      )
    #(int.max(current, undigits([bat, ..biggest])), biggest_n)
  })
  |> pair.first
}

fn drop_first_increasing(l: List(Int)) -> List(Int) {
  drop_first_increasing_loop(l, [])
}

fn drop_first_increasing_loop(l: List(Int), acc: List(Int)) -> List(Int) {
  case l {
    [] | [_] -> list.reverse(acc)
    [a, b, ..xs] if a < b -> list.append(list.reverse(acc), [b, ..xs])
    [a, b, ..xs] -> drop_first_increasing_loop([b, ..xs], [a, ..acc])
  }
}
