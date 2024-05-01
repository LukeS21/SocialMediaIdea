//
//  SocialMediaIdeaApp.swift
//  SocialMediaIdea
//
//  Created by Luke Sheakley on 5/1/24.
//

import SwiftUI
import Firebase

@main
struct SocialMediaIdeaApp: App {
    init(){
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
