import day02.{successors, unfoldr}
import gleam/list
import gleam/option.{None, Some}
import gleeunit

pub fn main() -> Nil {
  gleeunit.main()
}

// Test successors with 0..10
pub fn range_test() {
  let successors =
    successors(Some(0), fn(n) {
      case n < 10 {
        True -> Some(n + 1)
        False -> None
      }
    })

  let unfoldr =
    unfoldr(
      fn(n) {
        case n <= 10 {
          True -> Some(#(n, n + 1))
          False -> None
        }
      },
      0,
    )

  let expected = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

  assert expected == successors
  assert expected == unfoldr
}

// Test successors with Fibonacci numbers < 100
pub fn fibonacci_test() {
  let successors =
    successors(Some(#(0, 1)), fn(state) {
      let #(a, b) = state
      case b < 100 {
        True -> Some(#(b, a + b))
        False -> None
      }
    })
    |> list.map(fn(pair) { pair.0 })

  let unfoldr =
    unfoldr(
      fn(state) {
        let #(a, b) = state
        case a < 100 {
          True -> Some(#(a, #(b, a + b)))
          False -> None
        }
      },
      #(0, 1),
    )

  let expected = [0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89]
  assert expected == successors
  assert expected == unfoldr
}
