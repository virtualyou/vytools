# Postman

Postman is a tool for exercising APIs.
A Postman collection is a named set of pre-defined API requests for exercising an app.

https://www.postman.com/downloads/

### Pre-defined Environment configs

Once Postman is installed on your workstation, import the environment definitions from cdx-configs.

#### Postman 7

The following steps refer to buttons in the upper-right corner of the Postman interface:

    [gear] (Manage Environments)
      [Import]
        [choose file] cdx-configs/PostmanEnvironment.json (of local branch)
    [No Environment] > CDX local

#### Postman 8

The following steps refer to the left side of the Postman interface:

    [Environments]
      [Import]
        [choose file] cdx-configs/PostmanEnvironment.json (of local branch)
    [No Environment] > CDX local

To import the 'CDX dev' configs, switch to the `dev` branch of `cdx-configs` and repeat the above steps.

Each CDX code repository should include `PostmanCollection.json` that can be imported into Postman.
When a collection is imported, the defined requests appear on the left.

Whenever changes have been made to a collection,
  the collection needs to be re-Exported, overwriting the existing `PostmanCollection.json`,
  and committed along with code changes.

### Newman

Newman is a Collection runner for executing suites of collections from the command line.
This is used by the build pipeline.
