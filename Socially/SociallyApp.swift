//
//  SociallyApp.swift
//  Socially
//
//  Created by Robert Sandu on 5/12/23.
//

import SwiftUI
import Firebase

@main
struct SociallyApp: App {
    init(){
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
