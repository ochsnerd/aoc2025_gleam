import gleam/int
import gleam/list

pub type Tree(a) {
  Leaf
  Node(left: Tree(a), data: a, right: Tree(a))
}

pub fn return(v: a) -> Tree(a) {
  Node(Leaf, v, Leaf)
}

pub fn map(tree: Tree(a), with fun: fn(a) -> b) -> Tree(b) {
  case tree {
    Leaf -> Leaf
    Node(left:, data:, right:) ->
      Node(left: map(left, fun), data: fun(data), right: map(right, fun))
  }
}

// no (good) flat_map https://stackoverflow.com/a/6799885

// this just folds, so if we're not careful with the order of intervals in
// argument, we get an unbalanced tree
pub fn from_list(l: List(b), insert: fn(Tree(a), b) -> Tree(a)) -> Tree(a) {
  list.fold(l, Leaf, insert)
}

pub fn fold(
  over tree: Tree(a),
  from initial: acc,
  with fun: fn(acc, a) -> acc,
) -> acc {
  case tree {
    Leaf -> initial
    Node(left:, data:, right:) ->
      // preorder
      fold(right, fold(left, fun(initial, data), fun), fun)
    // inorder
    // fold(right, fun(fold(left, initial, fun), data), fun)
    // postorder
    // fun(fold(right, fold(left, initial, fun), fun), data)
  }
}

pub fn flatten(t: Tree(a)) -> List(a) {
  list.reverse(fold(t, [], fn(l, a) { [a, ..l] }))
}

// catamorphism is 'generalization' of fold for any recursive type
// confusingly: https://hackage-content.haskell.org/package/containers-0.8/docs/Data-Tree.html#v:foldTree
pub fn cata(f: fn(b, a, b) -> b, start: b, t: Tree(a)) -> b {
  case t {
    Leaf -> start
    Node(left:, data:, right:) ->
      f(cata(f, start, left), data, cata(f, start, right))
  }
}

pub fn depth(t: Tree(a)) -> Int {
  cata(fn(l, _, r) { 1 + int.max(l, r) }, 0, t)
}

pub fn size(t: Tree(a)) -> Int {
  cata(fn(l, _, r) { 1 + l + r }, 0, t)
}
