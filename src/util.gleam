import gleam/int
import gleam/list
import gleam/order
import gleam/result
import gleam/string
import simplifile

pub fn read_lines(filename: String) -> Result(List(String), Nil) {
  simplifile.read(filename)
  |> result.map(fn(s) { string.split(s, "\n") })
  |> result.map(fn(ss) { ss |> list.filter(fn(s) { !string.is_empty(s) }) })
  |> result.map_error(fn(_) { Nil })
}

// this sucks without typeclasses/generics
pub fn max_by_key(
  a: a,
  b: a,
  key: fn(a) -> k,
  compare: fn(k, k) -> order.Order,
) -> a {
  case compare(key(a), key(b)) {
    order.Lt -> b
    _ -> a
  }
}

// from standard library (hardcoded base 10), could also do string stuff
pub fn digits(x: Int) -> List(Int) {
  digits_loop(x, 10, [])
}

fn digits_loop(x: Int, base: Int, acc: List(Int)) -> List(Int) {
  case int.absolute_value(x) < base {
    True -> [x, ..acc]
    False -> digits_loop(x / base, base, [x % base, ..acc])
  }
}

pub fn undigits(numbers: List(Int)) -> Int {
  undigits_loop(numbers, 10, 0)
}

fn undigits_loop(numbers: List(Int), base: Int, acc: Int) -> Int {
  case numbers {
    [] -> acc
    [digit, ..rest] -> undigits_loop(rest, base, acc * base + digit)
  }
}
