import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/pair
import gleam/result
import gleam/string

pub fn solve(input: List(String)) -> Result(#(Int, Int), Nil) {
  let assert [line] = input
  use ranges <- result.try(parse(line))

  let part1 =
    ranges
    |> list.flat_map(fn(r) { invalid_ids_p1(r) })
    |> int.sum()

  let _ =
    list.each(ranges, fn(r) {
      assert invalid_ids(2, r) == invalid_ids_p1(r)
    })

  let part2 =
    ranges
    |> list.flat_map(fn(r) { invalid_ids_p2(r) })
    |> int.sum()

  // hello???
  // echo invalid_ids(2, Range(87, 115))
  Ok(#(part1, part2))
}

type Range {
  Range(start: Int, stop: Int)
}

fn invalid_ids_p1(r: Range) -> List(Int) {
  successors(Some(11), fn(id) {
    case next_invalid_id1_successors(id) {
      next if next <= r.stop -> Some(next)
      _ -> None
    }
  })
  |> list.filter(fn(id) { r.start <= id })
}

fn invalid_ids_p2(r: Range) -> List(Int) {
  let digits_stop = list.length(digits(r.stop))
  list.range(2, digits_stop)
  |> list.flat_map(fn(repeats) { invalid_ids(repeats, r) })
  |> list.unique()
}

fn invalid_ids(repeats: Int, r: Range) -> List(Int) {
  unfoldr(
    fn(chunk) {
      let next = next_invalid_id1_unfoldr(repeats, chunk)
      case pair.first(next) <= r.stop {
        True -> Some(next)
        False -> None
      }
    },
    1,
  )
  |> list.filter(fn(id) { r.start <= id })
}

fn next_invalid_id1_unfoldr(repeats: Int, chunk: Int) -> #(Int, Int) {
  let assert Ok(new__id) =
    chunk
    |> digits()
    |> list.repeat(repeats)
    |> list.flatten
    |> undigits()
  #(new__id, chunk + 1)
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
        // use start <- result.try(int.parse(start))
        // use stop <- result.try(int.parse(stop))
        let assert #(Ok(start), Ok(stop)) = #(int.parse(start), int.parse(stop))
        Ok(Range(start, stop))
      }
      _ -> Error(Nil)
    }
  })
}

fn next_invalid_id1_successors(i: Int) -> Int {
  let ds = digits(i)
  // interesting docs on list.length
  let assert Ok(first_half) =
    undigits(list.take(ds, { list.length(ds) + 1 } / 2))
  let first_half = first_half + 1
  let ds = digits(first_half)
  let assert Ok(id) = undigits(list.append(ds, ds))
  id
}

// cf. https://hackage.haskell.org/package/base-4.21.0.0/docs/Data-List.html#v:unfoldr
// cf. https://hackage.haskell.org/package/recursion-schemes-5.2.3/docs/Data-Functor-Foldable.html#v:unfold
pub fn unfoldr(f: fn(b) -> Option(#(a, b)), b0: b) -> List(a) {
  unfoldr_loop(f, b0, []) |> list.reverse()
}

fn unfoldr_loop(f: fn(b) -> Option(#(a, b)), b: b, acc: List(a)) -> List(a) {
  case f(b) {
    Some(#(a, b_new)) -> unfoldr_loop(f, b_new, [a, ..acc])
    None -> acc
  }
}

// cf. https://doc.rust-lang.org/std/iter/fn.successors.html
pub fn successors(first: Option(t), succ: fn(t) -> Option(t)) -> List(t) {
  case first {
    None -> []
    Some(s) -> successors_loop(s, succ, [s]) |> list.reverse()
  }
}

fn successors_loop(start: t, next: fn(t) -> Option(t), acc: List(t)) -> List(t) {
  case next(start) {
    None -> acc
    Some(n) -> successors_loop(n, next, [n, ..acc])
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

pub fn undigits(numbers: List(Int)) -> Result(Int, Nil) {
  undigits_loop(numbers, 10, 0)
}

fn undigits_loop(numbers: List(Int), base: Int, acc: Int) -> Result(Int, Nil) {
  case numbers {
    [] -> Ok(acc)
    [digit, ..] if digit >= base -> Error(Nil)
    [digit, ..rest] -> undigits_loop(rest, base, acc * base + digit)
  }
}
