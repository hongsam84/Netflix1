import Foundation

final class SupabaseNetRepository: NetRepository {
    func fetchNets() async throws -> [Net] {
        let requestURL = URL(string: NetApiConfig.serverURL)!
        let (data, _) = try! await URLSession.shared.data(from: requestURL)
        let decoder = JSONDecoder()
        return try! decoder.decode([Net].self, from: data)
    }
    
    func saveNet(_ net: Net) async throws {
            let requestURL = URL(string: NetApiConfig.serverURL)!
            var request = URLRequest(url: requestURL)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONEncoder().encode(net)
            
            let (_, response) = try await URLSession.shared.data(for: request)
            //debugPrint(response)

            // Guard cluase (조건에 맞지 않으면 바로 return (여기서는 throw)) 사용
            guard let httpResponse = response
                    as? HTTPURLResponse,
                    httpResponse.statusCode == 201
            else {
                throw URLError(.badServerResponse)
            }
        }
    func deleteNet(_ title: String) async throws {
            // 주의: eq.value
            let urlString = "\(NetApiConfig.projectURL)/rest/v1/netflix?title=eq.\(title)&apikey=\(NetApiConfig.apiKey)"
            let requestURL = URL(string: urlString)!
            var request = URLRequest(url: requestURL)
            request.httpMethod = "DELETE"
            
            let (_, response) = try await URLSession.shared.data(for: request)
            //debugPrint(response)

            // Guard cluase (조건에 맞지 않으면 바로 return (여기서는 throw)) 사용
            guard let httpResponse = response
                    as? HTTPURLResponse,
                    httpResponse.statusCode == 204
            else {
                throw URLError(.badServerResponse)
            }
        }
}
