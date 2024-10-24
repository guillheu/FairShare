import glaml
import gleam/result

pub type YamlFieldType {
  StringNode
  IntegerNode
  MapNode
  SequenceNode
  NilNode
}

pub type ConfigError {
  MissingYamlPath(path: String)
  IncorrectYamlFieldType(
    expected: YamlFieldType,
    found: YamlFieldType,
    path: String,
  )
  InvalidFieldFormat(details: String, path: String)
  InvalidConfig(details: String, path: String)
}

pub fn get_string_yaml_path(
  yaml_config: glaml.DocNode,
  yaml_path: String,
) -> Result(String, ConfigError) {
  glaml.sugar(yaml_config, yaml_path)
  |> result.map_error(fn(node_get_error) {
    case node_get_error {
      glaml.InvalidSugar -> panic as "invalid sugar"
      glaml.NodeNotFound(path) -> MissingYamlPath(path)
    }
  })
  |> result.try(fn(found_node) {
    case found_node {
      glaml.DocNodeStr(string_value) -> Ok(string_value)
      glaml.DocNodeInt(_) ->
        Error(IncorrectYamlFieldType(StringNode, IntegerNode, yaml_path))
      glaml.DocNodeMap(_) ->
        Error(IncorrectYamlFieldType(StringNode, MapNode, yaml_path))
      glaml.DocNodeNil ->
        Error(IncorrectYamlFieldType(StringNode, NilNode, yaml_path))
      glaml.DocNodeSeq(_) ->
        Error(IncorrectYamlFieldType(StringNode, SequenceNode, yaml_path))
    }
  })
}

pub fn get_int_yaml_path(
  yaml_config: glaml.DocNode,
  yaml_path: String,
) -> Result(Int, ConfigError) {
  glaml.sugar(yaml_config, yaml_path)
  |> result.map_error(fn(node_get_error) {
    case node_get_error {
      glaml.InvalidSugar -> panic as "invalid sugar"
      glaml.NodeNotFound(path) -> MissingYamlPath(path)
    }
  })
  |> result.try(fn(found_node) {
    case found_node {
      glaml.DocNodeStr(_) ->
        Error(IncorrectYamlFieldType(IntegerNode, StringNode, yaml_path))
      glaml.DocNodeInt(integer_value) -> Ok(integer_value)
      glaml.DocNodeMap(_) ->
        Error(IncorrectYamlFieldType(IntegerNode, MapNode, yaml_path))
      glaml.DocNodeNil ->
        Error(IncorrectYamlFieldType(IntegerNode, NilNode, yaml_path))
      glaml.DocNodeSeq(_) ->
        Error(IncorrectYamlFieldType(IntegerNode, SequenceNode, yaml_path))
    }
  })
}

pub fn get_seq_yaml_path(
  yaml_config: glaml.DocNode,
  yaml_path: String,
) -> Result(List(glaml.DocNode), ConfigError) {
  glaml.sugar(yaml_config, yaml_path)
  |> result.map_error(fn(node_get_error) {
    case node_get_error {
      glaml.InvalidSugar -> panic as "invalid sugar"
      glaml.NodeNotFound(path) -> MissingYamlPath(path)
    }
  })
  |> result.try(fn(found_node) {
    case found_node {
      glaml.DocNodeStr(_) ->
        Error(IncorrectYamlFieldType(SequenceNode, StringNode, yaml_path))
      glaml.DocNodeInt(_) ->
        Error(IncorrectYamlFieldType(SequenceNode, IntegerNode, yaml_path))
      glaml.DocNodeMap(_) ->
        Error(IncorrectYamlFieldType(SequenceNode, MapNode, yaml_path))
      glaml.DocNodeNil ->
        Error(IncorrectYamlFieldType(SequenceNode, NilNode, yaml_path))
      glaml.DocNodeSeq(sequence) -> Ok(sequence)
    }
  })
}

fn yaml_field_type_to_string(field_type: YamlFieldType) -> String {
  case field_type {
    StringNode -> "string"
    IntegerNode -> "integer"
    MapNode -> "map"
    SequenceNode -> "sequence"
    NilNode -> "nil"
  }
}

pub fn validate_yaml_get_result(
  yaml_get_result: Result(a, ConfigError),
  config_path: String,
) -> a {
  case yaml_get_result {
    Error(MissingYamlPath(path)) ->
      panic as {
        "path \"" <> path <> "\" is missing in config file " <> config_path
      }
    Error(IncorrectYamlFieldType(expected, found, path)) ->
      panic as {
        "incorrect field type at "
        <> path
        <> " in config file "
        <> config_path
        <> "\n\texpected: "
        <> yaml_field_type_to_string(expected)
        <> "\n\tfound: "
        <> yaml_field_type_to_string(found)
      }
    Ok(successful_result) -> successful_result
    Error(InvalidFieldFormat(details, path)) ->
      panic as {
        "configured field "
        <> path
        <> " in config file "
        <> config_path
        <> " has an invalid format:\n\t"
        <> details
      }
    Error(InvalidConfig(details, path)) ->
      panic as {
        "configured field "
        <> path
        <> " in config file "
        <> config_path
        <> " is not valid:\n\t"
        <> details
      }
  }
}
