import Testing
@testable import ArrayTrie

@Suite struct MergeTests {

    // MARK: - Merge Functionality

    @Test func testMergeEmptyTries() {
        let trie1 = ArrayTrie<String>()
        var trie2 = ArrayTrie<String>()
        trie2.set(["user"], value: "User Data")
        let merged1 = trie1.merging(with: trie2) { a, b in a }
        #expect(merged1.get(["user"]) == "User Data")
        let merged2 = trie2.merging(with: trie1) { a, b in a }
        #expect(merged2.get(["user"]) == "User Data")
        let merged3 = trie1.merging(with: ArrayTrie<String>()) { a, b in a }
        #expect(merged3.isEmpty)
    }

    @Test func testMergeDisjointPaths() {
        var trie1 = ArrayTrie<String>()
        var trie2 = ArrayTrie<String>()
        trie1.set(["users", "john"], value: "John")
        trie1.set(["users", "jane"], value: "Jane")
        trie2.set(["admin", "bob"], value: "Bob")
        trie2.set(["config", "db"], value: "Database")
        let merged = trie1.merging(with: trie2) { a, b in a }
        #expect(merged.get(["users", "john"]) == "John")
        #expect(merged.get(["users", "jane"]) == "Jane")
        #expect(merged.get(["admin", "bob"]) == "Bob")
        #expect(merged.get(["config", "db"]) == "Database")
    }

    @Test func testMergeOverlappingPaths() {
        var trie1 = ArrayTrie<String>()
        var trie2 = ArrayTrie<String>()
        trie1.set(["users", "john"], value: "John1")
        trie1.set(["users", "jane"], value: "Jane1")
        trie2.set(["users", "john"], value: "John2")
        trie2.set(["users", "bob"], value: "Bob2")
        let merged1 = trie1.merging(with: trie2) { a, b in a }
        #expect(merged1.get(["users", "john"]) == "John1")
        #expect(merged1.get(["users", "jane"]) == "Jane1")
        #expect(merged1.get(["users", "bob"]) == "Bob2")
        let merged2 = trie1.merging(with: trie2) { a, b in b }
        #expect(merged2.get(["users", "john"]) == "John2")
        let merged3 = trie1.merging(with: trie2) { a, b in "\(a)+\(b)" }
        #expect(merged3.get(["users", "john"]) == "John1+John2")
    }

    @Test func testMergePrefixRelationships() {
        var trie1 = ArrayTrie<String>()
        var trie2 = ArrayTrie<String>()
        trie1.set(["user", "profile"], value: "Profile")
        trie2.set(["user", "profile", "settings"], value: "Settings")
        let merged = trie1.merging(with: trie2) { a, b in a }
        #expect(merged.get(["user", "profile"]) == "Profile")
        #expect(merged.get(["user", "profile", "settings"]) == "Settings")
    }

    @Test func testMergeComplexScenarios() {
        var trie1 = ArrayTrie<String>()
        var trie2 = ArrayTrie<String>()
        trie1.set(["api", "v1", "users"], value: "V1Users")
        trie1.set(["api", "v1", "posts"], value: "V1Posts")
        trie1.set(["web", "login"], value: "WebLogin")
        trie2.set(["api", "v1", "users"], value: "V1UsersNew")
        trie2.set(["api", "v2", "users"], value: "V2Users")
        trie2.set(["mobile", "auth"], value: "MobileAuth")
        let merged = trie1.merging(with: trie2) { old, new in "\(old)|\(new)" }
        #expect(merged.get(["api", "v1", "users"]) == "V1Users|V1UsersNew")
        #expect(merged.get(["api", "v1", "posts"]) == "V1Posts")
        #expect(merged.get(["api", "v2", "users"]) == "V2Users")
        #expect(merged.get(["web", "login"]) == "WebLogin")
        #expect(merged.get(["mobile", "auth"]) == "MobileAuth")
        #expect(merged.get(["api", "v3", "users"]) == nil)
    }

    @Test func testMergeWithDifferentTypes() {
        var intTrie1 = ArrayTrie<Int>()
        var intTrie2 = ArrayTrie<Int>()
        intTrie1.set(["counter", "a"], value: 5)
        intTrie1.set(["counter", "b"], value: 10)
        intTrie2.set(["counter", "a"], value: 3)
        intTrie2.set(["counter", "c"], value: 7)
        let merged = intTrie1.merging(with: intTrie2) { a, b in a + b }
        #expect(merged.get(["counter", "a"]) == 8)
        #expect(merged.get(["counter", "b"]) == 10)
        #expect(merged.get(["counter", "c"]) == 7)
    }

    @Test func testMergeEdgeCases() {
        var trie1 = ArrayTrie<String>()
        var trie2 = ArrayTrie<String>()
        trie1.set([""], value: "Empty1")
        trie2.set([""], value: "Empty2")
        let merged1 = trie1.merging(with: trie2) { a, b in a }
        #expect(merged1.get([""]) == "Empty1")
        trie1.set(["x"], value: "X1")
        trie2.set(["x"], value: "X2")
        let merged2 = trie1.merging(with: trie2) { a, b in "\(a)-\(b)" }
        #expect(merged2.get(["x"]) == "X1-X2")
        let deepPath = (0..<20).map { "level\($0)" }
        trie1.set(deepPath, value: "Deep1")
        trie2.set(deepPath, value: "Deep2")
        let merged3 = trie1.merging(with: trie2) { a, b in b }
        #expect(merged3.get(deepPath) == "Deep2")
    }

    @Test func testMergePreservesCompression() {
        var trie1 = ArrayTrie<String>()
        var trie2 = ArrayTrie<String>()
        trie1.set(["very", "long", "path", "to", "resource"], value: "Resource1")
        trie2.set(["very", "long", "path", "to", "other"], value: "Other")
        let merged = trie1.merging(with: trie2) { a, b in a }
        #expect(merged.get(["very", "long", "path", "to", "resource"]) == "Resource1")
        #expect(merged.get(["very", "long", "path", "to", "other"]) == "Other")
        #expect(merged.get(["very", "long", "path"]) == nil)
        #expect(merged.get(["very", "long", "path", "to"]) == nil)
    }

    @Test func testMergeImmutability() {
        var trie1 = ArrayTrie<String>()
        var trie2 = ArrayTrie<String>()
        trie1.set(["original"], value: "Original1")
        trie2.set(["original"], value: "Original2")
        let merged = trie1.merging(with: trie2) { a, b in "Merged" }
        #expect(trie1.get(["original"]) == "Original1")
        #expect(trie2.get(["original"]) == "Original2")
        #expect(merged.get(["original"]) == "Merged")
        trie1.set(["new"], value: "New1")
        trie2.set(["new"], value: "New2")
        #expect(merged.get(["new"]) == nil)
        #expect(merged.get(["original"]) == "Merged")
    }

    @Test func testMergePerformance() {
        var trie1 = ArrayTrie<Int>()
        var trie2 = ArrayTrie<Int>()
        for i in 0..<100 {
            trie1.set(["group1", "item\(i)"], value: i)
            trie2.set(["group2", "item\(i)"], value: i + 100)
        }
        for i in 0..<20 {
            trie2.set(["group1", "item\(i)"], value: i + 1000)
        }
        let merged = trie1.merging(with: trie2) { a, b in a + b }
        #expect(merged.get(["group1", "item0"]) == 1000)
        #expect(merged.get(["group1", "item50"]) == 50)
        #expect(merged.get(["group2", "item0"]) == 100)
        var count = 0
        for i in 0..<100 {
            if merged.get(["group1", "item\(i)"]) != nil { count += 1 }
            if merged.get(["group2", "item\(i)"]) != nil { count += 1 }
        }
        #expect(count == 200)
    }

    // MARK: - MergeAll Static Method

    @Test func testMergeAllEmptyArray() {
        let result = ArrayTrie<String>.mergeAll(tries: []) { a, b in a }
        #expect(result.isEmpty)
        #expect(result.get(["any", "path"]) == nil)
    }

    @Test func testMergeAllSingleTrie() {
        var trie = ArrayTrie<String>()
        trie.set(["user", "name"], value: "John")
        trie.set(["user", "age"], value: "30")
        trie.set(["config", "debug"], value: "true")
        let result = ArrayTrie<String>.mergeAll(tries: [trie]) { a, b in a }
        #expect(result.get(["user", "name"]) == "John")
        #expect(result.get(["user", "age"]) == "30")
        #expect(result.get(["config", "debug"]) == "true")
    }

    @Test func testMergeAllTwoTries() {
        var trie1 = ArrayTrie<String>()
        var trie2 = ArrayTrie<String>()
        trie1.set(["users", "john"], value: "John1")
        trie1.set(["users", "jane"], value: "Jane1")
        trie2.set(["users", "bob"], value: "Bob2")
        trie2.set(["config", "mode"], value: "prod")
        let result = ArrayTrie<String>.mergeAll(tries: [trie1, trie2]) { a, b in a }
        #expect(result.get(["users", "john"]) == "John1")
        #expect(result.get(["users", "jane"]) == "Jane1")
        #expect(result.get(["users", "bob"]) == "Bob2")
        #expect(result.get(["config", "mode"]) == "prod")
    }

    @Test func testMergeAllMultipleDisjointTries() {
        var trie1 = ArrayTrie<String>()
        var trie2 = ArrayTrie<String>()
        var trie3 = ArrayTrie<String>()
        var trie4 = ArrayTrie<String>()
        trie1.set(["api", "v1"], value: "V1")
        trie2.set(["web", "login"], value: "Login")
        trie3.set(["mobile", "auth"], value: "Auth")
        trie4.set(["admin", "panel"], value: "Panel")
        let result = ArrayTrie<String>.mergeAll(tries: [trie1, trie2, trie3, trie4]) { a, b in a }
        #expect(result.get(["api", "v1"]) == "V1")
        #expect(result.get(["web", "login"]) == "Login")
        #expect(result.get(["mobile", "auth"]) == "Auth")
        #expect(result.get(["admin", "panel"]) == "Panel")
    }

    @Test func testMergeAllOverlappingPaths() {
        var trie1 = ArrayTrie<String>()
        var trie2 = ArrayTrie<String>()
        var trie3 = ArrayTrie<String>()
        trie1.set(["config", "database"], value: "mysql")
        trie1.set(["config", "port"], value: "3306")
        trie2.set(["config", "database"], value: "postgres")
        trie2.set(["config", "host"], value: "localhost")
        trie3.set(["config", "database"], value: "redis")
        trie3.set(["config", "timeout"], value: "30")
        let result1 = ArrayTrie<String>.mergeAll(tries: [trie1, trie2, trie3]) { a, b in a }
        #expect(result1.get(["config", "database"]) == "mysql")
        #expect(result1.get(["config", "port"]) == "3306")
        #expect(result1.get(["config", "host"]) == "localhost")
        #expect(result1.get(["config", "timeout"]) == "30")
        let result2 = ArrayTrie<String>.mergeAll(tries: [trie1, trie2, trie3]) { a, b in b }
        #expect(result2.get(["config", "database"]) == "redis")
        let result3 = ArrayTrie<String>.mergeAll(tries: [trie1, trie2, trie3]) { a, b in "\(a)|\(b)" }
        #expect(result3.get(["config", "database"]) == "mysql|postgres|redis")
    }

    @Test func testMergeAllComplexNested() {
        var trie1 = ArrayTrie<String>()
        var trie2 = ArrayTrie<String>()
        var trie3 = ArrayTrie<String>()
        trie1.set(["api", "v1", "users", "create"], value: "POST")
        trie1.set(["api", "v1", "users", "read"], value: "GET")
        trie1.set(["api", "v1", "posts"], value: "POSTS")
        trie2.set(["api", "v1", "users", "update"], value: "PUT")
        trie2.set(["api", "v2", "users"], value: "V2_USERS")
        trie2.set(["web", "dashboard"], value: "DASH")
        trie3.set(["api", "v1", "users", "delete"], value: "DELETE")
        trie3.set(["api", "v1", "users", "create"], value: "CREATE_V3")
        trie3.set(["mobile", "auth"], value: "MOBILE_AUTH")
        let result = ArrayTrie<String>.mergeAll(tries: [trie1, trie2, trie3]) { a, b in "\(a)+\(b)" }
        #expect(result.get(["api", "v1", "users", "create"]) == "POST+CREATE_V3")
        #expect(result.get(["api", "v1", "users", "read"]) == "GET")
        #expect(result.get(["api", "v1", "users", "update"]) == "PUT")
        #expect(result.get(["api", "v1", "users", "delete"]) == "DELETE")
        #expect(result.get(["api", "v1", "posts"]) == "POSTS")
        #expect(result.get(["api", "v2", "users"]) == "V2_USERS")
        #expect(result.get(["web", "dashboard"]) == "DASH")
        #expect(result.get(["mobile", "auth"]) == "MOBILE_AUTH")
    }

    @Test func testMergeAllWithIntegerValues() {
        var trie1 = ArrayTrie<Int>()
        var trie2 = ArrayTrie<Int>()
        var trie3 = ArrayTrie<Int>()
        trie1.set(["counters", "page_views"], value: 100)
        trie1.set(["counters", "users"], value: 50)
        trie2.set(["counters", "page_views"], value: 200)
        trie2.set(["counters", "orders"], value: 25)
        trie3.set(["counters", "page_views"], value: 150)
        trie3.set(["counters", "errors"], value: 5)
        let result = ArrayTrie<Int>.mergeAll(tries: [trie1, trie2, trie3]) { a, b in a + b }
        #expect(result.get(["counters", "page_views"]) == 450)
        #expect(result.get(["counters", "users"]) == 50)
        #expect(result.get(["counters", "orders"]) == 25)
        #expect(result.get(["counters", "errors"]) == 5)
    }

    @Test func testMergeAllOrderMatters() {
        var trie1 = ArrayTrie<String>()
        var trie2 = ArrayTrie<String>()
        var trie3 = ArrayTrie<String>()
        trie1.set(["value"], value: "A")
        trie2.set(["value"], value: "B")
        trie3.set(["value"], value: "C")
        let result1 = ArrayTrie<String>.mergeAll(tries: [trie1, trie2, trie3]) { a, b in a }
        let result2 = ArrayTrie<String>.mergeAll(tries: [trie3, trie2, trie1]) { a, b in a }
        #expect(result1.get(["value"]) == "A")
        #expect(result2.get(["value"]) == "C")
        let result3 = ArrayTrie<String>.mergeAll(tries: [trie1, trie2, trie3]) { a, b in "\(a)-\(b)" }
        let result4 = ArrayTrie<String>.mergeAll(tries: [trie3, trie2, trie1]) { a, b in "\(a)-\(b)" }
        #expect(result3.get(["value"]) == "A-B-C")
        #expect(result4.get(["value"]) == "C-B-A")
    }

    @Test func testMergeAllPrefixRelationships() {
        var trie1 = ArrayTrie<String>()
        var trie2 = ArrayTrie<String>()
        var trie3 = ArrayTrie<String>()
        trie1.set(["user"], value: "USER")
        trie2.set(["user", "profile"], value: "PROFILE")
        trie3.set(["user", "profile", "settings"], value: "SETTINGS")
        let result = ArrayTrie<String>.mergeAll(tries: [trie1, trie2, trie3]) { a, b in a }
        #expect(result.get(["user"]) == "USER")
        #expect(result.get(["user", "profile"]) == "PROFILE")
        #expect(result.get(["user", "profile", "settings"]) == "SETTINGS")
    }

    @Test func testMergeAllImmutability() {
        var trie1 = ArrayTrie<String>()
        var trie2 = ArrayTrie<String>()
        trie1.set(["original"], value: "Value1")
        trie2.set(["original"], value: "Value2")
        let originalTries = [trie1, trie2]
        let result = ArrayTrie<String>.mergeAll(tries: originalTries) { a, b in "Merged" }
        #expect(trie1.get(["original"]) == "Value1")
        #expect(trie2.get(["original"]) == "Value2")
        #expect(result.get(["original"]) == "Merged")
        trie1.set(["new"], value: "New1")
        trie2.set(["new"], value: "New2")
        #expect(result.get(["new"]) == nil)
        #expect(result.get(["original"]) == "Merged")
    }

    @Test func testMergeAllPerformance() {
        var tries: [ArrayTrie<Int>] = []
        for trieIndex in 0..<10 {
            var trie = ArrayTrie<Int>()
            for i in 0..<20 {
                trie.set(["trie\(trieIndex)", "item\(i)"], value: trieIndex * 100 + i)
            }
            for i in 0..<5 {
                trie.set(["shared", "item\(i)"], value: trieIndex * 10 + i)
            }
            tries.append(trie)
        }
        let result = ArrayTrie<Int>.mergeAll(tries: tries) { a, b in a + b }
        for trieIndex in 0..<10 {
            for i in 0..<20 {
                let expected = trieIndex * 100 + i
                #expect(result.get(["trie\(trieIndex)", "item\(i)"]) == expected)
            }
        }
        for i in 0..<5 {
            var expectedSum = 0
            for trieIndex in 0..<10 {
                expectedSum += trieIndex * 10 + i
            }
            #expect(result.get(["shared", "item\(i)"]) == expectedSum)
        }
    }

    @Test func testMergeAllMixedEmptyTries() {
        var trie1 = ArrayTrie<String>()
        let trie2 = ArrayTrie<String>()
        var trie3 = ArrayTrie<String>()
        let trie4 = ArrayTrie<String>()
        trie1.set(["data"], value: "Data1")
        trie3.set(["data"], value: "Data3")
        let result = ArrayTrie<String>.mergeAll(tries: [trie1, trie2, trie3, trie4]) { a, b in "\(a)|\(b)" }
        #expect(result.get(["data"]) == "Data1|Data3")
    }
}
