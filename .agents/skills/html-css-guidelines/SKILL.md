---
name: html-css-guidelines
description: HTML/CSS coding guidelines. Follow these guidelines when asked to write, refactor, or review HTML and/or CSS.
---

# HTML/CSS Coding Guidelines

Follow these guidelines when asked to write, refactor, or review HTML or CSS.

Produce conservative, standards-compliant HTML5 and CSS. Prefer simple,
portable, accessible, semantic markup and predictable presentation over
newer or more powerful features.

These guidelines are intentionally restrictive. Do not introduce modern
CSS or interactive web-platform features merely because they are available.

## Scope

- Use HTML5.
- Produce passive, document-oriented HTML only.
- Do not use JavaScript.
- Do not use forms or form controls.
- Do not use HTML mechanisms intended to collect, submit, or process
  user input.
- Do not use scripting APIs, event handlers, or other mechanisms intended
  to execute client-side code.
- Use CSS only for presentation. Do not use CSS as a substitute for
  application logic or scripting.
- CSS must be kept separate from HTML element markup; do not use inline
  styles.
- Prefer static document content and navigation over interactive controls.
- Follow these restrictions even when a newer technique would otherwise
  be considered modern best practice.

## HTML standards

* Use only HTML5 elements, attributes, and constructs with full
  Recommendation status in the applicable HTML standard.
* Do not use obsolete, deprecated, experimental, vendor-specific, or
  non-standard HTML features.
* Do not use features that are only proposed, experimental, or supported
  through browser-specific extensions.
* Prefer elements according to their semantic meaning rather than their
  default visual appearance.
* Use the simplest valid HTML structure that accurately represents the
  document.
* Do not use HTML elements merely for their presentational effect.

## Document structure

* Produce a complete HTML document when a complete document is requested.
* Use the HTML5 `<!doctype html>` declaration.
* Use an appropriate `html`, `head`, and `body` structure.
* Include a meaningful `<title>`.
* Declare the document character encoding appropriately.
* Keep metadata in `<head>` and document content in `<body>`.
* Use headings in a logical document hierarchy.
* Use `<main>`, `<header>`, `<footer>`, `<nav>`, `<section>`, `<article>`,
  and `<aside>` only when their semantic meaning is appropriate.
* Do not add structural elements merely to create styling hooks.

## Semantics

* Prefer semantic HTML elements over generic `<div>` and `<span>` elements
  where an appropriate semantic element exists.
* Use `<p>` for paragraphs.
* Use lists for lists.
* Use tables for tabular data, not for page layout.
* Use `<figure>` and `<figcaption>` when content and its caption form a
  meaningful figure.
* Use `<blockquote>` for quotations.
* Use `<code>`, `<pre>`, `<kbd>`, `<samp>`, and `<var>` according to their
  semantics.
* Do not use obsolete presentational elements such as `<font>`, `<center>`,
  or `<big>`.

## Links and navigation

- `<a>` is permitted for navigation to another resource or location.
- Links must represent genuine navigation, not application commands.
- Use meaningful link text that identifies the destination or purpose.
- Do not use JavaScript URLs.
- Do not use links as substitutes for buttons, form controls, or other
  interactive controls.
- Do not create fake links with non-link elements.
- Navigation must remain functional without scripting.

## Images and embedded content

* Use `<img>` for images that form part of the document content.
* Provide appropriate alternative text with `alt`.
* Use an empty `alt` value for genuinely decorative images.
* Do not use images containing text when ordinary text can express the
  same information.
* Do not use image maps, plugins, or other unnecessary interactive
  mechanisms.
* Do not embed active content.
* Avoid external embedded content unless it is explicitly required.

## Forms

## Forms and user input

Forms and form controls are not permitted.

Do not use:

- `<form>`
- `<input>`
- `<button>`
- `<select>`
- `<option>`
- `<optgroup>`
- `<textarea>`
- `<fieldset>`
- `<legend>`
- `<datalist>`
- `<output>`
- `<meter>`
- `<progress>`
- `<label>`

Do not use other HTML constructs whose primary purpose is collecting,
editing, submitting, or processing user input.

Do not simulate form controls using generic HTML elements, CSS, or links.

If information must be presented for the user to read or follow, represent
it as ordinary document content rather than as an input control.

## Accessibility

* Treat accessibility as part of semantic correctness.
* Use native HTML semantics before considering ARIA.
* Do not use ARIA to recreate semantics already provided by an appropriate
  native HTML element.
* Ensure interactive elements, where present, have an appropriate
  native semantic role and meaningful accessible name.
* Ensure form controls have associated labels.
* Provide appropriate alternative text for non-text content.
* Preserve meaningful document structure for assistive technologies.
* Do not introduce ARIA roles, states, or properties without a clear
  semantic or accessibility requirement.
* Do not use CSS to convey information that is unavailable from the
  document's semantic content.

## Separation of HTML and CSS

Do not use the `style` attribute on HTML elements.

CSS must not be embedded in HTML element attributes. Keep presentation
separate from document structure.

CSS may be provided only through:

- an external stylesheet referenced with `<link rel="stylesheet">`; or
- a single `<style>` element in the document `<head>`.

Do not use multiple `<style>` elements.

Do not use obsolete HTML presentational attributes as an alternative to
the `style` attribute.

Prefer an external stylesheet when the CSS is shared between documents or
is substantial. Use a single `<style>` element when the stylesheet is
specific to a single document and keeping it with that document improves
maintainability.

## CSS version restriction

Use CSS 2.0 only.

Do not use CSS3, CSS4, CSS Modules, vendor extensions, experimental
features, or later CSS specifications unless the user explicitly
instructs you to use a specific feature.

In particular, do not introduce the following unless explicitly requested:

* Flexbox
* CSS Grid
* CSS custom properties (variables)
* CSS transitions or animations
* transforms
* gradients
* media queries
* `calc()`
* `min()`, `max()`, or `clamp()`
* newer selectors such as `:not()` forms beyond the permitted CSS 2.0
  syntax, `:nth-child()`, `:nth-of-type()`, `:checked`, `:target`,
  `:has()`, or similar later features
* pseudo-elements or selectors introduced after CSS 2.0
* newer color functions or color spaces
* CSS nesting
* container queries
* modern logical properties
* newer layout mechanisms
* vendor-prefixed properties

When uncertain whether a CSS feature belongs to CSS 2.0, do not use it
unless explicitly instructed to do so.

## CSS structure

- Keep all CSS separate from HTML element markup.
- Never use the `style` attribute.
- Do not use CSS embedded in HTML attributes.
- Use either one `<style>` element in `<head>` or an external stylesheet.
- Do not use multiple `<style>` elements.
- Prefer external stylesheets when CSS is shared across documents.
- Prefer a single `<style>` element when CSS is specific to one document
  and there is a good reason to keep it with the document.
- Keep selectors as simple as practical.
- Avoid excessive selector specificity.
- Avoid unnecessary use of IDs for styling.
- Prefer classes for reusable presentation rules.
- Use element selectors when the rule naturally applies to an element type.
- Avoid deeply nested selectors.
- Group related declarations together.
- Use meaningful class names based on the purpose or semantic role of
  the element rather than its current visual appearance.

## CSS layout

Because CSS is restricted to CSS 2.0:

* Use normal flow, block formatting, inline formatting, floats, and
  positioning as appropriate.
* Use tables only when the content is genuinely tabular; do not use
  HTML tables as a page-layout mechanism.
* Prefer normal document flow over unnecessary positioning.
* Avoid absolute positioning when normal flow, margins, padding, floats,
  or other CSS 2.0 layout mechanisms provide a simpler solution.
* Do not introduce Flexbox or Grid as a workaround for difficult CSS 2.0
  layouts unless explicitly requested.

## Typography and presentation

* Use CSS for typography and visual presentation.
* Prefer relative units where they provide more robust sizing.
* Do not encode semantic meaning solely through visual styling.
* Ensure sufficient visual distinction between structural elements.
* Avoid excessive use of decorative styling.
* Do not use CSS expressions or other non-standard mechanisms.

## Colors and backgrounds

* Use CSS 2.0 color and background properties only.
* Do not use gradients, filters, blend modes, or newer color functions.
* Do not rely on color alone to communicate meaning.
* Ensure text remains readable against its background.

## Validation and conformance

* HTML must be valid according to the applicable HTML5 standard.
* CSS must use CSS 2.0 syntax and features.
* Do not knowingly emit invalid markup or CSS.
* Avoid relying on browser error recovery.
* Close and nest elements correctly according to HTML5 parsing rules.
* Use standards-compliant attribute syntax and values.
* Do not use browser-specific quirks as part of the design.

## Progressive enhancement

The passive-content restriction takes precedence over conventional
progressive-enhancement practices involving JavaScript.

Do not add a JavaScript enhancement layer.

Prefer a complete document that remains useful without scripting.

## Separation of concerns

Keep the responsibilities of each technology distinct:

* HTML expresses document structure, semantics, and content.
* CSS expresses presentation.
* JavaScript is not permitted.

Do not encode presentation through HTML when CSS can express it.
Do not use CSS to express document semantics or application behavior.

## Comments and maintainability

* Prefer clear HTML structure and meaningful class names over comments.
* Do not comment obvious HTML or CSS.
* Comment only when explaining a non-obvious constraint, compatibility
  requirement, or design decision.
* Avoid clever CSS techniques when a simpler CSS 2.0 solution exists.

## Related skills

When HTML or CSS is generated as the output of another language or
transformation, consult the relevant skill for that language or
transformation as well.

The HTML/CSS skill governs the generated HTML and CSS.

For example, when HTML/CSS is generated by XSLT, also consult the XSLT
skill. The XSLT skill governs the transformation implementation, while
this skill governs the generated HTML and CSS.

Do not duplicate transformation-language rules in this skill.

## Explicit exceptions

The CSS 2.0 restriction may be relaxed only when the user explicitly
requests a specific later CSS feature.

When an exception is requested:

* use only the explicitly requested later feature;
* do not introduce unrelated CSS3+ features;
* continue to follow all other guidelines in this skill.

Similarly, an explicit request to use a particular HTML feature does not
automatically permit unrelated non-standard or experimental features.
