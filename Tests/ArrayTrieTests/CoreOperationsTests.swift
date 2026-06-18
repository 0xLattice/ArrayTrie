import Testing
import TrieDictionary
@testable import ArrayTrie

@Suite struct CoreOperationsTests {

    @Test func testEmptyTrie() {
        let trie = ArrayTrie<String>()
        #expect(trie.isEmpty)
        #expect(trie.get(["nonexistent"]) == nil)
    }

    @Test func testSetAndGet() {
        var trie = ArrayTrie<String>()
        trie.set(["users", "john"], value: "John Doe")
        #expect(trie.get(["users", "john"]) == "John Doe")
        #expect(trie.get(["users", "jane"]) == nil)
        #expect(trie.get(["users"]) == nil)
        #expect(trie.get(["admins", "john"]) == nil)
    }

    @Test func testSetOverwrite() {
        var trie = ArrayTrie<String>()
        trie.set(["users", "john"], value: "John Doe")
        #expect(trie.get(["users", "john"]) == "John Doe")
        trie.set(["users", "john"], value: "Johnny")
        #expect(trie.get(["users", "john"]) == "Johnny")
    }

    @Test func testMultiplePaths() {
        var trie = ArrayTrie<String>()
        trie.set(["users", "john"], value: "John Doe")
        trie.set(["users", "jane"], value: "Jane Smith")
        trie.set(["admins", "bob"], value: "Bob Admin")
        #expect(trie.get(["users", "john"]) == "John Doe")
        #expect(trie.get(["users", "jane"]) == "Jane Smith")
        #expect(trie.get(["admins", "bob"]) == "Bob Admin")
    }

    @Test func testEmptyPath() {
        var trie = ArrayTrie<String>()
        trie.set([], value: "Root")
        #expect(trie.get([]) == "Root")
    }

    @Test func testEmptyStringInPath() {
        var trie = ArrayTrie<String>()
        trie.set([""], value: "Root")
        #expect(trie.get([""]) == "Root")
        trie.set(["hello", ""], value: "Root")
        #expect(trie.get(["hello", ""]) == "Root")
        #expect(trie.traverse(["hello"])?.get([""]) == "Root")
    }

    @Test func testRootValueBasicOperations() {
        var trie = ArrayTrie<String>()
        #expect(trie.get([]) == nil)
        #expect(trie.isEmpty)
        trie.set([], value: "Root Value")
        #expect(trie.get([]) == "Root Value")
        #expect(!trie.isEmpty)
        trie.set([], value: "New Root Value")
        #expect(trie.get([]) == "New Root Value")
        trie.set(["users"], value: "Users")
        #expect(trie.get([]) == "New Root Value")
        #expect(trie.get(["users"]) == "Users")
        let newTrie = trie.deleting(path: [])
        #expect(newTrie.get([]) == nil)
        #expect(newTrie.get(["users"]) == "Users")
    }

    @Test func testRootValueWithMerging() {
        var trie1 = ArrayTrie<String>()
        var trie2 = ArrayTrie<String>()
        trie1.set([], value: "Root1")
        trie2.set([], value: "Root2")
        trie1.set(["path1"], value: "Value1")
        trie2.set(["path2"], value: "Value2")
        let merged1 = trie1.merging(with: trie2) { a, b in a }
        #expect(merged1.get([]) == "Root1")
        #expect(merged1.get(["path1"]) == "Value1")
        #expect(merged1.get(["path2"]) == "Value2")
        let merged2 = trie1.merging(with: trie2) { a, b in "\(a)+\(b)" }
        #expect(merged2.get([]) == "Root1+Root2")
    }

    @Test func testRootValueMergeWithEmpty() {
        var trie1 = ArrayTrie<String>()
        let trie2 = ArrayTrie<String>()
        trie1.set([], value: "OnlyRoot")
        trie1.set(["path"], value: "RegularValue")
        let merged = trie1.merging(with: trie2) { a, b in a }
        #expect(merged.get([]) == "OnlyRoot")
        #expect(merged.get(["path"]) == "RegularValue")
    }

    @Test func testPrefixSplitting() {
        var trie = ArrayTrie<String>()
        trie.set(["users", "john", "profile"], value: "John's Profile")
        trie.set(["users", "john", "settings"], value: "John's Settings")
        trie.set(["users", "jane"], value: "Jane Smith")
        trie.set(["users"], value: "All Users")
        #expect(trie.get(["users"]) == "All Users")
        #expect(trie.get(["users", "john", "profile"]) == "John's Profile")
        #expect(trie.get(["users", "john", "settings"]) == "John's Settings")
        #expect(trie.get(["users", "jane"]) == "Jane Smith")
    }

    @Test func testCommonPrefixHandling() {
        var trie = ArrayTrie<String>()
        trie.set(["users", "john", "profile"], value: "John's Profile")
        trie.set(["users", "johnathan"], value: "Johnathan's Data")
        #expect(trie.get(["users", "john", "profile"]) == "John's Profile")
        #expect(trie.get(["users", "johnathan"]) == "Johnathan's Data")
    }

    @Test func testDifferentValueTypes() {
        var stringTrie = ArrayTrie<String>()
        var intTrie = ArrayTrie<Int>()
        var boolTrie = ArrayTrie<Bool>()
        stringTrie.set(["test"], value: "String Value")
        intTrie.set(["test"], value: 42)
        boolTrie.set(["test"], value: true)
        #expect(stringTrie.get(["test"]) == "String Value")
        #expect(intTrie.get(["test"]) == 42)
        #expect(boolTrie.get(["test"]) == true)
    }

    @Test func testNestedArrayTrieHandling() {
        var trie = ArrayTrie<ArrayTrie<String>>()
        var nestedTrie = ArrayTrie<String>()
        nestedTrie.set(["nested", "path"], value: "Nested Value")
        trie.set(["parent"], value: nestedTrie)
        let retrievedTrie = trie.get(["parent"])
        #expect(retrievedTrie != nil)
        #expect(retrievedTrie?.get(["nested", "path"]) == "Nested Value")
    }

    @Test func testEmptyChildren() {
        let emptyMap = TrieDictionary<ArrayTrieNode<String>>()
        let trie = ArrayTrie<String>(children: emptyMap)
        #expect(trie.isEmpty)
        #expect(trie.get(["any", "path"]) == nil)
    }

    @Test func testLongPathHandling() {
        var trie = ArrayTrie<String>()
        let longPath = (0..<1000).map { "segment\($0)" }
        trie.set(longPath, value: "Deep Value")
        #expect(trie.get(longPath) == "Deep Value")
    }

    @Test func testLongestCommonPrefix() {
        let array1: ArraySlice = ["a", "b", "c", "d", "e"][...]
        let array2: ArraySlice = ["a", "b", "x", "y", "z"][...]
        let commonPrefix = array1.longestCommonPrefix(array2)
        #expect(commonPrefix == ["a", "b"])
    }

    @Test func testLongestCommonPrefixEmpty() {
        let array1: ArraySlice = ["a", "b", "c"][...]
        let array2: ArraySlice<String> = [][...]
        let commonPrefix = array1.longestCommonPrefix(array2)
        #expect(commonPrefix == [])
    }

    @Test func testLongestCommonPrefixNoMatch() {
        let array1: ArraySlice = ["a", "b", "c"][...]
        let array2: ArraySlice = ["x", "y", "z"][...]
        let commonPrefix = array1.longestCommonPrefix(array2)
        #expect(commonPrefix == [])
    }

    @Test func testLongestCommonPrefixFullMatch() {
        let array1: ArraySlice = ["a", "b", "c"][...]
        let array2: ArraySlice = ["a", "b", "c"][...]
        let commonPrefix = array1.longestCommonPrefix(array2)
        #expect(commonPrefix == ["a", "b", "c"])
    }
}
