//
//  ReusableProfileContent.swift
//  Socially
//
//  Created by Robert Sandu on 5/12/23.
//

import SwiftUI
import SDWebImageSwiftUI

struct ReusableProfileContent: View {
    var user: User
    @State private var fetchedPosts: [Post] = []
    var body: some View {
        ScrollView(.vertical, showsIndicators: false){
            LazyVStack{
                HStack(spacing: 12){
                    Text("")
                    WebImage(url: user.userProfileURL).placeholder{
                        Image(systemName: "person.circle.fill")
                            .resizable()
                    }
                    .resizable()
                    .aspectRatio(contentMode:.fill)
                    .frame(width:100, height: 100)
                    .clipShape(Circle())
                    VStack(alignment: .leading, spacing: 6) {
                        Text(user.username)
                            .font(.title3)
                            .fontWeight(.semibold)
                        Text(user.userBio)
                            .font(.caption)
                            .foregroundColor(.black)
                            .lineLimit(3)
                        if let bioLink = URL(string: user.userBioLink){
                            Link(user.userBioLink, destination: bioLink)
                                .font(.callout)
                                .tint(.blue)
                                .lineLimit(1)
                        }
                    }
                    .hAlign(.leading)
                }
                HStack(spacing:8){
                    Text("")
                    Text("")
                    Text("Posts")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                        .hAlign(.leading)
                        .padding(.vertical, 15)
                }
                ReusablePostsView(basedOnUID: true, uid: user.userUID, posts: $fetchedPosts)
                
            }
        }
    }
}
