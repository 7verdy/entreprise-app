import gleam/dynamic
import gleam/int
import gleam/io
import gleam/json
import gleam/list
import gleam/string
import sqlight

pub fn create_table() {
  use conn <- sqlight.with_connection("data.db")
  let sql =
    "
        create table if not exists expenses (name text, amount int);
    "

  let assert Ok(Nil) = sqlight.exec(sql, conn)
  Nil
}

pub fn send_data(expense: #(String, Int)) {
  use conn <- sqlight.with_connection("data.db")
  let sql =
    string.concat([
      "
 insert into expenses values ('",
      expense.0,
      "', ",
      int.to_string(expense.1),
      ");",
    ])

  let assert Ok(Nil) = sqlight.exec(sql, conn)
  Nil
}

pub fn get_data() -> List(#(String, Int)) {
  use conn <- sqlight.with_connection("data.db")
  let expenses_decoder = dynamic.tuple2(dynamic.string, dynamic.int)

  let sql = "select * from expenses;"
  let assert Ok(expenses) =
    sqlight.query(sql, on: conn, with: [], expecting: expenses_decoder)

  expenses
}

fn expense_to_json(expense: #(String, Int)) -> json.Json {
  json.object([
    #("name", json.string(expense.0)),
    #("amount", json.int(expense.1)),
  ])
}
