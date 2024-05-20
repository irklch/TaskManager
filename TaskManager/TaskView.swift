//
//  TaskView.swift
//  TaskManager
//
//  Created by Ирина Кольчугина on 20.05.2024.
//
import SwiftUI

struct TaskViewItem: Identifiable {
    let id = UUID()
    let text: String
    let image: String
}

struct TaskView: View {
    let items: [TaskViewItem] = [
        TaskViewItem(text: "Item 1", image: "photo"),
        TaskViewItem(text: "Item 2", image: "photo"),
        TaskViewItem(text: "Item 3", image: "photo"),
        TaskViewItem(text: "Item 3", image: "photo"),
        TaskViewItem(text: "Item 3", image: "photo"),
        TaskViewItem(text: "Item 3", image: "photo"),
        TaskViewItem(text: "Item 3", image: "photo"),
        TaskViewItem(text: "Item 3", image: "photo"),
        // ... add more items
    ]

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) { // Make it scrollable horizontally
            VStack(spacing: 16) { // Arrange items horizontally with spacing
                ForEach(items) { item in
                    VStack(alignment: .leading) { // Vertical alignment for text and image
                        Image(systemName: item.image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 300, height: 100) // Set size for images
                            .cornerRadius(8)

                        Text(item.text)
                            .font(.headline)
                            .foregroundColor(.black)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 3)
                }
            }
            .padding()
        }
    }
}

#Preview {
    TaskView()
}
