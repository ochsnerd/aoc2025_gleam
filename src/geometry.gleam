import gleam/list

pub type Point {
  // positive y down
  Point(x: Int, y: Int)
}

pub type Rectangle {
  Rectangle(top_left: Point, bottom_right: Point)
}

pub fn neighbors(position: Point) -> List(Point) {
  directions()
  |> list.map(plus(position, _))
}

pub fn plus(a: Point, b: Point) -> Point {
  Point(a.x + b.x, a.y + b.y)
}

pub fn contains(r: Rectangle, p: Point) -> Bool {
  r.top_left.x <= p.x
  && r.top_left.y <= p.y
  && r.bottom_right.x >= p.x
  && r.bottom_right.y >= p.y
}

fn directions() -> List(Point) {
  [
    Point(-1, -1),
    Point(-1, 0),
    Point(-1, 1),
    Point(0, -1),
    Point(0, 1),
    Point(1, -1),
    Point(1, 0),
    Point(1, 1),
  ]
}
