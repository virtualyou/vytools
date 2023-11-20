# Maven command line #
The CI/CD pipeline uses Maven to build each app, and to validate it by running its MUnit test suite.
Individual developers also use this during development, and when reviewing PRs.

## Command Snippets

Most run configurations, including those that run the MUnit tests, require three program arguments:
 - `-Dcdx_configs=<projects-directory>/cdx-configs`
 - `-Dcdx_props_key=<secret>`
 - `-Denv=local`

The 'env' argument is required by the JSON-logger.

Assuming that MOPTS is defined in your shell, and that cdx-configs in checked out on the `local` branch,
the following will build an app from scratch, and run its MUnit test suite.
```
mvn clean package $MOPTS
```

Note that building an app and running its tests in a single step like this is a useful shortcut for day-to-day use,
but it produces binaries that CANNOT be deployed to other environments,
because the property values, (`-D` options), get substituted into Mule flow xml files under resources/.

In order to produce env-agnostic binaries,
the execution of the test suite, (a runtime thing), needs to be done separately from the build:

```
mvn clean package -DskipTests
mvn test -Denv=local -Dcdx_props_key=fv-@%wejGEN#H4Pk -Dcdx_configs=$CDX_PROJECTS/cdx-configs
```

The 1st command produces env-agnostic binaries, (leaving runtime vars unsubstituted)

The 2nd command runs the MUnit test suite using those binaries

##### TODOs:
##### Notes:

In general, these 3 env-specific properties are referenced
in `global.xml` of each app,
and in `mule-domain-config.xml` of cdx-mule-domain.
