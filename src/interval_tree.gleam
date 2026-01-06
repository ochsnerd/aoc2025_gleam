import gleam/int
import gleam/list
import gleam/order.{Eq, Gt, Lt}
import interval.{type Interval, Contained, Left, Right, compare}
import tree.{type Tree, Leaf as BLeaf, Node as BNode}
import util.{insert_sorted_by}

// Interval Tree
// https://en.wikipedia.org/wiki/Interval_tree
pub type Intervals {
  Intervals(
    mid: Int,
    // sorted by increasing Interval.start
    by_start: List(Interval),
    // sorted by decreasing Interval.stop (makes intersections easier)
    by_stop: List(Interval),
  )
}

pub type IntervalTree =
  Tree(Intervals)

// this just folds, so if we're not careful with the order of intervals in
// argument, we get an unbalanced tree
pub fn from_list(intervals: List(Interval)) -> IntervalTree {
  tree.from_list(intervals, insert)
}

pub fn insert(t: IntervalTree, i: Interval) -> IntervalTree {
  case t {
    BLeaf -> {
      let mid = { i.stop + i.start } / 2
      let data =
        Intervals(mid:, by_start: [i], by_stop: [
          i,
        ])
      BNode(data:, left: BLeaf, right: BLeaf)
    }
    BNode(data: Intervals(mid:, by_start:, by_stop:) as data, left:, right:) as node -> {
      case compare(i, mid) {
        Left -> BNode(..node, left: insert(left, i))
        Right -> BNode(..node, right: insert(right, i))
        Contained ->
          BNode(
            ..node,
            data: Intervals(
              ..data,
              by_start: by_start |> insert_sorted_by(i, fn(i) { i.start }),
              by_stop: by_stop |> insert_sorted_by(i, fn(i) { -i.stop }),
            ),
          )
      }
    }
  }
}

pub fn intersections(t: IntervalTree, p: Int) -> List(Interval) {
  intersections_loop(t, p, [])
}

fn intersections_loop(
  t: IntervalTree,
  p: Int,
  acc: List(Interval),
) -> List(Interval) {
  case t {
    BLeaf -> acc
    BNode(data: Intervals(mid:, by_start:, by_stop:), left:, right:) -> {
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
