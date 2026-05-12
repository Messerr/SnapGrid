//
//  StatColumn.swift
//  SnapGrid
//
//  Created by messerd on 5/11/26.
//

import SwiftUI

struct StatColumn: View {
    let value: Int
    let label: String
    
    var body: some View {
        VStack(spacing: 2) {
            Text("\(value)")
                .font(.headline)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    StatColumn(
        value: 10,
        label: "Followers"
    )
}
