import gleam/dynamic
import gleam/io
import sqlight

pub fn send_data() {
  use conn <- sqlight.with_connection("data.db")
  let sql =
    "
 create table cats (name text, age int);

 insert into cats (name, age) values 
 ('Nubi', 4),
 ('Biffy', 10),
 ('Ginny', 6);
 "

  io.println("Creating table cats and inserting data")
  let assert Ok(Nil) = sqlight.exec(sql, conn)
}

pub fn get_data() -> List(#(String, Int)) {
  use conn <- sqlight.with_connection("data.db")
  let cat_decoder = dynamic.tuple2(dynamic.string, dynamic.int)

  let sql = "select * from cats;"
  let assert Ok(cats) =
    sqlight.query(sql, on: conn, with: [], expecting: cat_decoder)

  cats
}
