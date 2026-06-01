# TDD Anti-Patterns

The ways tests go wrong. A bad test is worse than no test: it costs maintenance,
gives false confidence, and breaks for reasons unrelated to real defects.
Referenced by skills/tdd. Same format as the development anti-patterns: pattern,
why it hurts, the fix.

## Testing the wrong thing

**Testing implementation, not behavior.** Asserting on internal calls, private
state, or how the code works rather than what it does. The test breaks on every
refactor even when behavior is unchanged — so it punishes exactly the cleanup
you want to encourage. → Assert on observable behavior: inputs and outputs,
visible effects. If a refactor that preserves behavior breaks the test, the test
was testing the wrong layer.

**Tautological tests.** Tests that restate the implementation — mock everything,
then assert the mocks were called in the order the code calls them. They pass by
construction and prove nothing. → Test against an independent definition of
correct, not against the code's own structure.

**Tests that pass with the feature removed.** If deleting the production code
leaves the test green, the test exercises nothing. (This is why the RED step
requires confirming the failure is the *absence of the behavior*.) → Watch it
fail for the right reason before making it pass.

## Mocking gone wrong

**Over-mocking.** Mocking so much that the test only verifies the mocks, not the
system. The real integration — the part most likely to break — is never
exercised. → Mock at the true boundaries (network, clock, filesystem,
third-party services). Let your own code run for real.

**Mocking what you don't own, deeply.** Hand-rolling detailed fakes of external
libraries encodes your *assumptions* about them, which drift from reality. → Mock
a thin adapter you own, or use the library's official test doubles; verify the
real contract with a small number of integration tests.

## Test quality

**Fragile tests.** Break on irrelevant changes — timestamps, ordering, whitespace,
unrelated fields. Teams learn to ignore failures, which defeats the suite. → Test
the stable contract; tolerate incidental variation (compare sets not order,
freeze the clock, match the fields that matter).

**Slow tests by default.** Hitting real network/DB/filesystem in unit tests.
Slow suites get skipped, and skipped suites rot. → Keep the unit layer fast and
isolated; concentrate the slow, real-dependency tests in a smaller integration
layer.

**Interdependent tests.** Tests that share state and must run in a specific
order; one failure cascades into noise. → Each test sets up and tears down its
own state; any test can run alone.

**Assertion-free tests.** Tests that exercise code but assert nothing — they only
catch crashes, not wrong answers. → Every test makes at least one meaningful
assertion about the outcome.

**One test, many concerns.** A single test asserting a dozen unrelated things;
when it fails you don't know which. → One behavior per test; the test name says
which behavior.

## The diagnostic

**A test that's hard to write is usually telling you about the design, not the
test.** Tangled setup, needing to mock half the system, having to reach into
internals — these are signals the production code is too coupled or doing too
much. When a test fights you, consider fixing the design before fighting the
test. TDD's quiet benefit is that it surfaces these design problems early, while
they're cheap.
