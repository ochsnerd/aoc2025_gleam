import gleam/int
import gleam/order.{Lt}

pub type Interval {
  Interval(start: Int, stop: Int)
}

pub fn new(a: Int, b: Int) -> Interval {
  Interval(int.min(a, b), int.max(a, b))
}

pub type Order {
  Left
  Contained
  Right
}

pub fn compare(i: Interval, p: Int) -> Order {
  case int.compare(p, i.start), int.compare(i.stop, p) {
    Lt, _ -> Right
    _, Lt -> Left
    _, _ -> Contained
  }
}
