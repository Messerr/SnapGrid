//
//  MessageBubble.swift
//  SnapGrid
//
//  Created by David Messer on 5/13/26.
//

import SwiftUI

struct MessageBubble: View {
    let text: String
    let isFromMe: Bool
    let timestamp: Date
    
    var body: some View {
        HStack {
            if isFromMe { Spacer() }
            VStack(alignment: isFromMe ? .trailing : .leading, spacing: 2) {
                Text(text)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(
                        isFromMe ? Color.blue : Color(.systemGray5),
                        in: RoundedRectangle(cornerRadius: 16)
                    )
                    .foregroundStyle(isFromMe ? .white : .primary)
                Text(timestamp, format: .dateTime.hour().minute())
            }
            if !isFromMe { Spacer() }
        }
    }
}

#Preview {
    MessageBubble(
        text: "Hello",
        isFromMe: true,
        timestamp: .now
    )
}
