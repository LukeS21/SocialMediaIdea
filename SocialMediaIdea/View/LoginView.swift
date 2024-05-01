//
//  LoginView.swift
//  SocialMediaIdea
//
//  Created by Luke Sheakley on 5/1/24.
//

import SwiftUI
import PhotosUI
import Firebase

struct LoginView: View {
    // MARK: User Details
    @State var emailID: String = ""
    @State var password: String = ""
    // MARK: View Properties
    @State var createAccount: Bool = false
    @State var showError: Bool = false
    @State var errorMessage: String = ""
    var body: some View {
        VStack(spacing: 10){
            
            Text("Sign In.")
                .font(.largeTitle.bold())
                .hAlign(.leading)
            
            Text("Welcome Back.")
                .font(.title3)
                .hAlign(.leading)
            
            VStack(spacing:12){
                
                TextField("Email", text:$emailID)
                    .textContentType(.emailAddress)
                    .border(1,.gray.opacity(0.5))
                    .padding(.top, 25)
                
                SecureField("Password", text:$password)
                    .textContentType(.emailAddress)
                    .border(1,.gray.opacity(0.5))
                    .padding(.top, 25)
                
                Button("Reset Password", action: loginUser)
                    .font(.callout)
                    .fontWeight(.medium)
                    .tint(.black)
                    .hAlign(.trailing)
                
                Button{
                    
                }label: {
                    // MARK: Login Button
                    Text("Sign In")
                        .foregroundColor(.white)
                        .hAlign(.center)
                        .fillView(.black)
                }.padding(.top, 10)
            }
            
            // MARK: Register Button
            HStack{
                Text("Don't have an account?")
                Button("Register Now"){
                    createAccount.toggle()
                }
                .fontWeight(.bold)
                .foregroundColor(.black)
            }
            .vAlign(.bottom)
        }
        .vAlign(.top)
        .font(.callout)
        .padding(15)
        
        // MARK: Register View VIA Sheets
        .fullScreenCover(isPresented: $createAccount){
            registerView()
        }
        // MARK: Displaying Alert
        .alert(errorMessage, isPresented: $showError, actions: {})
    }
    
    func loginUser(){
        Task{
            do{
                try await Auth.auth().signIn(withEmail: emailID, password: password)
                print("User Found")
            }catch{
                await setError(error)
            }
        }
    }
    
    // MARK: Displaying Errors VIA Alert
    func setError(_ error: Error)async{
        // MARK: UI Must Be Updated on Main Thread
        await MainActor.run(body: {
            errorMessage = error.localizedDescription
            showError.toggle()
        })
    }
}

// MARK: Register View

struct registerView: View{
    // MARK: User Details
    @State var emailID: String = ""
    @State var password: String = ""
    @State var username: String = ""
    @State var userProfilePicData: Data?
    
    // MARK: View Properties
    @Environment(\.dismiss) var dismiss
    @State var showImagePicker: Bool = false
    @State var photoItem: PhotosPickerItem?
    var body: some View{
        VStack(spacing: 10){
            
            Text("Sign Up.")
                .font(.largeTitle.bold())
                .hAlign(.leading)
            
            Text("Welcome.")
                .font(.title3)
                .hAlign(.leading)
            
            //MARK: For Smaller Size Optimization
            ViewThatFits{
                ScrollView(.vertical, showsIndicators: false){
                    HelperView()
                }
                HelperView()
            }
            
            // MARK: Register Button
            HStack{
                Text("Already have an account?")
                Button("Login Now"){
                    dismiss()
                }
                .fontWeight(.bold)
                .foregroundColor(.black)
            }
            .vAlign(.bottom)
        }
        .vAlign(.top)
        .font(.callout)
        .padding(15)
        .photosPicker(isPresented: $showImagePicker, selection:$photoItem)
        .onChange(of: photoItem){ newValue in
            // MARK: Extracking UI Image From Photo Item
            if let newValue{
                Task{
                    do{
                        guard let imageData = try await newValue.loadTransferable(type: Data.self) else{return}
                        // MARK: UI Must Be Updated on Main Thread
                        await MainActor.run(body: {
                            userProfilePicData = imageData;
                        })
                    }catch{}
                }
            }
        }
    }
    
    @ViewBuilder
    func HelperView()-> some View{
        VStack(spacing:12){
            
            ZStack{
                if let userProfilePicData,let image = UIImage(data: userProfilePicData){
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }else{
                    Image("profilepicdefault")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }
            }
            .frame(width: 85,height: 85)
            .clipShape(Circle())
            .contentShape(Circle())
            .onTapGesture {
                showImagePicker.toggle()
            }
            .padding(.top,25)
            
            TextField("Username", text:$username)
                .textContentType(.emailAddress)
                .border(1,.gray.opacity(0.5))
                .padding(.top, 25)
            
            TextField("Email", text:$emailID)
                .textContentType(.emailAddress)
                .border(1,.gray.opacity(0.5))
                .padding(.top, 25)
            
            SecureField("Password", text:$password)
                .textContentType(.emailAddress)
                .border(1,.gray.opacity(0.5))
                .padding(.top, 25)
            
            Button{
                
            }label: {
                // MARK: Login Button
                Text("Sign Up")
                    .foregroundColor(.white)
                    .hAlign(.center)
                    .fillView(.black)
            }.padding(.top, 10)
        }
    }
}

#Preview {
    LoginView()
}

// MARK: View Extensions For UI Building

extension View{
    func hAlign(_ alignment: Alignment)->some View{
        self
            .frame(maxWidth: .infinity, alignment: alignment)
    }
    func vAlign(_ alignment: Alignment)->some View{
        self
            .frame(maxHeight: .infinity, alignment:     alignment)
    }
    
    // MARK: Custom Border View With Padding
    func border(_ width:CGFloat, _ color: Color)->some View{
        self
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            .background{
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .stroke(color, lineWidth: width)
            }
        
    }
    
    // MARK: Custom Fill View With Padding
    func fillView(_ color: Color)->some View{
        self
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            .background{
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .fill(color)
            }
        
    }
    
}
