import gleam/dict
import gleam/int
import gleam/list
import gleam/order
import gleam/pair
import gleam/result
import gleam/set
import gleam/string

pub fn solve(input: List(String)) -> Result(#(Int, Int), Nil) {
  use points <- result.try(list.try_map(input, parse))
  let part1 = part1(points)
  Ok(#(part1, 0))
}

fn part1(points: List(Point)) -> Int {
  points
  |> list.combination_pairs()
  |> list.map(fn(pair) {
    let #(a, b) = pair
    #(dist_sq(a, b), pair)
  })
  // sortBy (compare `on` fst)
  |> list.sort(fn(a, b) { int.compare(pair.first(a), pair.first(b)) })
  |> list.map(pair.second)
  |> list.take(1000)
  |> list.fold(
    points |> list.map(fn(p) { #(p, set.from_list([p])) }) |> dict.from_list(),
    fn(groups, connection) {
      let #(a, b) = connection
      let assert Ok(a_group) = dict.get(groups, a)
      let assert Ok(b_group) = dict.get(groups, b)
      let new_group = set.union(a_group, b_group)
      new_group
      |> set.fold(groups, fn(groups, member) {
        dict.insert(groups, member, new_group)
      })
    },
  )
  |> dict.to_list()
  |> list.map(pair.second)
  |> list.unique()
  |> list.sort(fn(a, b) { order.negate(int.compare(set.size(a), set.size(b))) })
  |> list.take(3)
  |> list.map(set.size)
  |> int.product()
}

type Point {
  Point(x: Int, y: Int, z: Int)
}

fn dist_sq(a: Point, b: Point) -> Int {
  let Point(ax, ay, az) = a
  let Point(bx, by, bz) = b
  let #(dx, dy, dz) = #(bx - ax, by - ay, bz - az)
  dx * dx + dy * dy + dz * dz
}

fn parse(l: String) -> Result(Point, Nil) {
  case string.split(l, ",") {
    [x, y, z] -> {
      use x <- result.try(int.parse(x))
      use y <- result.try(int.parse(y))
      use z <- result.try(int.parse(z))
      Ok(Point(x:, y:, z:))
    }
    _ -> Error(Nil)
  }
}
