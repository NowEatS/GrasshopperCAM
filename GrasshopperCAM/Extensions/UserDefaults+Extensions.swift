//
//  UserDefaults+Extensions.swift
//  GrasshopperCAM
//
//  Created by TaeWon Seo on 2021/06/24.
//

import Foundation

extension UserDefaults {
    static var shared: UserDefaults {
        let appGroupID = "group.com.noweat.grasshopperCam"
        return UserDefaults(suiteName: appGroupID)!
    }
}
