# ArrayTrie

[![Tests](https://github.com/adalinxx/ArrayTrie/actions/workflows/test.yml/badge.svg)](https://github.com/adalinxx/ArrayTrie/actions/workflows/test.yml)
[![Swift 6.0](https://img.shields.io/badge/Swift-6.0-orange.svg)](https://swift.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

A trie keyed by arrays of strings instead of individual characters.

## Why?

Dictionaries are flat. When your keys have hierarchical structure — URL paths, config namespaces, file system paths, permission trees — a flat dictionary forces you to fake structure with string concatenation and prefix scanning.

ArrayTrie gives you that structure natively. Each path segment is an edge in the tree, so operations that would require scanning every key in a dictionary become direct tree operations:

- **Subtree extraction**: `traverse(["api", "v1"])` returns the entire v1 subtree as its own trie — no filtering required.
- **Prefix queries**: `childKeys()`, `childValues()`, `valuesAlongPath()` answer questions about the tree's shape directly.
- **Tree merging**: Combine two configuration trees, two route tables, or two permission sets with a single `merging(with:)` call and a conflict resolution rule.

Path operations (`get`, `set`, `deleting`, `traverse`) run in **O(k)** time where k is the path length, independent of total entries. Whole-tree operations like `allValues()` and `merging(with:)` are O(n).

## Usage

These examples are pulled from [`RealWorldUseCaseTests.swift`](Tests/ArrayTrieTests/RealWorldUseCaseTests.swift) — they compile and run as tests.

### URL Routing

```swift
var router = ArrayTrie<String>()

router.set(["api", "v1", "users"], value: "listUsers")
router.set(["api", "v1", "users", "create"], value: "createUser")
router.set(["api", "v1", "posts"], value: "listPosts")
router.set(["api", "v2", "users"], value: "listUsersV2")
router.set(["health"], value: "healthCheck")

router.get(["api", "v1", "users"])        // "listUsers"
router.get(["api", "v3", "users"])        // nil — no v3 routes

let v1Routes = router.traverse(["api", "v1"])!
v1Routes.get(["users"])                   // "listUsers"
v1Routes.childKeys()                      // {"users", "posts"} (order unspecified)
```

### Config with Environment Overrides

```swift
var defaults = ArrayTrie<String>()
defaults.set(["database", "host"], value: "localhost")
defaults.set(["database", "port"], value: "5432")
defaults.set(["cache", "ttl"], value: "300")

var production = ArrayTrie<String>()
production.set(["database", "host"], value: "db.prod.internal")
production.set(["cache", "ttl"], value: "3600")

let config = defaults.merging(with: production) { _, override in override }

config.get(["database", "host"])  // "db.prod.internal" (overridden)
config.get(["database", "port"])  // "5432" (kept from defaults)
config.get(["cache", "ttl"])      // "3600" (overridden)
```

### Autocomplete

```swift
var index = ArrayTrie<Bool>()
index.set(["swift"], value: true)
index.set(["swiftui"], value: true)
index.set(["swiftdata"], value: true)
index.set(["python"], value: true)
index.set(["swing"], value: true)

let completions = index.traverse(path: "swift")!
completions.childKeys()  // contains "", "ui", "data" (order unspecified) — suffixes after "swift"
```

## Installation

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/adalinxx/ArrayTrie.git", from: "1.0.0"),
]
```

## API

### Core

| Method | Description |
|--------|-------------|
| `set(_:value:)` | Store a value at a path |
| `get(_:)` | Retrieve the value at a path |
| `deleting(path:)` | Return a new trie with a path removed |
| `isEmpty` | True when the trie has no children and no root value |

### Traversal

| Method | Description |
|--------|-------------|
| `traverse(_:)` | Get the subtrie rooted at an array path |
| `traverse(path:)` | Get the subtrie rooted at a string path (character-level) |
| `traverseChild(_:)` | Traverse one level by character |

### Query

| Method | Description |
|--------|-------------|
| `childKeys()` | Get all immediate child keys |
| `childCharacters()` | Get all immediate child characters |
| `allValues()` | Get all values in the subtree |
| `childValues()` | Get values of immediate children |
| `valuesAlongPath(_:)` | Collect (subtrie, value) pairs encountered along a string path |
| `valuesExcludingPrefix(_:)` | Get values whose keys don't share a prefix |
| `childPrefix(for:)` | Get the full prefix string for a child character |

### Merging

| Method | Description |
|--------|-------------|
| `merging(with:mergeRule:)` | Merge two tries with a conflict resolution closure |
| `mergeAll(tries:mergeRule:)` | Merge an array of tries (static) |

## Performance

| Operation | Time Complexity |
|-----------|----------------|
| get / set / delete / traverse | O(k), k = path length |

## License

[MIT](LICENSE)
