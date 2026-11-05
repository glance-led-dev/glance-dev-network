# HSS paid-request safeguards: maintainer deployment review

This is a **host-side proposal**, not a claim that the public app or production
servers have been updated. It makes no changes to app manifests, settings,
artwork or layouts, and is independent of the visual fixes in PR #980.

## Problem and evidence

The owner's Parse activity log shows several successful Scoretracker requests
in the same minute despite a ten-minute live selection. The log does not expose
contest parameters or Glance request IDs, so it does not establish that every
entry was an identical request, nor prove production uses this SDK unchanged.

Two relevant paths exist in the public host code:

1. The HTTP disk cache has no atomic reservation around a cache miss. Concurrent
   render subprocesses can fetch the same paid endpoint.
2. One logical HTTP call can rotate through up to three proxies after transport
   timeouts. A timeout does not prove Parse did not execute and bill a request.

The HSS app also advances its live cache label even after an earlier response
said Final, if the cached weekly schedule still says upcoming. The proposed
guard retains a usable Final independently of those advancing labels.

## Scope and behavior

- Exact HTTPS Parse host, existing MaxPreps API ID, snapshot 18 and HSS request
  labels only. Unrelated HTTP traffic retains its existing handling.
- Reserve the paid attempt in a transaction **before** outbound network I/O.
  An uncertain attempt consumes its live interval; no proxy retry is made.
- Existing successful responses can seed the guard during migration.
- Same API key, endpoint and game share state; different keys remain isolated.
  MaxPreps contest UUIDs normalize alternate slugs and tab/query variations.
- Overlapping installations with different selected intervals cannot force new
  calls just by alternating refresh labels. A shorter interval may fetch sooner
  than a longer one, while the latter receives the shared latest result.
- Retain a named-team, nonempty Final across future refresh labels. Permit only
  two final correction attempts, due 30 and 60 minutes after first observation.
  Failed corrections retain the previous good result. A usable correction that
  explicitly reverts to live resumes checks; an empty placeholder does not.
- Recovery labels in the separately prepared app proposal are recognized; this
  PR does **not** itself impose a four-hour kickoff cutoff or change game
  selection. The existing app's live window remains in force until that app
  proposal is reviewed separately.
- On unavailable/corrupt reservation storage, return a previous good response
  when available, otherwise a normal HTTP failure result. Never bypass the
  guard and issue an unreserved paid request.
- No credentials, request headers or raw request identity are written to the
  guard's identity column: it stores a SHA-256 identity hash and response state.
  Provider response bodies remain cached, as with the existing HTTP cache.

## Required production decisions — please confirm before rollout

1. **Actual request path:** confirm production renders use this host module, or
   port the same policy to the service that actually dispatches paid requests.
2. **Shared, durable coordination:** this SQLite reference coordinates threads
   and subprocesses that use one local database at
   `CACHE_DIR / paid-hss-v1.sqlite3`. It is **not** a cluster-wide guarantee when
   each server/container has a separate filesystem. If production is distributed,
   implement this transaction/reservation policy in Glance's shared database or
   route each identity to one durable coordinator. Do not assume copying SQLite
   files or putting them on an arbitrary network filesystem provides that safety.
3. **Persistence:** preserve the store across render subprocesses and server
   restarts/deployments, with owner-only filesystem permissions. Losing it can
   permit new billable attempts. Rows older than a year are pruned after writes.
4. **Timeout budget:** the protected request makes one attempt with a 12-second
   timeout. The render sandbox defaults to 30 seconds; several cold metadata
   misses can still exceed that total. Confirm the production budget and use
   host-managed/background fetches if necessary. Do not extend this timeout for
   unrelated apps or blindly retry an uncertain paid attempt.
5. **Observability:** record hashed identity, cache/reservation outcome and
   attempt count—not API keys or credential-bearing headers. Correlate those
   events with Parse's activity log to establish the actual production cause.

## Verification and rollout

Run `python3 -m unittest discover -s tests -p 'test_hss_paid_cache.py' -v`.
The suite uses synthetic credentials and mocked provider responses, including
12 simultaneous threads and eight independent processes sharing the store.
It covers user isolation, alternate game URLs, mixed live settings, final
corrections, timeouts, failures, corruption, migration and unrelated traffic.
No paid Parse calls are needed.

Before enabling for users, run the same concurrency and restart tests against
the **actual production shared store across two render hosts**, then canary one
game. At a ten-minute selection, confirm one paid attempt per eligible interval
per key/game, no routine calls after a validated Final, only the two bounded
correction attempts, and no repeated attempt after an uncertain timeout.

Keep the live app's existing ID and saved inputs. Roll back the host policy if
needed, but recognize that reverting it restores the original billing risks.
Do not describe this issue as fixed live until the production canary succeeds.
