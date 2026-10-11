# Contributing

Collections is an early draft, and feedback is the most useful contribution.

- **Questions and objections:** comment on an existing issue or open a new one. Concrete use cases (your event, market or association) are especially helpful.
- **Changes to the draft:** open a pull request that updates `spec/`, `schema/` and `examples/` together, so they stay in step.

## Ground rules

- **Stay neutral.** Field names and examples carry no brand.
- **No customer data, ever.** A collection describes businesses, never the people who use it.
- **Information, not instructions.** Nothing in a collection may tell an agent to install, connect or buy.
- **Use fictional data** in examples, on reserved `.example` domains.
- **Build on ARD.** Prefer an existing ARD field or a namespaced term over a new top-level field.
- **Write in UK English.**

Examples are grouped by draft (`examples/0.1/`, `examples/0.2/`). Every example must pass its draft's schema, and every file in an `invalid/` folder must fail it, for the reason its name gives. CI checks both on each push; run `./scripts/validate.sh` for the same check locally.

By contributing, you agree that your contributions are licensed under the Apache License 2.0.
