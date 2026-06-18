import TrieDictionary

private enum PrefixComparison {
    case equal
    case firstIsPrefix
    case secondIsPrefix
    case divergent
}

private func compareArrayPrefixes(_ a: [String], _ b: [String]) -> PrefixComparison {
    let sliceA = ArraySlice(a)
    let sliceB = ArraySlice(b)
    let commonPrefix = sliceA.longestCommonPrefix(sliceB)

    if commonPrefix.count == a.count && commonPrefix.count == b.count {
        return .equal
    } else if commonPrefix.count == a.count {
        return .firstIsPrefix
    } else if commonPrefix.count == b.count {
        return .secondIsPrefix
    } else {
        return .divergent
    }
}

public struct ArrayTrie<Value> {
    typealias Node = ArrayTrieNode<Value>
    typealias ChildMap = TrieDictionary<ArrayTrieNode<Value>>

    var rootValue: Value?
    var children: ChildMap

    init(children: ChildMap) {
        self.rootValue = nil
        self.children = children
    }

    init(rootValue: Value?, children: ChildMap) {
        self.rootValue = rootValue
        self.children = children
    }

    public init() {
        self.rootValue = nil
        self.children = [:]
    }

    public var isEmpty: Bool {
        children.count == 0 && rootValue == nil
    }

    public func childValues() -> [Value] {
        children.values().filter { $0.prefix.isEmpty && $0.value != nil }.map { $0.value! }
    }

    mutating func updateChildren(_ children: ChildMap) {
        self.children = children
    }

    mutating func updateChild(_ key: String, _ node: Node?) {
        children[key] = node
    }

    func with(child: String, node: Node?) -> Self {
        var newChildren = children
        newChildren[child] = node
        return Self(rootValue: rootValue, children: newChildren)
    }

    func with(rootValue: Value?) -> Self {
        Self(rootValue: rootValue, children: children)
    }

    public func traverse(_ path: [String]) -> Self? {
        guard let firstKey = path.first else { return self }
        guard let childNode = children[firstKey], let (subtrie, valueAtPath) = childNode.traverse(ArraySlice(path).dropFirst()) else { return nil }
        return Self(rootValue: valueAtPath, children: subtrie)
    }

    public func get(_ path: [String]) -> Value? {
        guard let firstKey = path.first else { return rootValue }
        guard let root = children[firstKey] else { return nil }
        return root.get(ArraySlice(path.dropFirst()))
    }

    public mutating func set(_ path: [String], value: Value) {
        guard let firstKey = path.first else {
            rootValue = value
            return
        }
        if children[firstKey] == nil {
            updateChild(firstKey, Node(prefix: Array(path.dropFirst()), value: value, children: [:]))
            return
        }
        children[firstKey]!.set(keys: ArraySlice(path).dropFirst(), to: value)
    }

    public func valuesAlongPath(_ path: String) -> [(Self, Value)] {
        children.getValuesAlongPath(path)
            .filter { $0.prefix.isEmpty }
            .filter { $0.value != nil }
            .map { (Self(rootValue: nil, children: $0.children), $0.value!) }
    }

    public func traverseChild(_ char: Character) -> Self? {
        guard let newChildren = children.traverseChild(char) else { return nil }
        return Self(rootValue: rootValue, children: newChildren)
    }

    public func childCharacters() -> [Character] {
        children.getAllChildCharacters()
    }

    public func childKeys() -> [String] {
        children.keys()
    }

    public func childPrefix(for char: Character) -> String? {
        children.getChildPrefix(char)
    }

    public func valuesExcludingPrefix(_ key: String) -> [Value] {
        if key.isEmpty { return [] }
        let firstChar = key.first!
        var result = [Value]()
        let otherChars = childCharacters().filter { $0 != firstChar }
        for char in otherChars {
            result.append(contentsOf: traverseChild(char)!.allValues())
        }
        guard let prefix = childPrefix(for: firstChar) else { return result }
        guard let traversed = traverse(path: prefix) else { return result }
        traversed.collectValuesExcludingPrefix(ArraySlice(key).dropFirst(prefix.count), into: &result)
        return result
    }

    private func collectValuesExcludingPrefix(_ key: ArraySlice<Character>, into values: inout [Value]) {
        if key.isEmpty { return }
        if let value = rootValue {
            values.append(value)
        }
        let firstChar = key.first!
        let otherChars = childCharacters().filter { $0 != firstChar }
        for char in otherChars {
            values.append(contentsOf: traverseChild(char)!.allValues())
        }
        guard let prefix = childPrefix(for: firstChar) else { return }
        guard let traversed = traverse(path: prefix) else { return }
        traversed.collectValuesExcludingPrefix(key.dropFirst(prefix.count), into: &values)
    }

    public func deleting(path: [String]) -> Self {
        guard let firstKey = path.first else { return with(rootValue: nil) }
        guard let childNode = children[firstKey] else { return self }
        return with(child: firstKey, node: childNode.deleting(ArraySlice(path).dropFirst()))
    }

    public func traverse(path: String) -> Self? {
        let traversed = children.traverse(path)
        return traversed.isEmpty ? nil : Self(rootValue: get([path]), children: traversed)
    }

    public func merging(with other: ArrayTrie<Value>, mergeRule: (Value, Value) -> Value) -> ArrayTrie<Value> {
        let mergedChildren = children.merge(other: other.children) { selfChild, otherChild in
            selfChild.merging(with: otherChild, mergeRule: mergeRule)
        }

        let mergedRootValue: Value?
        if let selfRootValue = self.rootValue, let otherRootValue = other.rootValue {
            mergedRootValue = mergeRule(selfRootValue, otherRootValue)
        } else {
            mergedRootValue = self.rootValue ?? other.rootValue
        }

        return ArrayTrie(rootValue: mergedRootValue, children: mergedChildren)
    }

    public static func mergeAll(tries: [Self], mergeRule: (Value, Value) -> Value) -> ArrayTrie<Value> {
        tries.reduce(Self()) { partialResult, next in
            partialResult.merging(with: next, mergeRule: mergeRule)
        }
    }

    public func allValues() -> [Value] {
        var values = [Value]()
        collectAllValues(into: &values)
        return values
    }

    private func collectAllValues(into values: inout [Value]) {
        if let rootValue = rootValue {
            values.append(rootValue)
        }
        for child in children.values() {
            child.collectAllValues(into: &values)
        }
    }
}

final class ArrayTrieNode<Value> {
    typealias ChildMap = TrieDictionary<ArrayTrieNode<Value>>

    var prefix: [String]
    var value: Value?
    var children: ChildMap

    init(prefix: [String], value: Value?, children: ChildMap) {
        self.prefix = prefix
        self.value = value
        self.children = children
    }

    func getChild(_ key: String) -> ArrayTrieNode<Value>? {
        children[key]
    }

    func updatePrefix(_ prefix: [String]) {
        self.prefix = prefix
    }

    func updateValue(_ value: Value?) {
        self.value = value
    }

    func updateChildren(_ children: ChildMap) {
        self.children = children
    }

    func updateChild(_ key: String, _ node: ArrayTrieNode<Value>?) {
        children[key] = node
    }

    func with(prefix: [String]?, children: ChildMap?) -> ArrayTrieNode<Value> {
        ArrayTrieNode(prefix: prefix ?? self.prefix, value: value, children: children ?? self.children)
    }

    func with(value: Value?) -> ArrayTrieNode<Value> {
        ArrayTrieNode(prefix: prefix, value: value, children: children)
    }

    func with(child: String, node: ArrayTrieNode<Value>?) -> ArrayTrieNode<Value> {
        var newChildren = children
        newChildren[child] = node
        return with(prefix: nil, children: newChildren)
    }

    func get(_ keys: ArraySlice<String>) -> Value? {
        if !keys.starts(with: prefix) { return nil }
        let suffix = keys.dropFirst(prefix.count)
        guard let firstValue = suffix.first else { return value }
        guard let childNode = getChild(firstValue) else { return nil }
        return childNode.get(suffix.dropFirst())
    }

    func set(keys: ArraySlice<String>, to value: Value) {
        if keys.count >= prefix.count && keys.starts(with: prefix) {
            let suffix = keys.dropFirst(prefix.count)

            guard let firstSuffixValue = suffix.first else {
                updateValue(value)
                return
            }

            if children[firstSuffixValue] == nil {
                updateChild(firstSuffixValue, Self(prefix: Array(suffix.dropFirst()), value: value, children: [:]))
                return
            }

            children[firstSuffixValue]!.set(keys: suffix.dropFirst(), to: value)
            return
        }

        if prefix.count > keys.count && prefix.starts(with: keys) {
            let suffix = prefix.dropFirst(keys.count)
            var newChild: ChildMap = [:]
            newChild[suffix.first!] = with(prefix: Array(suffix.dropFirst()), children: children)
            updatePrefix(Array(keys))
            updateValue(value)
            updateChildren(newChild)
            return
        }

        let prefixSlice = ArraySlice(prefix)
        let parentPrefix = keys.longestCommonPrefix(prefixSlice)
        let newPrefix = keys.dropFirst(parentPrefix.count)
        let oldPrefix = prefixSlice.dropFirst(parentPrefix.count)

        let newNode = Self(prefix: Array(newPrefix.dropFirst()), value: value, children: [:])
        let oldNode = with(prefix: Array(oldPrefix.dropFirst()), children: children)
        var newChildren: ChildMap = [:]
        newChildren[newPrefix.first!] = newNode
        newChildren[oldPrefix.first!] = oldNode

        updatePrefix(parentPrefix)
        updateValue(nil as Value?)
        updateChildren(newChildren)
    }

    func traverse(_ path: ArraySlice<String>) -> (children: ChildMap, value: Value?)? {
        if prefix.starts(with: path) {
            let suffix = prefix.dropFirst(path.count)
            guard let firstSuffix = suffix.first else { return (children, value) }
            var newChild: ChildMap = [:]
            newChild[firstSuffix] = Self(prefix: Array(suffix.dropFirst()), value: value, children: children)
            return (newChild, nil)
        }

        if !path.starts(with: prefix) { return nil }

        let suffix = path.dropFirst(prefix.count)
        guard let firstSuffix = suffix.first else { return (children, value) }
        guard let child = children[firstSuffix] else { return nil }
        return child.traverse(suffix.dropFirst())
    }

    func merging(with other: ArrayTrieNode<Value>, mergeRule: (Value, Value) -> Value) -> ArrayTrieNode<Value> {
        let comparison = compareArrayPrefixes(self.prefix, other.prefix)

        switch comparison {
        case .equal:
            let mergedValue: Value?
            if let selfValue = self.value, let otherValue = other.value {
                mergedValue = mergeRule(selfValue, otherValue)
            } else {
                mergedValue = self.value ?? other.value
            }

            let mergedChildren = self.children.merge(other: other.children) { selfChildren, otherChildren in
                selfChildren.merging(with: otherChildren, mergeRule: mergeRule)
            }

            return ArrayTrieNode(prefix: self.prefix, value: mergedValue, children: mergedChildren)

        case .firstIsPrefix:
            let otherSuffix = Array(other.prefix.dropFirst(self.prefix.count))
            let otherChildKey = otherSuffix.first!
            let otherChildNode = ArrayTrieNode(prefix: Array(otherSuffix.dropFirst()), value: other.value, children: other.children)

            let mergedChildren: ChildMap
            if let existingChild = self.children[otherChildKey] {
                let mergedChild = existingChild.merging(with: otherChildNode, mergeRule: mergeRule)
                var result = self.children
                result[otherChildKey] = mergedChild
                mergedChildren = result
            } else {
                var result = self.children
                result[otherChildKey] = otherChildNode
                mergedChildren = result
            }

            return ArrayTrieNode(prefix: self.prefix, value: self.value, children: mergedChildren)

        case .secondIsPrefix:
            let selfSuffix = Array(self.prefix.dropFirst(other.prefix.count))
            let selfChildKey = selfSuffix.first!
            let selfChildNode = ArrayTrieNode(prefix: Array(selfSuffix.dropFirst()), value: self.value, children: self.children)

            let mergedChildren: ChildMap
            if let existingChild = other.children[selfChildKey] {
                let mergedChild = existingChild.merging(with: selfChildNode, mergeRule: mergeRule)
                var result = other.children
                result[selfChildKey] = mergedChild
                mergedChildren = result
            } else {
                var result = other.children
                result[selfChildKey] = selfChildNode
                mergedChildren = result
            }

            return ArrayTrieNode(prefix: other.prefix, value: other.value, children: mergedChildren)

        case .divergent:
            let commonPrefix = ArraySlice(self.prefix).longestCommonPrefix(ArraySlice(other.prefix))
            let selfSuffix = Array(self.prefix.dropFirst(commonPrefix.count))
            let otherSuffix = Array(other.prefix.dropFirst(commonPrefix.count))

            let selfChildKey = selfSuffix.first!
            let otherChildKey = otherSuffix.first!

            let selfChildNode = ArrayTrieNode(prefix: Array(selfSuffix.dropFirst()), value: self.value, children: self.children)
            let otherChildNode = ArrayTrieNode(prefix: Array(otherSuffix.dropFirst()), value: other.value, children: other.children)

            var newChildren: ChildMap = [:]
            newChildren[selfChildKey] = selfChildNode
            newChildren[otherChildKey] = otherChildNode

            return ArrayTrieNode(prefix: commonPrefix, value: nil, children: newChildren)
        }
    }

    func deleting() -> ArrayTrieNode<Value>? {
        if children.isEmpty { return nil }
        if children.count > 1 { return with(value: nil as Value?) }
        let onlyChild = children.values().first!
        return Self(prefix: prefix + onlyChild.prefix, value: onlyChild.value, children: onlyChild.children)
    }

    func deleting(_ path: ArraySlice<String>) -> ArrayTrieNode<Value>? {
        if !path.starts(with: prefix) { return self }
        let suffix = path.dropFirst(prefix.count)
        guard let firstValue = suffix.first else { return deleting() }
        guard let child = getChild(firstValue) else { return self }

        guard let childResult = child.deleting(suffix.dropFirst()) else {
            if value != nil || children.count > 2 {
                return with(child: firstValue, node: nil)
            }
            let remainingChildKey = children.keys().filter { $0 != firstValue }.first!
            let remainingChild = children[remainingChildKey]!
            return Self(prefix: prefix + [remainingChildKey] + remainingChild.prefix, value: remainingChild.value, children: remainingChild.children)
        }

        return with(child: firstValue, node: childResult)
    }

    func allValues() -> [Value] {
        var values = [Value]()
        collectAllValues(into: &values)
        return values
    }

    func collectAllValues(into values: inout [Value]) {
        if let value = value {
            values.append(value)
        }
        for child in children.values() {
            child.collectAllValues(into: &values)
        }
    }
}

extension ArraySlice where Element: Equatable {
    public func longestCommonPrefix(_ other: Self) -> Array<Element> {
        zip(self, other).prefix { $0 == $1 }.map(\.0)
    }
}
