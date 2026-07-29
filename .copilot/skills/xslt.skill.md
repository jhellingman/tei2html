---
name: xslt-guidelines
description: Write XSLT code according to the coding guidelines and conventions of the repository.
---
# Coding Guidelines
* **Snake case.** Use `snake_case` for naming XSLT templates, functions, modes, and variables. The naming of elements output should follow the conventions of the output language being generated, for example, `camelCase` for CSS files.
* **Comments and Documentation.** Don't write comments unless the code cannot be explained sufficiently from the names of templates and functions.
* **Small is beautiful.** Write templates and functions that are short and deal with a single concern.
* **XSLT 3.0.** Use XSLT 3.0 constructs and features that are freely available in the Saxon-HE (Home Edition) XSLT processor. Do NOT use features only available the Saxon-PE or Saxon-EE. We do not want to force users to buy a version.
* **Use map.** Use the XSLT map feature when this improves readability.
* **Readability.** Prefer easy to read code above clever but tricky constructs.
* **Test coverage.** Write Xspec tests for each template and function.
