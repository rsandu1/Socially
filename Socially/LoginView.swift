//
//  LoginView.swift
//  Socially
//
//  Created by Robert Sandu on 5/12/23.
//


import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseStorage


struct LoginView: View {
    @State var emailID: String = ""
    @State var password: String = ""
    @State var createAccount: Bool = false
    @State var showError: Bool = false
    @State var errorMessage: String = ""
    @State var isLoading: Bool = false
    @AppStorage("log_status") var logStatus: Bool = false
    @AppStorage("user_profile_url") var profileURL: URL?
    @AppStorage("user_name") var userNameStored: String = ""
    @AppStorage("user_UID") var userUID: String = ""
    var body: some View {
        VStack(spacing: 10){
            Text("Sign In")
                .font(.largeTitle.bold())
            Text("Welcome Back")
                .font(.title3)
            VStack(spacing: 12){
                TextField("Email", text: $emailID)
                    .textContentType(.emailAddress)
                    .border(1, .black)
                SecureField("Password", text: $password)
                    .textContentType(.emailAddress)
                    .border(1, .black)
                Button("Reset password?", action: resetPassword)
                    .font(.callout)
                    .fontWeight(.medium)
                    .tint(.black)
                Button(action: loginUser){
                    Text("Sign in")
                        .foregroundColor(.white)
                        .hAlign(.center)
                        .fillView(.black)
                    
                }
                .padding(.top, 10)
            }
            HStack{
                Text("Don't have an account?")
                    .foregroundColor(.black)
                Button("Register Now"){
                    createAccount.toggle()
                }
                .fontWeight(.bold)
                .foregroundColor(.black)
            }
            .font(.callout)
            .vAlign(.bottom)
        }
        .vAlign(.top)
        .padding(15)
        .overlay(content: {
            LoadingView(show: $isLoading)
        })
        .fullScreenCover(isPresented: $createAccount){
            RegisterView()
        }
        .alert(errorMessage, isPresented: $showError, actions: {})
    }
    func loginUser(){
        isLoading = true
        closeKeyboard()
        Task{
            do{
               
                try await Auth.auth().signIn(withEmail: emailID, password: password)
                print("User Found")
                try await fetchUser()
            } catch {
                await setError(error)
            }
        }
    }
    func fetchUser()async throws{
        guard let userID = Auth.auth().currentUser?.uid else{return}
        let user = try await Firestore.firestore().collection("Users").document(userID).getDocument(as: User.self)
        await MainActor.run(body: {
            userUID = userID
            userNameStored = user.username
            profileURL = user.userProfileURL
            logStatus = true
        })
    }
    func resetPassword(){
        Task{
            do{
               
                try await Auth.auth().sendPasswordReset(withEmail: emailID)
                print("Link Sent")
            } catch {
                await setError(error)
            }
        }
    }
    func setError(_ error:Error) async{
        await MainActor.run(body: {
            errorMessage = error.localizedDescription
            showError.toggle()
            isLoading = false
        })
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
