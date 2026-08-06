# SKILL: Operational runbook for tei2html

This SKILL.md captures the essential maintenance/run instructions and quick commands (from repository analysis).

Quick commands
- Run the test suite (XSpec tests via Maven):
  `mvn test`

- Build examples and documentation (runs prepare-package phase, which does sample transforms and docs):
  `mvn package`

Prerequisites
- Java (JDK) and Maven installed and on PATH.
- Perl for pptools scripts if you use them.
- Recommended XSLT processor: Saxon (the project uses Saxon-HE in CI via Maven). The pom.xml declares saxon.version = 13.0 — confirm the Saxon version you intend to run locally.
- External binaries that some pptools scripts may expect: ImageMagick, 7zip, and other common image/archive utilities.

Where to start when something breaks
- Tests failing: run `mvn test` locally and inspect xspec/ output. The Maven xspec plugin runs XSpec tests using the Saxon dependency declared in pom.xml.
- Transform output odd or missing: inspect preprocess.xsl, tei2html.xsl (or the relevant tei2<format>.xsl), and modules/* for the specific feature.
- Missing localization/labels: check modules/localization.xsl and locale/ directory.

Important configuration files
- pom.xml — Maven lifecycle, plugin configuration (xspec, asciidoctor, xml-maven-plugin) and Saxon/version properties.
- dtd/catalog.xml — XML catalog used by XSpec / transforms (referenced in pom.xml). Ensure catalog resolution works in your environment.

CI notes
- .github/workflows/test.yml runs `mvn test` on ubuntu-latest and caches ~/.m2.
- .github/workflows/deploy-docs.yml exists to publish documentation (see file for specifics).

Risk reminders
- Saxon version mismatch or Saxon-HE vs. EE features may break transforms.
- pom.xml sets saxonOptions warnings=silent and outval=recover — errors may be hidden during transforms; consider enabling warnings for debugging.
- Many pptools Perl scripts assume external tools and specific encodings — document & verify prerequisites when using them.
