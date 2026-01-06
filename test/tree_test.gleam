import gleam/int
import gleam/order
import tree.{type Tree, Leaf, Node}

type BST =
  Tree(Int)

fn insert(t: BST, i: Int) -> BST {
  case t {
    Leaf -> tree.return(i)
    Node(left:, data:, right:) as node ->
      case int.compare(i, data) {
        order.Lt -> Node(..node, left: insert(left, i))
        order.Eq -> node
        // not sure if thats right
        order.Gt -> Node(..node, right: insert(right, i))
      }
  }
}

pub fn insert_test() {
  assert Node(Node(Leaf, 1, Leaf), 2, Node(Leaf, 3, Node(Leaf, 4, Leaf)))
    == tree.from_list([2, 1, 3, 4], insert)
}

pub fn depth_test() {
  assert tree.depth(tree.from_list([], insert)) == 0
  assert tree.depth(tree.from_list([1], insert)) == 1
  assert tree.depth(tree.from_list([2, 1, 3], insert)) == 2
  assert tree.depth(tree.from_list([1, 2, 3], insert)) == 3
}

pub fn size_test() {
  assert tree.size(tree.from_list([], insert)) == 0
  assert tree.size(tree.from_list([1], insert)) == 1
  assert tree.size(tree.from_list([2, 1, 3], insert)) == 3
  assert tree.size(tree.from_list([1, 2, 3], insert)) == 3
}

pub fn flatten_test() {
  assert tree.flatten(tree.from_list([], insert)) == []
  assert tree.flatten(tree.from_list([1], insert)) == [1]
  assert tree.flatten(tree.from_list([2, 1, 3], insert)) == [2, 1, 3]
  assert tree.flatten(tree.from_list([1, 2, 3], insert)) == [1, 2, 3]
}

pub fn show_order_test() {
  assert 6
    == tree.fold(tree.from_list([2, 1, 3], insert), 0, fn(a, i) {
      //   echo i
      a + i
    })
}
