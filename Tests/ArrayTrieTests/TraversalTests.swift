import Testing
@testable import ArrayTrie

@Suite struct TraversalTests {

    // MARK: - Array Path Traversal

    @Test func testTraversal() {
        var trie = ArrayTrie<String>()
        trie.set(["users", "john", "profile"], value: "John's Profile")
        trie.set(["users", "john", "settings"], value: "John's Settings")
        trie.set(["users", "jane", "profile"], value: "Jane's Profile")
        let subtrie = trie.traverse(["users", "john"])
        #expect(subtrie != nil)
        if let subtrie = subtrie {
            #expect(subtrie.get(["profile"]) == "John's Profile")
            #expect(subtrie.get(["settings"]) == "John's Settings")
            #expect(subtrie.get(["nonexistent"]) == nil)
        }
    }

    @Test func testTraversalNonExistent() {
        var trie = ArrayTrie<String>()
        trie.set(["users", "john"], value: "John Doe")
        let subtrie = trie.traverse(["users", "jane"])
        #expect(subtrie == nil)
    }

    @Test func testTraversalPath() {
        var trie = ArrayTrie<String>()
        trie.set(["users", "john"], value: "John Doe")
        let subtrie = trie.traverse(["users", "john"])
        #expect(subtrie != nil)
        if let subtrie = subtrie {
            #expect(subtrie.get([]) == "John Doe")
            #expect(subtrie.children.isEmpty)
        }
    }

    @Test func testTraversalEmptyPath() {
        var trie = ArrayTrie<String>()
        trie.set(["users", "john"], value: "John Doe")
        let subtrie = trie.traverse([])
        #expect(subtrie != nil)
        if let subtrie = subtrie {
            #expect(subtrie.get(["users", "john"]) == "John Doe")
        }
    }

    // MARK: - String Path Traversal

    @Test func testTraverseStringPath() {
        var trie = ArrayTrie<String>()
        trie.set(["users"], value: "All Users")
        trie.set(["users-admin"], value: "Admin Users")
        trie.set(["posts"], value: "All Posts")
        let usersSubtrie = trie.traverse(path: "users")
        #expect(usersSubtrie != nil)
        if let subtrie = usersSubtrie {
            #expect(!subtrie.isEmpty)
            let keys = subtrie.children.keys()
            #expect(subtrie.get([""]) == "All Users")
            #expect(keys.contains("-admin"))
        }
    }

    @Test func testTraverseStringPathNonExistent() {
        var trie = ArrayTrie<String>()
        trie.set(["users"], value: "All Users")
        trie.set(["posts"], value: "All Posts")
        let subtrie = trie.traverse(path: "comments")
        #expect(subtrie == nil)
    }

    @Test func testTraverseStringPathEmpty() {
        var trie = ArrayTrie<String>()
        trie.set(["users"], value: "All Users")
        trie.set(["posts"], value: "All Posts")
        let subtrie = trie.traverse(path: "")
        #expect(subtrie != nil)
        if let subtrie = subtrie {
            #expect(subtrie.get(["users"]) == "All Users")
            #expect(subtrie.get(["posts"]) == "All Posts")
        }
    }

    @Test func testTraverseStringPathPartialMatch() {
        var trie = ArrayTrie<String>()
        trie.set(["user"], value: "Single User")
        trie.set(["users"], value: "All Users")
        trie.set(["userdata"], value: "User Data")
        let subtrie = trie.traverse(path: "user")
        #expect(subtrie != nil)
        if let subtrie = subtrie {
            #expect(!subtrie.isEmpty)
            let keys = subtrie.children.keys()
            #expect(keys.contains("s"))
            #expect(keys.contains("data"))
        }
    }

    @Test func testTraverseStringPathWithSpecialCharacters() {
        var trie = ArrayTrie<String>()
        trie.set(["user@domain.com"], value: "Email User")
        trie.set(["user-name"], value: "Hyphenated User")
        trie.set(["user_id"], value: "Underscore User")
        let subtrie = trie.traverse(path: "user")
        #expect(subtrie != nil)
        if let subtrie = subtrie {
            #expect(!subtrie.isEmpty)
            let keys = subtrie.children.keys()
            #expect(keys.contains("@domain.com"))
            #expect(keys.contains("-name"))
            #expect(keys.contains("_id"))
        }
    }

    @Test func testTraverseStringPathEmptyTrie() {
        let trie = ArrayTrie<String>()
        let subtrie = trie.traverse(path: "anything")
        #expect(subtrie == nil)
    }

    @Test func testTraverseStringPathEmptyString() {
        var trie = ArrayTrie<String>()
        trie.set([""], value: "Empty Key")
        trie.set(["a"], value: "A")
        trie.set(["ab"], value: "AB")
        let subtrie = trie.traverse(path: "")
        #expect(subtrie != nil)
        if let result = subtrie {
            #expect(result.get([""]) == "Empty Key")
            #expect(result.get(["a"]) == "A")
            #expect(result.get(["ab"]) == "AB")
        }
    }

    @Test func testTraverseStringPathSingleCharacter() {
        var trie = ArrayTrie<String>()
        trie.set(["a"], value: "Just A")
        trie.set(["apple"], value: "Apple")
        trie.set(["application"], value: "Application")
        trie.set(["banana"], value: "Banana")
        let subtrie = trie.traverse(path: "a")
        #expect(subtrie != nil)
        if let result = subtrie {
            #expect(!result.isEmpty)
            let keys = result.children.keys()
            #expect(keys.contains(""))
            #expect(keys.contains("pple"))
            #expect(keys.contains("pplication"))
            #expect(!keys.contains("banana"))
        }
    }

    @Test func testTraverseStringPathComplexPrefixes() {
        var trie = ArrayTrie<String>()
        trie.set(["prefix"], value: "Prefix")
        trie.set(["prefixed"], value: "Prefixed")
        trie.set(["prefixing"], value: "Prefixing")
        trie.set(["pre"], value: "Pre")
        trie.set(["prepare"], value: "Prepare")
        trie.set(["other"], value: "Other")
        let subtrie = trie.traverse(path: "prefix")
        #expect(subtrie != nil)
        if let result = subtrie {
            #expect(!result.isEmpty)
            let keys = result.children.keys()
            #expect(keys.contains(""))
            #expect(keys.contains("ed"))
            #expect(keys.contains("ing"))
            #expect(!keys.contains("pre"))
            #expect(!keys.contains("prepare"))
        }
    }

    @Test func testTraverseStringPathNoCommonPrefix() {
        var trie = ArrayTrie<String>()
        trie.set(["banana"], value: "Banana")
        trie.set(["cherry"], value: "Cherry")
        trie.set(["date"], value: "Date")
        let subtrie = trie.traverse(path: "apple")
        #expect(subtrie == nil)
    }

    @Test func testTraverseStringPathCaseSensitive() {
        var trie = ArrayTrie<String>()
        trie.set(["Apple"], value: "Capital A")
        trie.set(["apple"], value: "Lowercase a")
        trie.set(["APPLE"], value: "All Caps")
        let lowerSubtrie = trie.traverse(path: "apple")
        #expect(lowerSubtrie != nil)
        if let result = lowerSubtrie {
            let keys = result.children.keys()
            #expect(keys.contains(""))
            #expect(!keys.contains("Apple"))
        }
        let upperSubtrie = trie.traverse(path: "Apple")
        #expect(upperSubtrie != nil)
        if let result = upperSubtrie {
            let keys = result.children.keys()
            #expect(keys.contains(""))
        }
    }

    @Test func testTraverseStringPathNumbers() {
        var trie = ArrayTrie<String>()
        trie.set(["123"], value: "One Two Three")
        trie.set(["1234"], value: "One Two Three Four")
        trie.set(["12"], value: "One Two")
        trie.set(["456"], value: "Four Five Six")
        let subtrie = trie.traverse(path: "123")
        #expect(subtrie != nil)
        if let result = subtrie {
            let keys = result.children.keys()
            #expect(keys.contains(""))
            #expect(keys.contains("4"))
            #expect(!keys.contains("12"))
        }
    }

    @Test func testTraverseStringPathUnicode() {
        var trie = ArrayTrie<String>()
        trie.set(["café"], value: "Coffee")
        trie.set(["cafés"], value: "Coffees")
        trie.set(["naïve"], value: "Naive")
        trie.set(["🙂happy"], value: "Happy")
        trie.set(["🙂sad"], value: "Sad")
        let cafeSubtrie = trie.traverse(path: "café")
        #expect(cafeSubtrie != nil)
        if let result = cafeSubtrie {
            let keys = result.children.keys()
            #expect(keys.contains(""))
            #expect(keys.contains("s"))
        }
        let emojiSubtrie = trie.traverse(path: "🙂")
        #expect(emojiSubtrie != nil)
        if let result = emojiSubtrie {
            let keys = result.children.keys()
            #expect(keys.contains("happy"))
            #expect(keys.contains("sad"))
        }
    }

    @Test func testTraverseStringPathSpecialCharacters() {
        var trie = ArrayTrie<String>()
        trie.set(["@user"], value: "User Mention")
        trie.set(["@admin"], value: "Admin Mention")
        trie.set(["#tag"], value: "Hashtag")
        trie.set(["$variable"], value: "Variable")
        trie.set(["file.txt"], value: "Text File")
        trie.set(["file.pdf"], value: "PDF File")
        let mentionSubtrie = trie.traverse(path: "@")
        #expect(mentionSubtrie != nil)
        if let result = mentionSubtrie {
            let keys = result.children.keys()
            #expect(keys.contains("user"))
            #expect(keys.contains("admin"))
        }
        let fileSubtrie = trie.traverse(path: "file")
        #expect(fileSubtrie != nil)
        if let result = fileSubtrie {
            let keys = result.children.keys()
            #expect(keys.contains(".txt"))
            #expect(keys.contains(".pdf"))
        }
    }

    @Test func testTraverseStringPathDeepNesting() {
        var trie = ArrayTrie<String>()
        trie.set(["api", "v1", "users"], value: "V1 Users")
        trie.set(["api", "v2", "users"], value: "V2 Users")
        trie.set(["application"], value: "App")
        trie.set(["app"], value: "Short App")
        let appSubtrie = trie.traverse(path: "app")
        #expect(appSubtrie != nil)
        if let result = appSubtrie {
            let keys = result.children.keys()
            #expect(keys.contains(""))
            #expect(keys.contains("lication"))
        }
        let apiSubtrie = trie.traverse(path: "api")
        let resultTrie = apiSubtrie!.traverse([""])
        #expect(apiSubtrie != nil)
        if let result = apiSubtrie {
            let keys = result.children.keys()
            #expect(keys.contains(""))
            #expect(!keys.contains("app"))
            #expect(resultTrie!.get(["v1", "users"]) == "V1 Users")
            #expect(resultTrie!.get(["v2", "users"]) == "V2 Users")
        }
    }

    @Test func testTraverseStringPathExactMatchVsPrefix() {
        var trie = ArrayTrie<String>()
        trie.set(["test"], value: "Test Exact")
        trie.set(["testing"], value: "Testing")
        trie.set(["tester"], value: "Tester")
        trie.set(["te"], value: "Te")
        let testSubtrie = trie.traverse(path: "test")
        #expect(testSubtrie != nil)
        if let result = testSubtrie {
            let keys = result.children.keys()
            #expect(keys.contains(""))
            #expect(keys.contains("ing"))
            #expect(keys.contains("er"))
            #expect(!keys.contains("te"))
        }
        let teSubtrie = trie.traverse(path: "te")
        #expect(teSubtrie != nil)
        if let result = teSubtrie {
            let keys = result.children.keys()
            #expect(keys.contains(""))
            #expect(keys.contains("st"))
            #expect(keys.contains("sting"))
            #expect(keys.contains("ster"))
        }
    }

    @Test func testTraverseStringPathWithRootValue() {
        var trie = ArrayTrie<String>()
        trie.set([], value: "Root Value")
        trie.set(["test"], value: "Test")
        trie.set(["temp"], value: "Temp")
        let testSubtrie = trie.traverse(path: "te")
        #expect(testSubtrie != nil)
        if let result = testSubtrie {
            #expect(result.get([]) == nil)
            let keys = result.children.keys()
            #expect(keys.contains("st"))
            #expect(keys.contains("mp"))
        }
        let emptySubtrie = trie.traverse(path: "")
        #expect(emptySubtrie != nil)
        if let result = emptySubtrie {
            #expect(result.get(["test"]) == "Test")
            #expect(result.get(["temp"]) == "Temp")
        }
    }

    @Test func testTraverseStringPathAfterOperations() {
        var trie = ArrayTrie<String>()
        trie.set(["apple"], value: "Apple")
        trie.set(["application"], value: "Application")
        trie.set(["banana"], value: "Banana")
        var subtrie = trie.traverse(path: "app")
        #expect(subtrie != nil)
        trie = trie.deleting(path: ["apple"])
        subtrie = trie.traverse(path: "app")
        #expect(subtrie != nil)
        if let result = subtrie {
            let keys = result.children.keys()
            #expect(!keys.contains("le"))
            #expect(keys.contains("lication"))
        }
        trie.set(["approach"], value: "Approach")
        subtrie = trie.traverse(path: "app")
        #expect(subtrie != nil)
        if let result = subtrie {
            let keys = result.children.keys()
            #expect(keys.contains("lication"))
            #expect(keys.contains("roach"))
        }
    }

    @Test func testTraverseStringPathPerformance() {
        var trie = ArrayTrie<String>()
        for i in 0..<1000 {
            trie.set(["prefix\(i)"], value: "Value \(i)")
        }
        for i in 0..<100 {
            trie.set(["other\(i)"], value: "Other \(i)")
        }
        let subtrie = trie.traverse(path: "prefix")
        #expect(subtrie != nil)
        if let result = subtrie {
            #expect(!result.isEmpty)
            let keys = result.children.keys()
            #expect(keys.count >= 1000)
        }
        let otherSubtrie = trie.traverse(path: "other")
        #expect(otherSubtrie != nil)
        if let result = otherSubtrie {
            let keys = result.children.keys()
            #expect(keys.count >= 100)
        }
    }

    @Test func testTraverseStringPathEdgeCases() {
        var trie = ArrayTrie<String>()
        trie.set([" "], value: "Space")
        trie.set(["\t"], value: "Tab")
        trie.set(["\n"], value: "Newline")
        trie.set(["normal"], value: "Normal")
        let spaceSubtrie = trie.traverse(path: " ")
        #expect(spaceSubtrie != nil)
        let tabSubtrie = trie.traverse(path: "\t")
        #expect(tabSubtrie != nil)
        let newlineSubtrie = trie.traverse(path: "\n")
        #expect(newlineSubtrie != nil)
        #expect(spaceSubtrie?.get([""]) == "Space")
        #expect(tabSubtrie?.get([""]) == "Tab")
        #expect(newlineSubtrie?.get([""]) == "Newline")
    }

    @Test func testTraverseStringPathLongPrefix() {
        var trie = ArrayTrie<String>()
        let longPrefix = String(repeating: "a", count: 100)
        trie.set([longPrefix], value: "Long A's")
        trie.set([longPrefix + "b"], value: "Long A's + B")
        trie.set([longPrefix + "c"], value: "Long A's + C")
        trie.set(["different"], value: "Different")
        let subtrie = trie.traverse(path: longPrefix)
        #expect(subtrie != nil)
        if let result = subtrie {
            let keys = result.children.keys()
            #expect(keys.contains(""))
            #expect(keys.contains("b"))
            #expect(keys.contains("c"))
            #expect(!keys.contains("different"))
        }
    }

    // MARK: - String Path Traversal Values and Contents

    @Test func testTraverseStringPathGetValues() {
        var trie = ArrayTrie<String>()
        trie.set(["user"], value: "User Root")
        trie.set(["users"], value: "Users Plural")
        trie.set(["user_profile"], value: "User Profile")
        trie.set(["user_settings"], value: "User Settings")
        trie.set(["username"], value: "Username")
        trie.set(["admin"], value: "Admin")
        let userSubtrie = trie.traverse(path: "user")
        #expect(userSubtrie != nil)
        if let result = userSubtrie {
            #expect(result.get([""]) == "User Root")
            #expect(result.get(["s"]) == "Users Plural")
            #expect(result.get(["_profile"]) == "User Profile")
            #expect(result.get(["_settings"]) == "User Settings")
            #expect(result.get(["name"]) == "Username")
            #expect(result.get(["admin"]) == nil)
            #expect(result.get(["xyz"]) == nil)
        }
    }

    @Test func testTraverseStringPathVerifyContents() {
        var trie = ArrayTrie<String>()
        trie.set(["api", "v1", "users"], value: "V1 Users")
        trie.set(["api", "v2", "users"], value: "V2 Users")
        trie.set(["api", "v1", "posts"], value: "V1 Posts")
        trie.set(["app"], value: "Application")
        trie.set(["apple"], value: "Fruit")
        trie.set(["application"], value: "Full App")
        let appSubtrie = trie.traverse(path: "app")
        #expect(appSubtrie != nil)
        if let result = appSubtrie {
            let childKeys = result.children.keys()
            #expect(childKeys.contains(""))
            #expect(childKeys.contains("le"))
            #expect(childKeys.contains("lication"))
            #expect(result.get([""]) == "Application")
            #expect(result.get(["le"]) == "Fruit")
            #expect(result.get(["lication"]) == "Full App")
            #expect(result.get(["api", "v1", "users"]) == nil)
            #expect(!result.isEmpty)
        }
        let apiSubtrie = trie.traverse(path: "api")
        #expect(apiSubtrie != nil)
        if let result = apiSubtrie {
            let childKeys = result.children.keys()
            #expect(childKeys.contains(""))
            #expect(!result.isEmpty)
        }
    }

    @Test func testTraverseStringPathComplexValueRetrieval() {
        var trie = ArrayTrie<String>()
        trie.set(["test"], value: "Test Base")
        trie.set(["testing"], value: "Testing Activity")
        trie.set(["tester"], value: "Person Who Tests")
        trie.set(["test_case"], value: "Test Case")
        trie.set(["test_suite"], value: "Test Suite")
        trie.set(["template"], value: "Template")
        trie.set(["temporary"], value: "Temporary")
        trie.set(["ten"], value: "Number Ten")
        let testSubtrie = trie.traverse(path: "test")
        #expect(testSubtrie != nil)
        if let result = testSubtrie {
            #expect(result.get([""]) == "Test Base")
            #expect(result.get(["ing"]) == "Testing Activity")
            #expect(result.get(["er"]) == "Person Who Tests")
            #expect(result.get(["_case"]) == "Test Case")
            #expect(result.get(["_suite"]) == "Test Suite")
            #expect(result.get(["template"]) == nil)
            #expect(result.get(["temporary"]) == nil)
            #expect(result.get(["ten"]) == nil)
            let keys = result.children.keys()
            #expect(keys.contains(""))
            #expect(keys.contains("ing"))
            #expect(keys.contains("er"))
            #expect(keys.contains("_case"))
            #expect(keys.contains("_suite"))
            #expect(!keys.contains("template"))
        }
        let teSubtrie = trie.traverse(path: "te")
        #expect(teSubtrie != nil)
        if let result = teSubtrie {
            #expect(result.get(["st"]) == "Test Base")
            #expect(result.get(["sting"]) == "Testing Activity")
            #expect(result.get(["ster"]) == "Person Who Tests")
            #expect(result.get(["mplate"]) == "Template")
            #expect(result.get(["mporary"]) == "Temporary")
            #expect(result.get(["n"]) == "Number Ten")
            let keys = result.children.keys()
            #expect(keys.contains("st"))
            #expect(keys.contains("mplate"))
            #expect(keys.contains("n"))
        }
    }

    @Test func testTraverseStringPathOperationsOnResult() {
        var trie = ArrayTrie<String>()
        trie.set(["prefix_a"], value: "A")
        trie.set(["prefix_b"], value: "B")
        trie.set(["prefix_c"], value: "C")
        trie.set(["other"], value: "Other")
        let subtrie = trie.traverse(path: "prefix")
        #expect(subtrie != nil)
        if var result = subtrie {
            #expect(result.get(["_a"]) == "A")
            #expect(result.get(["_b"]) == "B")
            #expect(result.get(["_c"]) == "C")
            #expect(result.get(["other"]) == nil)
            result.set(["_d"], value: "D")
            #expect(result.get(["_d"]) == "D")
            #expect(trie.get(["prefix_d"]) == nil)
            #expect(trie.get(["prefix_a"]) == "A")
            let deletedResult = result.deleting(path: ["_a"])
            #expect(deletedResult.get(["_a"]) == nil)
            #expect(deletedResult.get(["_b"]) == "B")
            #expect(trie.get(["prefix_a"]) == "A")
            #expect(!result.isEmpty)
            let emptySubtrie = trie.traverse(path: "nonexistent")
            #expect(emptySubtrie == nil)
        }
    }

    @Test func testTraverseStringPathNestedTraversals() {
        var trie = ArrayTrie<String>()
        trie.set(["prefix_group1_item1"], value: "Group1 Item1")
        trie.set(["prefix_group1_item2"], value: "Group1 Item2")
        trie.set(["prefix_group2_item1"], value: "Group2 Item1")
        trie.set(["prefix_other"], value: "Other")
        trie.set(["different"], value: "Different")
        let prefixTrie = trie.traverse(path: "prefix")
        #expect(prefixTrie != nil)
        if let pTrie = prefixTrie {
            #expect(pTrie.get(["_group1_item1"]) == "Group1 Item1")
            #expect(pTrie.get(["_group1_item2"]) == "Group1 Item2")
            #expect(pTrie.get(["_group2_item1"]) == "Group2 Item1")
            #expect(pTrie.get(["_other"]) == "Other")
            #expect(pTrie.get(["different"]) == nil)
            let group1Trie = pTrie.traverse(path: "_group1")
            #expect(group1Trie != nil)
            if let g1Trie = group1Trie {
                #expect(g1Trie.get(["_item1"]) == "Group1 Item1")
                #expect(g1Trie.get(["_item2"]) == "Group1 Item2")
                #expect(g1Trie.get(["_group2_item1"]) == nil)
                #expect(g1Trie.get(["_other"]) == nil)
                let itemTrie = g1Trie.traverse(path: "_item")
                #expect(itemTrie != nil)
                if let iTrie = itemTrie {
                    #expect(iTrie.get(["1"]) == "Group1 Item1")
                    #expect(iTrie.get(["2"]) == "Group1 Item2")
                }
            }
            let group2Trie = pTrie.traverse(path: "_group2")
            #expect(group2Trie != nil)
            if let g2Trie = group2Trie {
                #expect(g2Trie.get(["_item1"]) == "Group2 Item1")
                #expect(g2Trie.get(["_group1_item1"]) == nil)
            }
        }
    }

    @Test func testTraverseStringPathWithDifferentValueTypes() {
        var intTrie = ArrayTrie<Int>()
        var arrayTrie = ArrayTrie<[String]>()
        intTrie.set(["count_1"], value: 1)
        intTrie.set(["count_10"], value: 10)
        intTrie.set(["count_100"], value: 100)
        intTrie.set(["total"], value: 111)
        let countTrie = intTrie.traverse(path: "count")
        #expect(countTrie != nil)
        if let result = countTrie {
            #expect(result.get(["_1"]) == 1)
            #expect(result.get(["_10"]) == 10)
            #expect(result.get(["_100"]) == 100)
            #expect(result.get(["total"]) == nil)
            let sum = (result.get(["_1"]) ?? 0) + (result.get(["_10"]) ?? 0) + (result.get(["_100"]) ?? 0)
            #expect(sum == 111)
        }
        arrayTrie.set(["tags_red"], value: ["red", "color", "primary"])
        arrayTrie.set(["tags_blue"], value: ["blue", "color", "primary"])
        arrayTrie.set(["tags_green"], value: ["green", "color", "secondary"])
        arrayTrie.set(["categories"], value: ["misc"])
        let tagsTrie = arrayTrie.traverse(path: "tags")
        #expect(tagsTrie != nil)
        if let result = tagsTrie {
            #expect(result.get(["_red"]) == ["red", "color", "primary"])
            #expect(result.get(["_blue"]) == ["blue", "color", "primary"])
            #expect(result.get(["_green"]) == ["green", "color", "secondary"])
            #expect(result.get(["categories"]) == nil)
            let redTags = result.get(["_red"]) ?? []
            #expect(redTags.count == 3)
            #expect(redTags.contains("red"))
            #expect(redTags.contains("color"))
        }
    }

    @Test func testTraverseStringPathEmptyAndExactMatches() {
        var trie = ArrayTrie<String>()
        trie.set([""], value: "Empty Root")
        trie.set(["search"], value: "Search Exact")
        trie.set(["search_query"], value: "Search Query")
        trie.set(["search_results"], value: "Search Results")
        let emptyTraversal = trie.traverse(path: "")
        #expect(emptyTraversal != nil)
        if let result = emptyTraversal {
            #expect(result.get([""]) == "Empty Root")
            #expect(result.get(["search"]) == "Search Exact")
            #expect(result.get(["search_query"]) == "Search Query")
            #expect(result.get(["search_results"]) == "Search Results")
        }
        let searchTraversal = trie.traverse(path: "search")
        #expect(searchTraversal != nil)
        if let result = searchTraversal {
            #expect(result.get([""]) == "Search Exact")
            #expect(result.get(["_query"]) == "Search Query")
            #expect(result.get(["_results"]) == "Search Results")
            #expect(result.get(["empty"]) == nil)
            let keys = result.children.keys()
            #expect(keys.contains(""))
            #expect(keys.contains("_query"))
            #expect(keys.contains("_results"))
            #expect(keys.count == 3)
        }
    }

    @Test func testTraverseStringPathStructuralIntegrity() {
        var trie = ArrayTrie<String>()
        trie.set(["a"], value: "A")
        trie.set(["ab"], value: "AB")
        trie.set(["abc"], value: "ABC")
        trie.set(["abcd"], value: "ABCD")
        trie.set(["ab_test"], value: "AB Test")
        trie.set(["ac"], value: "AC")
        trie.set(["b"], value: "B")
        let aTraversal = trie.traverse(path: "a")
        #expect(aTraversal != nil)
        if let aResult = aTraversal {
            #expect(aResult.get([""]) == "A")
            #expect(aResult.get(["b"]) == "AB")
            #expect(aResult.get(["bc"]) == "ABC")
            #expect(aResult.get(["bcd"]) == "ABCD")
            #expect(aResult.get(["b_test"]) == "AB Test")
            #expect(aResult.get(["c"]) == "AC")
            #expect(aResult.get(["B"]) == nil)
            let keys = aResult.children.keys()
            #expect(keys.contains(""))
            #expect(keys.contains("b"))
            #expect(keys.contains("c"))
            #expect(!keys.contains("B"))
            let abTraversal = aResult.traverse(path: "b")
            #expect(abTraversal != nil)
            if let abResult = abTraversal {
                #expect(abResult.get([""]) == "AB")
                #expect(abResult.get(["c"]) == "ABC")
                #expect(abResult.get(["cd"]) == "ABCD")
                #expect(abResult.get(["_test"]) == "AB Test")
                #expect(abResult.get(["c"]) == "ABC")
                #expect(abResult.get(["AC"]) == nil)
            }
        }
    }

    @Test func testTraverseStringPathMemoryAndReferences() {
        var trie = ArrayTrie<String>()
        let largeString = String(repeating: "data", count: 1000)
        trie.set(["large_data_1"], value: largeString + "_1")
        trie.set(["large_data_2"], value: largeString + "_2")
        trie.set(["small"], value: "small")
        let largeTraversal = trie.traverse(path: "large")
        #expect(largeTraversal != nil)
        if let result = largeTraversal {
            #expect(result.get(["_data_1"]) == largeString + "_1")
            #expect(result.get(["_data_2"]) == largeString + "_2")
            #expect(result.get(["small"]) == nil)
            var mutableResult = result
            mutableResult.set(["_data_3"], value: largeString + "_3")
            #expect(mutableResult.get(["_data_3"]) == largeString + "_3")
            #expect(trie.get(["large_data_3"]) == nil)
            #expect(trie.get(["large_data_1"]) == largeString + "_1")
            #expect(trie.get(["small"]) == "small")
        }
    }

    @Test func testTraverseStringPathCompleteValueValidation() {
        var trie = ArrayTrie<String>()
        let testData = [
            ("user", "User"),
            ("user_admin", "User Admin"),
            ("user_guest", "User Guest"),
            ("users", "Multiple Users"),
            ("username", "Username Field"),
            ("utility", "Utility Function"),
            ("utils", "Utilities"),
            ("completely_different", "Different")
        ]
        for (path, value) in testData {
            trie.set([path], value: value)
        }
        let userTraversal = trie.traverse(path: "user")
        #expect(userTraversal != nil)
        if let result = userTraversal {
            #expect(result.get([""]) == "User")
            #expect(result.get(["_admin"]) == "User Admin")
            #expect(result.get(["_guest"]) == "User Guest")
            #expect(result.get(["s"]) == "Multiple Users")
            #expect(result.get(["name"]) == "Username Field")
            #expect(result.get(["utility"]) == nil)
            #expect(result.get(["utils"]) == nil)
            #expect(result.get(["completely_different"]) == nil)
            let allKeys = result.children.keys()
            let expectedKeys = ["", "_admin", "_guest", "s", "name"]
            #expect(allKeys.count == expectedKeys.count)
            for key in expectedKeys {
                #expect(allKeys.contains(key), "Expected key '\(key)' not found")
            }
            let userAdminTraversal = result.traverse(path: "_")
            #expect(userAdminTraversal != nil)
            if let adminResult = userAdminTraversal {
                #expect(adminResult.get(["admin"]) == "User Admin")
                #expect(adminResult.get(["guest"]) == "User Guest")
                #expect(adminResult.get(["s"]) == nil)
            }
        }
        let uTraversal = trie.traverse(path: "u")
        #expect(uTraversal != nil)
        if let result = uTraversal {
            #expect(result.get(["ser"]) == "User")
            #expect(result.get(["tility"]) == "Utility Function")
            #expect(result.get(["tils"]) == "Utilities")
            #expect(result.get(["sers"]) == "Multiple Users")
            #expect(result.get(["completely_different"]) == nil)
        }
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
