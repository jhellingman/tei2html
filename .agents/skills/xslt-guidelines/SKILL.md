---
name: xslt-guidelines
description: Write XSLT code according to the coding guidelines and conventions of the repository.
---
# XSLT Coding Guidelines

* **Naming convention.** Use lower case words separated by hyphens (`kebab-case` or `dash-case`) for naming XSLT templates, functions, modes, and variables. The naming of output elements should follow the conventions of the output language being generated, so, for example, `camelCase` for XML elements used in the TEI standard.
* **XSLT 3.0.** Use XSLT 3.0 constructs and features that are available in the Saxon-HE (Home Edition) XSLT processor only. Do NOT use features limited to Saxon-PE or Saxon-EE. We want to ensure `tei2html` works with the free version.
* **Comments and Documentation.** Don't write comments unless the code cannot be explained sufficiently from the names of templates and functions.
* **Small is beautiful.** Write templates and functions that are short and deal with a single concern.
* **Use map.** When appropriate, use the XSLT map feature when this improves readability.
* **Data-driven.** Avoid mixing code and data. When reasonable, use look-up tables in preference to long switch statements.
* **Readability.** Prefer easy to read code above clever but tricky constructs.
* **Test coverage.** Write `xspec` tests for each template and function.
