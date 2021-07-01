import UIKit

struct MenuItem: Hashable {

    enum Category: CaseIterable, CustomStringConvertible {
        case version
        case developers
    }
    
    private let identifier = UUID()
    let text: String
    let title: String
    let category: Category
    
}

extension MenuItem.Category {
    
    var description: String {
        switch self {
        case .version: return "앱 정보 📱"
        case .developers: return "개미들 🐜"
        }
    }
    
    var items: [MenuItem] {
        switch self {
        case .version:
            return [
                MenuItem(text: "Version", title: "\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? "")", category: self),
                MenuItem(text: "iOS", title: "\(Bundle.main.infoDictionary?["MinimumOSVersion"] ?? "")", category: self)
            ]
        case .developers:
            return [
                MenuItem(text: "🐸", title: "개굴", category: self),
                MenuItem(text: "🐻", title: "태웡", category: self)
            ]
        }
    }
    
}

