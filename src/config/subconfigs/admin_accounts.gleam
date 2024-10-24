import config/generics
import glaml
import gleam/bit_array
import gleam/bool
import gleam/int
import gleam/list
import gleam/result

pub opaque type AdminAccountsConfig {
  AdmAccsConfig(accounts: List(AdminAccountConfig))
}

pub type AdminAccountsConfigUnvalidated {
  AdmAccsConfigUnvalidated(accounts: List(AdminAccountConfig))
}

pub type AdminAccountConfig {
  AdmAccConfig(name: String, pw_hash: BitArray, salt: BitArray)
}

pub fn from_yaml(
  yaml_config: glaml.Document,
) -> Result(AdminAccountsConfig, generics.ConfigError) {
  let unvalidated_admin_accounts = {
    use admin_account_nodes <- result.map(generics.get_seq_yaml_path(
      glaml.doc_node(yaml_config),
      "admin_accounts",
    ))
    use admin_account_node, index <- list.index_map(admin_account_nodes)
    use name <- result.try(generics.get_string_yaml_path(
      admin_account_node,
      "name",
    ))
    use pw_hash <- result.try(generics.get_string_yaml_path(
      admin_account_node,
      "pw_hash",
    ))
    use salt <- result.try(generics.get_string_yaml_path(
      admin_account_node,
      "salt",
    ))

    use admin_account <- result.try(new_single(
      name,
      pw_hash,
      salt,
      "admin_accounts.#" <> int.to_string(index),
    ))
    Ok(admin_account)
  }

  let flat_result =
    result.flatten({
      use accounts_list_result <- result.map(unvalidated_admin_accounts)
      let accounts_result_list = result.all(accounts_list_result)
      use accounts_list <- result.map(accounts_result_list)
      AdmAccsConfig(accounts_list)
    })
  use unvalidated_accounts_config <- result.try(flat_result)
  validate(unvalidated_accounts_config)
}

fn new_single(
  name: String,
  pw_hash: String,
  salt: String,
  base_path: String,
) -> Result(AdminAccountConfig, generics.ConfigError) {
  use pw_hash_bit_array <- result.try(result.replace_error(
    bit_array.base16_decode(pw_hash),
    generics.InvalidFieldFormat(
      "password hash is not a valid hex string",
      base_path <> ".pw_hash",
    ),
  ))

  use salt_bit_array <- result.try(result.replace_error(
    bit_array.base16_decode(salt),
    generics.InvalidFieldFormat(
      "salt is not a valid hex string",
      base_path <> ".salt",
    ),
  ))
  Ok(AdmAccConfig(name, pw_hash_bit_array, salt_bit_array))
}

fn validate(
  admin_accounts: AdminAccountsConfig,
) -> Result(AdminAccountsConfig, generics.ConfigError) {
  {
    use field_lists_tuple, admin_account <- list.try_fold(
      admin_accounts.accounts,
      #(list.new(), list.new(), list.new()),
    )
    let names = field_lists_tuple.0
    let pw_hashes = field_lists_tuple.1
    let salts = field_lists_tuple.2
    use _ <- result.try({
      case bit_array.byte_size(admin_account.pw_hash) {
        len if len == 32 -> Ok(admin_account.pw_hash)
        _ ->
          Error(generics.InvalidFieldFormat(
            "password hash should be 256 bits (32 bytes, 64 hex digits) long (result of a sha256 hash)",
            "admin_accounts.#"
              <> int.to_string(list.length(names))
              <> ".pw_hash",
          ))
      }
    })
    use <- bool.guard(
      list.contains(names, admin_account.name),
      Error(generics.InvalidConfig(
        "multiple admin accounts have the same name \""
          <> admin_account.name
          <> "\"",
        "admin_accounts.#" <> int.to_string(list.length(names)) <> ".name",
      )),
    )
    use <- bool.guard(
      list.contains(pw_hashes, admin_account.pw_hash),
      Error(generics.InvalidConfig(
        "multiple admin accounts have the same password hash \""
          <> bit_array.base16_encode(admin_account.pw_hash)
          <> "\"",
        "admin_accounts.#"
          <> int.to_string(list.length(pw_hashes))
          <> ".pw_hash",
      )),
    )
    use <- bool.guard(
      list.contains(salts, admin_account.salt),
      Error(generics.InvalidConfig(
        "multiple admin accounts have the same salt \""
          <> bit_array.base16_encode(admin_account.salt)
          <> "\"",
        "admin_accounts.#" <> int.to_string(list.length(salts)) <> ".salt",
      )),
    )
    let names = list.prepend(names, admin_account.name)
    let pw_hashes = list.prepend(pw_hashes, admin_account.pw_hash)
    let salts = list.prepend(salts, admin_account.salt)
    Ok(#(names, pw_hashes, salts))
  }
  |> result.replace(admin_accounts)
}

pub fn read(
  admin_account_config: AdminAccountsConfig,
) -> AdminAccountsConfigUnvalidated {
  AdmAccsConfigUnvalidated(admin_account_config.accounts)
}
