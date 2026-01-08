import gleam/int
import gleam/list
import gleam/result
import gleam/string
import gleam/yielder
import util

pub fn solve(input: List(String)) -> Result(#(Int, Int), Nil) {
  use problems1 <- result.try(parse1(input))
  use part1 <- result.try(problems1 |> list.try_map(solve_problem))
  let problems2 = parse2(input)
  use part2 <- result.try(problems2 |> list.try_map(solve_problem))
  Ok(#(part1 |> int.sum(), part2 |> int.sum()))
}

type Operation =
  fn(Int, Int) -> Int

fn parse_op(s: String) -> Result(Operation, Nil) {
  case s {
    "+" -> Ok(int.add)
    "*" -> Ok(int.multiply)
    _ -> Error(Nil)
  }
}

type Problem {
  Problem(operands: List(Int), operation: Operation)
}

fn parse_problem(input: List(String)) -> Result(Problem, Nil) {
  // TODO Get rid of reverse
  case list.reverse(input) {
    [o, ..is] -> {
      use is <- result.try(list.try_map(is, int.parse))
      use operation <- result.try(parse_op(o))
      Ok(Problem(operands: list.reverse(is), operation:))
    }
    _ -> Error(Nil)
  }
}

fn solve_problem(p: Problem) -> Result(Int, Nil) {
  list.reduce(p.operands, p.operation)
}

fn parse1(input: List(String)) -> Result(List(Problem), Nil) {
  input
  |> list.map(util.split_spaces)
  |> list.transpose()
  |> list.try_map(parse_problem)
}

fn parse2(input: List(String)) -> List(Problem) {
  let assert [operators, ..numbers] =
    input |> list.reverse() |> list.map(string.reverse)
  yielder.unfold(#(operators, numbers), fn(acc) {
    case acc {
      #("", _) -> yielder.Done
      #(operators, numbers) -> {
        let #(problem, acc) = parse_one_problem(operators, numbers)
        yielder.Next(problem, acc)
      }
    }
  })
  |> yielder.to_list()
}

fn parse_one_problem(
  operators: String,
  numbers: List(String),
) -> #(Problem, #(String, List(String))) {
  let assert Ok(#(op, operators)) = string.pop_grapheme(operators)
  let assert Ok(operation) = parse_op(op)
  let operators = string.trim_start(operators)
  let #(operands, numbers) = parse_together(numbers)
  #(Problem(operands:, operation:), #(operators, numbers))
}

fn parse_together(lines: List(String)) -> #(List(Int), List(String)) {
  parse_together_loop(lines, [])
}

fn parse_together_loop(
  lines: List(String),
  acc: List(Int),
) -> #(List(Int), List(String)) {
  case lines |> list.try_map(string.pop_grapheme) |> result.map(list.unzip) {
    Error(Nil) -> #(list.reverse(acc), lines)
    Ok(#(starts, lines)) -> {
      case list.all(starts, fn(c) { c == " " }) {
        True -> #(list.reverse(acc), lines)
        False -> {
          let assert Ok(number) =
            int.parse(
              starts |> list.reverse |> string.join("") |> string.trim(),
            )
          parse_together_loop(lines, [number, ..acc])
        }
      }
    }
  }
}
