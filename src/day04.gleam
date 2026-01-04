import geometry.{type Point, Point, neighbors}
import gleam/int
import gleam/list
import gleam/set
import gleam/string
import gleam/yielder

pub fn solve(input: List(String)) -> Result(#(Int, Int), Nil) {
  let rolls = to_set(input)
  let part1 = solve1(rolls)
  let part2 = solve2(rolls)
  assert part2 == solve2_fold(rolls)
  Ok(#(part1, part2))
}

fn solve1(rolls: set.Set(Point)) -> Int {
  rolls
  |> all_removable()
  |> set.size()
}

fn solve2(rolls: set.Set(Point)) -> Int {
  solve2_loop(rolls, 0)
}

fn solve2_loop(rolls: set.Set(Point), removed: Int) -> Int {
  let removable = all_removable(rolls)
  // sad: since set.Set is an opaque type, I cannot directly pattern match on
  // the empty constructor
  case set.is_empty(removable) {
    True -> removed
    False ->
      solve2_loop(
        rolls |> set.difference(removable),
        removed + set.size(removable),
      )
  }
}

fn all_removable(rolls: set.Set(Point)) -> set.Set(Point) {
  rolls
  |> set.filter(is_removable(_, rolls))
}

fn is_removable(roll: Point, rolls: set.Set(Point)) -> Bool {
  roll
  |> neighbors()
  |> list.count(set.contains(rolls, _))
  < 4
}

fn to_set(input: List(String)) -> set.Set(Point) {
  input
  |> list.index_map(fn(line, row) {
    line
    |> string.to_graphemes()
    |> list.index_map(fn(char, column) { #(char, row, column) })
  })
  |> list.flatten()
  |> list.filter_map(fn(x) {
    case x {
      #("@", row, column) -> Ok(Point(row, column))
      _ -> Error(Nil)
    }
  })
  |> set.from_list()
}

fn solve2_fold(rolls: set.Set(Point)) -> Int {
  yielder.unfold(rolls, fn(rolls) {
    let removable = all_removable(rolls)
    case set.is_empty(removable) {
      True -> yielder.Done
      False ->
        yielder.Next(set.size(removable), rolls |> set.difference(removable))
    }
  })
  |> yielder.fold(0, int.add)
}
