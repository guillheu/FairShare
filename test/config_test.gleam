import config/generics
import glaml
import gleam/int
import gleam/list
import gleam/result
import gleeunit/should

pub fn get_string_yaml_path_test() {
  let assert Ok(test_yaml) =
    "step_1:
  a_key: a string
  step_2:
    list_1:
    - value1
    - 123
    - \"123\"
    list_2:
    - \"a string\"
    - another_string
"
    |> glaml.parse_string()
    |> result.map(glaml.doc_node)

  let test_cases =
    list.new()
    |> list.prepend(#(glaml.DocNodeStr("some string"), ".", should.be_ok))
    |> list.prepend(#(glaml.DocNodeStr("123"), ".", should.be_ok))
    |> list.prepend(#(glaml.DocNodeStr("0x123abc"), ".", should.be_ok))
    |> list.prepend(#(glaml.DocNodeStr(""), ".", should.be_ok))
    |> list.prepend(#(glaml.DocNodeInt(123), ".", should.be_error))
    |> list.prepend(#(glaml.DocNodeInt(0), ".", should.be_error))
    |> list.prepend(#(glaml.DocNodeInt(-420), ".", should.be_error))
    |> list.prepend(#(glaml.DocNodeNil, ".", should.be_error))
    |> list.prepend(#(
      glaml.DocNodeSeq(list.wrap(glaml.DocNodeStr("a string"))),
      ".",
      should.be_error,
    ))
    |> list.prepend(#(
      glaml.DocNodeSeq(list.wrap(glaml.DocNodeStr("a string"))),
      ".#0",
      should.be_ok,
    ))
    |> list.prepend(#(
      glaml.DocNodeStr("some string"),
      "missing_key",
      should.be_error,
    ))
    |> list.prepend(#(
      glaml.DocNodeStr("some string"),
      "a.#0.missing.key",
      should.be_error,
    ))
    |> list.prepend(#(test_yaml, "step_1.a_key", should.be_ok))
    |> list.prepend(#(test_yaml, ".", should.be_error))
    |> list.prepend(#(test_yaml, "step_1", should.be_error))
    |> list.prepend(#(test_yaml, "step_1.step_2", should.be_error))
    |> list.prepend(#(test_yaml, "step_1.step_2.list_1", should.be_error))
    |> list.prepend(#(test_yaml, "step_1.step_2.list_2", should.be_error))
    |> list.prepend(#(test_yaml, "step_1.step_2.list_1.#0", should.be_ok))
    |> list.prepend(#(test_yaml, "step_1.step_2.list_1.#1", should.be_error))
    |> list.prepend(#(test_yaml, "step_1.step_2.list_1.#2", should.be_ok))
    |> list.prepend(#(test_yaml, "step_1.step_2.list_2.#0", should.be_ok))
    |> list.prepend(#(test_yaml, "step_1.step_2.list_2.#1", should.be_ok))
    |> list.prepend(#(test_yaml, "missing.path", should.be_error))
    |> list.prepend(#(test_yaml, "#1", should.be_error))
    |> list.prepend(#(test_yaml, "step_1.#0", should.be_error))
    |> list.prepend(#(test_yaml, "step_1.list_1.#3", should.be_error))
    |> list.reverse

  use #(arg1, arg2, res), index <- list.index_map(test_cases)
  let message = int.to_string(index) <> " : " <> arg2
  generics.get_string_yaml_path(arg1, arg2)
  |> result.replace(message)
  |> result.replace_error(message)
  |> res
}

pub fn get_int_yaml_path_test() {
  let assert Ok(test_yaml) =
    "step_1:
  a_key: a string
  step_2:
    list_1:
    - value1
    - 123
    - \"123\"
    list_2:
    - \"a string\"
    - another_string
"
    |> glaml.parse_string()
    |> result.map(glaml.doc_node)

  let test_cases =
    list.new()
    |> list.prepend(#(glaml.DocNodeStr("some string"), ".", should.be_error))
    |> list.prepend(#(glaml.DocNodeStr("123"), ".", should.be_error))
    |> list.prepend(#(glaml.DocNodeStr("0x123abc"), ".", should.be_error))
    |> list.prepend(#(glaml.DocNodeStr(""), ".", should.be_error))
    |> list.prepend(#(glaml.DocNodeInt(123), ".", should.be_ok))
    |> list.prepend(#(glaml.DocNodeInt(0), ".", should.be_ok))
    |> list.prepend(#(glaml.DocNodeInt(-420), ".", should.be_ok))
    |> list.prepend(#(glaml.DocNodeNil, ".", should.be_error))
    |> list.prepend(#(
      glaml.DocNodeSeq(list.wrap(glaml.DocNodeStr("a string"))),
      ".",
      should.be_error,
    ))
    |> list.prepend(#(
      glaml.DocNodeSeq(list.wrap(glaml.DocNodeStr("a string"))),
      ".#0",
      should.be_error,
    ))
    |> list.prepend(#(
      glaml.DocNodeStr("some string"),
      "missing_key",
      should.be_error,
    ))
    |> list.prepend(#(
      glaml.DocNodeStr("some string"),
      "a.#0.missing.key",
      should.be_error,
    ))
    |> list.prepend(#(test_yaml, "step_1.a_key", should.be_error))
    |> list.prepend(#(test_yaml, ".", should.be_error))
    |> list.prepend(#(test_yaml, "step_1", should.be_error))
    |> list.prepend(#(test_yaml, "step_1.step_2", should.be_error))
    |> list.prepend(#(test_yaml, "step_1.step_2.list_1", should.be_error))
    |> list.prepend(#(test_yaml, "step_1.step_2.list_2", should.be_error))
    |> list.prepend(#(test_yaml, "step_1.step_2.list_1.#0", should.be_error))
    |> list.prepend(#(test_yaml, "step_1.step_2.list_1.#1", should.be_ok))
    |> list.prepend(#(test_yaml, "step_1.step_2.list_1.#2", should.be_error))
    |> list.prepend(#(test_yaml, "step_1.step_2.list_2.#0", should.be_error))
    |> list.prepend(#(test_yaml, "step_1.step_2.list_2.#1", should.be_error))
    |> list.prepend(#(test_yaml, "missing.path", should.be_error))
    |> list.prepend(#(test_yaml, "#1", should.be_error))
    |> list.prepend(#(test_yaml, "step_1.#0", should.be_error))
    |> list.prepend(#(test_yaml, "step_1.list_1.#3", should.be_error))
    |> list.reverse

  use #(arg1, arg2, res), index <- list.index_map(test_cases)
  let message = int.to_string(index) <> " : " <> arg2
  generics.get_int_yaml_path(arg1, arg2)
  |> result.replace(message)
  |> result.replace_error(message)
  |> res
}

pub fn get_seq_yaml_path_test() {
  let assert Ok(test_yaml) =
    "step_1:
  a_key: a string
  step_2:
    list_1:
    - value1
    - 123
    - \"123\"
    list_2:
    - \"a string\"
    - another_string
"
    |> glaml.parse_string()
    |> result.map(glaml.doc_node)

  let test_cases =
    list.new()
    |> list.prepend(#(glaml.DocNodeStr("some string"), ".", should.be_error))
    |> list.prepend(#(glaml.DocNodeStr("123"), ".", should.be_error))
    |> list.prepend(#(glaml.DocNodeStr("0x123abc"), ".", should.be_error))
    |> list.prepend(#(glaml.DocNodeStr(""), ".", should.be_error))
    |> list.prepend(#(glaml.DocNodeInt(123), ".", should.be_error))
    |> list.prepend(#(glaml.DocNodeInt(0), ".", should.be_error))
    |> list.prepend(#(glaml.DocNodeInt(-420), ".", should.be_error))
    |> list.prepend(#(glaml.DocNodeNil, ".", should.be_error))
    |> list.prepend(#(
      glaml.DocNodeSeq(list.wrap(glaml.DocNodeStr("a string"))),
      ".",
      should.be_ok,
    ))
    |> list.prepend(#(
      glaml.DocNodeSeq(list.wrap(glaml.DocNodeStr("a string"))),
      ".#0",
      should.be_error,
    ))
    |> list.prepend(#(
      glaml.DocNodeStr("some string"),
      "missing_key",
      should.be_error,
    ))
    |> list.prepend(#(
      glaml.DocNodeStr("some string"),
      "a.#0.missing.key",
      should.be_error,
    ))
    |> list.prepend(#(test_yaml, "step_1.a_key", should.be_error))
    |> list.prepend(#(test_yaml, ".", should.be_error))
    |> list.prepend(#(test_yaml, "step_1", should.be_error))
    |> list.prepend(#(test_yaml, "step_1.step_2", should.be_error))
    |> list.prepend(#(test_yaml, "step_1.step_2.list_1", should.be_ok))
    |> list.prepend(#(test_yaml, "step_1.step_2.list_2", should.be_ok))
    |> list.prepend(#(test_yaml, "step_1.step_2.list_1.#0", should.be_error))
    |> list.prepend(#(test_yaml, "step_1.step_2.list_1.#1", should.be_error))
    |> list.prepend(#(test_yaml, "step_1.step_2.list_1.#2", should.be_error))
    |> list.prepend(#(test_yaml, "step_1.step_2.list_2.#0", should.be_error))
    |> list.prepend(#(test_yaml, "step_1.step_2.list_2.#1", should.be_error))
    |> list.prepend(#(test_yaml, "missing.path", should.be_error))
    |> list.prepend(#(test_yaml, "#1", should.be_error))
    |> list.prepend(#(test_yaml, "step_1.#0", should.be_error))
    |> list.prepend(#(test_yaml, "step_1.list_1.#3", should.be_error))
    |> list.reverse

  use #(arg1, arg2, res), index <- list.index_map(test_cases)
  let message = int.to_string(index) <> " : " <> arg2
  generics.get_seq_yaml_path(arg1, arg2)
  |> result.replace(message)
  |> result.replace_error(message)
  |> res
}
