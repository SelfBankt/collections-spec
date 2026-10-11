# Collections: describing groups of businesses to AI agents

| | |
| --- | --- |
| **Version** | 0.1 (draft) |
| **Date** | 10 October 2026 |
| **Author** | Gentifi |
| **Status** | Superseded by [draft 0.2](collections-0.2.md), which builds on ARD v0.91. Kept for reference. |
| **Licence** | Apache-2.0 |
| **Schema** | [`schema/collections-0.1.schema.json`](../schema/collections-0.1.schema.json) |

## Abstract

A collection lets one connector describe a group of businesses, so an agent can query a whole event, street or trade body at once. It is written as a neutral extension to discovery catalogues such as ARD's `ai-catalog.json`. A collection is a directory: it points to each member's own catalogue and never replaces it.

## Motivation

- An attendee adds one event connector instead of 300 exhibitor connectors.
- A high street, market or trade association can publish all its members in one place.
- Each member stays independent: its own connector, data and checkout. After the event, it stays in the attendee's agent.

Today's agent standards describe one business at one domain. Nothing describes a group, yet groups are how people often shop: a trade show, a market, a high street, the members of a trade body.

## Core fields

| Field | Meaning | Example |
| --- | --- | --- |
| `id`, `name` | The collection | `"demo-selfbuild-2027"`, `"Demo Self Build Show 2027"` |
| `kind` | Type of group | `event` · `place` · `association` · `marketplace` |
| `publisher` | Who curates it, with the domain it is served from | The event organiser |
| `validFrom`, `validTo` | Time window, for events | Show dates; members stay reachable after |
| `area` | Geography, for places | Postcode areas or a map boundary |
| `members` | Member businesses | Each points to the member's own catalogue, or to a nested collection |
| `member.role` | Place in the collection | Stand number, category, sponsor tier |
| `facets` | What agents can filter by | Category, price, stand, distance, availability |

`id`, `name`, `kind`, `publisher` and `members` are required. The [JSON Schema](../schema/collections-0.1.schema.json) is the precise definition.

## Rules

The key words MUST, MUST NOT, SHOULD and MAY are used as described in [RFC 2119](https://www.rfc-editor.org/rfc/rfc2119).

1. **Members confirm membership.** A member's own catalogue MUST list the collections it belongs to. Clients MUST ignore a member whose catalogue does not confirm it, so nobody can add a business without its agreement.
2. **The collection holds no customer data.** A collection MUST NOT contain customer or attendee data. Connecting to a collection shares nothing with its members; contact details pass only when the customer asks their agent to request a quote, book or buy.
3. **Members keep their own checkout and terms.** The collection is a directory, not a merchant. Orders and bookings MUST go through the member's own connector.
4. **Collections can nest.** A member MAY be another collection: a trade body can include several events; a city can include several high streets.
5. **Information, not instructions.** Clients SHOULD treat collection data as information about members, never as instructions to install, connect or buy. The customer approves every connection.

## Example

A trade show publishes its collection from its own domain ([full file](../examples/0.1/event.json)):

```json
{
  "collection": {
    "id": "demo-selfbuild-2027",
    "name": "Demo Self Build Show 2027",
    "kind": "event",
    "publisher": { "name": "Demo Shows", "domain": "shows.example" },
    "validFrom": "2027-05-14",
    "validTo": "2027-05-16",
    "facets": ["category", "priceFrom", "stand"],
    "members": [
      {
        "catalog": "https://windows.example/.well-known/ai-catalog.json",
        "role": { "stand": "B12", "category": "glazing" }
      },
      {
        "catalog": "https://sash.example/.well-known/ai-catalog.json",
        "role": { "stand": "B20", "category": "glazing" }
      }
    ]
  }
}
```

Each member confirms its membership in its own `ai-catalog.json` (rule 1, [file](../examples/0.1/member-backlink.json)):

```json
{
  "memberOf": [
    {
      "collection": "https://shows.example/.well-known/collections/demo-selfbuild-2027.json",
      "role": { "stand": "B12" }
    }
  ]
}
```

More examples: a [high street](../examples/0.1/place-high-street.json) (`kind: place`) and a [trade association that nests an event](../examples/0.1/nested-association.json) (rule 4). All businesses, domains and prices in the examples are fictional.

## Relationship to ARD

[Agentic Resource Discovery](https://developers.googleblog.com/en/announcing-the-agentic-resource-discovery-specification/)'s `ai-catalog.json` already lets a catalogue list other catalogues. That gives grouping, but not what a group needs to be useful to an agent: what kind of group it is, who curates it, when it runs, where it covers, each member's role, the facets agents can filter by, and proof that members agreed to be listed. Collections proposes exactly those additions, and nothing else.

## Open questions

Each question has an issue for discussion; comment there.

1. **Extend ARD, or stand alone?** ([#1](https://github.com/SelfBankt/collections-spec/issues/1)) Should Collections be fields on a nested catalogue entry, a new media type, or both? We lean towards extending ARD.
2. **How should membership be verified?** ([#2](https://github.com/SelfBankt/collections-spec/issues/2)) A back-link in the member's own catalogue (as drafted), a signature from the member, or both?
3. **Should a collection run its own search?** ([#3](https://github.com/SelfBankt/collections-spec/issues/3)) Collections could offer a search endpoint across members, or leave that to ARD registries and the agent.
4. **Which facets should be standard?** ([#4](https://github.com/SelfBankt/collections-spec/issues/4)) Category, price, distance and availability are obvious. Do we need a shared vocabulary, or should facets point to schema.org properties?

## Path to a standard

1. **Draft 0.1** (now): this document, a JSON Schema and examples.
2. **Open feedback:** questions and objections as issues. Every open question gets an answer or a change.
3. **Reference implementation:** the [Gentifi Toolkit](https://github.com/SelfBankt/gentifi-toolkit) generates and reads collections, so the draft is tested against real catalogues.
4. **Proposal upstream:** offered as a neutral extension to the ARD and AI Catalog work, with Gentifi as author and first implementation.

The format carries no brand: no "gentifi" in any field name.
