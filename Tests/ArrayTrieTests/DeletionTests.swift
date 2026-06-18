import Testing
@testable import ArrayTrie

@Suite struct DeletionTests {

    @Test func testDeletion() {
        var trie = ArrayTrie<String>()
        trie.set(["users", "john"], value: "John Doe")
        trie.set(["users", "jane"], value: "Jane Smith")
        let newTrie = trie.deleting(path: ["users", "john"])
        #expect(trie.get(["users", "john"]) == "John Doe")
        #expect(trie.get(["users", "jane"]) == "Jane Smith")
        #expect(newTrie.get(["users", "john"]) == nil)
        #expect(newTrie.get(["users", "jane"]) == "Jane Smith")
    }

    @Test func testDeletionNonExistent() {
        var trie = ArrayTrie<String>()
        trie.set(["users", "john"], value: "John Doe")
        let newTrie = trie.deleting(path: ["users", "jane"])
        #expect(newTrie.get(["users", "john"]) == "John Doe")
    }

    @Test func testDeletionEmptyPath() {
        var trie = ArrayTrie<String>()
        trie.set(["users", "john"], value: "John Doe")
        let newTrie = trie.deleting(path: [])
        #expect(newTrie.get(["users", "john"]) == "John Doe")
    }
}
