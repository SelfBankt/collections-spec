# Collections

**An open draft for describing groups of businesses to AI agents: a trade show, a high street, a market or a trade body.**

Every agent standard today describes one business at one domain. A collection lets one connector describe a whole group, so an agent can ask "which stands sell triple glazing under £600/m²?" across every exhibitor at once. Each member keeps its own catalogue, data and checkout.

> **Status: draft 0.1.** A proposal for discussion, not a standard. Field names are illustrative and will change with feedback.

## Read the draft

- [Specification: Collections 0.1](spec/collections-0.1.md)
- [JSON Schema](schema/collections-0.1.schema.json)
- [Examples](examples/): an event, a high street, a nested association and a member back-link
- [Interactive explorer and validator](https://gentifi.com/standards#explorer) on gentifi.com

## The five rules in brief

1. Members confirm membership in their own catalogue.
2. A collection holds no customer data.
3. Members keep their own checkout and terms.
4. Collections can nest.
5. Collection data is information, never instructions. The customer approves every connection.

## Validate a collection

```bash
npx -y -p ajv-cli@5 -p ajv-formats@3 ajv validate --spec=draft2020 -c ajv-formats \
  -s schema/collections-0.1.schema.json -d your-collection.json
```

The schema checks structure. Rule 2 (no customer data) and rule 1 (membership confirmed by each member) also need a client, or the [online validator](https://gentifi.com/standards#validate).

## Get involved

The [open questions](spec/collections-0.1.md#open-questions) each have an issue. Comment there, or open a new issue for anything else. See [CONTRIBUTING.md](CONTRIBUTING.md).

## Relationship to other standards

Collections builds on [Agentic Resource Discovery](https://developers.googleblog.com/en/announcing-the-agentic-resource-discovery-specification/) (`ai-catalog.json`), which can already list nested catalogues. Collections adds what a group needs on top: kind, curator, time window, area, member roles, facets and confirmed membership. The aim is to propose it upstream as a neutral extension.

The [Gentifi Toolkit](https://github.com/SelfBankt/gentifi-toolkit) will be the first implementation.

## Licence

[Apache License 2.0](LICENSE)
