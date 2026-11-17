---
name: mdchange-request
description: >-
  Creates or updates MDCMS object requests directly for IBM i Source Physical File members
  and IFS stream files (no source-control dependency). Use when the user asks to request MDChange objects,
  update an object request, or run mdchange-request.
disable-model-invocation: true
---

# MDCMS Object Request (Native IBM i & IFS)

`<skill-dir>` is the directory that contains this SKILL.md. Resolve it from the path given for this file.

`mdchange.properties` is `../mdchange-config/mdchange.properties`, relative to `<skill-dir>`. Resolve it to an absolute path. Do not read or write any other properties file for these settings.

When executing a command, replace `<skill-dir>` with the absolute directory of this SKILL.md.

Never print tokens or connection credentials. In any text shown to the user, including a command, write the token as `***`. Do not paste an executed command line into the chat. Do not modify `settings.json`.

Do not open, read, or summarize any other skill unless the user confirms that skill should be run. Confirmation applies only to the skill the user named.

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

## Properties

Read `../mdchange-config/mdchange.properties`.

These properties must be defined with a value:

- `MDCMS_API_URL`
- `MDCMS_CONNECTION_HOST`
- `MDCMS_CONNECTION_SECURE`
- `APPLICATION`
- `LEVEL`
- `MDCMS_PROJECT`
- `MDCMS_TASK`
- `MDCMS_SUBTASK`

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

## 6. Objects / Members / IFS Source Specification

Ask the user whether they are working with:
1. **Source Physical File Member** (e.g. RPG, RPGLE, SQLRPGLE, CLP, CLLE, DSPF, PF)
2. **IFS Stream File**

### Change reason (`rsn`)

The MDCMS REST API accepts only these reason values: `*MIGRATE`, `*DELETE`, `*RECOMPILE`, `*UPDATE`. Do not use `*MODIFY` or `*NEW`; the API does not accept them.

- Use `*MIGRATE` when checking out an existing member/object and uploading edited source.
- Use `*DELETE` to delete the object.
- Use `*RECOMPILE` or `*UPDATE` only when the user explicitly asks for that reason.

### For Source Physical File Member:
Gather or confirm:
- `objn`: Object Name (max 10 chars, e.g. `FRS021`)
- `objt`: Object Type (e.g. `*PGM`, `*SRVPGM`, `*MODULE`, `*FILE`)
- `attr`: Source Attribute (e.g. `RPG`, `RPGLE`, `SQLRPGLE`, `CLP`, `CLLE`, `DSPF`, `PF`) — if unknown, query `<skill-dir>/get-attributes.sh --url <MDCMS_API_URL> --token *** --appl <APPLICATION> --lvl <LEVEL> --objt <objt>`
- `fsfl`: Source File (e.g. `QRPGSRC`, `QRPGLESRC`, `QDDSSRC`, `QCLSRC`, `QCLLESRC`)
- `fsmb`: Source Member name (defaults to `objn`)
- `rsn`: Reason for change (`*MIGRATE`, `*DELETE`, `*RECOMPILE`, or `*UPDATE`)
- Optional local source file path if attaching/uploading edited source from workspace.

**Source format must match the actual member.** Do not assume RPGLE/`QRPGLESRC`. The `fsfl`, the member's source type, and `attr` must all describe the real member as it exists on IBM i (or in the MDCMS level), and `attr` must map to the right compiler.

### For IFS Stream File:
Gather or confirm:
- `ifsp`: IFS Directory path (e.g. `/home/projects/app`)
- `ifsf`: IFS File name (e.g. `app.js`)
- `rsn`: Reason for change (`*MIGRATE`, `*DELETE`, `*RECOMPILE`, or `*UPDATE`)
- Optional local file path if attaching/uploading edited source from workspace.

## 7. Query Existing Object Requests

Invoke `<skill-dir>/get-object-requests.sh` with Bash (never PowerShell). Pass:

- `url` from `MDCMS_API_URL`
- `token`: the noted token
- `appl` from `APPLICATION`
- `lvl` from `LEVEL`
- `status`: `01`
- `objn`: `objn` (if member)
- `objt`: `objt` (if member)
- `ifsp`: `ifsp` (if IFS)
- `ifsf`: `ifsf` (if IFS)

Show the command with `--token ***`. Do not paste the real token.

```text
<skill-dir>/get-object-requests.sh --url <MDCMS_API_URL> --token *** --appl <APPLICATION> --lvl <LEVEL> --status 01 --objn <objn> --objt <objt>
```

Execute exactly:

```text
bash "<skill-dir>/get-object-requests.sh" --url "<MDCMS_API_URL>" --token "<noted token>" --appl "<APPLICATION>" --lvl "<LEVEL>" --status "01" --objn "<objn>" --objt "<objt>"
```

The script prints `HTTP_STATUS=` and then the response body.

If `objectRequests` contains one or more rows:
- If a row exists where `user` equals the noted user, note `objectId` and `rfp`. If local source was modified and needs uploading, go to **8. PATCH OBJECT-REQUEST**. If already checked out on IBM i directly, note the RFP number and proceed to Next skills.
- If rows exist but for a different user, prompt the user:
  - Skip Object
  - Update Request for other User (use that `objectId` for PATCH OBJECT-REQUEST)
  - Create New Request (go to **9. POST OBJECT-REQUEST**)
  - Abort

If `objectRequests` is empty or no request exists:
- Proceed to **9. POST OBJECT-REQUEST**.

## 8. PATCH OBJECT-REQUEST (Source Upload)

If the change reason is `*DELETE` or no local file upload is needed, this step is done.

If a local file is being uploaded to an existing request:
Invoke `<skill-dir>/patch-object-request.sh` with Bash (never PowerShell):

- `url` from `MDCMS_API_URL`
- `token`: the noted token
- `object-id`: `objectId` from section 7
- `full-path`: local path to source file
- `fsmb`: member name (or `ifsf` for IFS)

```text
<skill-dir>/patch-object-request.sh --url <MDCMS_API_URL> --token *** --object-id <objectId> --full-path <full-path> --fsmb <fsmb>
```

Execute exactly:

```text
bash "<skill-dir>/patch-object-request.sh" --url "<MDCMS_API_URL>" --token "<noted token>" --object-id "<objectId>" --full-path "<full-path>" --fsmb "<fsmb>"
```

The script prints `HTTP_STATUS=` and then the response body.

If HTTP status is not 200 or `rtn.sev` is > 10, display the error and prompt to retry, ignore, or abort.

## 9. POST OBJECT-REQUEST (Create Request)

If a new request must be created:

### Without Local File Attachment:
Run `<skill-dir>/post-object-request.sh` with Bash (never PowerShell):

- `url` from `MDCMS_API_URL`
- `token`: the noted token
- `appl` from `APPLICATION`
- `lvl` from `LEVEL`
- `rsn`: `*MIGRATE`, `*DELETE`, `*RECOMPILE`, or `*UPDATE`
- `proj`: `MDCMS_PROJECT`
- `task`: `MDCMS_TASK`
- `stsk`: `MDCMS_SUBTASK`
- `arfp`: `*YES` if an RFP number is already noted, otherwise `*AUTO`
- `rfp`: the noted RFP number if known, otherwise `0`
- `lock`: `*YES`
- Plus member parameters (`--objn`, `--objt`, `--attr`, `--fsfl`, `--fsmb`) or IFS parameters (`--ifsp`, `--ifsf`).

```text
<skill-dir>/post-object-request.sh --url <MDCMS_API_URL> --token *** --appl <APPLICATION> --lvl <LEVEL> --rsn <rsn> --proj <proj> --task <task> --stsk <stsk> --arfp <arfp> --rfp <rfp> --lock *YES --objn <objn> --objt <objt> --attr <attr> --fsfl <fsfl> --fsmb <fsmb>
```

Execute exactly:

```text
bash "<skill-dir>/post-object-request.sh" --url "<MDCMS_API_URL>" --token "<noted token>" --appl "<APPLICATION>" --lvl "<LEVEL>" --rsn "<rsn>" --proj "<proj>" --task "<task>" --stsk "<stsk>" --arfp "<arfp>" --rfp "<rfp>" --lock "*YES" --objn "<objn>" --objt "<objt>" --attr "<attr>" --fsfl "<fsfl>" --fsmb "<fsmb>"
```

### With Local File Attachment:
Run `<skill-dir>/post-object-request-with-attachment.sh` with the same parameters plus `--full-path <full-path>`.

Execute exactly:

```text
bash "<skill-dir>/post-object-request-with-attachment.sh" --url "<MDCMS_API_URL>" --token "<noted token>" --appl "<APPLICATION>" --lvl "<LEVEL>" --rsn "<rsn>" --proj "<proj>" --task "<task>" --stsk "<stsk>" --arfp "<arfp>" --rfp "<rfp>" --lock "*YES" --objn "<objn>" --objt "<objt>" --attr "<attr>" --fsfl "<fsfl>" --fsmb "<fsmb>" --full-path "<full-path>"
```

The script prints `HTTP_STATUS=` and then the response body.

When the script is finished, handle the response:
1. If `rtn.msg` is `Target Object already locked by another request`, show the user the error and ask to retry, retry unlocked, ignore, or abort.
   - Abort: abort.
   - Retry: retry the POST OBJECT-REQUEST step with `lock` still set to `*YES`.
   - Retry unlocked: retry the POST OBJECT-REQUEST step with `lock` set to `*NO`.
   - Ignore: this object is done.
2. If the HTTP status is not 200 or `rtn.sev` is greater than 10, show the user the error and ask to retry, ignore, or abort.
3. If there is no error, note the RFP number and objectId from the response.

## Next skills

Continue here only when the object-request step finished without the user cancelling or aborting the run.

Ask whether skill `mdchange-include-dependencies` should be run. Offer a Yes button and a No button. Do not offer an Other button and do not offer the option to Skip. If the AskQuestion tool is available, use it; otherwise ask in chat.

Do not open, read, or summarize either skill before the user confirms that skill.

If the user selects Yes, read skill `mdchange-include-dependencies` and follow it. Do not ask about `mdchange-create-objects` in this step. That skill asks when it finishes.

If the user selects No, ask whether skill `mdchange-create-objects` should be run. Offer a Yes button and a No button. Do not offer an Other button and do not offer the option to Skip. If the AskQuestion tool is available, use it; otherwise ask in chat.

If the user selects Yes, read skill `mdchange-create-objects` and follow it.

If the user selects No, stop.
