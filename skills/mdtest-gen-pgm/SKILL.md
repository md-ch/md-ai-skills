---
name: mdtest-gen-pgm
description: >-
  Generate a MDTest-Based test program to unit test an application process
disable-model-invocation: true
---

# MDTest Prompts

`<skill-dir>` is the directory that contains this SKILL.md. Resolve it from the path given for this file.

`mdtest.properties` is `<skill-dir>/mdtest.properties`. Do not read or write any other properties file for these settings.

When executing a command, replace `<skill-dir>` with the absolute directory of this SKILL.md.

Never print tokens or connection credentials. In any text shown to the user, including a command, write the token as `***`. Do not paste an executed command line into the chat. Do not modify `settings.json`.

Check if `MDTEST_EXAMPLES` exists in `mdtest.properties` and that file `RPGEXP1.sqlrpgle` exists in the value of `MDTEST_EXAMPLES`.

Check if `MDTEST_PROCS` exists in `mdtest.properties` and that the file name is `MDRTESTP.rpgle` and it exists in the repository location specified by `MDTEST_PROCS`.

Check if `MDTEST_TEST_PROGRAMS` exists in `mdtest.properties` and that the path exists in the repository for the value of `MDTEST_TEST_PROGRAMS`.

## Prompt for name of application program

If a file was attached to the chat, ask if that is the application program or otherwise provide the name of the file containing the program source code.

## Prompt for name of testing program

Prompt for the name of the testing program. It will then be stored with the appropriate file type in the relative path value of `MDTEST_TEST_PROGRAMS`.

If the program already exists, ask if the file should be replaced or updated or if the process should abort.

# Create/Update Test Program

Analyze the contents of the application program and then create or update the code for the test program that will test the application program with the possible options and various plausible values.

The test results will be logged by using the appropriate MDTEST procedures in `MDTEST_PROCS`

Prior to any calls to the the application program, the test program should register code coverage for the application program.
See `MDTEST_EXAMPLES`\RPGEXP1.sqlrpgle for use of MDTEST procedures.