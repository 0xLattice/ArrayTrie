import Testing
@testable import ArrayTrie

@Suite struct QueryTests {

    // MARK: - valuesExcludingPrefix

    @Test func testValuesExcludingPrefix() {
        var trie = ArrayTrie<String>()
        trie.set(["apple", "red"], value: "Red Apple")
        trie.set(["apple", "green"], value: "Green Apple")
        trie.set(["banana", "yellow"], value: "Yellow Banana")
        trie.set(["cherry", "red"], value: "Red Cherry")
        trie.set(["apricot", "orange"], value: "Orange Apricot")
        let notApple = trie.valuesExcludingPrefix("apple")
        #expect(Set(notApple) == Set(["Yellow Banana", "Red Cherry", "Orange Apricot"]))
        let notB = trie.valuesExcludingPrefix("b")
        #expect(Set(notB) == Set(["Red Apple", "Green Apple", "Red Cherry", "Orange Apricot"]))
        let notCherry = trie.valuesExcludingPrefix("cherry")
        #expect(Set(notCherry) == Set(["Red Apple", "Green Apple", "Yellow Banana", "Orange Apricot"]))
        let emptyKey = trie.valuesExcludingPrefix("")
        #expect(emptyKey.isEmpty)
        let nonExistent = trie.valuesExcludingPrefix("zebra")
        #expect(Set(nonExistent) == Set(["Red Apple", "Green Apple", "Yellow Banana", "Red Cherry", "Orange Apricot"]))
    }

    @Test func testValuesExcludingPrefixEdgeCases() {
        var trie = ArrayTrie<String>()
        trie.set(["app"], value: "App Value")
        trie.set(["apple"], value: "Apple Value")
        trie.set(["application"], value: "Application Value")
        trie.set(["apply"], value: "Apply Value")
        trie.set(["appy"], value: "Appy Value")
        trie.set(["banana"], value: "Banana Value")
        trie.set(["band"], value: "Band Value")
        trie.set(["cat"], value: "Cat Value")
        let exactMatch = trie.valuesExcludingPrefix("app")
        #expect(Set(exactMatch) == Set(["Banana Value", "Band Value", "Cat Value"]))
        let prefixMatch = trie.valuesExcludingPrefix("appl")
        #expect(Set(prefixMatch) == Set(["App Value", "Banana Value", "Band Value", "Cat Value", "Appy Value"]))
        let singleChar = trie.valuesExcludingPrefix("a")
        #expect(Set(singleChar) == Set(["Banana Value", "Band Value", "Cat Value"]))
        let longerKey = trie.valuesExcludingPrefix("applications")
        #expect(Set(longerKey) == Set(["App Value", "Apple Value", "Application Value", "Apply Value", "Banana Value", "Band Value", "Cat Value", "Appy Value"]))
    }

    @Test func testValuesExcludingPrefixWithRootValues() {
        var trie = ArrayTrie<String>()
        trie.set([], value: "Root Value")
        trie.set(["a"], value: "A Value")
        trie.set(["ab"], value: "AB Value")
        trie.set(["b"], value: "B Value")
        trie.set(["c"], value: "C Value")
        let notA = trie.valuesExcludingPrefix("a")
        #expect(Set(notA) == Set(["Root Value", "B Value", "C Value"]))
        let notAB = trie.valuesExcludingPrefix("ab")
        #expect(Set(notAB) == Set(["Root Value", "A Value", "B Value", "C Value"]))
    }

    @Test func testValuesExcludingPrefixNestedPaths() {
        var trie = ArrayTrie<String>()
        trie.set(["api"], value: "API Root")
        trie.set(["api", "v1"], value: "API V1")
        trie.set(["api", "v1", "users"], value: "API V1 Users")
        trie.set(["api", "v2"], value: "API V2")
        trie.set(["web"], value: "Web Root")
        trie.set(["web", "admin"], value: "Web Admin")
        let notAPI = trie.valuesExcludingPrefix("api")
        #expect(Set(notAPI) == Set(["Web Root", "Web Admin"]))
        let notWeb = trie.valuesExcludingPrefix("web")
        #expect(Set(notWeb) == Set(["API Root", "API V1", "API V1 Users", "API V2"]))
        let notAP = trie.valuesExcludingPrefix("ap")
        #expect(Set(notAP) == Set(["Web Root", "Web Admin"]))
        let notXYZ = trie.valuesExcludingPrefix("xyz")
        #expect(Set(notXYZ) == Set(["API Root", "API V1", "API V1 Users", "API V2", "Web Root", "Web Admin"]))
    }

    @Test func testValuesExcludingPrefixEmptyTrie() {
        let trie = ArrayTrie<String>()
        let result = trie.valuesExcludingPrefix("anything")
        #expect(result.isEmpty)
        let emptyResult = trie.valuesExcludingPrefix("")
        #expect(emptyResult.isEmpty)
    }

    // MARK: - valuesAlongPath

    @Test func testValuesAlongPathBasic() {
        var trie = ArrayTrie<String>()
        trie.set(["u"], value: "U")
        trie.set(["us"], value: "US")
        trie.set(["use"], value: "USE")
        trie.set(["user"], value: "USER")
        trie.set(["users"], value: "USERS")
        let results = trie.valuesAlongPath("user")
        let values = results.map { $0.1 }
        #expect(values.contains("U"))
        #expect(values.contains("US"))
        #expect(values.contains("USE"))
        #expect(values.contains("USER"))
        #expect(!values.contains("USERS"))
    }

    @Test func testValuesAlongPathEmpty() {
        let trie = ArrayTrie<String>()
        let results = trie.valuesAlongPath("anything")
        #expect(results.isEmpty)
    }

    @Test func testValuesAlongPathEmptyString() {
        var trie = ArrayTrie<String>()
        trie.set(["a"], value: "A")
        trie.set(["b"], value: "B")
        let results = trie.valuesAlongPath("")
        #expect(results.isEmpty)
    }

    @Test func testValuesAlongPathNoMatches() {
        var trie = ArrayTrie<String>()
        trie.set(["apple"], value: "APPLE")
        trie.set(["banana"], value: "BANANA")
        let results = trie.valuesAlongPath("orange")
        #expect(results.isEmpty)
    }

    @Test func testValuesAlongPathPartialMatches() {
        var trie = ArrayTrie<String>()
        trie.set(["test"], value: "TEST")
        trie.set(["testing"], value: "TESTING")
        trie.set(["best"], value: "BEST")
        trie.set(["rest"], value: "REST")
        trie.set(["te"], value: "TE")
        trie.set(["t"], value: "T")
        let results = trie.valuesAlongPath("test")
        let values = results.map { $0.1 }
        #expect(values.contains("TEST"))
        #expect(values.contains("TE"))
        #expect(values.contains("T"))
        #expect(!values.contains("TESTING"))
        #expect(!values.contains("BEST"))
        #expect(!values.contains("REST"))
    }

    @Test func testValuesAlongPathMultipleTypes() {
        var intTrie = ArrayTrie<Int>()
        var boolTrie = ArrayTrie<Bool>()
        intTrie.set(["n"], value: 1)
        intTrie.set(["nu"], value: 12)
        intTrie.set(["num"], value: 123)
        boolTrie.set(["t"], value: true)
        boolTrie.set(["tr"], value: false)
        boolTrie.set(["tru"], value: true)
        let intResults = intTrie.valuesAlongPath("num")
        let boolResults = boolTrie.valuesAlongPath("tr")
        let intValues = intResults.map { $0.1 }
        let boolValues = boolResults.map { $0.1 }
        #expect(intValues.contains(1))
        #expect(intValues.contains(12))
        #expect(intValues.contains(123))
        #expect(boolValues.contains(true))
        #expect(boolValues.contains(false))
    }

    // MARK: - childValues

    @Test func testChildValuesEmpty() {
        let trie = ArrayTrie<String>()
        let values = trie.childValues()
        #expect(values.isEmpty)
    }

    @Test func testChildValuesSingleLevel() {
        var trie = ArrayTrie<String>()
        trie.set(["user"], value: "User Data")
        trie.set(["admin"], value: "Admin Data")
        trie.set(["guest"], value: "Guest Data")
        let values = trie.childValues()
        #expect(values.count == 3)
        #expect(values.contains("User Data"))
        #expect(values.contains("Admin Data"))
        #expect(values.contains("Guest Data"))
    }

    @Test func testChildValuesWithDeepPaths() {
        var trie = ArrayTrie<String>()
        trie.set(["user"], value: "User Data")
        trie.set(["admin"], value: "Admin Data")
        trie.set(["user", "profile"], value: "Profile Data")
        trie.set(["user", "settings"], value: "Settings Data")
        trie.set(["admin", "permissions"], value: "Permissions Data")
        let values = trie.childValues()
        #expect(values.count == 2)
        #expect(values.contains("User Data"))
        #expect(values.contains("Admin Data"))
        #expect(!values.contains("Profile Data"))
        #expect(!values.contains("Settings Data"))
        #expect(!values.contains("Permissions Data"))
    }

    @Test func testChildValuesWithNilValues() {
        var trie = ArrayTrie<String>()
        trie.set(["user"], value: "User Data")
        trie.set(["admin"], value: "Admin Data")
        trie.set(["user", "profile"], value: "Profile Data")
        trie.set(["guest", "info"], value: "Guest Info")
        let values = trie.childValues()
        #expect(values.count == 2)
        #expect(values.contains("User Data"))
        #expect(values.contains("Admin Data"))
        #expect(!values.contains("Profile Data"))
        #expect(!values.contains("Guest Info"))
    }

    @Test func testChildValuesMixedTypes() {
        var intTrie = ArrayTrie<Int>()
        var boolTrie = ArrayTrie<Bool>()
        intTrie.set(["count"], value: 42)
        intTrie.set(["total"], value: 100)
        intTrie.set(["deep", "value"], value: 999)
        boolTrie.set(["enabled"], value: true)
        boolTrie.set(["disabled"], value: false)
        boolTrie.set(["nested", "flag"], value: true)
        let intValues = intTrie.childValues()
        let boolValues = boolTrie.childValues()
        #expect(intValues.count == 2)
        #expect(intValues.contains(42))
        #expect(intValues.contains(100))
        #expect(!intValues.contains(999))
        #expect(boolValues.count == 2)
        #expect(boolValues.contains(true))
        #expect(boolValues.contains(false))
    }

    @Test func testChildValuesAfterDeletion() {
        var trie = ArrayTrie<String>()
        trie.set(["user"], value: "User Data")
        trie.set(["admin"], value: "Admin Data")
        trie.set(["guest"], value: "Guest Data")
        var values = trie.childValues()
        #expect(values.count == 3)
        trie = trie.deleting(path: ["admin"])
        values = trie.childValues()
        #expect(values.count == 2)
        #expect(values.contains("User Data"))
        #expect(values.contains("Guest Data"))
        #expect(!values.contains("Admin Data"))
    }

    @Test func testChildValuesWithRootValue() {
        var trie = ArrayTrie<String>()
        trie.set([], value: "Root Value")
        trie.set(["user"], value: "User Data")
        trie.set(["admin"], value: "Admin Data")
        let values = trie.childValues()
        #expect(values.count == 2)
        #expect(values.contains("User Data"))
        #expect(values.contains("Admin Data"))
        #expect(!values.contains("Root Value"))
    }

    @Test func testChildValuesEmptyStrings() {
        var trie = ArrayTrie<String>()
        trie.set([""], value: "Empty String Value")
        trie.set(["user"], value: "User Data")
        trie.set(["", "nested"], value: "Nested Under Empty")
        let values = trie.childValues()
        #expect(values.count == 2)
        #expect(values.contains("Empty String Value"))
        #expect(values.contains("User Data"))
        #expect(!values.contains("Nested Under Empty"))
    }

    @Test func testChildValuesAfterMerging() {
        var trie1 = ArrayTrie<String>()
        var trie2 = ArrayTrie<String>()
        trie1.set(["user"], value: "User1")
        trie1.set(["admin"], value: "Admin1")
        trie2.set(["user"], value: "User2")
        trie2.set(["guest"], value: "Guest2")
        let merged = trie1.merging(with: trie2) { a, b in "\(a)+\(b)" }
        let values = merged.childValues()
        #expect(values.count == 3)
        #expect(values.contains("User1+User2"))
        #expect(values.contains("Admin1"))
        #expect(values.contains("Guest2"))
    }

    @Test func testChildValuesPerformance() {
        var trie = ArrayTrie<Int>()
        for i in 0..<1000 {
            trie.set(["item\(i)"], value: i)
        }
        for i in 0..<100 {
            trie.set(["deep", "item\(i)"], value: i + 10000)
        }
        let values = trie.childValues()
        #expect(values.count == 1000)
        for i in 0..<1000 {
            #expect(values.contains(i))
        }
        for i in 0..<100 {
            #expect(!values.contains(i + 10000))
        }
    }

    @Test func testChildValuesOrder() {
        var trie = ArrayTrie<String>()
        trie.set(["zebra"], value: "Z")
        trie.set(["apple"], value: "A")
        trie.set(["banana"], value: "B")
        let values = trie.childValues()
        #expect(values.count == 3)
        #expect(values.contains("Z"))
        #expect(values.contains("A"))
        #expect(values.contains("B"))
    }

    // MARK: - traverseChild

    @Test func testTraverseChildBasic() {
        var trie = ArrayTrie<String>()
        trie.set(["apple"], value: "APPLE")
        trie.set(["banana"], value: "BANANA")
        trie.set(["apricot"], value: "APRICOT")
        let result = trie.traverseChild("a")
        #expect(result != nil)
        if let subtrie = result {
            #expect(!subtrie.isEmpty)
            let keys = subtrie.children.keys()
            #expect(!keys.isEmpty)
        }
    }

    @Test func testTraverseChildNonExistent() {
        var trie = ArrayTrie<String>()
        trie.set(["apple"], value: "APPLE")
        trie.set(["banana"], value: "BANANA")
        let result = trie.traverseChild("z")
        #expect(result == nil)
    }

    @Test func testTraverseChildEmptyTrie() {
        let trie = ArrayTrie<String>()
        let result = trie.traverseChild("a")
        #expect(result == nil)
    }

    @Test func testTraverseChildSingleCharacterKeys() {
        var trie = ArrayTrie<String>()
        trie.set(["a"], value: "A")
        trie.set(["b"], value: "B")
        trie.set(["c"], value: "C")
        let resultA = trie.traverseChild("a")
        let resultB = trie.traverseChild("b")
        #expect(resultA != nil)
        #expect(resultB != nil)
        if let subtrieA = resultA {
            #expect(!subtrieA.isEmpty)
        }
        if let subtrieB = resultB {
            #expect(!subtrieB.isEmpty)
        }
    }

    @Test func testTraverseChildPreservesRootValue() {
        var trie = ArrayTrie<String>()
        trie.set([], value: "ROOT")
        trie.set(["apple"], value: "APPLE")
        trie.set(["banana"], value: "BANANA")
        let result = trie.traverseChild("a")
        #expect(result != nil)
        if let subtrie = result {
            #expect(subtrie.get([]) == "ROOT")
        }
    }

    @Test func testTraverseChildMultiplePrefixes() {
        var trie = ArrayTrie<String>()
        trie.set(["test"], value: "TEST")
        trie.set(["team"], value: "TEAM")
        trie.set(["tea"], value: "TEA")
        trie.set(["tree"], value: "TREE")
        let result = trie.traverseChild("t")
        #expect(result != nil)
        if let subtrie = result {
            #expect(!subtrie.isEmpty)
            let keys = subtrie.children.keys()
            #expect(!keys.isEmpty)
        }
    }

    @Test func testTraverseChildSpecialCharacters() {
        var trie = ArrayTrie<String>()
        trie.set(["@mention"], value: "MENTION")
        trie.set(["#hashtag"], value: "HASHTAG")
        trie.set(["$dollar"], value: "DOLLAR")
        let mentionResult = trie.traverseChild("@")
        let hashResult = trie.traverseChild("#")
        let dollarResult = trie.traverseChild("$")
        #expect(mentionResult != nil)
        #expect(hashResult != nil)
        #expect(dollarResult != nil)
    }

    @Test func testTraverseChildAfterMerging() {
        var trie1 = ArrayTrie<String>()
        var trie2 = ArrayTrie<String>()
        trie1.set(["apple"], value: "APPLE1")
        trie1.set(["banana"], value: "BANANA1")
        trie2.set(["apricot"], value: "APRICOT2")
        trie2.set(["cherry"], value: "CHERRY2")
        let merged = trie1.merging(with: trie2) { a, b in a }
        let result = merged.traverseChild("a")
        #expect(result != nil)
        if let subtrie = result {
            #expect(!subtrie.isEmpty)
        }
    }

    @Test func testTraverseChildMultipleTypes() {
        var intTrie = ArrayTrie<Int>()
        var stringTrie = ArrayTrie<String>()
        intTrie.set(["number"], value: 42)
        intTrie.set(["negative"], value: -1)
        stringTrie.set(["name"], value: "John")
        stringTrie.set(["null"], value: "NULL")
        let intResult = intTrie.traverseChild("n")
        let stringResult = stringTrie.traverseChild("n")
        #expect(intResult != nil)
        #expect(stringResult != nil)
    }

    // MARK: - childCharacters

    @Test func testChildCharactersBasic() {
        var trie = ArrayTrie<String>()
        trie.set(["apple"], value: "APPLE")
        trie.set(["banana"], value: "BANANA")
        trie.set(["cherry"], value: "CHERRY")
        trie.set(["apricot"], value: "APRICOT")
        let characters = trie.childCharacters()
        #expect(characters.count >= 3)
        #expect(characters.contains("a"))
        #expect(characters.contains("b"))
        #expect(characters.contains("c"))
    }

    @Test func testChildCharactersEmpty() {
        let trie = ArrayTrie<String>()
        let characters = trie.childCharacters()
        #expect(characters.isEmpty)
    }

    @Test func testChildCharactersSingleKey() {
        var trie = ArrayTrie<String>()
        trie.set(["test"], value: "TEST")
        let characters = trie.childCharacters()
        #expect(characters.count >= 1)
        #expect(characters.contains("t"))
    }

    @Test func testChildCharactersSpecialCharacters() {
        var trie = ArrayTrie<String>()
        trie.set(["@mention"], value: "MENTION")
        trie.set(["#hashtag"], value: "HASHTAG")
        trie.set(["$dollar"], value: "DOLLAR")
        trie.set(["123number"], value: "NUMBER")
        let characters = trie.childCharacters()
        #expect(characters.contains("@"))
        #expect(characters.contains("#"))
        #expect(characters.contains("$"))
        #expect(characters.contains("1"))
    }

    @Test func testChildCharactersUnicode() {
        var trie = ArrayTrie<String>()
        trie.set(["cafe\u{0301}"], value: "CAFE")
        trie.set(["nai\u{0308}ve"], value: "NAIVE")
        trie.set(["re\u{0301}sume\u{0301}"], value: "RESUME")
        trie.set(["\u{1F642}emoji"], value: "EMOJI")
        let characters = trie.childCharacters()
        #expect(characters.contains("c"))
        #expect(characters.contains("n"))
        #expect(characters.contains("r"))
        #expect(characters.contains("\u{1F642}"))
    }

    @Test func testChildCharactersDuplicates() {
        var trie = ArrayTrie<String>()
        trie.set(["apple"], value: "APPLE")
        trie.set(["apricot"], value: "APRICOT")
        trie.set(["avocado"], value: "AVOCADO")
        let characters = trie.childCharacters()
        let uniqueCharacters = Array(Set(characters))
        #expect(characters.count == uniqueCharacters.count)
        #expect(characters.contains("a"))
    }

    @Test func testChildCharactersAfterDeletion() {
        var trie = ArrayTrie<String>()
        trie.set(["apple"], value: "APPLE")
        trie.set(["banana"], value: "BANANA")
        trie.set(["cherry"], value: "CHERRY")
        var characters = trie.childCharacters()
        let originalCount = characters.count
        #expect(characters.contains("b"))
        trie = trie.deleting(path: ["banana"])
        characters = trie.childCharacters()
        #expect(characters.count <= originalCount)
        #expect(characters.contains("a"))
        #expect(characters.contains("c"))
    }

    @Test func testChildCharactersAfterMerging() {
        var trie1 = ArrayTrie<String>()
        var trie2 = ArrayTrie<String>()
        trie1.set(["apple"], value: "APPLE")
        trie1.set(["banana"], value: "BANANA")
        trie2.set(["cherry"], value: "CHERRY")
        trie2.set(["date"], value: "DATE")
        let merged = trie1.merging(with: trie2) { a, b in a }
        let characters = merged.childCharacters()
        #expect(characters.contains("a"))
        #expect(characters.contains("b"))
        #expect(characters.contains("c"))
        #expect(characters.contains("d"))
    }

    @Test func testChildCharactersEmptyStringKeys() {
        var trie = ArrayTrie<String>()
        trie.set([""], value: "EMPTY")
        trie.set(["test"], value: "TEST")
        let characters = trie.childCharacters()
        #expect(characters.contains("t"))
    }

    @Test func testChildCharactersPerformance() {
        var trie = ArrayTrie<Int>()
        for i in 0..<1000 {
            let key = "key\(i % 26)_\(i)"
            trie.set([key], value: i)
        }
        let characters = trie.childCharacters()
        #expect(characters.contains("k"))
        let uniqueCharacters = Array(Set(characters))
        #expect(characters.count == uniqueCharacters.count)
    }

    @Test func testChildCharactersOrder() {
        var trie = ArrayTrie<String>()
        trie.set(["zebra"], value: "Z")
        trie.set(["apple"], value: "A")
        trie.set(["banana"], value: "B")
        let characters = trie.childCharacters()
        #expect(characters.contains("z"))
        #expect(characters.contains("a"))
        #expect(characters.contains("b"))
    }

    @Test func testChildCharactersMultipleTypes() {
        var stringTrie = ArrayTrie<String>()
        var intTrie = ArrayTrie<Int>()
        stringTrie.set(["string"], value: "STRING")
        stringTrie.set(["text"], value: "TEXT")
        intTrie.set(["number"], value: 42)
        intTrie.set(["negative"], value: -1)
        let stringChars = stringTrie.childCharacters()
        let intChars = intTrie.childCharacters()
        #expect(stringChars.contains("s"))
        #expect(stringChars.contains("t"))
        #expect(intChars.contains("n"))
    }

    @Test func testChildCharactersConsistency() {
        var trie = ArrayTrie<String>()
        trie.set(["test"], value: "TEST")
        trie.set(["temp"], value: "TEMP")
        trie.set(["tree"], value: "TREE")
        let characters1 = trie.childCharacters()
        let characters2 = trie.childCharacters()
        #expect(characters1.count == characters2.count)
        #expect(Set(characters1) == Set(characters2))
    }

    // MARK: - childKeys

    @Test func testChildKeysBasic() {
        var trie = ArrayTrie<String>()
        trie.set(["users"], value: "USERS")
        trie.set(["admins"], value: "ADMINS")
        trie.set(["guests"], value: "GUESTS")
        let keys = trie.childKeys()
        #expect(keys.count == 3)
        #expect(keys.contains("users"))
        #expect(keys.contains("admins"))
        #expect(keys.contains("guests"))
    }

    @Test func testChildKeysEmpty() {
        let trie = ArrayTrie<String>()
        let keys = trie.childKeys()
        #expect(keys.isEmpty)
    }

    @Test func testChildKeysSingleKey() {
        var trie = ArrayTrie<String>()
        trie.set(["onlykey"], value: "VALUE")
        let keys = trie.childKeys()
        #expect(keys.count == 1)
        #expect(keys.contains("onlykey"))
    }

    @Test func testChildKeysWithEmptyString() {
        var trie = ArrayTrie<String>()
        trie.set([""], value: "EMPTY")
        trie.set(["test"], value: "TEST")
        let keys = trie.childKeys()
        #expect(keys.count == 2)
        #expect(keys.contains(""))
        #expect(keys.contains("test"))
    }

    @Test func testChildKeysAfterDeletion() {
        var trie = ArrayTrie<String>()
        trie.set(["apple"], value: "APPLE")
        trie.set(["banana"], value: "BANANA")
        trie.set(["cherry"], value: "CHERRY")
        var keys = trie.childKeys()
        #expect(keys.count == 3)
        #expect(keys.contains("banana"))
        trie = trie.deleting(path: ["banana"])
        keys = trie.childKeys()
        #expect(keys.count == 2)
        #expect(!keys.contains("banana"))
        #expect(keys.contains("apple"))
        #expect(keys.contains("cherry"))
    }

    @Test func testChildKeysWithNestedPaths() {
        var trie = ArrayTrie<String>()
        trie.set(["users", "john"], value: "JOHN")
        trie.set(["users", "jane"], value: "JANE")
        trie.set(["admins", "bob"], value: "BOB")
        let rootKeys = trie.childKeys()
        #expect(rootKeys.count == 2)
        #expect(rootKeys.contains("users"))
        #expect(rootKeys.contains("admins"))
        let usersSubtrie = trie.traverse(["users"])
        #expect(usersSubtrie != nil)
        if let usersSubtrie = usersSubtrie {
            let userKeys = usersSubtrie.childKeys()
            #expect(userKeys.count == 2)
            #expect(userKeys.contains("john"))
            #expect(userKeys.contains("jane"))
        }
    }

    @Test func testChildKeysConsistency() {
        var trie = ArrayTrie<String>()
        trie.set(["test"], value: "TEST")
        trie.set(["temp"], value: "TEMP")
        trie.set(["tree"], value: "TREE")
        let keys1 = trie.childKeys()
        let keys2 = trie.childKeys()
        #expect(keys1.count == keys2.count)
        #expect(Set(keys1) == Set(keys2))
    }

    // MARK: - allValues

    @Test func testAllValuesEmpty() {
        let trie = ArrayTrie<String>()
        let values = trie.allValues()
        #expect(values.isEmpty)
    }

    @Test func testAllValuesRootOnly() {
        var trie = ArrayTrie<String>()
        trie.set([], value: "root")
        let values = trie.allValues()
        #expect(values.count == 1)
        #expect(values[0] == "root")
    }

    @Test func testAllValuesSinglePath() {
        var trie = ArrayTrie<String>()
        trie.set(["users", "john"], value: "John Doe")
        let values = trie.allValues()
        #expect(values.count == 1)
        #expect(values[0] == "John Doe")
    }

    @Test func testAllValuesMultiplePaths() {
        var trie = ArrayTrie<String>()
        trie.set(["users", "john"], value: "John Doe")
        trie.set(["users", "jane"], value: "Jane Smith")
        trie.set(["admins", "alice"], value: "Alice Admin")
        let values = trie.allValues()
        let valueSet = Set(values)
        #expect(values.count == 3)
        #expect(valueSet == Set(["John Doe", "Jane Smith", "Alice Admin"]))
    }

    @Test func testAllValuesWithRootAndChildren() {
        var trie = ArrayTrie<String>()
        trie.set([], value: "root")
        trie.set(["users", "john"], value: "John Doe")
        trie.set(["users", "jane"], value: "Jane Smith")
        let values = trie.allValues()
        let valueSet = Set(values)
        #expect(values.count == 3)
        #expect(valueSet == Set(["root", "John Doe", "Jane Smith"]))
    }

    @Test func testAllValuesNestedPaths() {
        var trie = ArrayTrie<String>()
        trie.set(["a"], value: "A")
        trie.set(["a", "b"], value: "AB")
        trie.set(["a", "b", "c"], value: "ABC")
        trie.set(["a", "x"], value: "AX")
        let values = trie.allValues()
        let valueSet = Set(values)
        #expect(values.count == 4)
        #expect(valueSet == Set(["A", "AB", "ABC", "AX"]))
    }

    @Test func testAllValuesAfterDeletion() {
        var trie = ArrayTrie<String>()
        trie.set(["users", "john"], value: "John Doe")
        trie.set(["users", "jane"], value: "Jane Smith")
        trie.set(["admins", "alice"], value: "Alice Admin")
        trie = trie.deleting(path: ["users", "john"])
        let values = trie.allValues()
        let valueSet = Set(values)
        #expect(values.count == 2)
        #expect(valueSet == Set(["Jane Smith", "Alice Admin"]))
    }

    @Test func testAllValuesAfterMerging() {
        var trie1 = ArrayTrie<String>()
        trie1.set(["users", "john"], value: "John")
        trie1.set(["users", "jane"], value: "Jane")
        var trie2 = ArrayTrie<String>()
        trie2.set(["users", "bob"], value: "Bob")
        trie2.set(["admins", "alice"], value: "Alice")
        let mergedTrie = trie1.merging(with: trie2) { first, second in
            first + "-" + second
        }
        let values = mergedTrie.allValues()
        let valueSet = Set(values)
        #expect(values.count == 4)
        #expect(valueSet == Set(["John", "Jane", "Bob", "Alice"]))
    }

    @Test func testAllValuesWithConflictMerging() {
        var trie1 = ArrayTrie<String>()
        trie1.set(["users", "john"], value: "John1")
        var trie2 = ArrayTrie<String>()
        trie2.set(["users", "john"], value: "John2")
        let mergedTrie = trie1.merging(with: trie2) { first, second in
            first + "-" + second
        }
        let values = mergedTrie.allValues()
        #expect(values.count == 1)
        #expect(values[0] == "John1-John2")
    }

    @Test func testAllValuesWithDifferentTypes() {
        var trie = ArrayTrie<Int>()
        trie.set(["numbers", "one"], value: 1)
        trie.set(["numbers", "two"], value: 2)
        trie.set(["numbers", "three"], value: 3)
        let values = trie.allValues()
        let valueSet = Set(values)
        #expect(values.count == 3)
        #expect(valueSet == Set([1, 2, 3]))
    }

    @Test func testAllValuesEmptyStringsInPath() {
        var trie = ArrayTrie<String>()
        trie.set(["", "empty"], value: "EmptyPrefix")
        trie.set(["empty", ""], value: "EmptySuffix")
        trie.set(["normal", "path"], value: "Normal")
        let values = trie.allValues()
        let valueSet = Set(values)
        #expect(values.count == 3)
        #expect(valueSet == Set(["EmptyPrefix", "EmptySuffix", "Normal"]))
    }

    @Test func testAllValuesPerformanceLargeTrie() {
        var trie = ArrayTrie<String>()
        for i in 0..<1000 {
            trie.set(["level1", "level2", "item\(i)"], value: "Value\(i)")
        }
        let values = trie.allValues()
        #expect(values.count == 1000)
        let valueSet = Set(values)
        #expect(valueSet.count == 1000)
        #expect(valueSet.contains("Value0"))
        #expect(valueSet.contains("Value500"))
        #expect(valueSet.contains("Value999"))
    }

    @Test func testAllValuesConsistency() {
        var trie = ArrayTrie<String>()
        trie.set(["a"], value: "A")
        trie.set(["b"], value: "B")
        trie.set(["c"], value: "C")
        let values1 = trie.allValues()
        let values2 = trie.allValues()
        #expect(Set(values1) == Set(values2))
        #expect(values1.count == values2.count)
    }

    @Test func testAllValuesImmutability() {
        var originalTrie = ArrayTrie<String>()
        originalTrie.set(["test"], value: "Original")
        let originalValues = originalTrie.allValues()
        originalTrie.set(["new"], value: "New")
        #expect(originalValues.count == 1)
        #expect(originalValues[0] == "Original")
        let newValues = originalTrie.allValues()
        #expect(newValues.count == 2)
        #expect(Set(newValues) == Set(["Original", "New"]))
    }

    @Test func testValuesAlongPathsResultingTries() {
        var trie = ArrayTrie<String>()
        trie.set(["test"], value: "test")
        trie.set(["te"], value: "te")
        trie.set(["tes"], value: "tes")
        trie.set(["test", "foo"], value: "test,foo")
        trie.set(["test", "fo"], value: "test,fo")
        trie.set(["te", "foe"], value: "te,foe")
        trie.set(["tes", "far"], value: "tes,far")
        let pathValuesAndTries = trie.valuesAlongPath("test")
        let values = pathValuesAndTries.map { $0.1 }
        #expect(values.contains("test"))
        #expect(values.contains("te"))
        #expect(values.contains("tes"))
        for pathValueAndTrie in pathValuesAndTries {
            if pathValueAndTrie.1 == "test" {
                #expect(pathValueAndTrie.0.get(["foo"]) == "test,foo")
                #expect(pathValueAndTrie.0.get(["fo"]) == "test,fo")
            }
            if pathValueAndTrie.1 == "te" {
                #expect(pathValueAndTrie.0.get(["foe"]) == "te,foe")
            }
            if pathValueAndTrie.1 == "tes" {
                #expect(pathValueAndTrie.0.get(["far"]) == "tes,far")
            }
        }
    }
}
