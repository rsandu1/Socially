//
//  MainView.swift
//  Socially
//
//  Created by Robert Sandu on 5/12/23.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        TabView{
            PostsView()
                .tabItem{
                    Image(systemName: "rectangle.portrait.on.rectangle.portrait.angled")
                    Text("Posts")
                }
            ProfileView()
                .tabItem{
                    Image(systemName: "gear")
                    Text("Profile")
                }
        }
        .tint(.black)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
