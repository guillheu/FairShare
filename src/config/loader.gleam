import filepath
import glaml
import gleam/int

import config/generics
import config/subconfigs/activities
import config/subconfigs/admin_accounts
import config/subconfigs/http

pub opaque type GroupMakerConfig {
  GMConfig(
    http_server_config: http.HTTPServerConfig,
    activities_config: activities.ActivitiesConfig,
    admin_accounts_config: admin_accounts.AdminAccountsConfig,
  )
}

pub type GroupMakerConfigUnvalidated {
  GMConfigUnvalidated(
    http_server_config: http.HTTPServerConfigUnvalidated,
    activities_config: activities.ActivitiesConfigUnvalidated,
    admin_accounts_config: admin_accounts.AdminAccountsConfigUnvalidated,
  )
}

/// Loads a yaml config file at a given path
/// We assume the given config file contains ALL the necessary fields.
/// No default value will be applied.
/// Any missing/poorly formatted field will result in a crash
pub fn load_config(config_path: String) -> GroupMakerConfig {
  case filepath.extension(config_path) {
    Ok(extension) if extension == "yaml" || extension == "yml" -> Nil
    _ -> panic as "config file should be a .yaml or .yml file"
  }

  let yaml_config = case glaml.parse_file(config_path) {
    Ok(document) -> document
    Error(doc_error) ->
      panic as {
        "error opening config file "
        <> config_path
        <> "\n"
        <> doc_error.msg
        <> "\nlocation: "
        <> int.to_string(doc_error.loc.0)
        <> ":"
        <> int.to_string(doc_error.loc.1)
      }
  }

  let http_config =
    http.from_yaml(yaml_config)
    |> generics.validate_yaml_get_result(config_path)

  let activities_config =
    activities.from_yaml(yaml_config)
    |> generics.validate_yaml_get_result(config_path)

  let admin_accounts =
    admin_accounts.from_yaml(yaml_config)
    |> generics.validate_yaml_get_result(config_path)
  // |> list.map(fn(admin_account_result) {
  //   generics.validate_yaml_get_result(admin_account_result, config_path)
  // })
  // |> admin_accounts.validate()
  // |> generics.validate_yaml_get_result(config_path)

  GMConfig(http_config, activities_config, admin_accounts)
}

pub fn read(group_maker_config: GroupMakerConfig) -> GroupMakerConfigUnvalidated {
  GMConfigUnvalidated(
    http.read(group_maker_config.http_server_config),
    activities.read(group_maker_config.activities_config),
    admin_accounts.read(group_maker_config.admin_accounts_config),
  )
}
