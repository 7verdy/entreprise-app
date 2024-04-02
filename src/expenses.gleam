import gleam/dynamic
import gleam/int
import gleam/io
import gleam/json
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string
import lustre
import lustre/attribute
import lustre/effect
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import lustre/ui
import lustre_http

// MAIN ------------------------------------------------------------------------

pub fn app() {
  lustre.application(init, update, view)
}

// MODEL -----------------------------------------------------------------------

pub type Expense {
  Expense(name: String, amount: Int)
}

pub type Model {
  Model(name: String, amount: Int, expenses: List(Expense))
}

fn init(_) -> #(Model, effect.Effect(Msg)) {
  #(Model("", 0, []), effect.none())
}

// UPDATE ----------------------------------------------------------------------

pub opaque type Msg {
  AddExpense
  UpdateName(String)
  UpdateAmount(String)
}

fn update(model: Model, msg: Msg) -> #(Model, effect.Effect(Msg)) {
  case msg {
    AddExpense -> {
      #(
        Model(
          ..model,
          expenses: [Expense(model.name, model.amount), ..model.expenses],
        ),
        effect.none(),
      )
    }
    UpdateName(name) -> {
      #(Model(..model, name: name), effect.none())
    }
    UpdateAmount(amount) -> {
      #(
        Model(..model, amount: result.unwrap(int.parse(amount), 0)),
        effect.none(),
      )
    }
  }
}

// TODO: Implement saving expenses to a database
fn add_expense() -> effect.Effect(Msg) {
  todo
}

// VIEW ------------------------------------------------------------------------

fn view(model: Model) -> Element(Msg) {
  let styles = [#("width", "100vw"), #("height", "100vh"), #("padding", "1rem")]

  let message = model.name
  let amount = model.amount
  let expenses = model.expenses

  io.debug(expenses)

  ui.centre(
    [attribute.style(styles)],
    html.div([], [
      html.form([attribute.method("POST")], [
        ui.input([attribute.value(message), event.on_input(UpdateName)]),
        ui.input([
          attribute.value(int.to_string(amount)),
          event.on_input(UpdateAmount),
        ]),
        ui.button([event.on_click(AddExpense)], [element.text("Add Expense")]),
      ]),
      html.div([], case list.length(expenses) {
        0 -> [element.text("No expenses")]
        _ ->
          list.map(expenses, fn(expense) {
            html.div([], [
              element.text(
                expense.name <> " - " <> int.to_string(expense.amount),
              ),
            ])
          })
      }),
    ]),
  )
}
