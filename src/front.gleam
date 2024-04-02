import gleam/dynamic
import gleam/fetch
import gleam/http/request
import gleam/int
import gleam/io
import gleam/javascript/promise
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
import lustre_http.{type HttpError}

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
  #(Model("", 0, []), fetch_expenses())
}

// UPDATE ----------------------------------------------------------------------

pub type Msg {
  GotResponse(Result(Nil, HttpError))
  GotExpenses(Result(List(Expense), HttpError))
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
        add_expense(model.name, model.amount),
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
    GotResponse(Ok(_)) -> {
      io.println("  /!\\ Got response")
      #(model, effect.none())
    }
    GotResponse(Error(_)) -> {
      io.println("  /!\\ Failed to get response")
      #(model, effect.none())
    }
    GotExpenses(Ok(body)) -> {
      io.println("  /!\\ Got expenses")
      #(Model(..model, expenses: body), effect.none())
    }
    GotExpenses(Error(_)) -> {
      io.println("  /!\\ Failed to get expenses")
      #(model, effect.none())
    }
  }
}

// EFFECTS ---------------------------------------------------------------------

fn add_expense(name: String, amount: Int) -> effect.Effect(Msg) {
  // io.println("=== [FRONTEND] Adding expense... ===")
  let url = "http://localhost:3000/add-expense"
  let body =
    json.object([#("name", json.string(name)), #("amount", json.int(amount))])
  lustre_http.post(url, body, lustre_http.expect_anything(GotResponse))
}

// TODO: Implement fetching expenses from a database
fn fetch_expenses() -> effect.Effect(Msg) {
  let url = "http://localhost:3000/get-expenses"
  io.println("=== [FRONTEND] Fetching expenses... ===")
  let decoder =
    dynamic.decode2(
      Expense,
      dynamic.field("name", dynamic.string),
      dynamic.field("amount", dynamic.int),
    )
  lustre_http.get(
    url,
    lustre_http.expect_json(dynamic.list(decoder), GotExpenses),
  )
}

// VIEW ------------------------------------------------------------------------

fn view(model: Model) -> Element(Msg) {
  let styles = [#("width", "100vw"), #("height", "100vh"), #("padding", "1rem")]

  let message = model.name
  let amount = model.amount
  let expenses = model.expenses

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
