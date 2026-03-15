import day01
import day02
import day03
import day04
import day05
import day06
import day07
import day08
import gleam/dict
import gleam/erlang/process.{type Name, type Subject}
import gleam/int
import gleam/io
import gleam/list
import gleam/otp/actor.{type StartResult}
import gleam/otp/factory_supervisor as factory
import gleam/otp/static_supervisor as supervisor
import gleam/otp/supervision
import gleam/result
import gleam/string
import gleam/yielder
import input
import util

// TODO: update gleam

const solutions = [
  #(1, #(day01.solve, "day01")),
  #(2, #(day02.solve, "day02")),
  #(3, #(day03.solve, "day03")),
  #(4, #(day04.solve, "day04")),
  #(5, #(day05.solve, "day05")),
  #(6, #(day06.solve, "day06")),
  #(7, #(day07.solve, "day07")),
  #(8, #(day08.solve, "day08")),
]

// simple perf check:
// gleam build && gleam run -m gleescript && time ./aoc2025_gleam < input.txt
pub fn main() {
  // Strategy:
  // Read stdin, for every line spawn a 'one-shot' actor that attempts to solve
  // the day read from input. Send the result to a 'printer' actor.

  // A name is stored in a table in the erlang VM.
  // It allows looking up currently active Subjects,
  // which are actor-specific and change when a
  // supervisor restarts an actor
  let solver_name = process.new_name("solvers")
  let printer_name = process.new_name("results")
  let assert Ok(_) = start_supervision_tree(printer_name, solver_name)

  let printer_subject = process.named_subject(printer_name)
  let computations = read_and_solve(solver_name)
  wait_all_finished(computations)
  // To shutdown, we send a message and wait up to 100ms for a reply
  actor.call(printer_subject, 100, Shutdown)
}

fn solve(day: String) -> Result(String, Nil) {
  use day <- result.try(int.parse(day))
  let solutions = dict.from_list(solutions)
  use pair <- result.try(dict.get(solutions, day))
  let #(f, input_name) = pair
  use lines <- result.try(util.read_lines("input/" <> input_name <> ".txt"))
  use #(part1, part2) <- result.try(f(lines))
  Ok(input_name <> ": " <> int.to_string(part1) <> ", " <> int.to_string(part2))
}

pub fn read_and_solve(solvers_name: Name(_)) -> List(Subject(_)) {
  yielder.repeatedly(fn() { input.input("") })
  |> yielder.take_while(result.is_ok)
  |> yielder.map(result.unwrap(_, ""))
  |> yielder.map(string.trim)
  |> yielder.take_while(fn(s) { s != "q" })
  |> yielder.map(fn(v) {
    let supervisor = factory.get_by_name(solvers_name)
    let assert Ok(started) = factory.start_child(supervisor, v)
    actor.send(started.data, Solve)
    started.data
  })
  |> yielder.to_list()
}

fn wait_all_finished(subjects: List(Subject(_))) -> Nil {
  list.each(subjects, fn(solver_subject) {
    process.subject_owner(solver_subject)
    |> result.map(process.monitor)
    |> result.map(fn(monitor) {
      process.new_selector()
      |> process.select_specific_monitor(monitor, fn(_) { Nil })
      |> process.selector_receive_forever()
    })
  })
}

pub type PrinterMessage {
  Shutdown(confirm: process.Subject(Nil))
  Line(String)
}

fn handle_message(
  count: Int,
  message: PrinterMessage,
) -> actor.Next(Int, PrinterMessage) {
  case message {
    Line(s) -> {
      io.println(s)
      actor.continue(count + 1)
    }
    Shutdown(confirm) -> {
      io.println("Done after printing " <> int.to_string(count) <> " messages")
      process.send(confirm, Nil)
      actor.stop()
    }
  }
}

fn start_printer(name: Name(_)) -> StartResult(_) {
  actor.new(0)
  |> actor.named(name)
  |> actor.on_message(handle_message)
  |> actor.start
}

pub type SolverMessage {
  Solve
}

fn start_solver(day: String, printer_name: Name(_)) -> StartResult(_) {
  let subject = process.named_subject(printer_name)
  actor.new(Nil)
  |> actor.on_message(fn(_, msg: SolverMessage) {
    case msg {
      Solve -> {
        case solve(day) {
          Ok(result) -> actor.send(subject, Line(result))
          Error(_) -> actor.send(subject, Line("Could not solve day " <> day))
        }
        actor.stop()
      }
    }
  })
  |> actor.start()
}

fn start_supervision_tree(
  printer_name: Name(_),
  solvers_name: Name(_),
) -> StartResult(_) {
  let printer =
    supervisor.new(supervisor.OneForOne)
    |> supervisor.add(supervision.worker(fn() { start_printer(printer_name) }))
    |> supervisor.supervised

  let solver_factory_supervisor =
    factory.worker_child(fn(day) { start_solver(day, printer_name) })
    |> factory.named(solvers_name)
    // never restart
    |> factory.restart_strategy(supervision.Temporary)
    |> factory.supervised

  supervisor.new(supervisor.OneForOne)
  |> supervisor.add(solver_factory_supervisor)
  |> supervisor.add(printer)
  |> supervisor.start
}
