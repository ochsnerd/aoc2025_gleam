import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/order
import gleam/result
import gleam/string

pub fn solve(input: List(String)) -> Result(#(Int, Int), Nil) {
  use line <- result.try(single(input))
  use ranges <- result.try(parse(line))

  let part1 =
    ranges
    |> list.flat_map(fn(r) { invalid_ids_1(r) })
    |> int.sum()

  Ok(#(part1, 0))
  // hello???
  // echo invalid_ids(Range(95, 115))
}

type Range {
  Range(start: Int, stop: Int)
}

fn invalid_ids_1(r: Range) -> List(Int) {
  successors(Some(some_previous_invalid_id(r.start)), fn(id) {
    case next_invalid_id(id) {
      next if next <= r.stop -> Some(next)
      _ -> None
    }
  })
  |> list.filter(fn(id) { r.start <= id })
}

fn parse(line: String) -> Result(List(Range), Nil) {
  line
  |> string.split(",")
  // list.try_map <=> Iterator.map(fn(T) -> Result<U, E>).collect::<Result<Vec<U>, E>>()
  |> list.try_map(fn(s) {
    case string.split(s, "-") {
      // Cannot do a string pattern with a variable at the start :(
      [start, stop] -> {
        // Applicative
        use start <- result.try(int.parse(start))
        use stop <- result.try(int.parse(stop))
        Ok(Range(start, stop))
      }
      _ -> Error(Nil)
    }
  })
}

fn some_previous_invalid_id(i: Int) -> Int {
  let assert Ok(ds) = digits(i, 10)
  let len = list.length(ds)
  let assert Ok(first_half) = undigits(list.take(ds, len / 2), 10)
  let first_half = first_half - 1
  let assert Ok(ds) = digits(first_half, 10)
  let assert Ok(id) = undigits(list.append(ds, ds), 10)
  int.max(0, id)
}

fn next_invalid_id(i: Int) -> Int {
  assert is_invalid_id(i)
  let assert Ok(ds) = digits(i, 10)
  // interesting docs on list.length
  let len = list.length(ds)
  let assert Ok(first_half) = undigits(list.take(ds, { len + 1 } / 2), 10)
  let first_half = first_half + 1
  let assert Ok(ds) = digits(first_half, 10)
  let assert Ok(id) = undigits(list.append(ds, ds), 10)
  id
}

fn is_invalid_id(i: Int) -> Bool {
  case int.compare(i, 0) {
    order.Lt -> False
    // by my definition
    order.Eq -> True
    _ -> {
      let assert Ok(ds) = digits(i, 10)
      // interesting docs on list.length
      let len = list.length(ds)
      case len % 2 {
        0 -> {
          let #(a, b) = list.split(ds, len / 2)
          list.all(list.zip(a, b), fn(x) {
            let #(l, r) = x
            l == r
          })
        }
        _ -> False
      }
    }
  }
}

// Generalization of list.range:
// ```gleam
//   list.range(a, b)
// ```
// is equivalent to
// ```gleam
//   generate(option.Some(1), fn(i) {
//     case i + 1 {
//       i if i < 10 -> option.Some(i)
//       _ -> option.None
//    }
//  })
//   generate(Some(a), 
// ```
fn successors(start: Option(t), next: fn(t) -> Option(t)) -> List(t) {
  case start {
    None -> []
    Some(s) -> list.reverse(successors_loop(s, next, [s]))
  }
}

fn successors_loop(start: t, next: fn(t) -> Option(t), acc: List(t)) -> List(t) {
  case next(start) {
    None -> acc
    Some(n) -> successors_loop(n, next, [n, ..acc])
  }
}

fn single(l: List(t)) -> Result(t, Nil) {
  case l {
    [i] -> Ok(i)
    _ -> Error(Nil)
  }
}

// from standard library
pub fn digits(x: Int, base: Int) -> Result(List(Int), Nil) {
  case base < 2 {
    True -> Error(Nil)
    False -> Ok(digits_loop(x, base, []))
  }
}

fn digits_loop(x: Int, base: Int, acc: List(Int)) -> List(Int) {
  case int.absolute_value(x) < base {
    True -> [x, ..acc]
    False -> digits_loop(x / base, base, [x % base, ..acc])
  }
}

pub fn undigits(numbers: List(Int), base: Int) -> Result(Int, Nil) {
  case base < 2 {
    True -> Error(Nil)
    False -> undigits_loop(numbers, base, 0)
  }
}

fn undigits_loop(numbers: List(Int), base: Int, acc: Int) -> Result(Int, Nil) {
  case numbers {
    [] -> Ok(acc)
    [digit, ..] if digit >= base -> Error(Nil)
    [digit, ..rest] -> undigits_loop(rest, base, acc * base + digit)
  }
}
