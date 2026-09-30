import SwiftUI

struct OpenSourceLicensesView: View {
    @Environment(\.dismiss) private var dismiss

    private var license: String {
        guard let url = Bundle.main.url(forResource: "TVVLCKit-LGPL-2.1", withExtension: "txt"),
              let text = try? String(contentsOf: url, encoding: .utf8) else {
            return "License text is unavailable. See the VLCKit source repository."
        }
        return text
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Button("Done") { dismiss() }
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Open Source Licenses").font(.title)
                    Text("TVVLCKit 3.7.2 / libVLC").font(.headline)
                    Text("Copyright © 2010–2023 Pierre d’Herbemont and VideoLAN, and the respective libVLC contributors. Licensed under GNU LGPL version 2.1 or later. Provided without warranty.")
                    Text("You may obtain, modify, and redistribute the library source under its license. Home2VLC uses the unmodified official TVVLCKit binary.")
                    Link("VLCKit source and build instructions", destination: URL(string: "https://code.videolan.org/videolan/VLCKit")!)
                    Text(license).font(.system(.caption, design: .monospaced))
                }
            }
        }
        .padding(40)
    }
}
