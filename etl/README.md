# etl

A collections of scripts to automate Gen3 metadata processing.


## metadata

```commandline

Usage: metadata [OPTIONS] COMMAND [ARGS]...

  Metadata loader.

Options:
  --gen3_credentials_file TEXT  API credentials file downloaded from gen3
                                profile.  [default: credentials.json]

  --help                        Show this message and exit.

Commands:
  drop-program  Drops empty program
  drop-project  Drops empty project
  empty         Empties project, deletes all metadata.
  load          Loads metadata into project
  ls            Introspects schema and returns types in order.

```