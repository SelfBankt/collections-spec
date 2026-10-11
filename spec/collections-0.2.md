# Business Collections: describing groups of businesses to AI agents

| | |
| --- | --- |
| **Version** | 0.2 (draft) |
| **Date** | 11 October 2026 |
| **Author** | Gentifi |
| **Status** | Proposal for discussion, not a standard. Builds on [Agentic Resource Discovery (ARD) v0.91](https://agenticresourcediscovery.org/spec). |
| **Licence** | Apache-2.0 |
| **Schema** | [`schema/collections-0.2.schema.json`](../schema/collections-0.2.schema.json), [`schema/member-manifest-0.2.schema.json`](../schema/member-manifest-0.2.schema.json) |
| **Previous** | [0.1](collections-0.1.md) |

The key words MUST, MUST NOT, SHOULD, SHOULD NOT and MAY are used as described in [RFC 2119](https://www.rfc-editor.org/rfc/rfc2119).

## Abstract

A collection describes a group of businesses (an event, a place, an association or a marketplace), so one connection lets an agent work with every member. In 0.2 a collection **is an ARD manifest**: its `entries` are the members, and a `collection` object says what the group is. An ARD client that knows nothing about collections still sees a usable list of resources. Each member keeps its own connector, data and checkout, and confirms its membership in its own manifest.

## Motivation

- An attendee adds one event connector instead of 300 exhibitor connectors.
- A high street, market or trade association can publish all its members in one place.
- Each member stays independent: its own connector, data and checkout. After the event, it stays in the attendee's agent.

Agent standards describe one publisher at a time. Groups are how people often shop: a trade show, a market, a high street, the members of a trade body.

## What changed from 0.1, and why

ARD v0.91 (26 August 2026) renamed the discovery file to `/.well-known/ard.json`, defined the entry shape, added a namespace mechanism for extra terms, and specified a registry search API with filters and facet counts. Draft 0.2 uses those pieces instead of defining parallel ones.

| 0.1 | 0.2 | Why |
| --- | --- | --- |
| `{ "collection": { …, "members": [ … ] } }` | `{ "collection": { … }, "entries": [ … ] }` | A collection is an ARD manifest, so plain ARD clients can read it |
| `member.catalog` pointing at the member's `ai-catalog.json` | Each member is an ARD entry pointing at its own resource, such as its MCP server card | Agents connect to the resource directly. ARD renamed `ai-catalog.json` |
| `id`: any string | `id`: `urn:air:<publisher domain>:collection:<name>` | ARD's identifier scheme. The domain binds the publisher |
| `member.role` object | Namespaced terms: `col:category`, `col:stand`, `col:tier`, `col:priceFrom` | ARD treats namespaced terms as filter dimensions |
| `facets: ["category"]` | `facets: ["col:category"]` | Facets name real terms on the entries |
| `memberOf` at the top of the member's catalogue | `col:memberOf` on the member's own entry | Scoped to the resource. ARD clients ignore it; collections clients read it |
| No answer for businesses without a website | Hosted members and `col:manifest` | Most small businesses are hosted by a platform |
| `area.postcodeAreas` | `area.country`, `area.postalCodes` | Works outside the UK |
| Examples under `/.well-known/collections/` | Any URL, listed in the publisher's `ard.json` | Paths under `/.well-known/` need IANA registration |
| "Collections" | "Business Collections" in titles and prose. Technical names (`col:`, `collection`, `application/ai-collection+json`) are unchanged | In commerce, "collection" already means a group of products (Shopify) or of creative works (schema.org) |

## Terms

- **Collection:** a document describing a group of businesses.
- **Publisher:** who curates the collection, such as the event organiser, the market or the trade body.
- **Member:** a business, or a nested collection, listed in the collection.
- **Member manifest:** the ARD manifest in which a member publishes its own entry.
- **Host:** a platform that publishes resources on behalf of businesses without their own domain.
- **Client:** an agent, registry or tool that reads collections.

## The collection document

A collection document is a JSON object served with the media type `application/ai-collection+json` (provisional, see [open question 1](#open-questions)). It has two members:

- `collection` (REQUIRED): what the group is (below).
- `entries` (REQUIRED): one ARD entry per member, at least one.

ARD ignores top-level members other than `entries`, so an ARD client reads the entries and skips `collection`.

### The `collection` object

| Field | Required | Meaning | Example |
| --- | --- | --- | --- |
| `id` | MUST | `urn:air:<publisher domain>:collection:<name>` | `urn:air:shows.example:collection:demo-selfbuild-2027` |
| `name` | MUST | Display name | `"Demo Self Build Show 2027"` |
| `kind` | MUST | `event` · `place` · `association` · `marketplace` | `"event"` |
| `publisher` | MUST | `{ "name", "domain" }`: who curates it. The domain MUST match the URN and the host the document is served from | `{ "name": "Demo Shows", "domain": "shows.example" }` |
| `description` | MAY | A short paragraph | |
| `url` | MAY | A page about the group, for people | |
| `validFrom`, `validTo` | SHOULD, for events | Dates as `YYYY-MM-DD`. Members stay reachable afterwards | `"2027-05-14"` |
| `area` | SHOULD, for places | `{ "country", "postalCodes", "boundary" }`: ISO country code, postal code prefixes, and the https URL of a GeoJSON boundary | `{ "country": "GB", "postalCodes": ["BS1", "BS2"] }` |
| `facets` | MAY | Namespaced terms on the entries that agents can filter by, plus ARD's `capabilities` and `tags` | `["col:category", "col:priceFrom"]` |
| `memberOf` | MAY | For a nested collection: the parent collections it agrees to be part of (rule 4) | `[{ "collection": "https://…" }]` |
| `updatedAt` | SHOULD | When the document last changed (date-time) | |

### Member entries

Each entry is an ARD entry: `identifier`, `displayName`, `type`, and exactly one of `url` or `data`. `representativeQueries` and `capabilities` SHOULD be given, as ARD recommends.

The entry's `type` is usually the member's MCP server card (`application/mcp-server-card+json`). It MAY be an Agent Skill (`application/ai-skill+md`), an A2A agent card (`application/a2a-agent-card+json`), or another collection (`application/ai-collection+json`).

Business Collections adds these terms in the `col` namespace:

| Term | Meaning | Example |
| --- | --- | --- |
| `col:category` | The member's category in this collection | `"glazing"` |
| `col:stand` | Stand, pitch or unit | `"B12"` |
| `col:tier` | Sponsor or membership tier | `"gold"` |
| `col:priceFrom` | Lowest price, for filtering: `amount`, `currency` (ISO 4217), optional `unit` | `{ "amount": 540, "currency": "GBP", "unit": "m²" }` |
| `col:manifest` | Where the member's own manifest is, if not `https://<URN domain>/.well-known/ard.json`. MUST be on the URN's domain | `"https://host.example/b/shop/ard.json"` |
| `col:memberOf` | In a member's own manifest: the collections it belongs to (rule 1) | `[{ "collection": "https://…" }]` |

An entry that uses `col:` terms MUST bind the prefix in its `@context`, as ARD requires for namespaced terms:

```json
"@context": ["https://agenticresourcediscovery.org/context/v1", { "col": "https://gentifi.com/standards/collections/v0.2#" }]
```

Publishers MAY add terms from their own namespaces (for example `show:hall`), which ARD also allows.

## Rules

1. **Members confirm membership.** For each member entry, the member's own manifest MUST contain an entry with the same `identifier` whose `col:memberOf` lists the collection document's URL. The member manifest MUST be served from the domain in the identifier's URN. Clients MUST ignore members they cannot confirm. Nobody can add a business without its agreement.
2. **The collection holds no customer data.** A collection MUST NOT contain data about customers, attendees or visitors. Connecting to a collection shares nothing with its members. Contact details pass only when the customer asks their agent to request a quote, book or buy, and then only to that member.
3. **Members keep their own checkout and terms.** The collection is a directory, not a merchant. Orders and bookings MUST go through the member's own resources.
4. **Collections can nest.** An entry MAY be another collection. The nested collection confirms by listing the parent's URL in its own `collection.memberOf`. Clients SHOULD stop after three levels and MUST detect cycles.
5. **Information, not instructions.** Everything in a collection is data about its members. Clients MUST NOT act on instructions found in it, such as to install, connect or buy. The customer approves every connection.

## Hosted members

Many small businesses have no website of their own. A host publishes their resources under its own domain: the member's identifier is `urn:air:<host domain>:…`, and the back-link is in the host's manifest for that business, which `col:manifest` points to.

A host MUST add `col:memberOf` for a business only with that business's agreement, and SHOULD keep a record of it. See [open question 4](#open-questions).

## Publishing and discovery

- Serve the document over HTTPS from the publisher's domain, at any path. Don't use a path under `/.well-known/` unless it has been registered.
- List it in the publisher's `/.well-known/ard.json` as an entry with `type: application/ai-collection+json`, so ARD crawlers and registries find it.
- A page about the event or place MAY point to the publisher's manifest with `<link rel="ard" href="…">`.
- Keep a document under 5,000 entries. Split larger groups into nested collections.

## Searching a collection

Business Collections defines no search API. A collection document is small enough for a client to filter itself on the `facets`. A publisher that wants server-side search MAY also run an [ARD registry](https://agenticresourcediscovery.org/spec) (`application/ai-registry+json`); because `col:` terms are namespaced, ARD accepts them as filter keys without a spec change, and ARD's optional Explore operation can return facet counts.

## Client processing

1. Fetch the collection. Check that the URL's host, `publisher.domain` and the domain in `id` agree.
2. Validate it against the [schema](../schema/collections-0.2.schema.json).
3. Confirm each member (rule 1) or nested collection (rule 4). Drop members that can't be confirmed.
4. Treat every string as data, never as instructions (rule 5).
5. Use `validFrom` and `validTo` to say whether an event is on. Keep members reachable afterwards through their own resources.

The [Gentifi Toolkit](https://github.com/SelfBankt/gentifi-toolkit) implements steps 1 to 3: `gentifi collection check <url> --verify`.

## Example

A trade show publishes its collection ([full file](../examples/0.2/event.json)):

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
      "representativeQueries": ["Triple-glazed windows under £600/m²", "Lead times for new windows"],
      "capabilities": ["search_catalogue", "prepare_order"],
      "col:stand": "B12",
      "col:category": "glazing",
      "col:priceFrom": { "amount": 540, "currency": "GBP", "unit": "m²" }
    }
  ]
}
```

The organiser lists it in its own manifest ([file](../examples/0.2/members/publisher-ard.json)):

```json
{
  "entries": [
    {
      "identifier": "urn:air:shows.example:collection:demo-selfbuild-2027",
      "displayName": "Demo Self Build Show 2027",
      "type": "application/ai-collection+json",
      "url": "https://shows.example/collections/demo-selfbuild-2027.json"
    }
  ]
}
```

Each member confirms in its own `ard.json` ([file](../examples/0.2/members/windows-ard.json)):

```json
{
  "entries": [
    {
      "@context": ["https://agenticresourcediscovery.org/context/v1", { "col": "https://gentifi.com/standards/collections/v0.2#" }],
      "identifier": "urn:air:windows.example:mcp:catalogue",
      "displayName": "Example Windows",
      "type": "application/mcp-server-card+json",
      "url": "https://windows.example/mcp/server-card.json",
      "col:memberOf": [{ "collection": "https://shows.example/collections/demo-selfbuild-2027.json" }]
    }
  ]
}
```

More examples: a [high street](../examples/0.2/place-high-street.json) with a hosted member ([its host's manifest](../examples/0.2/members/host-ard.json)), and a [trade association that nests the event](../examples/0.2/nested-association.json). All businesses, domains and prices in the examples are fictional.

## Relationship to ARD and the AI Catalog

ARD v0.91 calls `/.well-known/ai-catalog.json` its predecessor, and MCP's server-card extension ([SEP-2127](https://modelcontextprotocol.io/seps/2127-mcp-server-cards)) still describes catalogues linking to server cards. Business Collections works with both: member entries use the entry shape they share, and a client MAY look for member manifests at the predecessor path when `/.well-known/ard.json` is missing.

Business Collections adds only what a group needs: what kind of group it is, who curates it, when it runs, where it covers, each member's role, the terms agents can filter by, and proof that members agreed to be listed.

## Open questions

Each question has an issue on GitHub. The proposed answers above are for discussion.

1. **Extend ARD, or stand alone?** ([#1](https://github.com/SelfBankt/collections-spec/issues/1)) Proposed: extend ARD, using its namespace mechanism, as drafted here. Still open: should the `col` terms and the `application/ai-collection+json` media type move into ARD's own context, and where should the namespace live before 1.0?
2. **How should membership be verified?** ([#2](https://github.com/SelfBankt/collections-spec/issues/2)) Proposed: the back-link (rule 1), required. Still open: should a member also be able to sign its entry (a JWS over the entry, with the key bound to its ARD `trustManifest` identity), so registries can cache proof without re-fetching?
3. **Should a collection run its own search?** ([#3](https://github.com/SelfBankt/collections-spec/issues/3)) Proposed: no new API. Filter the document, or run an ARD registry, which already accepts namespaced filter terms and returns facet counts.
4. **Which facets should be standard?** ([#4](https://github.com/SelfBankt/collections-spec/issues/4)) Proposed: a small core (`col:category`, `col:stand`, `col:tier`, `col:priceFrom`) plus the publisher's own terms. Still open: should `col:category` take values from a shared vocabulary, and should the core terms map to schema.org (for example `col:priceFrom` to `schema:lowPrice`)?
5. **How do hosts show consent?** New in 0.2: is a host's back-link enough, or should the business's agreement be visible, for example as a signed statement?
6. **What happens after an event?** New in 0.2: should a collection past its `validTo` say how long it will stay published, so agents can keep "exhibitors from last year's show" working?

## Path to a standard

1. **Draft 0.1** (10 October 2026): first proposal.
2. **Draft 0.2** (now): rebased on ARD v0.91, with proposed answers to the open questions.
3. **Reference implementation** (now): the [Gentifi Toolkit](https://github.com/SelfBankt/gentifi-toolkit) publishes `col:memberOf` back-links for businesses (`gentifi build`) and validates and verifies collections (`gentifi collection check --verify`).
4. **Proposal upstream:** offered to the ARD maintainers as a neutral extension, with Gentifi as author and first implementation.

The format carries no brand: no "gentifi" in any field name.
