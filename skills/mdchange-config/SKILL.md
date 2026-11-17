---
name: mdchange-config
description: >-
  Writes the MDCMS API URL, application, level, and task settings
  to mdchange.properties for IBM i native development (no source-control dependency). Use when the user asks to configure
  MDChange or MDCMS, set MDCMS_API_URL, APPLICATION, LEVEL, MDCMS_PROJECT, MDCMS_TASK, or MDCMS_SUBTASK,
  or when another MDChange skill says a required property is missing.
disable-model-invocation: true
---

# MDCMS Configuration (Native IBM i)

`<skill-dir>` is the directory that contains this SKILL.md. Resolve it from the path given for this file.

`mdchange.properties` is `<skill-dir>/mdchange.properties`. Do not read or write any other properties file for these settings.

When executing a command, replace `<skill-dir>` with the absolute directory of this SKILL.md.

Never print tokens or connection credentials. In any text shown to the user, including a command, write the token as `***`. Do not paste an executed command line into the chat. Do not modify `settings.json`.

This skill ends when these configuration steps are complete. Do not open, read, or summarize any other skill.

## Running a script

Run these scripts with a standard Bash shell, never PowerShell `curl`.

On Windows the agent shell is PowerShell. Do not use `&&` or `||` in that shell. Windows PowerShell does not accept `&&` as a statement separator. Run one command at a time, or separate commands with `;`.

```text
bash "<skill-dir>/script.sh" --url "<MDCMS_API_URL>" --token "<noted token>" --flag "<value>"
```

Pass the noted token as `--token`. In any text shown to the user, write that argument as `--token ***`. Do not paste the executed command into the chat.

Quote the script path and all parameter values.

Use the same form on Windows, macOS, and Linux.

Do not rebuild the curl commands manually.

## 1. Ensure `mdchange.properties` exists

1. If `<skill-dir>/mdchange.properties` does not exist, create it as an empty file.

## 2. `MDCMS_API_URL`

Read `<skill-dir>/mdchange.properties`.

If `MDCMS_API_URL` is already defined, go to next section. Do not prompt and do not overwrite it.

If `MDCMS_API_URL` is not defined:

1. Read the user settings file for the IDE. It is JSON with comments.
   - Windows: `%APPDATA%\Cursor\User\settings.json` or `%APPDATA%\Code\User\settings.json`
   - macOS: `~/Library/Application Support/Cursor/User/settings.json` or `~/Library/Application Support/Code/User/settings.json`
2. Read the `mdopen-86-vsc.connections` array.
3. Prompt the user with the `nickname` values from that array. Include a Cancel choice. If the AskQuestion tool is available, use it; otherwise ask in chat.
4. If the user cancels, abort. Do not write `MDCMS_API_URL`.
5. For the selected nickname, use that array element and set `MDCMS_API_URL` as follows:
   - If `secure` is boolean `true` or the string `"true"`, start with `https://`. Otherwise start with `http://`.
   - Append `host`.
   - If `port` is not blank, append `:` and the `port` value.
   - Append the string `/MDCMS` and then the `environment` value (append `/MDCMS` even when `environment` is blank).
6. set `MDCMS_CONNECTION_HOST` to the value of `host`
7. set `MDCMS_CONNECTION_SECURE` to the value of `secure`
8. set `MDCMS_CONNECTION_PORT` to the value of `port`
9. set `MDCMS_CONNECTION_ENVIRONMENT` to the value of `environment`
10. Write `MDCMS_API_URL` and write or replace `MDCMS_CONNECTION_HOST`, `MDCMS_CONNECTION_SECURE`, `MDCMS_CONNECTION_PORT` and `MDCMS_CONNECTION_ENVIRONMENT` into `<skill-dir>/mdchange.properties`. Preserve every other line already in that file.

Examples:

- `secure` `"true"`, `host` `dev.example`, `port` blank, `environment` `T86` → `https://dev.example/MDCMST86`
- `secure` `"false"`, `host` `10.0.0.1`, `port` `1901`, `environment` blank → `http://10.0.0.1:1901/MDCMS`

## 3. API token and MDCMS User

Read `MDCMS_CONNECTION_HOST`, `MDCMS_CONNECTION_SECURE`, `MDCMS_CONNECTION_PORT`, and `MDCMS_CONNECTION_ENVIRONMENT` from `<skill-dir>/mdchange.properties`.

Call the MCP tool `get_mdcms_api_token` on the `mdopen-86` server. Pass those property values as:

- `host` = `MDCMS_CONNECTION_HOST`
- `port` = `MDCMS_CONNECTION_PORT`
- `https` = `true` when `MDCMS_CONNECTION_SECURE` is boolean `true` or the string `"true"`, otherwise `false`
- `environment` = `MDCMS_CONNECTION_ENVIRONMENT`

The tool returns one value in the form `token;userid`.

Note the returned token and the returned user for this execution run. The token is the text before the first `;`. The user is the text after the first `;`. Do not display the token. Do not write the token or the user into `mdchange.properties` or any other file.

If the call fails, tell the user to check the MCP Port values in the MDOpen Settings. Abort.

If the token is blank or missing, or the returned value has no user after `;`, tell the user to configure the token and user for the defined MDOpen connection. Abort.

In every later step, the bearer token is this noted token. Pass it as `--token`. In any text shown to the user, write `--token ***`. The noted user is the user ID used when matching object requests.

## 4. `APPLICATION` and `LEVEL`

Check if `APPLICATION` and `LEVEL` are defined in `mdchange.properties` with values.

- `APPLICATION` must be upper-case and a maximum of 6 characters.
- `LEVEL` must be an integer with a maximum of 3 digits.

If a value is defined but does not abide by those restrictions, remove that value and save `mdchange.properties`.

If `APPLICATION` or `LEVEL` is not defined or has no value, run `<skill-dir>/get-levels.sh` with Bash (never PowerShell). The script calls `MDCMS_API_URL` + `/levels?checkoutAllowed=true`. The bearer token is the noted token.

Show the user the command below with `--token ***`. Run it with Running a script. Do not paste the executed command into the chat.

```text
<skill-dir>/get-levels.sh --url <MDCMS_API_URL> --token *** --checkout-allowed true
```

Execute exactly:

```text
bash "<skill-dir>/get-levels.sh" --url "<MDCMS_API_URL>" --token "<noted token>" --checkout-allowed "true"
```

The command line that runs must start with `&`. Put the noted token in `--token`. The command shown to the user keeps `--token ***`.

`get-levels.sh` accepts `--url`, `--token`, and `--checkout-allowed`. The script prints `HTTP_STATUS=` and then the response body. It does not print the token.

If the response has an HTTP status > 200, show the status to the user and abort.

Show the list of `appl`, `lvl`, and `desc` properties to the user for selection of the application and level to use. Include a Cancel choice. If the AskQuestion tool is available, use it; otherwise ask in chat.

If the user cancels, abort. Do not write `APPLICATION` or `LEVEL`.

Store the selection as `APPLICATION` and `LEVEL` in `<skill-dir>/mdchange.properties`. Preserve every other line already in that file.

## 5. `MDCMS_PROJECT`, `MDCMS_TASK`, and `MDCMS_SUBTASK`

Check these properties in `<skill-dir>/mdchange.properties`:

- `MDCMS_PROJECT` must be upper-case and a maximum of 12 characters.
- `MDCMS_TASK` must be a numeric value of a maximum of 7 digits and greater than 0.
- `MDCMS_SUBTASK` must be a numeric value of a maximum of 7 digits and greater than or equal to 0.

If any of the three is undefined or has an invalid value, prompt the user for MDCMS Project, MDCMS Task, and MDCMS Subtask. Validate the answers against those rules. If an answer is invalid, prompt again. When all three are valid, save them as `MDCMS_PROJECT`, `MDCMS_TASK`, and `MDCMS_SUBTASK` in `mdchange.properties`. Preserve every other line already in that file.

Run `<skill-dir>/task.sh` with Bash (never PowerShell). Pass `url` = `MDCMS_API_URL`, `token` = the noted token, `proj` = `MDCMS_PROJECT`, `task` = `MDCMS_TASK`, and `subtask` = `MDCMS_SUBTASK`.

Show the user the command below with `--token ***`. Run it with Running a script. Do not paste the executed command into the chat.

```text
<skill-dir>/task.sh --url <MDCMS_API_URL> --token *** --proj <MDCMS_PROJECT> --task <MDCMS_TASK> --subtask <MDCMS_SUBTASK>
```

Execute exactly:

```text
bash "<skill-dir>/task.sh" --url "<MDCMS_API_URL>" --token "<noted token>" --proj "<MDCMS_PROJECT>" --task "<MDCMS_TASK>" --subtask "<MDCMS_SUBTASK>"
```

The command line that runs must start with `&`. Put the noted token in `--token`. The command shown to the user keeps `--token ***`. Do not use `--env-file`.

The script prints `HTTP_STATUS=` and then the response body. It does not print the token.

If the HTTP status is greater than 200, show the status to the user and return to the step that prompts for MDCMS Project, MDCMS Task, and MDCMS Subtask.

If the HTTP status is 200 and the response property `closeDate` is greater than 0, inform the user that the task is closed and return to the step that prompts for MDCMS Project, MDCMS Task, and MDCMS Subtask.

If the HTTP status is 200 and `closeDate` is not greater than 0, configuration is complete.
