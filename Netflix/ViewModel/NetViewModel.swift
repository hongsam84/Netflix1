import SwiftUI

@MainActor
@Observable
final class NetViewModel {
    private let repository: NetRepository
            
    init(repository: NetRepository = SupabaseNetRepository()) {
        self.repository = repository
    }
    
    private var _nets: [Net] = []
    var nets: [Net] { _nets }
    
    // ⭐ 타입별 필터링
    var movies: [Net] {
        _nets.filter { $0.type.lowercased() == "movie" }
    }
    
    var dramas: [Net] {
        _nets.filter { $0.type.lowercased() == "drama" }
    }
    
    var path = NavigationPath()
    
    func loadNetlists() async {
        _nets = try! await repository.fetchNets()
    }
    
    func addNet(_ net: Net) async {
        do {
            try await repository.saveNet(net)
            _nets.append(net)
        }
        catch {
            debugPrint("에러 발생: \(error)")
        }
    }
    
    func deleteNet(_ net: Net) async {
        do {
            try await repository.deleteNet(net.title)
            if let index = _nets.firstIndex(where: { $0.title == net.title }) {
                _nets.remove(at: index)
            }
        }
        catch {
            debugPrint("에러 발생: \(error)")
        }
    }
}
