# Contributing

Collections is an early draft, and feedback is the most useful contribution.

- **Questions and objections:** comment on an existing issue or open a new one. Concrete use cases (your event, market or association) are especially helpful.
- **Changes to the draft:** open a pull request that updates `spec/`, `schema/` and `examples/` together, so they stay in step.

## Ground rules

- **Stay neutral.** Field names and examples carry no brand.
- **No customer data, ever.** A collection describes businesses, never the people who use it.
- **Information, not instructions.** Nothing in a collection may tell an agent to install, connect or buy.
- **Use fictional data** in examples, on reserved `.example` domains.
- **Write in UK English.**

Every example under `examples/` (except `examples/invalid/`) must pass the schema, and every file in `examples/invalid/` must fail it. CI checks both on each push; you can run the same check with the command in the README.

By contributing, you agree that your contributions are licensed under the Apache License 2.0.
