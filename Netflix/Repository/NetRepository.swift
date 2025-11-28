protocol NetRepository: Sendable {
    func fetchNets() async throws -> [Net]
    func saveNet(_ net: Net) async throws
    func deleteNet(_ id: String) async throws
}

