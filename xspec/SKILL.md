# SKILL: Tests & XSpec quick notes

Purpose: how tests are wired and how to run or extend them.

Where tests live
- xspec/ — XSpec test files for XSLT modules and behaviors.

How tests run
- Maven xspec-maven-plugin is configured in pom.xml to run during the `test` phase.
- The plugin uses Saxon (Saxon-HE declared as a dependency) and the plugin configuration points to dtd/catalog.xml for XML catalog resolution.

Commands
- Run the full test suite:
  mvn test

- Run a subset or iterate on a single XSpec: edit or add tests under xspec/ and re-run `mvn test`. The xspec-maven-plugin picks up tests from the directory configured in pom.xml.

Debugging
- If an XSpec fails, check saxonOptions in pom.xml (dtd/ea/expand/ext/strip settings) as they affect processor behavior.
- Enable Saxon warnings/outval during local runs to surface recoverable errors (pom currently sets warnings silent and outval recover for test plugin configuration).

Adding tests
- Add XSpec files alongside related modules in xspec/ that exercise the module-level templates/functions.
- Use the XML catalog (dtd/catalog.xml) if tests reference entity/DTD resolution.

Test gaps
- README notes tests cover various but not all aspects — prioritize adding XSpec tests for modules with no coverage before refactors.