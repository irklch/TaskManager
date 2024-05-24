//
//  TaskItemView.swift
//  TaskManager
//
//  Created by Ирина Кольчугина on 24.05.2024.
//

import SwiftUI

struct TaskItemView: View {
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("UX Research")
                    .font(.headline)
                Spacer()
                Image(systemName: "arrow.up.right.square")
            }
            .padding(.bottom, 1)

            Text("Started 10:30 PM")
                .font(.subheadline)
                .foregroundColor(.gray)

            Text("Formulating design strategies on user data.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.bottom, 10)

            HStack {
                HStack {
                    Text("20%")
                        .font(.subheadline)
                        .fontWeight(.bold)
                    ProgressView(value: 0.2)
                        .progressViewStyle(LinearProgressViewStyle(tint: .hex316AFD))
                        .frame(width: 100)
                }
                Spacer()
                HStack(spacing: -10) {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .clipShape(Circle())
                    ZStack {
                        Circle()
                            .fill(.hex000101)
                            .frame(width: 30, height: 30)
                        Image(systemName: "plus")
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
    }
}

#Preview {
    TaskScreenView()
}
