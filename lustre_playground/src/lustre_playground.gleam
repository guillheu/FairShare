// import gleam/dynamic
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import lustre
import lustre/attribute.{class}
import lustre/effect
import lustre/element
import lustre/element/html
import lustre/event
import lustre_http
import prng/random
import prng/seed

// const rng_api_url = "https://www.randomnumberapi.com/api/v1.0/random?min=1&max=100&count=1"

pub type Model {
  Model(count: Int, target: Int, history: List(Int))
}

pub type Msg {
  Increment
  Decrement
  ApiIncrementBy(Result(List(Int), lustre_http.HttpError))
  ApiDecrementBy(Result(List(Int), lustre_http.HttpError))
}

fn init(_flags) -> #(Model, effect.Effect(Msg)) {
  #(Model(0, 10, []), effect.none())
}

pub fn update(model: Model, msg: Msg) -> #(Model, effect.Effect(Msg)) {
  io.debug(msg)
  case msg {
    Increment -> #(model, get_random_number(True))
    Decrement -> #(model, get_random_number(False))
    ApiIncrementBy(Ok(int_list)) ->
      case int_list {
        [number, ..] -> #(
          Model(
            ..model,
            count: model.count + number,
            history: [number, ..model.history],
          ),
          effect.none(),
        )
        _ -> #(model, effect.none())
      }
    ApiDecrementBy(Ok(int_list)) ->
      case int_list {
        [number, ..] -> #(
          Model(
            ..model,
            count: model.count - number,
            history: [number, ..model.history],
          ),
          effect.none(),
        )
        _ -> #(model, effect.none())
      }
    ApiIncrementBy(Error(e)) -> {
      io.debug(e)
      #(model, effect.none())
    }
    ApiDecrementBy(Error(e)) -> {
      io.debug(e)
      #(model, effect.none())
    }
  }
}

pub fn view(model: Model) -> element.Element(Msg) {
  let count_string = int.to_string(model.count)
  let count_history = int_list_to_string(model.history)
  let target_message = case model.count, model.target {
    count, target if count == target -> "You win!"
    _, target -> "Target : " <> int.to_string(target)
  }
  html.div([class("text-4xl")], [
    html.div([], [
      html.header([class("p-4 bg-red-500 text-white")], [
        html.h1([class("w-full mx-auto max-w-screen-xl font-bold")], [
          html.text("FairShare"),
        ]),
      ]),
    ]),
    html.button([class("p-2"), event.on_click(Increment)], [element.text("+")]),
    html.button([class("p-2"), event.on_click(Decrement)], [element.text("-")]),
    html.h2([], [html.text("Current Count")]),
    html.text(count_string),
    html.h2([], [html.text("History")]),
    html.text(count_history),
    html.br([]),
    html.br([]),
    html.text(target_message),
  ])
}

fn int_list_to_string(int_list: List(Int)) -> String {
  use current_string, new_int <- list.fold(list.reverse(int_list), "[]")
  current_string
  |> string.drop_right(1)
  |> string.append(" " <> int.to_string(new_int) <> " ]")
}

fn get_random_number(increment: Bool) -> effect.Effect(Msg) {
  // let decoder = dynamic.list(dynamic.int)
  // let expect = case increment {
  //   True -> lustre_http.expect_json(decoder, ApiIncrementBy)
  //   False -> lustre_http.expect_json(decoder, ApiDecrementBy)
  // }

  // lustre_http.get(rng_api_url, expect)
  let randint_generator = random.int(1, 2)
  let #(roll_result, _) = random.step(randint_generator, seed.random())

  effect.from(fn(dispatch) {
    case increment {
      True -> dispatch(ApiIncrementBy(Ok([roll_result])))
      False -> dispatch(ApiDecrementBy(Ok([roll_result])))
    }
  })
}

pub fn main() {
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)

  Nil
}
