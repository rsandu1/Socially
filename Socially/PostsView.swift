//
//  PostsView.swift
//  Socially
//
//  Created by Robert Sandu on 5/12/23.
//

import SwiftUI

struct PostsView: View {
    @State private var recentPosts: [Post] = []
    @State private var createNewPost: Bool = false
    var body: some View {
        NavigationStack{
            ReusablePostsView(posts: $recentPosts)
                .hAlign(.center).vAlign(.center)
                .overlay(alignment: .bottom) {
                    Button{
                        createNewPost.toggle()
                    } label: {
                        Image(systemName: "plus")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(13)
                            .background(.black, in: Circle())
                    }
                }
                .toolbar(content: {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink {
                            SearchUserView()
                        }label: {
                            Image(systemName: "magnifyingglass")
                                .tint(.black)
                                .scaleEffect(0.9)
                        }
                    }
                })
                .navigationTitle("Posts")
        }
        .fullScreenCover(isPresented: $createNewPost) {
                CreateNewPost { post in
                    recentPosts.insert(post, at:0)
                }
            }
    }
}

struct PostsView_Previews: PreviewProvider {
    static var previews: some View {
        PostsView()
    }
}
