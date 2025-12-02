import gleam/list
import gleam/result
import gleam/string
import simplifile

pub fn read_lines(filename: String) -> Result(List(String), Nil) {
  simplifile.read(filename)
  |> result.map(fn(s) { string.split(s, "\n") })
  |> result.map(fn(ss) { ss |> list.filter(fn(s) { !string.is_empty(s) }) })
  |> result.map_error(fn(_) { Nil })
}
