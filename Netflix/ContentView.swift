import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            MovieView()
                .tabItem {
                    Image(systemName: "rectangle.stack.fill")
                    Text("Movie")
                }
            DramaView()
                .tabItem {
                    Image(systemName: "film")
                    Text("Drama")
                }
        }
    }
}

struct MovieView: View {
    @State private var viewModel = NetViewModel()
    @State private var showingAddSheet = false
    
    var body: some View {
        NavigationStack(path: $viewModel.path) {
            MovieListView(viewModel: viewModel)
            .navigationDestination(for: Net.self) { net in
                MovieDetailView(Net: net)
            }
            .navigationTitle("영화")
            .task {
                await viewModel.loadNetlists()
            }
            .refreshable {
                await viewModel.loadNetlists()
            }
            .toolbar {
                Button {
                    showingAddSheet.toggle()
                } label: {
                    Image(systemName: "plus.circle.fill")
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                NetAddView(viewModel: viewModel)
            }
        }
    }
}

struct MovieListView: View {
    let viewModel: NetViewModel
    
    func deleteNet(offsets: IndexSet) {
        Task {
            for index in offsets {
                let net = viewModel.nets[index]
                await viewModel.deleteNet(net)
            }
        }
    }
    
    var body: some View {
        List {
            ForEach(viewModel.movies) { net in
                NavigationLink(value: net) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(net.type)
                                .font(.headline)
                            Text(net.title)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .onDelete(perform: deleteNet)
        }
    }
}

struct MovieDetailView: View {
    let Net: Net

    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 15) {
                
                AsyncImage(url: URL(string: Net.image_url)) { image in
                    image
                        .resizable()
                        .scaledToFit()
                } placeholder: {
                    ProgressView()
                }
                .frame(height: 250)
                .cornerRadius(12)
                .padding(.bottom, 10)

                
                Text(String(Net.rating))
                    .font(.title)
                    .foregroundColor(.yellow)
                    .padding(.bottom, 10)
                
                Text(Net.story)
                    .font(.body)
                    .multilineTextAlignment(.leading)
            }
            .padding()
        }
        .navigationTitle(Net.title)
        .navigationBarTitleDisplayMode(.large)
    }
}

struct DramaView: View {
    @State private var viewModel = NetViewModel()
    @State private var showingAddSheet = false
    
    var body: some View {
        NavigationStack(path: $viewModel.path) {
            DramaListView(viewModel: viewModel)
            .navigationDestination(for: Net.self) { net in
                MovieDetailView(Net: net)
            }
            .navigationTitle("드라마")
            .task {
                await viewModel.loadNetlists()
            }
            .refreshable {
                await viewModel.loadNetlists()
            }
            .toolbar {
                Button {
                    showingAddSheet.toggle()
                } label: {
                    Image(systemName: "plus.circle.fill")
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                NetAddView(viewModel: viewModel)
            }
        }
    }
}

struct DramaListView: View {
    let viewModel: NetViewModel
    
    func deleteNet(offsets: IndexSet) {
        Task {
            for index in offsets {
                let net = viewModel.nets[index]
                await viewModel.deleteNet(net)
            }
        }
    }
    
    var body: some View {
        List {
            ForEach(viewModel.dramas) { net in
                NavigationLink(value: net) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(net.type)
                                .font(.headline)
                            Text(net.title)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .onDelete(perform: deleteNet)
        }
    }
}

struct DramaDetailView: View {
    let Net: Net

    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 15) {
                
                AsyncImage(url: URL(string: Net.image_url)) { image in
                    image
                        .resizable()
                        .scaledToFit()
                } placeholder: {
                    ProgressView()
                }
                .frame(height: 250)
                .cornerRadius(12)
                .padding(.bottom, 10)

                
                Text(String(Net.rating))
                    .font(.title)
                    .foregroundColor(.yellow)
                    .padding(.bottom, 10)
                
                Text(Net.story)
                    .font(.body)
                    .multilineTextAlignment(.leading)
            }
            .padding()
        }
        .navigationTitle(Net.title)
        .navigationBarTitleDisplayMode(.large)
    }
}

struct NetAddView: View {
    let viewModel: NetViewModel
    
    @Environment(\.dismiss) var dismiss
    
    @State var type = ""
    @State var title = ""
    @State var story = ""
    @State var rating = 3
    @State var image_url = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("노래 정보 *")) {
                    TextField("유형", text: $type)
                    TextField("제목", text: $title)
                }
                
                Section(header: Text("선호도 *")) {
                    Picker("별점", selection: $rating) {
                        ForEach(1...5, id: \.self) { score in
                            Text("\(score)점")
                                .tag(score)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section(header: Text("내용")) {
                    TextEditor(text: $story)
                        .frame(height: 150)
                }
                
                Section(header: Text("이미지 URL")) {
                    TextEditor(text: $image_url)
                        .frame(height: 150)
                }
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("추가") {
                        Task {
                            await viewModel.addNet(
                                Net( id: nil, type: type, title: title, story: story, rating: rating, image_url: image_url)
                            )
                            dismiss()
                        }
                    }
                    .disabled(title.isEmpty || type.isEmpty)
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
