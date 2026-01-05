import gleam/int
import gleam/list
import gleam/result
import gleam/string
import interval.{type Interval, new}
import interval_tree.{type Tree, from_list, intersections}

pub fn solve(input: List(String)) -> Result(#(Int, Int), Nil) {
  use #(intervals, points) <- result.try(read(input))
  let interval_tree = from_list(intervals)
  let part1 = part1(interval_tree, points)
  let part2 = part2(intervals)
  Ok(#(part1, part2))
}

fn part1(intervals: Tree, points: List(Int)) -> Int {
  points
  |> list.count(fn(p) { intersections(intervals, p) != [] })
}

type Point {
  Start(v: Int)
  Stop(v: Int)
}

type Section {
  Section(open_intervals: Int, start: Int)
}

fn part2(intervals: List(Interval)) -> Int {
  intervals
  |> list.flat_map(fn(i) { [Start(v: i.start), Stop(i.stop + 1)] })
  |> list.sort(fn(p1, p2) { int.compare(p1.v, p2.v) })
  |> list.scan(Section(open_intervals: 0, start: 0), fn(acc, p) {
    case p {
      Start(v:) -> Section(open_intervals: acc.open_intervals + 1, start: v)
      Stop(v:) -> Section(open_intervals: acc.open_intervals - 1, start: v)
    }
  })
  |> list.window_by_2()
  |> list.filter_map(fn(ps) {
    case ps {
      #(Section(open_intervals: 0, ..), _) -> Error(Nil)
      #(Section(start: begin, ..), Section(start: end, ..)) -> Ok(end - begin)
    }
  })
  |> int.sum()
}

fn read(input: List(String)) -> Result(#(List(Interval), List(Int)), Nil) {
  let #(intervals, points) =
    list.split_while(input, fn(s) { !string.is_empty(s) })

  use intervals <- result.try(
    intervals
    |> list.try_map(fn(s) {
      case string.split(s, "-") {
        [start, stop] -> {
          use start <- result.try(int.parse(start))
          use stop <- result.try(int.parse(stop))
          Ok(new(start, stop))
        }
        _ -> Error(Nil)
      }
    }),
  )
  use points <- result.try(
    points
    // list.split_while keeps the split-element ("")
    |> list.drop(1)
    |> list.try_map(int.parse),
  )
  Ok(#(intervals, points))
}
