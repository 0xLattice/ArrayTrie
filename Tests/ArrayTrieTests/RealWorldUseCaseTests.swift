import Testing
@testable import ArrayTrie

@Suite("Real-World Use Cases")
struct RealWorldUseCaseTests {

    // MARK: - URL Routing

    @Test func urlRouting() {
        var router = ArrayTrie<String>()

        router.set(["api", "v1", "users"], value: "listUsers")
        router.set(["api", "v1", "users", "create"], value: "createUser")
        router.set(["api", "v1", "posts"], value: "listPosts")
        router.set(["api", "v2", "users"], value: "listUsersV2")
        router.set(["health"], value: "healthCheck")

        #expect(router.get(["api", "v1", "users"]) == "listUsers")
        #expect(router.get(["api", "v1", "users", "create"]) == "createUser")
        #expect(router.get(["health"]) == "healthCheck")
        #expect(router.get(["api", "v3", "users"]) == nil)

        let v1Routes = router.traverse(["api", "v1"])!
        #expect(v1Routes.get(["users"]) == "listUsers")
        #expect(v1Routes.get(["posts"]) == "listPosts")
        #expect(v1Routes.get(["users", "create"]) == "createUser")

        let allV1Keys = v1Routes.childKeys()
        #expect(Set(allV1Keys) == Set(["users", "posts"]))
    }

    @Test func routeVersionMerging() {
        var v1 = ArrayTrie<String>()
        v1.set(["users", "list"], value: "v1:listUsers")
        v1.set(["users", "get"], value: "v1:getUser")

        var v2 = ArrayTrie<String>()
        v2.set(["users", "list"], value: "v2:listUsers")
        v2.set(["users", "search"], value: "v2:searchUsers")

        let merged = v1.merging(with: v2) { _, newer in newer }

        #expect(merged.get(["users", "list"]) == "v2:listUsers")
        #expect(merged.get(["users", "get"]) == "v1:getUser")
        #expect(merged.get(["users", "search"]) == "v2:searchUsers")
    }

    // MARK: - Configuration Management

    @Test func hierarchicalConfigWithOverrides() {
        var defaults = ArrayTrie<String>()
        defaults.set(["database", "host"], value: "localhost")
        defaults.set(["database", "port"], value: "5432")
        defaults.set(["cache", "ttl"], value: "300")

        var production = ArrayTrie<String>()
        production.set(["database", "host"], value: "db.prod.internal")
        production.set(["cache", "ttl"], value: "3600")

        let config = defaults.merging(with: production) { _, override in override }

        #expect(config.get(["database", "host"]) == "db.prod.internal")
        #expect(config.get(["database", "port"]) == "5432")
        #expect(config.get(["cache", "ttl"]) == "3600")
    }

    @Test func configSectionExtraction() {
        var config = ArrayTrie<String>()
        config.set(["database", "host"], value: "localhost")
        config.set(["database", "port"], value: "5432")
        config.set(["database", "name"], value: "myapp")
        config.set(["cache", "ttl"], value: "300")
        config.set(["server", "port"], value: "8080")

        let dbConfig = config.traverse(["database"])!
        let dbKeys = dbConfig.childKeys()
        let dbValues = dbConfig.childValues()

        #expect(Set(dbKeys) == Set(["host", "port", "name"]))
        #expect(dbValues.count == 3)
        #expect(dbValues.contains("localhost"))
    }

    // MARK: - File System Paths

    @Test func fileSystemBrowsing() {
        var fs = ArrayTrie<String>()
        fs.set(["home", "user", "documents", "resume.pdf"], value: "application/pdf")
        fs.set(["home", "user", "documents", "notes.txt"], value: "text/plain")
        fs.set(["home", "user", "photos", "vacation.jpg"], value: "image/jpeg")
        fs.set(["etc", "nginx", "nginx.conf"], value: "text/plain")

        let docs = fs.traverse(["home", "user", "documents"])!
        let docFiles = docs.childKeys()
        #expect(Set(docFiles) == Set(["resume.pdf", "notes.txt"]))

        let homeDir = fs.traverse(["home", "user"])!
        let topDirs = homeDir.childKeys()
        #expect(Set(topDirs) == Set(["documents", "photos"]))
    }

    @Test func fileSystemDeletion() {
        var fs = ArrayTrie<Int>()
        fs.set(["src", "main.swift"], value: 1024)
        fs.set(["src", "utils.swift"], value: 512)
        fs.set(["README.md"], value: 256)

        let fs2 = fs.deleting(path: ["src", "utils.swift"])

        #expect(fs.get(["src", "utils.swift"]) == 512)
        #expect(fs2.get(["src", "utils.swift"]) == nil)
        #expect(fs2.get(["src", "main.swift"]) == 1024)
        #expect(fs2.get(["README.md"]) == 256)
    }

    // MARK: - Permission Hierarchies

    @Test func permissionInheritance() {
        var permissions = ArrayTrie<[String]>()
        permissions.set(["a"], value: ["read"])
        permissions.set(["admin"], value: ["read", "write"])
        permissions.set(["admin-users"], value: ["read", "write", "manage-users"])

        let along = permissions.valuesAlongPath("admin-users")
        let allPerms = along.flatMap { $0.1 }

        #expect(allPerms.contains("read"))
        #expect(allPerms.contains("write"))
        #expect(allPerms.contains("manage-users"))
    }

    @Test func mergingPermissionSets() {
        var roleA = ArrayTrie<Int>()
        roleA.set(["files", "read"], value: 1)
        roleA.set(["files", "write"], value: 0)

        var roleB = ArrayTrie<Int>()
        roleB.set(["files", "read"], value: 1)
        roleB.set(["files", "write"], value: 1)
        roleB.set(["admin", "access"], value: 1)

        let effective = ArrayTrie<Int>.mergeAll(tries: [roleA, roleB]) { a, b in max(a, b) }

        #expect(effective.get(["files", "read"]) == 1)
        #expect(effective.get(["files", "write"]) == 1)
        #expect(effective.get(["admin", "access"]) == 1)
    }

    // MARK: - Autocomplete / Search Index

    @Test func autocompleteWithStringTraversal() {
        var index = ArrayTrie<Bool>()
        index.set(["swift"], value: true)
        index.set(["swiftui"], value: true)
        index.set(["swiftdata"], value: true)
        index.set(["swing"], value: true)
        index.set(["python"], value: true)

        let completions = index.traverse(path: "swift")!
        let suffixes = completions.childKeys()

        #expect(suffixes.contains(""))
        #expect(suffixes.contains("ui"))
        #expect(suffixes.contains("data"))
        #expect(!suffixes.contains("python"))
    }

    // MARK: - Feature Flags

    @Test func featureFlagsByNamespace() {
        var flags = ArrayTrie<Bool>()
        flags.set(["payments", "stripe-v2"], value: true)
        flags.set(["payments", "apple-pay"], value: false)
        flags.set(["ui", "dark-mode"], value: true)
        flags.set(["ui", "new-nav"], value: false)
        flags.set(["deprecated", "old-checkout"], value: false)

        let paymentFlags = flags.traverse(["payments"])!
        let paymentKeys = paymentFlags.childKeys()
        #expect(Set(paymentKeys) == Set(["stripe-v2", "apple-pay"]))

        let nonDeprecated = flags.valuesExcludingPrefix("deprecated")
        #expect(nonDeprecated.count == 4)
    }
}
