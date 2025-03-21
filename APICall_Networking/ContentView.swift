//
//  ContentView.swift
//  APICall_Networking
//
//  Created by Nirusan Manoharan on 2025-03-20.
//

import SwiftUI

struct ContentView: View {
    
    @State private var user: GitHubUser?
    @State var userNameSearch = "nirumano"
    
    var body: some View {
        ZStack{
            LinearGradient(gradient: Gradient(colors: [.black, .purple]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
            
            VStack (spacing:20){
                
                AsyncImage(url: URL(string: user?.avatarUrl ?? "")){
                    image in image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(Circle())
                    
                }
                placeholder: {
                    Circle()
                        .foregroundColor(.secondary)
                }
                .frame(width: 120, height: 120)
                
                HStack{
                    
                    Image("githubIcon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 18, height: 18)
                        .colorInvert()
                    
                    Text(user?.login ?? "Login Placeholder")
                        .fontWeight(.bold)
                        .font(.title)
                        .foregroundColor(.white)
                }.padding(.bottom,10)
                
                VStack (alignment: .leading){
                    
                    
                    Text(user?.name ?? "Name Placeholder")
                        .fontWeight(.bold)
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding(.bottom,5)
                    
                    Text(user?.bio ?? "Bio Placeholder")
                        .foregroundColor(.white)
                    
                }
                Spacer()
                
                VStack{
                TextField("Enter github username", text: $userNameSearch)
                    .padding()
                    .frame(width: 280, height: 40)
                    .background(.white)
                    .foregroundColor(.gray)
                    .font(.title3)
                    .cornerRadius(2)
                    
                
                Button{
                    
                    
                }label: {
                    HStack{
                        Image("githubIcon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                            .colorInvert()
                        Text("Search User")
                    }.frame(width: 280, height: 50)
                        .background(.gray)
                        .foregroundColor(.white)
                        .font(.system(size: 20, weight: .bold, design: .default))
                        .cornerRadius(10)
                        .padding(2)
                }
                }//.padding(.bottom,50)
                Spacer()
            }
            .padding()
            .task {
                do {
                    user = try await getUser()
                }
                catch GHError.invalidURL{
                    print("invalid URL")
                }
                catch GHError.invalidResponse{
                    print("invalid response")
                }
                catch GHError.invalidData{
                    print("invalid data")
                }
                catch{
                    print("unexpected error")
                }
            }
        }
    }
    
    func getUser() async throws -> GitHubUser { //throws is what calls the errors if the async func does not go through
        let endpoint = "https://api.github.com/users/\(userNameSearch)"
        
        guard let url = URL(string:endpoint)
        else{throw GHError.invalidURL
        }
        
        let(data,response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200
        else{
            throw GHError.invalidResponse
        }
        do{ //if we get a success 200 code, than do
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase //since swift does camel case and not underscore, this might throw us a data error code parsing the JSON structure. This line is not needed if the json is camelcase by default.
            return try decoder.decode(GitHubUser.self, from: data)
        }
        catch{ //if we do not get a 200 code, than invalid data error message
            throw GHError.invalidData
        }
    }
}

#Preview {
    ContentView()
}


struct GitHubUser: Codable{
    let avatarUrl: String
    let login: String
    let bio: String
    let name: String
}

enum GHError : Error{
    case invalidURL
    case invalidResponse
    case invalidData
}
