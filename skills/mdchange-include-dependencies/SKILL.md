---
name: mdchange-include-dependencies
description: >-
  Posts MDCMS RFP dependencies for an object request. Use when the user asks to
  include dependencies, add RFP dependencies, or run mdchange-include-dependencies.
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

## 10. POST RFP-DEPENDENCIES

`request.fslb` and `request.rfp` come from `post-object-request-with-attachment.sh`. That script is the one invoked with `rsn` set to `*MIGRATE`. Use a response already in this conversation. Do not open another skill to find it.

If that script was executed at least once in this conversation with `rsn` set to `*MIGRATE`, an HTTP status of 200, and `request.fslb` not blank, use `request.rfp` from the first such response.

If this conversation has no such response, ask the user for the RFP number. If the user does not provide one, stop.

Invoke `<skill-dir>/post-rfp-dependencies.sh` with Git Bash (never PowerShell). Do not use `--env-file`. Pass every argument at runtime:

- `url` from `MDCMS_API_URL`
- `token`: the noted token
- `appl` from `APPLICATION`
- `rfp`: the RFP number resolved above
- `clear-existing`: `false`

Show the user the command below with `--token ***`. Run it with Running a script. Do not paste the executed command into the chat.

```text
<skill-dir>/post-rfp-dependencies.sh --url <MDCMS_API_URL> --token *** --appl <APPLICATION> --rfp <rfp> --clear-existing false
```

On Windows, execute exactly:

```text
& "C:\Program Files\Git\bin\bash.exe" "<skill-dir>/post-rfp-dependencies.sh" --url "<MDCMS_API_URL>" --token "<noted token>" --appl "<APPLICATION>" --rfp "<rfp>" --clear-existing "false"
```

The command line that runs must start with `&`. Put the noted token in `--token`. The command shown to the user keeps `--token ***`. Do not use `--env-file`.

The script prints `HTTP_STATUS=` and then the response body. It does not print the token.

If the HTTP status is not 200, show the status to the user and abort. Do not ask about another skill.

## Next skill

Continue here only when `post-rfp-dependencies.sh` returned HTTP status 200.

Ask the user whether skill `mdchange-create-objects` should be run. Offer a Yes button and a No button. Do not offer an Other button and do not offer the option to Skip. If the AskQuestion tool is available, use it; otherwise ask in chat.

Do not open, read, or summarize that skill before the user confirms it.

If the user selects No, stop.

If the user selects Yes, read skill `mdchange-create-objects` and follow it.
