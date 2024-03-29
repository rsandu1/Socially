//
//  RegisterView.swift
//  Socially
//
//  Created by Robert Sandu on 5/12/23.
//

import SwiftUI
import PhotosUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

struct RegisterView: View{
    @State var emailID: String = ""
    @State var password: String = ""
    @State var username: String = ""
    @State var userBio: String = ""
    @State var userBioLink: String = ""
    @State var userProfilePicData: Data?
    @Environment(\.dismiss) var dismiss
    @State var showImagePicker: Bool = false
    @State var photoItem: PhotosPickerItem?
    @State var showError:Bool = false
    @State var errorMessage:String = ""
    @State var isLoading: Bool = false
    @AppStorage("log_status") var logStatus: Bool = false
    @AppStorage("user_profile_url") var profileURL: URL?
    @AppStorage("user_name") var userNameStored: String = ""
    @AppStorage("user_UID") var userUID: String = ""
    var body: some View{
        VStack(spacing: 10){
            Text("Sign Up")
                .font(.largeTitle.bold())
            Text("See What is Going on Around You")
                .font(.title3)
            ViewThatFits {
                ScrollView(.vertical,showsIndicators: false){
                    HelperView()
                }
                HelperView()
            }
            HStack{
                Text("Already have an account?")
                    .foregroundColor(.black)
                Button("Login Now"){
                    dismiss()
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
        .photosPicker(isPresented: $showImagePicker, selection: $photoItem)
        .onChange(of: photoItem) { newValue in
            if let newValue{
                Task{
                    do{
                        guard let imageData = try await newValue.loadTransferable(type:Data.self) else {return}
                        await MainActor.run(body: {
                            userProfilePicData = imageData
                        })
                    } catch{
                        
                    }
                }
            }
        }
        .alert(errorMessage, isPresented: $showError, actions: {})
    }
    @ViewBuilder
    func HelperView()->some View{
        VStack(spacing: 12){
            ZStack{
                if let userProfilePicData, let image = UIImage(data: userProfilePicData){
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode:.fill)
                }else{
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }
            }
            .frame(width:85, height:85)
            .clipShape(Circle())
            .contentShape(Circle())
            .onTapGesture{
                showImagePicker.toggle()
            }
            .padding(.top, 25)
            
            TextField("Username", text: $username)
                .textContentType(.emailAddress)
                .border(1, .black)
            TextField("Email", text: $emailID)
                .textContentType(.emailAddress)
                .border(1, .black)
            SecureField("Password", text: $password)
                .textContentType(.emailAddress)
                .border(1, .black)
            TextField("About You", text: $userBio,axis: .vertical)
                .frame(minHeight: 100, alignment: .top)
                .textContentType(.emailAddress)
                .border(1, .black)
            TextField("Bio Link (Optional)", text: $userBioLink)
                .textContentType(.emailAddress)
                .border(1, .black)
            Button(action: registerUser){
                Text("Sign up")
                    .foregroundColor(.white)
                    .hAlign(.center)
                    .fillView(.black)
                
            }
            .disableWithOpacity(username == "" || userBio == "" || emailID == "" || password == "" || userProfilePicData == nil)
            .padding(.top, 10)
        }
    }
    
    func registerUser(){
        isLoading = true
        closeKeyboard()
        Task{
            do{
                try await Auth.auth().createUser(withEmail: emailID, password: password)
                guard let userUID = Auth.auth().currentUser?.uid else{return}
                guard let imageData = userProfilePicData else {return}
                let storageRef = Storage.storage().reference().child("Profile_Images").child(userUID)
                let _ = try await storageRef.putDataAsync(imageData)
                let downloadURL = try await storageRef.downloadURL()
                let user = User(username: username, userBio: userBio, userBioLink: userBioLink, userUID: userUID, userEmail: emailID, userProfileURL: downloadURL)
                let _ = try Firestore.firestore().collection("Users").document(userUID).setData(from: user, completion: { error in
                    if error == nil {
                        print("Saved Successfully")
                        userNameStored = username
                        self.userUID = userUID
                        profileURL = downloadURL
                        logStatus = true
                    }
                })
                
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

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
