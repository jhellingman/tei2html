---
name: xslt-guidelines
description: XSLT coding guidelines. Follow when asked to write, refactor, or review XSLT code.
---
# XSLT Coding Guidelines

Follow these guidelines when asked to write, refactor, or review XSLT code.

Produce modern, readable, maintainable XSLT 3.0. Prefer declarative,
rule-based transformations and use XPath/XSLT 3.0 features where they
make the solution clearer or more robust.

## Compatibility

- Target the XSLT 3.0 specification.
- Prefer constructs supported by Saxon-HE.
- Do not use processor-specific extensions unless explicitly requested.
- Do not use features requiring Saxon-PE/EE unless explicitly requested.
- Do not claim a transformation is streamable unless its streamability
  has been verified on an appropriate processor.
- Avoid relying on implementation-specific serialization or error behavior.

## Naming

- Use lower-case words separated by hyphens (`kebab-case`) for
  templates, functions, modes, variables, parameters, accumulators,
  and keys.
- Output element and attribute names follow the vocabulary being generated.
- Use meaningful names that communicate intent.

## Declarative style

- Prefer template rules using `xsl:apply-templates` over procedural
  iteration when the transformation naturally follows the structure
  of the source tree.
- Use named templates, `xsl:for-each`, `xsl:choose`, and `xsl:call-template`
  when they provide a clearer solution.
- Do not use rule-based constructs merely for stylistic consistency.
- Use XPath expressions for values and calculations; use XSLT
  instructions for transformation structure and output construction.
- Use conditional expressions for simple values. Prefer `xsl:choose`
  when conditional branches contain substantial or structurally
  different output.

## XPath and sequences

- Treat sequences as the fundamental XSLT/XPath data model; don't think in
  terms of XSLT 1.0 node sets or mutable collections.
- Specify sequence cardinality where it communicates an important contract,
  e.g. `xs:string`, `xs:string?`, `element(item)+`.
- Prefer XPath sequence operations such as `!`, `?`, predicates,
  `for`, and `fold-left()` when they make the transformation clearer.
- Prefer `!` for straightforward mapping, e.g. `$items ! normalize-space(.)`.
- Use predicates for filtering rather than procedural iteration.
- Use `for` expressions when the mapping requires more substantial logic
  or local variables.
- Don't use positional selection such as `[1]` merely to hide an unexpected
  cardinality. Make the intended cardinality explicit and handle invalid
  input deliberately.
- Avoid unnecessary conversion between nodes and atomic values, and be
  conscious of atomization.
- Understand the difference between general comparisons (`=`, `!=`) and
  value comparisons (`eq`, `ne`), particularly when operands can contain
  multiple items.
- Avoid temporary XML structures when a sequence of nodes or atomic values
  is sufficient.
- Use precise sequence types on function and template interfaces rather
  than generic `item()*` where the actual contract is known.

## Types and interfaces

- Type function parameters and return values explicitly.
- Type template parameters explicitly when they form part of the
  template's interface.
- Type variables when the type communicates an important invariant
  or catches useful errors.
- Use the narrowest useful sequence type, including cardinality.
- Declare `xsl:context-item` when a template requires or assumes a
  specific context-item type.

## Templates and functions

- Keep templates and functions focused on one concern.
- Prefer short, readable implementations over clever expressions.
- Aim to keep templates below 40 lines unless a longer implementation
  is clearly easier to understand.
- Functions should normally be side-effect-free and should not depend
  implicitly on context unless that dependency is intentional.
- Use functions for reusable computation; use templates for
  rule-based transformation and output construction.

## Modes

- Use named modes when a source tree requires multiple processing
  strategies or transformation phases.
- Give modes meaningful names.
- Use `xsl:mode` and `on-no-match` instead of verbose identity-template
  boilerplate where appropriate.
- Avoid unnecessary proliferation of modes.

## Grouping and lookup

- Use `xsl:for-each-group` for grouping rather than manually tracking
  group boundaries.
- Use `xsl:key` and `key()` for repeated lookups and joins.
- When using `key()` with multiple source documents, specify the
  relevant third argument where required.

## Parameters

- Use parameters for externally configurable behavior.
- Use variables for values derived within a transformation.
- Give parameters explicit types and sensible defaults where appropriate.
- Prefer explicit parameter passing when dependencies are local.
- Use tunnel parameters only when a value genuinely needs to propagate
  through several layers of template processing.

## XSLT 3.0 features

Use XSLT 3.0 features when they make the solution clearer or more robust.

- Use maps for naturally keyed data.
- Use arrays for ordered collections when their semantics are appropriate.
- Use `xsl:iterate` for algorithms requiring explicit state between
  successive items.
- Use `xsl:accumulator` when state naturally follows source-tree traversal.
- Use streaming only when memory requirements justify its constraints.
- Use packages when explicit modular interfaces are beneficial.
- Do not introduce advanced XSLT features merely to demonstrate them.

## Data-driven design

- Avoid mixing large amounts of code and configuration data.
- Prefer maps, sequences, or external data files for lookup/configuration
  data when this improves maintainability.
- Avoid long chains of conditional branches when a lookup table expresses
  the relationship more clearly.

## Namespaces

- Declare every namespace used in XPath at the stylesheet root.
- Use `xpath-default-namespace` deliberately when appropriate.
- Never rely on lexical namespace prefixes matching those in the source.
- Use `exclude-result-prefixes` for namespaces that should not appear
  in the result.
- Be deliberate about namespace copying and inheritance.

## XML construction and copying

- Prefer `xsl:copy` plus template application when a subtree must be
  copied while remaining transformable.
- Use `xsl:copy-of` when an unchanged copy is actually intended.
- Do not use string manipulation where the requirement concerns the
  XML data model.
- Never use `disable-output-escaping`.

## Error handling

- Fail early when required input invariants are violated.
- Use `xsl:assert` for important invariants.
- Use `xsl:message` for diagnostic information.
- Use `xsl:try`/`xsl:catch` only when controlled recovery or error
  handling is genuinely required.
- Do not silently turn errors or invalid input into missing output.

## External resources and security

- Treat external documents, URIs, parameters, and dynamic XPath as
  potentially untrusted.
- Avoid unnecessary use of `doc()`, `collection()`, `unparsed-text()`,
  and external URI resolution.
- Avoid `xsl:evaluate` unless dynamic XPath is genuinely required.
- Do not use extension functions or external libraries unless explicitly
  requested.

## Serialization

- Configure serialization explicitly with `xsl:output` when output
  format matters.
- Distinguish constructing the result tree from serializing it.
- Do not rely on processor-specific serialization behavior.
- Do not manipulate serialized XML as text unless text processing is
  explicitly the requirement.

## Comments and documentation

- Prefer self-documenting names and structure.
- Do not comment standard XSLT/XPath language features.
- Comment non-obvious algorithms, external constraints, invariants,
  or decisions that cannot be communicated clearly through code.

## Target language and vocabulary

When generating output for a specific target language, markup vocabulary,
or technology, look for and follow the corresponding skill.

When rules concern the generated output, follow the target-language or
vocabulary skill. When rules concern the transformation implementation,
follow this XSLT skill.

For example, when generating HTML and CSS, consult the HTML/CSS skill for
HTML semantics, document structure, accessibility, CSS conventions,
browser compatibility, and other target-language concerns.

Do not duplicate target-language or vocabulary-specific rules in this skill.

## Testing

Write XSpec tests for non-trivial templates, functions, and significant
transformation behavior. Cover important branches, edge cases, and error
conditions, and add regression tests for significant bugs. Follow the
`xspec-guidelines` skill for test design and implementation.

## Maintainability

- Prefer simple, explicit solutions over clever or highly compressed XPath.
- Avoid premature abstraction.
- Avoid duplicating transformation rules when modes, functions,
  or templates provide a clearer reusable abstraction.
- Preserve the input document's semantic structure unless the
  transformation explicitly requires otherwise.
