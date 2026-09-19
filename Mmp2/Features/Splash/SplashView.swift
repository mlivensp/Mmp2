//
//  SplashView.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 9/13/26.
//

import SwiftUI

struct SplashView: View {
    @Environment(AppRootManager.self) var appRootManager
    
    var body: some View {
        ZStack {
            Color.blue
                .ignoresSafeArea()
            
            Text("Splash")
                .font(.title)
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
        
        .onAppear() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation(.spring()) {
                    appRootManager.currentRoot = .home
                }
            }
        }
    }
}

#Preview {
    SplashView()
}
