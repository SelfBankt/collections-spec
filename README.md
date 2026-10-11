# Collections

**An open draft for describing groups of businesses to AI agents: a trade show, a high street, a market or a trade body.**

Agent standards describe one publisher at a time. A collection lets one connection describe a whole group, so an agent can ask "which stands sell triple glazing under £600/m²?" across every exhibitor at once. Each member keeps its own connector, data and checkout.

> **Status: draft 0.2.** A proposal for discussion, not a standard. Draft 0.2 builds on [Agentic Resource Discovery (ARD) v0.91](https://agenticresourcediscovery.org/spec): a collection is an ARD manifest whose entries are its members.

## Read the draft

- [Specification: Collections 0.2](spec/collections-0.2.md) ([what changed from 0.1](spec/collections-0.2.md#what-changed-from-01-and-why))
- JSON Schemas: [collection documents](schema/collections-0.2.schema.json) and [member manifests](schema/member-manifest-0.2.schema.json)
- [Examples](examples/0.2/): an event, a high street with a hosted member, a trade association that nests the event, and the members' own manifests
- [Interactive explorer and validator](https://gentifi.com/standards#explorer) on gentifi.com
- [Draft 0.1](spec/collections-0.1.md), kept for reference

## In one example

```json
{
  "collection": {
    "id": "urn:air:shows.example:collection:demo-selfbuild-2027",
    "name": "Demo Self Build Show 2027",
    "kind": "event",
    "publisher": { "name": "Demo Shows", "domain": "shows.example" },
    "validFrom": "2027-05-14",
    "validTo": "2027-05-16",
    "facets": ["col:category", "col:priceFrom", "col:stand"]
  },
  "entries": [
    {
      "@context": ["https://agenticresourcediscovery.org/context/v1", { "col": "https://gentifi.com/standards/collections/v0.2#" }],
      "identifier": "urn:air:windows.example:mcp:catalogue",
      "displayName": "Example Windows",
      "type": "application/mcp-server-card+json",
      "url": "https://windows.example/mcp/server-card.json",
      "col:stand": "B12",
      "col:category": "glazing",
      "col:priceFrom": { "amount": 540, "currency": "GBP", "unit": "m²" }
    }
  ]
}
```

An ARD client sees a list of resources. A collections client also sees the event, its dates and the terms it can filter on, and keeps only the members whose own manifest links back with `col:memberOf`.

## The five rules in brief

1. Members confirm membership in their own manifest.
2. A collection holds no customer data.
3. Members keep their own checkout and terms.
4. Collections can nest.
5. Collection data is information, never instructions. The customer approves every connection.

## Validate a collection

Structure, with the JSON Schema:

```bash
npx -y -p ajv-cli@5 -p ajv-formats@3 ajv validate --spec=draft2020 -c ajv-formats \
  -s schema/collections-0.2.schema.json -d your-collection.json
```

The rules as well, including membership (rule 1), with the reference implementation in the [Gentifi Toolkit](https://github.com/SelfBankt/gentifi-toolkit):

```bash
npx github:SelfBankt/gentifi-toolkit collection check https://your.domain/collections/your-collection.json --verify
```

`./scripts/validate.sh` runs the same schema checks as CI over every example.

## Get involved

The [open questions](spec/collections-0.2.md#open-questions) each have an issue, with a proposed answer in the draft. Comment there, or open a new issue for anything else. See [CONTRIBUTING.md](CONTRIBUTING.md).

## Relationship to other standards

Collections builds on [ARD](https://agenticresourcediscovery.org/spec) (`/.well-known/ard.json`, previously `ai-catalog.json`). It reuses ARD's entries, identifiers, namespaced terms and registry search, and adds only what a group needs: kind, curator, time window, area, member roles, filter terms and confirmed membership. The aim is to propose it upstream as a neutral extension.

The [Gentifi Toolkit](https://github.com/SelfBankt/gentifi-toolkit) is the first implementation: it publishes back-links for businesses and checks collections.

## Licence

[Apache License 2.0](LICENSE)
