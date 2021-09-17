//
//  CreditsView.swift
//  OpenSesame
//
//  Created by Ethan Lipnik on 9/17/21.
//

import SwiftUI

struct CreditsView: View {
    var body: some View {
        Form {
            Section("Creator & Maintainer") {
                VStack {
                    AsyncImage(url: URL(string: "https://pbs.twimg.com/profile_images/1384494074955173888/EkfIwNyD_400x400.jpg")) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                                .shadow(radius: 15, y: 10)
                        case .failure:
                            RoundedRectangle(cornerRadius: 30)
                                .fill(Color.red)
                                .shadow(color: Color.red.opacity(0.4), radius: 15, y: 10)
                        case .empty:
                            RoundedRectangle(cornerRadius: 30)
                                .fill(Color.secondary)
                                .shadow(radius: 15, y: 10)
                        @unknown default:
                            RoundedRectangle(cornerRadius: 30)
                                .fill(Color.secondary)
                                .shadow(radius: 15, y: 30)
                        }
                    }
                        .aspectRatio(1/1, contentMode: .fit)
                        .padding(.vertical)
                    Link("Ethan Lipnik", destination: URL(string: "https://www.ethanlipnik.com")!)
                        .font(.title.bold())
                }
            }
            Section("OpenSesame depends on the following open-source projects:") {
                Text("[SwiftOTP](https://github.com/OpenSesameManager/SwiftOTP.git) by [lachlanbell](https://github.com/lachlanbell) ([License](https://github.com/lachlanbell/SwiftOTP/blob/master/LICENSE))")
                Text("[FaviconFinder](https://github.com/OpenSesameManager/FaviconFinder.git) by [will-lumley](https://github.com/will-lumley) ([License](https://github.com/OpenSesameManager/FaviconFinder/blob/main/LICENSE.txt))")
                Text("[KeychainAccess](https://github.com/kishikawakatsumi/KeychainAccess.git) by [kishikawakatsumi](https://github.com/kishikawakatsumi) ([License](https://github.com/kishikawakatsumi/KeychainAccess/blob/master/LICENSE))")
                Text("[DomainParser](https://github.com/Dashlane/SwiftDomainParser.git) by [Dashlane](https://github.com/Dashlane) ([License](https://github.com/Dashlane/SwiftDomainParser/blob/master/LICENSE))")
                Text("[CSV.swift](https://github.com/yaslab/CSV.swift.git) by [yaslab](https://github.com/yaslab) ([License](https://github.com/yaslab/CSV.swift/blob/master/LICENSE))")
                Text("[CodeScanner](https://github.com/twostraws/CodeScanner.git) by [twostraws](https://github.com/twostraws) ([License](https://github.com/twostraws/CodeScanner/blob/main/LICENSE))")
            }
        }.navigationTitle("Acknowledgements")
    }
}

struct CreditsView_Previews: PreviewProvider {
    static var previews: some View {
        CreditsView()
    }
}
