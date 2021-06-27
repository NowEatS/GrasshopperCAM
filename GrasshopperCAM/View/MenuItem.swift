import UIKit

struct MenuItem: Hashable {

    enum Category: CaseIterable, CustomStringConvertible {
        case imageSave
        case alertSave
        case developer
    }
    
    private let identifier = UUID()
    let text: String
    let title: String
    let category: Category
    
}

extension MenuItem.Category {
    
    var description: String {
        switch self {
        case .imageSave: return "이미지 저장 on / off"
        case .alertSave: return "저장 알림 on / off"
        case .developer: return "개미들"
        }
    }
    
    var items: [MenuItem] {
        switch self {
        case .developer:
            return [
                MenuItem(text: "🐸", title: "개굴", category: self),
                MenuItem(text: "🐻", title: "태웡", category: self)
            ]
        default:
            return []
        }
    }
    
}

