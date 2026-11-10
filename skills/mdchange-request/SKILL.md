---
name: mdchange-request
description: >-
  Creates or updates MDCMS object requests for selected repository files. Use
  when the user asks to request MDChange objects, update an object request, or
  run mdchange-request. Does not post RFP dependencies or create objects.
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
- `LEVEL`
- `REPOSITORY_ID`
- `MAP_BRANCH_TO_TASK` (`true` or `false`)
- `PROJECT_STARTING_POSITION` (an integer from 1 to 99)

`MDCMS_CONNECTION_PORT` and `MDCMS_CONNECTION_ENVIRONMENT` may be blank.

When `MAP_BRANCH_TO_TASK` is `false`, `MDCMS_PROJECT`, `MDCMS_TASK`, and `MDCMS_SUBTASK` must also be defined with a value.

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

## 7. Files and existing object requests

If files were added to the chat prior to running the skill, use those. Otherwise show the list of uncommitted changes for the current branch in the repository and ask the user to select 1, multiple files, or all files of the changes for requesting and building. Allow selecting more than one file. Include an All choice and a Cancel choice. If the AskQuestion tool is available, use it with multiple selection; otherwise ask in chat.

List those changes with this command. Do not chain it to another command with `&&`.

```text
git -C "<repository-root>" status --short
```

If the user cancels, abort.

Get the checked-out branch and the git status of each selected file before calling `get-object-requests.sh`. Run these as separate PowerShell commands. Do not use `&&` or `||`. Do not use `cd ... && git ...`.

```text
git -C "<repository-root>" branch --show-current
git -C "<repository-root>" status --short -- "<repository-relative-path>"
```

Pass every selected repository-relative path as its own argument after `--`. The branch name is the output of `git branch --show-current`. A short status of `D` means the file is deleted.

For each selected file, repeat the following steps.

Invoke `<skill-dir>/get-object-requests.sh` with Git Bash (never PowerShell). Do not use `--env-file`. Pass every argument at runtime:

- `url` from `MDCMS_API_URL`
- `token`: the noted token
- `appl` from `APPLICATION`
- `lvl` from `LEVEL`
- `reason`: `DELETE` if the file is set to be deleted in the repository, otherwise `MODIFY`
- `status`: `01`
- `repoId` from `REPOSITORY_ID`
- `branch`: the name of the currently checked-out branch
- `gpath`: the directory of the file relative to the repository root, with a leading `/` and `/` as the folder separator. Use `/` when the file is at the repository root. Do not include any part of the path above the root of the repository on the file system.
- `gfile`: the file name in the repository

Example: repository root `C:\VS Code Repos\ado-mdcms\MDCMS` and file `C:\VS Code Repos\ado-mdcms\MDCMS\source\MCRPGLE\MDWSOCRT.sqlrpgle` give `gpath` `/source/MCRPGLE` and `gfile` `MDWSOCRT.sqlrpgle`. A file at the repository root gives `gpath` `/`.

Show the user the command below with `--token ***`. Run it with Running a script. Do not paste the executed command into the chat.

```text
<skill-dir>/get-object-requests.sh --url <MDCMS_API_URL> --token *** --appl <APPLICATION> --lvl <LEVEL> --reason <DELETE|MODIFY> --status 01 --repoId <REPOSITORY_ID> --branch <branch> --gpath <gpath> --gfile <gfile>
```

On Windows, execute exactly:

```text
& "C:\Program Files\Git\bin\bash.exe" "<skill-dir>/get-object-requests.sh" --url "<MDCMS_API_URL>" --token "<noted token>" --appl "<APPLICATION>" --lvl "<LEVEL>" --reason "<DELETE|MODIFY>" --status "01" --repoId "<REPOSITORY_ID>" --branch "<branch>" --gpath "<gpath>" --gfile "<gfile>"
```

The command line that runs must start with `&`. Put the noted token in `--token`. The command shown to the user keeps `--token ***`. Do not use `--env-file`.

The script prints `HTTP_STATUS=` and then the response body. It does not print the token.

The response body contains an `objectRequests` array.

If `objectRequests` contains one or more rows, use the first row whose `user` equals the noted user from the MCP tool for the PATCH OBJECT-REQUEST step.

If one or more rows are returned and none of them has `user` equal to the noted user, show the details of the first row to the user and ask them to choose. Include Skip Object, Update Request for other User, Create New Request, and Abort. Do not offer an Other button. If the AskQuestion tool is available, use it; otherwise ask in chat.

- Skip Object: begin the loop for the next selected file.
- Update Request for other User: use the first row for the PATCH OBJECT-REQUEST step.
- Create New Request: proceed to the POST OBJECT-REQUEST step.
- Abort: abort the run.

If `objectRequests` is missing or empty, skip to the POST OBJECT-REQUEST step.

## 8. PATCH OBJECT-REQUEST

Note the value of `rfp` from the object-requests row selected for this file in section 7, if an RFP number has not already been noted during this execution run.

If the reason for this file was set to `DELETE`, this file is done. Return to the loop for the next file.

Otherwise invoke `<skill-dir>/patch-object-request.sh` with Git Bash (never PowerShell). Do not use `--env-file`. Pass every argument at runtime:

- `url` from `MDCMS_API_URL`
- `token`: the noted token
- `object-id`: `objectId` from the object-requests row selected for this file in section 7
- `full-path`: the full path of the file
- `gfile`: the file name in the repository

Show the user the command below with `--token ***`. Run it with Running a script. Do not paste the executed command into the chat.

```text
<skill-dir>/patch-object-request.sh --url <MDCMS_API_URL> --token *** --object-id <objectId> --full-path <full-path> --gfile <gfile>
```

On Windows, execute exactly:

```text
& "C:\Program Files\Git\bin\bash.exe" "<skill-dir>/patch-object-request.sh" --url "<MDCMS_API_URL>" --token "<noted token>" --object-id "<objectId>" --full-path "<full-path>" --gfile "<gfile>"
```

The command line that runs must start with `&`. Put the noted token in `--token`. The command shown to the user keeps `--token ***`. Do not use `--env-file`.

The script prints `HTTP_STATUS=` and then the response body. It does not print the token.

When the script is finished, If the HTTP status is not 200 or `rtn.sev` is greater than 10, show the user the error and ask to retry, ignore, or abort. If the AskQuestion tool is available, use it; otherwise ask in chat.

- Abort: abort.
- Retry: retry the PATCH OBJECT-REQUEST step.
- No error, or the user ignored the error: this file is done. Return to the loop for the next file.

## 9. POST OBJECT-REQUEST

If the reason for this file was set to `DELETE`, invoke `<skill-dir>/post-object-request.sh` with Git Bash (never PowerShell). Do not use `--env-file`. Pass every argument at runtime:

- `url` from `MDCMS_API_URL`
- `token`: the noted token
- `appl` from `APPLICATION`
- `lvl` from `LEVEL`
- `rsn`: `*DELETE`
- `repo` from `REPOSITORY_ID`
- `gpath`: the same repository-relative directory already determined for this file in section 7. Do not pass a filesystem path, a drive letter, or the repository root.
- `gfile`: the file name in the repository
- `branch`: the name of the currently checked-out branch
- `proj`: `*BRANCH` if `MAP_BRANCH_TO_TASK` is `true`, otherwise `MDCMS_PROJECT`. When `MAP_BRANCH_TO_TASK` is `true` and `PROJECT_STARTING_POSITION` is greater than 1, append `,` and `PROJECT_STARTING_POSITION`, so the value is `*BRANCH,<PROJECT_STARTING_POSITION>`
- `task`: `0` if `MAP_BRANCH_TO_TASK` is `true`, otherwise `MDCMS_TASK`
- `stsk`: `0` if `MAP_BRANCH_TO_TASK` is `true`, otherwise `MDCMS_SUBTASK`
- `arfp`: `*YES` if an RFP number has been noted during this execution run, otherwise `*AUTO`
- `rfp`: the noted RFP number if an RFP number has been noted during this execution run, otherwise `0`
- `lock`: `*YES`

Show the user the command below with `--token ***`. Run it with Running a script. Do not paste the executed command into the chat.

```text
<skill-dir>/post-object-request.sh --url <MDCMS_API_URL> --token *** --appl <APPLICATION> --lvl <LEVEL> --rsn *DELETE --repo <REPOSITORY_ID> --gpath <gpath> --gfile <gfile> --branch <branch> --proj <proj> --task <task> --stsk <stsk> --arfp <*YES|*AUTO> --rfp <rfp> --lock *YES
```

On Windows, execute exactly:

```text
& "C:\Program Files\Git\bin\bash.exe" "<skill-dir>/post-object-request.sh" --url "<MDCMS_API_URL>" --token "<noted token>" --appl "<APPLICATION>" --lvl "<LEVEL>" --rsn "*DELETE" --repo "<REPOSITORY_ID>" --gpath "<gpath>" --gfile "<gfile>" --branch "<branch>" --proj "<proj>" --task "<task>" --stsk "<stsk>" --arfp "<*YES|*AUTO>" --rfp "<rfp>" --lock "*YES"
```

The command line that runs must start with `&`. Put the noted token in `--token`. The command shown to the user keeps `--token ***`. Do not use `--env-file`.

The script prints `HTTP_STATUS=` and then the response body. It does not print the token.

When the script is finished, handle the response in this order:

1. If `rtn.msg` is `Target Object already locked by another request`, show the user the error and ask to retry, retry unlocked, ignore, or abort. If the AskQuestion tool is available, use it; otherwise ask in chat.
   - Abort: abort.
   - Retry: retry the POST OBJECT-REQUEST step with `lock` still set to `*YES`.
   - Retry unlocked: retry the POST OBJECT-REQUEST step with `lock` set to `*NO`.
   - Ignore: this file is done. Return to the loop for the next file.
2. If the HTTP status is not 200 or `rtn.sev` is greater than 10, show the user the error and ask to retry, ignore, or abort. If the AskQuestion tool is available, use it; otherwise ask in chat.
   - Abort: abort.
   - Retry: retry the POST OBJECT-REQUEST step with `lock` still set to `*YES`.
   - Ignore: this file is done. Return to the loop for the next file.
3. If there is no error, note the RFP number from the response if an RFP number has not already been noted during this execution run. This file is done. Return to the loop for the next file.

If the reason for this file was set to `MODIFY`, invoke `<skill-dir>/post-object-request-with-attachment.sh` with Git Bash (never PowerShell). Do not use `--env-file`. Pass the same arguments as the DELETE request, with these differences:

- `rsn`: `*MIGRATE`
- `full-path`: the full path of the file

Show the user the command below with `--token ***`. Run it with Running a script. Do not paste the executed command into the chat.

```text
<skill-dir>/post-object-request-with-attachment.sh --url <MDCMS_API_URL> --token *** --appl <APPLICATION> --lvl <LEVEL> --rsn *MIGRATE --repo <REPOSITORY_ID> --gpath <gpath> --gfile <gfile> --branch <branch> --proj <proj> --task <task> --stsk <stsk> --arfp <*YES|*AUTO> --rfp <rfp> --lock *YES --full-path <full-path>
```

On Windows, execute exactly:

```text
& "C:\Program Files\Git\bin\bash.exe" "<skill-dir>/post-object-request-with-attachment.sh" --url "<MDCMS_API_URL>" --token "<noted token>" --appl "<APPLICATION>" --lvl "<LEVEL>" --rsn "*MIGRATE" --repo "<REPOSITORY_ID>" --gpath "<gpath>" --gfile "<gfile>" --branch "<branch>" --proj "<proj>" --task "<task>" --stsk "<stsk>" --arfp "<*YES|*AUTO>" --rfp "<rfp>" --lock "*YES" --full-path "<full-path>"
```

The command line that runs must start with `&`. Put the noted token in `--token`. The command shown to the user keeps `--token ***`. Do not use `--env-file`.

When the script is finished, use the same response handling as the DELETE reason.

## Next skills

Continue here only when the object-request loop finished without the user cancelling or aborting the run.

Ask whether skill `mdchange-include-dependencies` should be run. Offer a Yes button and a No button. Do not offer an Other button and do not offer the option to Skip. If the AskQuestion tool is available, use it; otherwise ask in chat.

Do not open, read, or summarize either skill before the user confirms that skill.

If the user selects Yes, read skill `mdchange-include-dependencies` and follow it. Do not ask about `mdchange-create-objects` in this step. That skill asks when it finishes.

If the user selects No, ask whether skill `mdchange-create-objects` should be run. Offer a Yes button and a No button. Do not offer an Other button and do not offer the option to Skip. If the AskQuestion tool is available, use it; otherwise ask in chat.

If the user selects Yes, read skill `mdchange-create-objects` and follow it.

If the user selects No, stop.
