import gleam/int
import gleam/list
import gleam/order.{Eq, Gt, Lt}
import interval.{type Interval, Contained, Left, Right, compare}
import util.{insert_sorted_by}

// Interval Tree
// https://en.wikipedia.org/wiki/Interval_tree
pub type Tree {
  Leaf
  Node(
    mid: Int,
    // sorted by increasing Interval.start
    by_start: List(Interval),
    // sorted by decreasing Interval.stop (makes intersections easier)
    by_stop: List(Interval),
    left: Tree,
    right: Tree,
  )
}

pub fn empty() -> Tree {
  Leaf
}

// this just folds, so if we're not careful with the order of intervals in
// argument, we get an unbalanced tree
pub fn from_list(intervals: List(Interval)) -> Tree {
  list.fold(intervals, empty(), insert)
}

pub fn insert(t: Tree, i: Interval) -> Tree {
  case t {
    Leaf ->
      Node(
        mid: { i.stop + i.start } / 2,
        by_start: [i],
        by_stop: [i],
        left: Leaf,
        right: Leaf,
      )
    Node(mid:, by_start:, by_stop:, left:, right:) as node -> {
      case compare(i, mid) {
        Left -> Node(..node, left: insert(left, i))
        Right -> Node(..node, right: insert(right, i))
        Contained ->
          Node(
            ..node,
            by_start: by_start |> insert_sorted_by(i, fn(i) { i.start }),
            by_stop: by_stop |> insert_sorted_by(i, fn(i) { -i.stop }),
          )
      }
    }
  }
}

pub fn intersections(t: Tree, p: Int) -> List(Interval) {
  intersections_loop(t, p, [])
}

fn intersections_loop(t: Tree, p: Int, acc: List(Interval)) -> List(Interval) {
  case t {
    Leaf -> acc
    Node(mid:, by_start:, by_stop:, left:, right:) -> {
      case int.compare(p, mid) {
        Eq -> list.append(by_start, acc)
        Lt ->
          intersections_loop(
            left,
            p,
            list.append(
              by_start |> list.take_while(fn(i) { p >= i.start }),
              acc,
            ),
          )
        Gt ->
          intersections_loop(
            right,
            p,
            list.append(by_stop |> list.take_while(fn(i) { p <= i.stop }), acc),
          )
      }
    }
  }
}
