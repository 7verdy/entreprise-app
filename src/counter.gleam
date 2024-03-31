import gleam/int
import lustre
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import lustre/ui

// MAIN ------------------------------------------------------------------------

pub fn app() {
  lustre.simple(init, update, view)
}

// MODEL -----------------------------------------------------------------------

type Model =
  Int

fn init(initial_count: Int) -> Model {
  case initial_count < 0 {
    True -> 0
    False -> initial_count
  }
}

// UPDATE ----------------------------------------------------------------------

pub opaque type Msg {
  Incr
  Decr
  AddExpense
}

fn update(model: Model, msg: Msg) -> Model {
  case msg {
    Incr -> model + 1
    Decr -> model - 1
    AddExpense -> {
      model
    }
  }
}

// VIEW ------------------------------------------------------------------------

fn view(model: Model) -> Element(Msg) {
  let styles = [#("width", "100vw"), #("height", "100vh"), #("padding", "1rem")]
  let count = int.to_string(model)

  ui.centre(
    [attribute.style(styles)],
    ui.stack([], [
      ui.button([event.on_click(Incr)], [element.text("+")]),
      html.p([attribute.style([#("text-align", "center")])], [
        element.text(count),
      ]),
      ui.button([event.on_click(Decr)], [element.text("-")]),
    ]),
  )
}
