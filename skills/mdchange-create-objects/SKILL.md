---
name: mdchange-create-objects
description: >-
  Creates MDCMS objects for an RFP and shows creation results, spool files, and
  source fixes. Use when the user asks to build or create MDCMS objects, or to
  run mdchange-create-objects.
disable-model-invocation: true
---

# MDCMS change-request URL

`<skill-dir>` is the directory that contains this SKILL.md. Resolve it from the path given for this file.

`mdchange.properties` is `../mdchange-config/mdchange.properties`, relative to `<skill-dir>`. Resolve it to an absolute path. Do not read or write any other properties file for these settings.

When executing a command, replace `<skill-dir>` with the absolute directory of this SKILL.md.

Never print tokens or connection credentials. In any text shown to the user, including a command, write the token as `***`. Do not paste an executed command line into the chat. Do not modify `settings.json`.

Do not open, read, or summarize any other skill unless the user confirms that skill should be run. Confirmation applies only to the skill the user named.

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

## Properties

Read `../mdchange-config/mdchange.properties`.

These properties must be defined with a value:

- `MDCMS_API_URL`
- `MDCMS_CONNECTION_HOST`
- `MDCMS_CONNECTION_SECURE`
- `APPLICATION`

`MDCMS_CONNECTION_PORT` and `MDCMS_CONNECTION_ENVIRONMENT` may be blank.

If any required property is missing or has no value, ask the user to run skill `mdchange-config`, then stop. Do not open, read, or summarize that skill. Do not create or edit `mdchange.properties`.

## API token and MDCMS User

Read `MDCMS_CONNECTION_HOST`, `MDCMS_CONNECTION_SECURE`, `MDCMS_CONNECTION_PORT`, and `MDCMS_CONNECTION_ENVIRONMENT` from `mdchange.properties`.

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

## 11. POST OBJECT-CREATION

Resolve the RFP from a response already in this conversation. Do not open another skill to find it.

Use `request.rfp` from the first `post-object-request-with-attachment.sh` response in this conversation with `rsn` set to `*MIGRATE`, an HTTP status of 200, and `request.fslb` not blank. If there was no such response, use `request.rfp` from the first `patch-object-request.sh` response in this conversation with an HTTP status of 200 and `request.srcn` not blank.

If neither response is in this conversation, ask the user for the RFP number. If the user does not provide one, this run is finished.

Invoke `<skill-dir>/post-object-creation.sh` with Git Bash (never PowerShell). Do not use `--env-file`. Pass every argument at runtime:

- `url` from `MDCMS_API_URL`
- `token`: the noted token
- `appl` from `APPLICATION`
- `rfp`: the RFP number resolved above
- `from-first-missing`: `*YES`
- `stop-when-error`: `*YES`

Show the user the command below with `--token ***`. Run it with Running a script. Do not paste the executed command into the chat.

```text
<skill-dir>/post-object-creation.sh --url <MDCMS_API_URL> --token *** --appl <APPLICATION> --rfp <rfp> --from-first-missing *YES --stop-when-error *YES
```

On Windows, execute exactly:

```text
& "C:\Program Files\Git\bin\bash.exe" "<skill-dir>/post-object-creation.sh" --url "<MDCMS_API_URL>" --token "<noted token>" --appl "<APPLICATION>" --rfp "<rfp>" --from-first-missing "*YES" --stop-when-error "*YES"
```

The command line that runs must start with `&`. Put the noted token in `--token`. The command shown to the user keeps `--token ***`. Do not use `--env-file`.

The script prints `HTTP_STATUS=` and then the response body. It does not print the token.

If the response does not include `logId` with a value greater than 0, this run is finished.

## 12. GET OBJECT-CREATION

Invoke `<skill-dir>/get-object-creation.sh` with Git Bash (never PowerShell). Do not use `--env-file`. Pass every argument at runtime:

- `url` from `MDCMS_API_URL`
- `token`: the noted token
- `logid`: `logId` from the `post-object-creation.sh` response

Show the user the command below with `--token ***`. Run it with Running a script. Do not paste the executed command into the chat.

```text
<skill-dir>/get-object-creation.sh --url <MDCMS_API_URL> --token *** --logid <logId>
```

On Windows, execute exactly:

```text
& "C:\Program Files\Git\bin\bash.exe" "<skill-dir>/get-object-creation.sh" --url "<MDCMS_API_URL>" --token "<noted token>" --logid "<logId>"
```

The command line that runs must start with `&`. Put the noted token in `--token`. The command shown to the user keeps `--token ***`. Do not use `--env-file`.

The script prints `HTTP_STATUS=` and then the response body. It does not print the token.

If the HTTP status is not 200, abort.

If `status` is `jobq-timeout` or `abnormal-jobend`, ask the user to retry or cancel. If the AskQuestion tool is available, use it; otherwise ask in chat.

- Cancel: abort.
- Retry: return to the POST OBJECT-CREATION step and invoke `post-object-creation.sh` again.

If `status` is `pending` or `running`, wait 1 second and repeat this GET OBJECT-CREATION step. On Windows use `Start-Sleep -Seconds 1`. On macOS or Linux use `sleep 1`.

If `status` is `complete`, show the creation results to the user as a formatted markdown table. Use one row for each element of the `objects` array. Use these column headings, in this order: Object Name, Attribute, Status, Spoolfile, Git Path, Git File, Ignore Reason. Fill each row from that element:

- Object Name: `objectName`
- Attribute: `attr`
- Status: `createStatus`
- Spoolfile: `spoolFound`
- Git Path: `gpath`
- Git File: `gfile`
- Ignore Reason: `ignoreReason`

When `gfile` has a value, render the Git File cell as a markdown link that opens that file in the workspace editor. The link text is the `gfile` value. The link target is the workspace-relative path of that file. Build it from `gpath` and `gfile`: drop the leading `/` from `gpath`, then append `/` and `gfile`, using `/` as the separator. When `gpath` is `/`, the target is `gfile` alone. When `gfile` is blank, leave the Git File cell empty.

Example: `gpath` `/source/MCRPGLE` and `gfile` `MDWSOCRT.sqlrpgle` give the Git File cell `[MDWSOCRT.sqlrpgle](source/MCRPGLE/MDWSOCRT.sqlrpgle)`.

`spoolFound` is true when a spool file is available for that object. The source for that object is the repository file indicated by `gpath` and `gfile`.

For each object row where `spoolFound` is true and `createStatus` is not `Ignored`, let the user view the spool file. When `spoolFound` is true, `createStatus` is `Error`, and both `gpath` and `gfile` are not blank, also let the user have the agent try to fix that source from the errors in the spool file. Offer those actions for the current object, plus a choice to continue to the next object, plus a choice to skip to the next object in error. Include a Done choice. Do not offer an Other button. If the AskQuestion tool is available, use it; otherwise ask in chat.

- Done: this run is finished.
- Continue: go to the next object row. If there is no next row, this run is finished.
- Skip to the next object in error. Skip over subsequent rows until `spoolFound` is true and `createStatus` is `Error`. If there are no more rows with this condition, this run is finished.
- View the spool file: retrieve it as described below and show the contents to the user, then offer these choices again for the same object.
- Fix the source: offer this only when `spoolFound` is true, `createStatus` is `Error`, and both `gpath` and `gfile` are not blank. Retrieve the spool file if it has not already been retrieved for this object. Using the errors in that spool file, try to fix the repository source indicated by `gpath` and `gfile`. Show the user what changed, then offer these choices again for the same object.

To retrieve a spool file, invoke `<skill-dir>/get-object-creation-spoolfile.sh` with Git Bash (never PowerShell). Do not use `--env-file`. Pass every argument at runtime:

- `url` from `MDCMS_API_URL`
- `token`: the noted token
- `objectid`: `objectId` of the selected object from the `get-object-creation.sh` response

Show the user the command below with `--token ***`. Run it with Running a script. Do not paste the executed command into the chat.

```text
<skill-dir>/get-object-creation-spoolfile.sh --url <MDCMS_API_URL> --token *** --objectid <objectId>
```

On Windows, execute exactly:

```text
& "C:\Program Files\Git\bin\bash.exe" "<skill-dir>/get-object-creation-spoolfile.sh" --url "<MDCMS_API_URL>" --token "<noted token>" --objectid "<objectId>"
```

The command line that runs must start with `&`. Put the noted token in `--token`. The command shown to the user keeps `--token ***`. Do not use `--env-file`.

The script prints `HTTP_STATUS=` and then the response body. It does not print the token.

If the HTTP status is not 200, show the status to the user and abort.
