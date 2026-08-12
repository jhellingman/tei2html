---
name: perl-guidelines
description: Perl coding guidelines. Follow these guidelines when asked to write, refactor, or review Perl code.
---
# Perl Coding Guidelines

Use for writing, reviewing, refactoring, or designing Perl 5.36+ code.

## Core Rules

* Target **Perl 5.36+** and start modules/scripts with `use v5.36;`.
* Use subroutine **signatures**; do not manually unpack `@_`.
* Prefer clear, idiomatic modern Perl over clever or overly terse code.
* Understand and deliberately use Perl's **scalar/list context**.
* Prefer postfix dereferencing (`$ref->@*`, `$ref->%*`) for nested structures.
* Use `say` rather than `print` with explicit newlines.
* Keep data and APIs immutable where practical.

## OO and Modules

* Prefer **Moo** for lightweight OO; use Moose only when its metaprotocol is needed.
* Define attributes as read-only (`is => 'ro'`) and validate them with `Types::Standard`.
* Do not create objects by directly blessing hashrefs.
* Use roles for shared behavior.
* For exported functions, use `Exporter 'import'` with `@EXPORT_OK`; avoid `@EXPORT`.
* Keep application code organized around focused modules and testable boundaries.

## Error Handling

* Handle failures explicitly; do not silently ignore errors.
* Use `autodie` for straightforward resource operations.
* Use `Try::Tiny` when exception-style handling is needed on Perl versions without native `try/catch`.
* On Perl 5.40+, native `try/catch` is preferred where appropriate.
* Keep error messages contextual and actionable.

## I/O and Security

* Always use **three-argument `open`** with an explicit encoding.
* Never use two-argument `open`.
* Prefer `Path::Tiny` for filesystem operations.
* For web-facing CGI scripts, enable taint mode (`-T`) and validate/untaint external input with strict allowlists.
* Never interpolate untrusted input into shell commands; use list-form `system` or `IPC::Run3`.
* Never interpolate values into SQL. Use DBI placeholders.
* Guard user-controlled paths against traversal using canonical paths such as `Cwd::realpath`.
* Treat environment variables and external input as untrusted.

## Regex

* Prefer named captures (`(?<name>...)`) over positional captures.
* Use `/x` for complex regular expressions.
* Precompile patterns with `qr//` when reused.
* Validate input with anchored, explicit allowlists rather than permissive catch-all patterns.

## Data and Persistence

* Represent structured value objects/DTOs with Moo + `Types::Standard`.
* Put DBI/DBIx::Class access behind repository interfaces rather than spreading SQL/database details through application code.
* Use reproducible dependency management with `cpanfile` and `carton`.

## Testing and Quality

* Every new behavior should have tests; keep unit and integration tests separate.
* Run the project's test suite with `prove -lr t/` (or the project's established equivalent).
* Format with `perltidy` using the project convention.
* Run `perlcritic` with at least severity 3 and the `core`, `pbp`, and `security` themes.
* For security-focused review, run `perlcritic` with the `security` theme at severity 4+.

## Review Checklist

Before considering Perl code complete, verify:

1. `use v5.36;` and signatures are used where applicable.
2. OO code uses Moo/typed, read-only attributes rather than blessed hashrefs.
3. File, process, and SQL operations cannot be injection vectors.
4. Regexes are readable, anchored, and use named captures when capturing.
5. Errors are handled deliberately.
6. Tests cover the changed behavior.
7. `perltidy`, `perlcritic`, and the test suite pass.

