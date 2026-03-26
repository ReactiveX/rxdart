# I. Original Issue #804

We hit this in a real Flutter app and reduced it to the minimal repro below.

This also reproduces with `stream_transform`, so it does not appear to be
specific to our app code:

- https://github.com/dart-lang/tools/issues/2348

## 1. Minimal reproduction

```dart
import 'dart:async';
import 'dart:io';

import 'package:rxdart/rxdart.dart';

Future<void> main() async {
  final stream = Rx.combineLatest2(
    _emitOnceAndNeverClose('left'),
    Stream.value('right').switchMap(_emitOnceAndNeverClose),
    (left, right) => '$left|$right',
  );

  final value = await stream.first.timeout(const Duration(milliseconds: 200));
  stdout.writeln(value);
}

Stream<T> _emitOnceAndNeverClose<T>(T value) async* {
  yield value;
  await Completer<void>().future;
}
```

### How to run

```bash
dart run repro.dart
```

## 2. Expected vs Actual behavior

### Expected behavior

The program should complete and print:

```text
left|right
```

### Actual behavior

The stream emits a value, but `await stream.first` never completes and times
out:

```text
Unhandled exception:
TimeoutException after 0:00:00.200000: Future not completed
```

Without the timeout, it hangs indefinitely.

## 3. What I verified

- `switchMap` is required. Replacing the `switchMap(...)` branch with a direct
  `_emitOnceAndNeverClose('right')` stream makes the problem disappear.
- The non-`switchMap` branch also matters. Replacing
  `_emitOnceAndNeverClose('left')` with `Stream.value('left')` makes the
  problem disappear.
- `Stream.value('right').switchMap(_emitOnceAndNeverClose)` alone works.
- `combineLatest` without `switchMap` works.
- The combined stream does emit its first data event. The hang happens
  afterward while `Stream.first` waits for cancellation to complete.

## 4. Additional context

We originally ran into this in a Flutter app where the source streams were
long-lived Drift watchers (`watchSingleOrNull()`), wrapped in `async*`
syncers. Those streams are intentionally open-ended until canceled.

The failure happened when we composed those watcher streams with
`combineLatest` and `switchMap`, then awaited `.first` to get one initial
bootstrap value. The minimal repro above removes Drift entirely and still
reproduces, so this does not appear to be Drift-specific.

## 5. Environment

- rxdart: `0.28.0`
- Also reproduced on: `0.27.7`
- Dart SDK: `3.12.0-113.1.beta`
- Flutter: `3.42.0-0.0.pre`
- Platform: `macos_arm64`

---

# II. Root cause analysis

**This is not a bug in rxdart.** It is a design property of Dart's `async*`
runtime. The investigation below explains exactly why.

## 1. How Dart compiles `async*` generators

The Dart VM compiles every `async*` function into a state machine driven by
[`_AsyncStarStreamController<T>`][async_patch]. Three methods matter:

[async_patch]: https://github.com/dart-lang/sdk/blob/main/sdk/lib/_internal/vm/lib/async_patch.dart

### `add()` — called when the generator hits `yield`

```dart
bool add(T event) {
  controller.add(event);                     // deliver event to listener
  if (!controller.hasListener) return true;  // ← cancel check at yield: if already cancelled, tell generator to stop
  scheduleGenerator();                       // queue a microtask to resume the body
  isSuspendedAtYield = true;                 // mark: "generator is paused at a yield"
  return false;
}
```

After `yield`, the generator **suspends** and `isSuspendedAtYield = true`.
It will resume later, in a **scheduled microtask** via `runBody()`:

```dart
void runBody() {
  isSuspendedAtYield = false;      // mark: "generator is running"
  asyncStarBody!(!controller.hasListener);
}
```

### `onCancel()` — called when the subscription is cancelled

```dart
onCancel() {
  if (controller.isClosed) return null;
  if (cancellationFuture == null) {
    cancellationFuture = _Future();
    // Only resume the generator if it is suspended at a yield.
    // Cancellation does not affect an async generator that is
    // suspended at an await.
    if (isSuspendedAtYield) {
      scheduleGenerator();         // resume → generator exits → close()
    }
  }
  return cancellationFuture;       // caller waits for this future
}
```

Two cases:
- `isSuspendedAtYield == true` → generator is resumed, runs `finally`, body
  returns → `close()` is called → `cancellationFuture` completes. ✅
- `isSuspendedAtYield == false` → generator is **not** resumed.
  `cancellationFuture` is still returned. In this repro, it remains
  incomplete because the generator is stuck at an `await` that never resolves,
  so neither normal return nor an error path can complete it. ❌

### `close()` — the normal success path that completes `cancellationFuture`

```dart
close() {
  final future = cancellationFuture;
  if ((future != null) && future._mayComplete) {
    future._completeWithValue(null);   // ← normal successful completion path
  }
  controller.close();
}
```

`addError(...)` can also complete `cancellationFuture` with an error after
cancel, but that does not happen in this repro.

`close()` is called when the `async*` body **returns** (finishes). If the
body never finishes, `close()` is never called, and `cancellationFuture`
stays incomplete forever.

## 2. The core mechanism — why `cancel()` can hang

Consider this `async*` function:

```dart
Stream<T> emitOnceAndNeverClose<T>(T value) async* {
  yield value;                       // (1) add() → isSuspendedAtYield = true
  //                                    (2) microtask: runBody() → isSuspendedAtYield = false
  await Completer<void>().future;    // (3) body is now stuck at await, never returns
}
```

The timeline after a listener subscribes:

| Step                                      | What happens                                | `isSuspendedAtYield` |
|-------------------------------------------|---------------------------------------------|----------------------|
| Generator hits `yield value`              | `add()` delivers event, schedules microtask | `true`               |
| Microtask fires `runBody()`               | Generator resumes past `yield`              | `false`              |
| Generator hits `await Completer().future` | Body suspended at `await` — never returns   | `false`              |

Now if `cancel()` is called:

- `onCancel()` checks `isSuspendedAtYield` → it's `false`
- Generator is **not resumed** (by design — see SDK comment)
- What happens next depends on whether the `await`ed future is **finite or
  infinite**:

**Finite `await`** (e.g. `await Future.delayed(Duration(seconds: 1))`):
the future eventually completes → generator resumes → body returns →
`close()` is called → `cancellationFuture` completes. Cancellation is
**delayed**, not blocked. ✅

**Infinite `await`** (e.g. `await Completer<void>().future` where no one
calls `.complete()`): the future never completes → generator never resumes →
body never returns → `close()` never called → `cancellationFuture` **never
completes**. ❌ ← this is the repro case.

> The Dart SDK comment says explicitly:
> *"Only resume the generator if it is suspended at a yield.
> Cancellation does not affect an async generator that is suspended at an
> await."*

## 3. How the cancel chain propagates — from `async*` to `Stream.first`

Three layers connect A's `cancellationFuture` to `Stream.first`:

**Layer 1 — `Stream.first`** waits for its subscription's cancel future:

```dart
// Dart SDK — Stream.first
void _cancelAndValue(subscription, future, value) {
  var cancelFuture = subscription.cancel();
  // ↓ waits for cancel to finish before completing the future
  cancelFuture.whenComplete(() => future._complete(value));
}
```

**Layer 2 — `CombineLatestStream`** collects ALL source cancel futures via
`Future.wait`:

```dart
// rxdart — CombineLatestStream._buildController()
controller.onCancel = () {
  values = null;
  return subscriptions.cancelAll();  // ← returns Future.wait([...])!
};

// rxdart — subscription.dart
Future<void>? cancelAll() =>
    waitFuturesList([for (final s in this) s.cancel()]);

// rxdart — future.dart
Future<void>? waitFuturesList(List<Future<void>> futures) {
  switch (futures.length) {
    case 0: return null;
    case 1: return futures[0];
    default: return Future.wait(futures).then(_ignore);
  }
}
```

So CombineLatest's `onCancel` returns `Future.wait([A.cancel(), B.cancel()])`.
If **any one** of these never completes → `Future.wait` never completes →
CombineLatest's cancel never completes.

**Layer 3 — `async*` generator's `cancel()`** returns `cancellationFuture`
(see section 1).

**The full chain:**

```
Stream.first
  → subscription.cancel()
    → CombineLatest.onCancel()
      → Future.wait([A.cancel(), B.cancel()])
        → A.cancel() returns cancellationFuture (never completes ❌)
        → B.cancel() returns cancellationFuture (completes ✅)
      → Future.wait never completes (blocked by A)
    → cancel future never completes
  → Stream.first hangs forever
```

## 4. Why timing matters — `scheduleMicrotask` is the key

A critical detail: `scheduleGenerator()` calls `scheduleMicrotask(runBody)`.
This does **not** run `runBody()` immediately — it **queues** it to run in
the **next** microtask. All synchronous code in the **current** microtask
finishes first.

This means: everything that happens synchronously after `add()` returns —
`combineLatest` checking values, emitting, `Stream.first` receiving the
value, calling `cancel()` — all runs **before** `runBody()` gets a chance to
execute.

### Happy case: both streams emit directly (no `switchMap`) → ✅

When `combineLatest` subscribes to A and B, both `async*` generators queue
their initial body in the microtask queue via `onListen → scheduleGenerator`:

```
Subscription time (sync):
  combineLatest subscribes to A → A's onListen → scheduleMicrotask  → [MT1: A body]
  combineLatest subscribes to B → B's onListen → scheduleMicrotask  → [MT2: B body]

Microtask queue: MT1, MT2
```

Now the microtasks fire in FIFO order:

```
MT1: A's body starts → yield 'left' → add()
     ├─ controller.add('left') → combineLatest stores A's value (waits for B)
     ├─ scheduleGenerator() → appends to queue                → [MT2, MT3: A runBody]
     └─ isSuspendedAtYield = true

MT2: B's body starts → yield 'right' → add()
     ├─ controller.add('right') → combineLatest has both → emits 'left|right'
     │   └─ Stream.first receives value (synchronously)
     │       └─ cancel() → onCancel() for A
     │           ├─ cancellationFuture = _Future()
     │           ├─ isSuspendedAtYield is STILL true ✅ (MT3 hasn't fired yet)
     │           ├─ scheduleGenerator() → NO-OP (isScheduled already true from MT1's add())
     │           │   The already-queued MT3 will handle cancellation.
     │           └─ returns cancellationFuture (pending)
     ├─ scheduleGenerator() → appends to queue                → [MT3, MT4: B runBody]
     └─ isSuspendedAtYield = true

MT3: A's runBody() fires (queued during MT1's add())
     ├─ isScheduled = false
     ├─ isSuspendedAtYield = false
     └─ asyncStarBody!(!controller.hasListener)
          → !hasListener = true (subscription was cancelled)
            → body receives "cancelled" signal → runs finally → returns
              → close() called → cancellationFuture completes ✅

(MT4: B's generator already cancelled → exits cleanly)
```

The key: **MT2 (B yields) was queued at subscription time, BEFORE MT3 (A's
`runBody`)** which was queued during MT1. So B yields and triggers `cancel()`
while A is still at `isSuspendedAtYield = true`. ✅

### Bug case: stream B via `switchMap` → ❌

With `switchMap`, B is not an `async*` generator subscribed directly.
Instead, `combineLatest` subscribes to `Stream.value('right').switchMap(...)`.
`Stream.value` delivers its value in a microtask, and only **then** does
`switchMap` subscribe to the inner `async*` generator:

```
Subscription time (sync):
  combineLatest subscribes to A            → onListen → scheduleMicrotask → [MT1: A body]
  combineLatest subscribes to switchMap    → switchMap subscribes to Stream.value('right')
    → Stream.value schedules delivery                                     → [MT2: deliver 'right']

Microtask queue: MT1, MT2
```

Now the microtasks fire in FIFO order:

```
MT1: A's body starts → yield 'left' → add()
     ├─ controller.add('left') → combineLatest stores A's value (waits for B)
     ├─ scheduleGenerator() → appends to queue          → [MT2, MT3: A runBody]
     └─ isSuspendedAtYield = true

MT2: Stream.value delivers 'right' to switchMap
     └─ switchMap subscribes to inner emitOnceAndNeverClose('right')
        └─ onListen → scheduleMicrotask → appends      → [MT3, MT4: B body]

MT3: A's runBody() fires ← THIS IS THE PROBLEM
     ├─ isSuspendedAtYield = false
     └─ generator resumes past yield → enters await Completer().future (stuck forever)

MT4: B's body starts → yield 'right' → add()
     ├─ controller.add('right') → combineLatest emits 'left|right'
     │   └─ Stream.first receives value
     │       └─ cancel() → onCancel() for A
     │           └─ isSuspendedAtYield is false ❌
     │               → generator NOT resumed → cancellationFuture never completes
     ...

→ Stream.first waits for cancellationFuture → hangs forever
```

The key difference: **MT3 (A's `runBody`) was queued during MT1, BEFORE MT4
(B's body)** which was queued during MT2. So A resumes past `yield` and
enters `await` **before** B gets a chance to emit and trigger `cancel()`. ❌

### Summary: it's all about microtask queue ordering

| Scenario               | Queue order                        | `runBody()` fires before `cancel()`? | Result |
|------------------------|------------------------------------|--------------------------------------|--------|
| Both `async*` directly | B-body queued **before** A-runBody | No                                   | ✅      |
| B via `switchMap`      | A-runBody queued **before** B-body | Yes                                  | ❌      |
| B via `delay(1ms)`     | A-runBody queued **before** B-body | Yes                                  | ❌      |

**TL;DR:** In the failing timing, A reaches a never-ending `await` before B
emits its first value; after that, cancel cannot drive A to completion, so
A's `cancellationFuture` never completes.

## 5. Verdict

**This is not a bug in `CombineLatestStream`, rxdart, or `Stream.first`.**

The root cause is a **design property of Dart's `async*` runtime**: once the
generator advances past a `yield` into an `await` that never completes, it
can no longer be cancelled — its `cancellationFuture` will never complete
because the body never returns and no error path completes the cancellation.

This affects **any** code that awaits `StreamSubscription.cancel()` on such a
stream — `Stream.first`, `Stream.single`, `await for` + `break`, etc. —
regardless of whether rxdart is involved.

## 6. Practical guidance

- Avoid `await`ing a never-completing `Future` inside an `async*` generator
  after `yield` when downstream code depends on `StreamSubscription.cancel()`
  settling (`Stream.first`, `Stream.single`, `await for` + `break`). Ensure
  the generator can eventually `return` or throw, so cancellation can complete.
- For intentionally long-lived/open-ended sources, prefer a
  `StreamController`-based implementation with explicit `onCancel` cleanup
  instead of parking an `async*` generator on an infinite `await`. This makes
  cancellation semantics explicit and lets the caller's cancel future settle
  predictably.

**Source**: [`_AsyncStarStreamController`][async_patch] in the Dart SDK (VM
runtime).

---

## License attribution for Dart SDK code excerpts

This document quotes source code from the Dart SDK for educational/diagnostic
purposes. The Dart SDK is licensed under a BSD-style license. The original
copyright notice is reproduced below.

> Copyright 2012, the Dart project authors.
>
> Redistribution and use in source and binary forms, with or without
> modification, are permitted provided that the following conditions are met:
>
> 1. Redistributions of source code must retain the above copyright notice,
>    this list of conditions and the following disclaimer.
> 2. Redistributions in binary form must reproduce the above copyright notice,
>    this list of conditions and the following disclaimer in the documentation
>    and/or other materials provided with the distribution.
> 3. Neither the name of the copyright holder nor the names of its
>    contributors may be used to endorse or promote products derived from this
>    software without specific prior written permission.
>
> THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
> AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
> IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
> ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
> LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
> CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
> SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
> INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
> CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
> ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
> POSSIBILITY OF SUCH DAMAGE.

**Pinned revision**: the excerpts in this document were taken from
[`sdk/lib/_internal/vm/lib/async_patch.dart`][async_patch_pinned] at Dart SDK
commit [`3.7.0`][dart_tag] (December 2024). If the Dart SDK has since changed,
refer to that revision to reconcile any differences.

[async_patch_pinned]: https://github.com/dart-lang/sdk/blob/3.7.0/sdk/lib/_internal/vm/lib/async_patch.dart
[dart_tag]: https://github.com/dart-lang/sdk/releases/tag/3.7.0

