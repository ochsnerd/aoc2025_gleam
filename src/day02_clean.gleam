import gleam/int
import gleam/list
import gleam/string
import gleam/yielder

pub fn solve(input: List(String)) -> Result(#(Int, Int), Nil) {
  let assert [line] = input
  let ranges = parse(line)

  let part1 =
    ranges
    |> list.flat_map(invalid_ids(2, _))
    |> int.sum()

  let part2 =
    ranges
    |> list.flat_map(fn(range) {
      let len = range.stop |> int.to_string() |> string.length()
      list.range(2, len)
      |> list.flat_map(invalid_ids(_, range))
      |> list.unique()
    })
    |> int.sum()

  Ok(#(part1, part2))
}

fn invalid_ids(repeats: Int, range: Range) -> List(Int) {
  yielder.unfold(1, next_invalid_id(repeats, _))
  |> yielder.drop_while(fn(id) { id < range.start })
  |> yielder.take_while(fn(id) { id < range.stop })
  |> yielder.to_list()
}

fn next_invalid_id(repeats: Int, chunk: Int) -> yielder.Step(Int, Int) {
  let assert Ok(new__id) =
    chunk
    |> int.to_string()
    |> list.repeat(repeats)
    |> string.join("")
    |> int.parse()
  yielder.Next(new__id, chunk + 1)
}

type Range {
  Range(start: Int, stop: Int)
}

fn parse(line: String) -> List(Range) {
  line
  |> string.split(",")
  |> list.map(fn(s) {
    let assert [start, stop] = string.split(s, "-")
    let assert Ok(start) = int.parse(start)
    let assert Ok(stop) = int.parse(stop)
    Range(start, stop)
  })
}
