import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/option
import gleam/pair
import gleam/result
import gleam/set.{type Set}
import gleam/string

pub fn solve(input: List(String)) -> Result(#(Int, Int), Nil) {
  let input = list.map(input, parse_line)
  use start <- result.try(list.first(input))
  use rest <- result.try(list.rest(input))
  let part1 = part1(start, rest)
  let part2 = part2(start, rest)
  Ok(#(part1, part2))
}

fn part1(start: Set(Int), levels: List(Set(Int))) -> Int {
  levels
  |> list.fold(#(0, start), do_level)
  |> pair.first
}

fn part2(start: Set(Int), levels: List(Set(Int))) -> Int {
  let start =
    start
    |> set.to_list()
    |> list.map(fn(i) { #(i, 1) })
    |> dict.from_list()
  levels
  |> list.fold(start, do_level2)
  |> dict.to_list()
  |> list.map(pair.second)
  |> int.sum()
}

fn parse_line(line: String) -> Set(Int) {
  line
  |> string.to_graphemes()
  |> list.index_fold(set.new(), fn(set, c, i) {
    case c {
      "^" | "S" -> set.insert(set, i)
      _ -> set
    }
  })
}

fn do_level(incoming: #(Int, Set(Int)), splitters: Set(Int)) -> #(Int, Set(Int)) {
  let #(splits, streams) = incoming
  set.fold(streams, #(splits, set.new()), fn(p, stream) {
    case set.contains(splitters, stream), p {
      True, #(splits, outgoing) -> #(
        splits + 1,
        outgoing |> set.insert(stream + 1) |> set.insert(stream - 1),
      )
      False, #(splits, outgoing) -> #(splits, outgoing |> set.insert(stream))
    }
  })
}

fn do_level2(incoming: Dict(Int, Int), splitters: Set(Int)) -> Dict(Int, Int) {
  dict.fold(incoming, dict.new(), fn(outgoing, position, weight) {
    case set.contains(splitters, position) {
      True ->
        outgoing
        |> add_beam(position - 1, weight)
        |> add_beam(position + 1, weight)
      False -> add_beam(outgoing, position, weight)
    }
  })
}

fn add_beam(
  streams: Dict(Int, Int),
  position: Int,
  weight: Int,
) -> Dict(Int, Int) {
  dict.upsert(streams, position, fn(existing) {
    existing |> option.map(int.add(_, weight)) |> option.unwrap(weight)
  })
}
