// thanks claude
import gleam/list
import gleam/set
import interval.{new as new_interval}
import interval_tree.{Leaf, Node, from_list as new_tree, intersections}

// Test: Empty list should create an empty tree (Leaf)
pub fn new_tree_empty_test() {
  let tree = new_tree([])
  assert tree == Leaf
}

// Test: Single interval should create a Node with that interval
pub fn new_tree_single_interval_test() {
  let interval = new_interval(5, 10)
  let tree = new_tree([interval])

  case tree {
    Leaf -> panic as "Expected Node, got Leaf"
    Node(
      mid: mid,
      by_start: by_start,
      by_stop: by_stop,
      left: left,
      right: right,
    ) -> {
      // Check the structure
      assert left == Leaf
      assert right == Leaf
      assert by_start == [interval]
      assert by_stop == [interval]
      assert mid == 7
    }
  }
}

// Test: Two non-overlapping intervals
pub fn new_tree_two_intervals_non_overlapping_test() {
  let i1 = new_interval(1, 5)
  let i2 = new_interval(10, 15)
  let tree = new_tree([i1, i2])

  case tree {
    Leaf -> panic as "Expected Node, got Leaf"
    Node(mid: _, by_start: _, by_stop: _, left: left, right: right) -> {
      // One interval should be in left or right subtree
      let has_left = case left {
        Leaf -> False
        Node(..) -> True
      }
      let has_right = case right {
        Leaf -> False
        Node(..) -> True
      }
      // At least one subtree should exist
      assert has_left || has_right
    }
  }
}

// Test: Single point interval [1,1] should be returned when querying for point 1
pub fn intersections_single_point_test() {
  let interval = new_interval(1, 1)
  let tree = new_tree([interval])
  let results = intersections(tree, 1)

  assert results == [interval]
}

pub fn intersections_single_point2_test() {
  let interval = new_interval(1, 1)
  let tree = new_tree([interval, interval])
  let results = intersections(tree, 1)

  assert results == [interval, interval]
}

// Test: intersections on empty tree should return empty list
pub fn intersections_empty_tree_test() {
  let tree = new_tree([])
  let results = intersections(tree, 5)

  assert results == []
}

// Test: Query point with no matching intervals
pub fn intersections_no_match_test() {
  let i1 = new_interval(1, 5)
  let i2 = new_interval(10, 15)
  let tree = new_tree([i1, i2])
  let results = intersections(tree, 7)

  assert results == []
}

// Test: Query point at interval boundaries (start point)
pub fn intersections_at_start_boundary_test() {
  let interval = new_interval(5, 10)
  let tree = new_tree([interval])
  let results = intersections(tree, 5)

  assert results == [interval]
}

// Test: Query point at interval boundaries (stop point)
pub fn intersections_at_stop_boundary_test() {
  let interval = new_interval(5, 10)
  let tree = new_tree([interval])
  let results = intersections(tree, 10)

  assert results == [interval]
}

// Test: Query point in the middle of interval
pub fn intersections_middle_of_interval_test() {
  let interval = new_interval(5, 15)
  let tree = new_tree([interval])
  let results = intersections(tree, 10)

  assert results == [interval]
}

// Test: Multiple overlapping intervals at same node
pub fn intersections_multiple_overlapping_test() {
  let i1 = new_interval(5, 15)
  let i2 = new_interval(3, 12)
  let i3 = new_interval(7, 20)
  let tree = new_tree([i1, i2, i3])
  let results = intersections(tree, 10)

  // All three intervals contain point 10
  assert list.length(results) == 3
}

// Test: Query point less than mid (tests left traversal)
pub fn intersections_left_traversal_test() {
  // Create intervals that will force left traversal
  let i1 = new_interval(1, 10)
  let i2 = new_interval(20, 30)
  let tree = new_tree([i1, i2])
  let results = intersections(tree, 5)

  // Only i1 should match
  assert list.length(results) == 1
}

// Test: Query point greater than mid (tests right traversal)
pub fn intersections_right_traversal_test() {
  let i1 = new_interval(1, 10)
  let i2 = new_interval(20, 30)
  let tree = new_tree([i1, i2])
  let results = intersections(tree, 25)

  // Only i2 should match
  assert list.length(results) == 1
}

// Test: Negative intervals
pub fn intersections_negative_intervals_test() {
  let i1 = new_interval(-10, -5)
  let i2 = new_interval(-3, 3)
  let tree = new_tree([i1, i2])
  let results = intersections(tree, -7)

  assert list.length(results) == 1
}

// Test: Query with zero
pub fn intersections_zero_test() {
  let i1 = new_interval(-5, 5)
  let i2 = new_interval(-10, -1)
  let tree = new_tree([i1, i2])
  let results = intersections(tree, 0)

  assert list.length(results) == 1
}

// Test: Large interval spanning multiple potential nodes
pub fn intersections_large_span_test() {
  let i1 = new_interval(1, 100)
  let i2 = new_interval(10, 20)
  let i3 = new_interval(50, 60)
  // let i4 = new_interval(60, 70)
  // echo new_tree([i1, i2, i3])
  // echo new_tree([i1, i2, i4])
  let tree = echo new_tree([i1, i2, i3])

  // Query at 15 should find i1 and i2
  let results = intersections(tree, 15)
  assert list.length(results) == 2
}

// Test: Query just outside interval (too low)
pub fn intersections_just_below_test() {
  let interval = new_interval(5, 10)
  let tree = new_tree([interval])
  let results = intersections(tree, 4)

  assert results == []
}

// Test: Query just outside interval (too high)
pub fn intersections_just_above_test() {
  let interval = new_interval(5, 10)
  let tree = new_tree([interval])
  let results = intersections(tree, 11)

  assert results == []
}

// Test: Multiple intervals with same start point
pub fn intersections_same_start_test() {
  let i1 = new_interval(5, 10)
  let i2 = new_interval(5, 15)
  let i3 = new_interval(5, 8)
  let tree = new_tree([i1, i2, i3])
  let results = intersections(tree, 5)

  // All three should be found
  assert list.length(results) == 3
}

// Test: Multiple intervals with same stop point
pub fn intersections_same_stop_test() {
  let i1 = new_interval(5, 10)
  let i2 = new_interval(7, 10)
  let i3 = new_interval(3, 10)
  let tree = new_tree([i1, i2, i3])
  let results = intersections(tree, 10)

  // All three should be found
  assert list.length(results) == 3
}

// Test: Intervals created with reversed parameters (b < a)
pub fn new_interval_reversed_test() {
  let interval = new_interval(10, 5)
  let tree = new_tree([interval])
  let results = intersections(tree, 7)

  // Should still work (new_interval normalizes)
  assert list.length(results) == 1
}

// Test: Very wide range query coverage
pub fn intersections_wide_range_test() {
  let intervals = [
    new_interval(0, 10),
    new_interval(20, 30),
    new_interval(40, 50),
    new_interval(60, 70),
  ]
  let tree = new_tree(intervals)

  // Query in middle of first interval
  let r1 = intersections(tree, 5)
  assert list.length(r1) == 1

  // Query between intervals
  let r2 = intersections(tree, 15)
  assert r2 == []
}

// Test: Adjacent non-overlapping intervals
pub fn intersections_adjacent_intervals_test() {
  let i1 = new_interval(1, 5)
  let i2 = new_interval(6, 10)
  let tree = new_tree([i1, i2])

  // Query at gap between intervals
  let results = intersections(tree, 5)
  assert list.length(results) == 1

  let results2 = intersections(tree, 6)
  assert list.length(results2) == 1
}

pub fn multiple_intervals_at_same_node_test() {
  let i1 = new_interval(-1, 1)
  let i2 = new_interval(-2, 0)
  let i3 = new_interval(0, 2)
  let tree = new_tree([i1, i2, i3])

  assert set.from_list([i1, i2]) == set.from_list(intersections(tree, -1))
  assert set.from_list([i1, i3]) == set.from_list(intersections(tree, 1))
}
