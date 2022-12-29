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
                Link(destination: URL(string: "https://www.ethanlipnik.com")!) {
                    HStack {
                        Label {
                            Text("Ethan Lipnik")
                                .font(.headline)
                        } icon: {
                            AsyncImage(
                                url: URL(
                                    string: "https://www.ethanlipnik.com/_next/image?url=%2F_next%2Fstatic%2Fmedia%2FProfilePic.4dd0e195.png&w=1080&q=75"
                                )
                            ) { phase in
                                switch phase {
                                case let .success(image):
                                    image
                                        .resizable()
                                        .clipShape(RoundedRectangle(
                                            cornerRadius: 5,
                                            style: .continuous
                                        ))
                                case .failure:
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(Color.red)
                                case .empty:
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(Color.secondary)
                                @unknown default:
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(Color.secondary)
                                }
                            }
                            .aspectRatio(1 / 1, contentMode: .fit)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption.bold())
                            .foregroundColor(Color.secondary)
                    }
                }
            }
            Section("OpenSesame depends on the following open-source projects:") {
                Text(
                    "[SwiftOTP](https://github.com/OpenSesameManager/SwiftOTP.git) by [lachlanbell](https://github.com/lachlanbell) ([License](https://github.com/lachlanbell/SwiftOTP/blob/master/LICENSE))"
                )
                Text(
                    "[FaviconFinder](https://github.com/OpenSesameManager/FaviconFinder.git) by [will-lumley](https://github.com/will-lumley) ([License](https://github.com/OpenSesameManager/FaviconFinder/blob/main/LICENSE.txt))"
                )
                Text(
                    "[KeychainAccess](https://github.com/kishikawakatsumi/KeychainAccess.git) by [kishikawakatsumi](https://github.com/kishikawakatsumi) ([License](https://github.com/kishikawakatsumi/KeychainAccess/blob/master/LICENSE))"
                )
                Text(
                    "[DomainParser](https://github.com/Dashlane/SwiftDomainParser.git) by [Dashlane](https://github.com/Dashlane) ([License](https://github.com/Dashlane/SwiftDomainParser/blob/master/LICENSE))"
                )
                Text(
                    "[CSV.swift](https://github.com/yaslab/CSV.swift.git) by [yaslab](https://github.com/yaslab) ([License](https://github.com/yaslab/CSV.swift/blob/master/LICENSE))"
                )
                Text(
                    "[CodeScanner](https://github.com/twostraws/CodeScanner.git) by [twostraws](https://github.com/twostraws) ([License](https://github.com/twostraws/CodeScanner/blob/main/LICENSE))"
                )
                Text(
                    "[ScreenCorners](https://github.com/kylebshr/ScreenCorners.git) by [kylebshr](https://github.com/kylebshr) ([License](https://github.com/kylebshr/ScreenCorners/blob/main/LICENSE))"
                )
            }
        }.navigationTitle("Acknowledgements")
    }
}

struct CreditsView_Previews: PreviewProvider {
    static var previews: some View {
        CreditsView()
    }
}
