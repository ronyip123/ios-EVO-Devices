//
//  FeaturesNotAvailable.swift
//  EVO Devices
//
//  Created by Ronald Yip on 7/6/21.
//

import SwiftUI

struct FeaturesNotAvailable: View {
    @Binding var showViewState: Bool
    var body: some View {
        VStack{
            Text("These features are not avaiable in the version of connected device.")
                .padding()
            Button (action: { self.showViewState.toggle()}){
                Text("Done")
            }
            .buttonStyle(RoundedRectangleButtonStyle(alarmstate: false))
        }
        
    }
}

//struct FeaturesNotAvailable_Previews: PreviewProvider {
//    static var previews: some View {
//        FeaturesNotAvailable()
//    }
//}
