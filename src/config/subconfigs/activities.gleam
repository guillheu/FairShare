import config/generics
import glaml
import gleam/result

pub opaque type ActivitiesConfig {
  AConfig(min_select: Int, max_select: Int)
}

pub type ActivitiesConfigUnvalidated {
  AConfigUnvalidated(min_select: Int, max_select: Int)
}

pub fn from_yaml(
  yaml_config: glaml.Document,
) -> Result(ActivitiesConfig, generics.ConfigError) {
  let yaml_config = glaml.doc_node(yaml_config)
  use activities_max <- result.try(generics.get_int_yaml_path(
    yaml_config,
    "activities.max_select",
  ))
  use activities_min <- result.try(generics.get_int_yaml_path(
    yaml_config,
    "activities.min_select",
  ))
  use validated_config <- result.try(
    validate(AConfig(activities_min, activities_max)),
  )
  Ok(validated_config)
}

fn validate(
  config: ActivitiesConfig,
) -> Result(ActivitiesConfig, generics.ConfigError) {
  case config.max_select, config.min_select {
    max, _ if max < 0 ->
      Error(generics.InvalidFieldFormat(
        "field cannot be negative, must be >= 0",
        "activities.max_select",
      ))
    _, min if min < 0 ->
      Error(generics.InvalidFieldFormat(
        "field cannot be negative, must be >= 0",
        "activities.min_select",
      ))
    max, min if min > max ->
      Error(generics.InvalidFieldFormat(
        "min cannot be greater than max",
        "activities.min_select",
      ))
    _, _ -> Ok(config)
  }
}

pub fn read(activities_config: ActivitiesConfig) -> ActivitiesConfigUnvalidated {
  AConfigUnvalidated(activities_config.min_select, activities_config.max_select)
}
