import SwiftUI
import identiaFlow
import Combine
import Network

@main
struct FlowDemoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class NetworkMonitor: ObservableObject {
    private var pathMonitor: NWPathMonitor
    private let queue = DispatchQueue.global(qos: .background)
    @Published var isConnected: Bool = false

    init() {
        pathMonitor = NWPathMonitor()
        pathMonitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                self.isConnected = path.status == .satisfied
            }
        }
    }
    
    func startMonitoring() {
        pathMonitor.start(queue: queue)
    }
    
    func stopMonitoring() {
        pathMonitor.cancel()
    }
}


struct ContentView: View {
    @State private var showIdentiaFlow = false
    @StateObject private var networkMonitor = NetworkMonitor() // Monitor de red como un objeto de estado
    
    // Valores hardcoded para idSession, endPoint, y style
    @State private var idSession = ""
    @State private var endPoint = ""
    @State private var style = ""

    var body: some View {
        VStack {
            Button("Mostrar IdentiaFlow") {
                // Verifica la conectividad antes de establecer showIdentiaFlow a true
                if networkMonitor.isConnected {
                    self.showIdentiaFlow = true
                } else {
                    // Aquí puedes mostrar alguna alerta o mensaje indicando que no hay conexión a internet.
                    print("No hay conexión a Internet. Por favor, verifica tu conexión y vuelve a intentarlo.")
                }
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            
            if showIdentiaFlow {
                
                IdentiaFlowView(idSession: idSession, endPoint: endPoint, style: style) { jsonString in
                    // Manejar la respuesta obtenida de IdentiaFlowView
                    print("Respuesta de IdentiaFlow: \(jsonString)")
                    
                    // Resetear el indicador de mostrar IdentiaFlow
                    DispatchQueue.main.async {
                        self.showIdentiaFlow = false
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity) // Ajustar el tamaño
            }
        }
        .onAppear {
            networkMonitor.startMonitoring()
        }
        .onDisappear {
            networkMonitor.stopMonitoring()
        }
    }
}
