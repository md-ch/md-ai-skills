---
name: mdchange-config
description: >-
  Writes the MDCMS API URL, application, level, repository, and task-mapping
  settings to mdchange.properties. Use when the user asks to configure MDChange
  or MDCMS, set MDCMS_API_URL, APPLICATION, LEVEL, REPOSITORY_ID, or
  MAP_BRANCH_TO_TASK, or when another MDChange skill says a required property
  is missing.
disable-model-invocation: true
---

# MDCMS change-request URL

`<skill-dir>` is the directory that contains this SKILL.md. Resolve it from the path given for this file.

`mdchange.properties` is `<skill-dir>/mdchange.properties`. Do not read or write any other properties file for these settings.

When executing a command, replace `<skill-dir>` with the absolute directory of this SKILL.md.

Never print tokens or connection credentials. In any text shown to the user, including a command, write the token as `***`. Do not paste an executed command line into the chat. Do not modify `settings.json`.

This skill ends when these configuration steps are complete. Do not open, read, or summarize any other skill.

## Running a script

Run these scripts with Git Bash, never PowerShell `curl`.

On Windows the agent shell is PowerShell. Do not use `&&` or `||` in that shell. Windows PowerShell does not accept `&&` as a statement separator. Do not run `cd ... && git ...`. Run one command at a time, or separate commands with `;`. For git, use `git -C "<repository-root>"` instead of changing directory.

A quoted program path is not a command unless it starts with the call operator `&`. Use this form:

```text
& "C:\Program Files\Git\bin\bash.exe" "<skill-dir>/script.sh" --url "<MDCMS_API_URL>" --token "<noted token>" --flag "<value>"
```

Pass the noted token as `--token`. In any text shown to the user, write that argument as `--token ***`. Do not paste the executed command into the chat.

Quote the bash path, the script path, and all parameter values.

On macOS or Linux, run `bash "<skill-dir>/script.sh"` with the same quoted arguments. Do not prefix that command with `&`.

Do not rebuild the curl.

## 1. Ensure `mdchange.properties` exists

1. If `<skill-dir>/mdchange.properties` does not exist, create it as an empty file.

## 2. `MDCMS_API_URL`

Read `<skill-dir>/mdchange.properties`.

If `MDCMS_API_URL` is already defined, go to next section. Do not prompt and do not overwrite it.

If `MDCMS_API_URL` is not defined:

1. Read the user settings file for the IDE. It is JSON with comments.
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

If `APPLICATION` or `LEVEL` is not defined or has no value, run `<skill-dir>/get-levels.sh` with Git Bash (never PowerShell). The script calls `MDCMS_API_URL` + `/levels?checkoutAllowed=true`. The bearer token is the noted token.

Show the user the command below with `--token ***`. Run it with Running a script. Do not paste the executed command into the chat.

```text
<skill-dir>/get-levels.sh --url <MDCMS_API_URL> --token *** --checkout-allowed true
```

On Windows, execute exactly:

```text
& "C:\Program Files\Git\bin\bash.exe" "<skill-dir>/get-levels.sh" --url "<MDCMS_API_URL>" --token "<noted token>" --checkout-allowed "true"
```

The command line that runs must start with `&`. Put the noted token in `--token`. The command shown to the user keeps `--token ***`.

`get-levels.sh` accepts `--url`, `--token`, and `--checkout-allowed`. The script prints `HTTP_STATUS=` and then the response body. It does not print the token.

If the response has an HTTP status > 200, show the status to the user and abort.

Show the list of `appl`, `lvl`, and `desc` properties to the user for selection of the application and level to use. Include a Cancel choice. If the AskQuestion tool is available, use it; otherwise ask in chat.

If the user cancels, abort. Do not write `APPLICATION` or `LEVEL`.

Store the selection as `APPLICATION` and `LEVEL` in `<skill-dir>/mdchange.properties`. Preserve every other line already in that file.

## 5. `REPOSITORY_ID`

Check if `REPOSITORY_ID` is defined in `<skill-dir>/mdchange.properties`.

A plausible value is upper-case and a maximum of 10 characters.

If `REPOSITORY_ID` is plausible and a MDCMS REST API has already been invoked during this skill execution, continue to the next step. Do not prompt and do not call `get-git-repositories.sh`.

Otherwise run `<skill-dir>/get-git-repositories.sh` with Git Bash (never PowerShell). Do this when `REPOSITORY_ID` is undefined, has no value, or is not plausible, and also when it is plausible but no MDCMS REST API has been invoked yet during this skill execution. The script calls `MDCMS_API_URL` + `/git-repositories` with no query parameters. The bearer token is the noted token.

Show the user the command below with `--token ***`. Run it with Running a script. Do not paste the executed command into the chat.

```text
<skill-dir>/get-git-repositories.sh --url <MDCMS_API_URL> --token ***
```

On Windows, execute exactly:

```text
& "C:\Program Files\Git\bin\bash.exe" "<skill-dir>/get-git-repositories.sh" --url "<MDCMS_API_URL>" --token "<noted token>"
```

The command line that runs must start with `&`. Put the noted token in `--token`. The command shown to the user keeps `--token ***`. Do not use `--env-file`.

The script prints `HTTP_STATUS=` and then the response body. It does not print the token.

If the response has an HTTP status > 200, show the status to the user and abort.

If `REPOSITORY_ID` was already plausible and the response contains an array element whose `repoId` equals `REPOSITORY_ID`, continue to the next step without prompting the user.

Otherwise, including when that plausible value is not in the response, perform the same actions as when the value is not plausible. Use the response already returned. Do not invoke the script a second time.

Show the list of `repoId`, `repoURL`, and `gitType` properties to the user for selection of the `repoId`. Include a Cancel choice. If the AskQuestion tool is available, use it; otherwise ask in chat.

If the user cancels, abort. Do not write `REPOSITORY_ID`.

Store the selected `repoId` as `REPOSITORY_ID` in `<skill-dir>/mdchange.properties`. Preserve every other line already in that file.

## 6. `MAP_BRANCH_TO_TASK`, `PROJECT_STARTING_POSITION`, `MDCMS_PROJECT`, `MDCMS_TASK`, and `MDCMS_SUBTASK`

Check if `MAP_BRANCH_TO_TASK` and `PROJECT_STARTING_POSITION` are defined in `<skill-dir>/mdchange.properties`.

`MAP_BRANCH_TO_TASK` must be `true` or `false`. `PROJECT_STARTING_POSITION` must be an integer from 1 to 99.

If `MAP_BRANCH_TO_TASK` is `true` or `false` and `PROJECT_STARTING_POSITION` is an integer from 1 to 99, continue. Do not prompt.

Otherwise, if `MAP_BRANCH_TO_TASK` is not `true` or `false`, prompt the user with the question "Map Repository Branch name to MDCMS Tasks?" and offer a Yes button and a No button. Do not offer an Other button and do not offer the option to Skip. If the AskQuestion tool is available, use it; otherwise ask in chat.

If the user clicks Yes, set `MAP_BRANCH_TO_TASK` to `true`. Then ask for the starting position of the project in the branch name. A valid value is an integer from 1 to 99. If the answer is invalid, prompt again. Store the entered value in `PROJECT_STARTING_POSITION`.

If the user clicks No, set `MAP_BRANCH_TO_TASK` to `false` and set `PROJECT_STARTING_POSITION` to `1`.

If `MAP_BRANCH_TO_TASK` is already `true` and `PROJECT_STARTING_POSITION` is missing or not an integer from 1 to 99, ask for the starting position of the project in the branch name. A valid value is an integer from 1 to 99. If the answer is invalid, prompt again. Store the entered value in `PROJECT_STARTING_POSITION`.

If `MAP_BRANCH_TO_TASK` is already `false` and `PROJECT_STARTING_POSITION` is missing or not an integer from 1 to 99, set `PROJECT_STARTING_POSITION` to `1`.

Save `mdchange.properties`. Preserve every other line already in that file.

If `MAP_BRANCH_TO_TASK` is `true`, configuration is complete. Do not prompt for project, task, or subtask, and do not call `task.sh`.

If `MAP_BRANCH_TO_TASK` is `false`, check these properties:

- `MDCMS_PROJECT` must be upper-case and a maximum of 12 characters.
- `MDCMS_TASK` must be a numeric value of a maximum of 7 digits and greater than 0.
- `MDCMS_SUBTASK` must be a numeric value of a maximum of 7 digits and greater than or equal to 0.

If any of the three is undefined or has an invalid value, prompt for MDCMS Project, MDCMS Task, and MDCMS Subtask. Validate the answers against those rules. If an answer is invalid, prompt again. When all three are valid, save them as `MDCMS_PROJECT`, `MDCMS_TASK`, and `MDCMS_SUBTASK` in `mdchange.properties`. Preserve every other line already in that file.

If `MAP_BRANCH_TO_TASK` is `false`, run `<skill-dir>/task.sh` with Git Bash (never PowerShell). Pass `url` = `MDCMS_API_URL`, `token` = the noted token, `proj` = `MDCMS_PROJECT`, `task` = `MDCMS_TASK`, and `subtask` = `MDCMS_SUBTASK`.

Show the user the command below with `--token ***`. Run it with Running a script. Do not paste the executed command into the chat.

```text
<skill-dir>/task.sh --url <MDCMS_API_URL> --token *** --proj <MDCMS_PROJECT> --task <MDCMS_TASK> --subtask <MDCMS_SUBTASK>
```

On Windows, execute exactly:

```text
& "C:\Program Files\Git\bin\bash.exe" "<skill-dir>/task.sh" --url "<MDCMS_API_URL>" --token "<noted token>" --proj "<MDCMS_PROJECT>" --task "<MDCMS_TASK>" --subtask "<MDCMS_SUBTASK>"
```

The command line that runs must start with `&`. Put the noted token in `--token`. The command shown to the user keeps `--token ***`. Do not use `--env-file`.

The script prints `HTTP_STATUS=` and then the response body. It does not print the token.

If the HTTP status is greater than 200, show the status to the user and return to the step that prompts for MDCMS Project, MDCMS Task, and MDCMS Subtask.

If the HTTP status is 200 and the response property `closeDate` is greater than 0, inform the user that the task is closed and return to the step that prompts for MDCMS Project, MDCMS Task, and MDCMS Subtask.

If the HTTP status is 200 and `closeDate` is not greater than 0, configuration is complete.
