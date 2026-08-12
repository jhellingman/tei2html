---
name: xspec-guidelines
description: XSpec coding guidelines. Follow when asked to write, refactor, or review XSpec tests.
---

# XSpec Testing Guidelines

Follow these guidelines when asked to write, refactor, or review XSpec tests for XSLT.

Write tests that clearly express the intended behavior of the transformation.
Prefer small, focused examples that fail for meaningful reasons.

Do not automatically create one test for every function, template, XPath expression,
variable, or line of XSLT. Create tests around  behavior, contracts, branches, and edge cases.

## Test behavior, not implementation

- Test observable behavior rather than the internal implementation of a stylesheet.
- Prefer testing templates and functions through their public or meaningful interfaces.
- Avoid tests that merely reproduce the implementation's XPath expressions.
- Refactoring the XSLT should not require changing tests unless the behavior changes.
- Test implementation details only when they represent an important contract.

## Test structure

- Give each scenario a clear, descriptive name that explains the behavior being tested.
- Keep scenarios focused on one behavior or closely related set of behaviors.
- Use `x:description` and `x:scenario` structure consistently.
- Prefer several small scenarios over one large scenario with many unrelated assertions.
- Organize related scenarios into logical descriptions.

## Test naming

- Use names that describe the expected behavior, not the implementation.
- Prefer names such as `removes-empty-elements` or `groups-items-by-category`
  over names such as `calls-template-foo`.
- Use consistent naming for test fixtures and supporting files.

## Coverage

- Provide XSpec coverage for every non-trivial template and function.
- Cover important branches and meaningful edge cases rather than aiming for
  coverage of every line of code.
- Include tests for:
  - normal input
  - empty or missing input
  - optional elements and attributes
  - multiple occurrences where cardinality matters
  - namespaces
  - whitespace and normalization
  - Unicode where relevant
  - boundary values
  - invalid or unexpected input
  - error conditions where applicable
- Test both positive and negative cases when behavior requires rejection or
  omission.
- When order, grouping, or cardinality matters, test those properties explicitly.

## Assertions

- Prefer the simplest assertion that clearly expresses the requirement.
- Use `expect` when the expected result is small and stable.
- Use XPath assertions when only a specific property of the result matters.
- Avoid asserting the entire result tree when only one property is relevant.
- When the complete result is itself the contract, use a complete expected result.
- Keep assertions independent where practical so that a failure identifies
  the violated behavior clearly.
- Do not add assertions that merely duplicate one another.

## Expected results

- Keep expected XML small and focused.
- Use complete expected output when structural equality is the intended contract.
- Use targeted XPath assertions when insignificant output differences would
  otherwise make tests unnecessarily brittle.
- Do not weaken assertions simply to make tests pass.
- Treat whitespace, namespace nodes, ordering, and serialization differences
  deliberately rather than accidentally.

## Test fixtures

- Keep source fixtures minimal: include only data necessary to demonstrate
  the behavior being tested.
- Prefer small inline test data for simple scenarios.
- Use external fixture files when the input or expected output is large,
  reused, or easier to understand as a separate document.
- Give fixtures descriptive names.
- Avoid one enormous fixture containing unrelated test cases.

## Functions

- Test functions with representative inputs and important boundary cases.
- Test empty sequences and cardinality boundaries when they are part of
  the function's contract.
- Test error conditions when the function deliberately rejects input.
- Prefer testing a function through its public interface when possible.

## Templates and modes

- Test named templates through their intended interface.
- For matched templates, prefer scenarios that exercise the template through
  template application rather than invoking implementation details directly.
- Test different modes separately when they represent different behaviors.
- Test mode-specific behavior rather than assuming that testing the default
  mode covers all modes.

## Parameters

- Test important parameter values and defaults.
- Test parameter combinations when their interaction affects behavior.
- Do not duplicate the entire test suite merely to test insignificant
  parameter variations.

## Error handling

- Test expected failures explicitly.
- When a stylesheet uses `xsl:assert`, `xsl:message`, or error handling,
  verify the relevant error behavior where it forms part of the contract.
- Do not write tests that depend unnecessarily on processor-specific error
  messages.

## Maintainability

- Avoid duplication between scenarios where shared fixtures or variables make
  the tests clearer.
- Do not over-abstract test setup: test data should remain easy to understand.
- Keep tests readable to someone who has not written the stylesheet.
- Prefer explicit test data over elaborate test-generation mechanisms.
- Update tests when requirements change; don't weaken tests to accommodate
  implementation changes.

## Regression tests

- Add a regression test for every significant bug that is fixed.
- Make the regression fixture as small as possible while reproducing the bug.
- Name the scenario after the behavior or defect being protected, not merely
  after an issue number.

## Test independence

- Scenarios should be independent and should not rely on execution order.
- Avoid shared mutable state or external side effects.
- Tests should produce the same result when run individually or as part of
  the complete suite.

## Test quality

A good XSpec test should make it easy to answer:

1. What behavior is being tested?
2. What input triggers that behavior?
3. What result is expected?
4. Why would this test fail if the behavior regressed?

Prefer tests that provide a clear answer to all four questions.
