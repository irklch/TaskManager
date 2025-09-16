//
//  CustomTabBar.swift
//  TaskManager
//
//  Created by Ирина Кольчугина on 20.05.2024.
//

import SwiftUI

struct CustomTabBar: View {
    private let viewModel: CustomTabBarViewModel

    init(viewModel: CustomTabBarViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        HStack {
            plusButton()
            HStack {
                ForEach(viewModel.tabItems.indices, id: \.self) { index in
                    getTabButton(by: index)
                }
            }
            .frame(height: Offset.pageSizeWithSpaces)
            .padding([.leading, .trailing], 0)
            .background(Color.hex000101)
            .cornerRadius(Offset.superViewCornerRadius)
            .animation(.easeInOut(duration: 0.3), value: viewModel.selectedIndex)
        }
    }

    private func plusButton() -> some View {
        let roundedBackgroundView = RoundedRectangle(cornerRadius: Offset.superViewCornerRadius)
            .fill(.hex316AFD)
            .frame(height: Offset.pageSizeWithSpaces)

        let plusImage = Image(systemName: "plus")
            .font(.system(size: 25))
            .foregroundColor(.hexF2F2F2)
            .frame(
                width: Offset.pageSizeWithSpaces,
                height: Offset.pageSizeWithSpaces)
            .background(
                ZStack {
                    roundedBackgroundView
                }
            )

        return Button(action: addNewItem) {
            plusImage
        }
    }

    private func tabBarItemsBackground() -> some View {
        let tabsCount: CGFloat = .init(viewModel.tabItems.count)
        let rectWidth: CGFloat = tabsCount * Offset.pageSizeWithSpaces + ((tabsCount-1) * Offset.pageLeadingPadding)
        return RoundedRectangle(cornerRadius: Offset.superViewCornerRadius)
            .fill(.hex000101)
            .frame(
                width: rectWidth,
                height: Offset.pageSizeWithSpaces)
    }

    private func getTabButton(by index: Int) -> some View {
        let isSelected = index == viewModel.selectedIndex
        
        let tabContent = HStack(spacing: 0) {
            if isSelected {
                // Отступ от левого края до изображения
                Spacer()
                    .frame(width: 10)
                
                // Изображение
                Image(systemName: viewModel.tabItems[index].icon)
                    .font(.system(size: 18))
                    .foregroundColor(.hexF2F2F2)
                    .frame(width: 30, height: Offset.pageSize)
                
                // Отступ от изображения до текста
                Spacer()
                    .frame(width: 6)
                
                // Текст
                Text(viewModel.tabItems[index].title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.hexF2F2F2)
                    .transition(.opacity.combined(with: .scale))
                
                // Отступ от текста до правого края
                Spacer()
                    .frame(width: 10)
            } else {
                // В неактивном состоянии - только иконка по центру
                Image(systemName: viewModel.tabItems[index].icon)
                    .font(.system(size: 18))
                    .foregroundColor(.hexF2F2F2)
                    .frame(width: Offset.pageSize, height: Offset.pageSize)
            }
        }
        .frame(width: isSelected ? nil : Offset.pageSize, height: Offset.pageSize)
        .background(
            ZStack {
                if isSelected {
                    RoundedRectangle(cornerRadius: Offset.pageCornerRadius)
                        .fill(Color.hex316AFD)
                        .overlay(
                            RoundedRectangle(cornerRadius: Offset.pageCornerRadius)
                                .stroke(Color.hex000101, lineWidth: 1)
                        )
                } else {
                    RoundedRectangle(cornerRadius: Offset.pageCornerRadius)
                        .fill(Color.hex000101)
                        .overlay(
                            RoundedRectangle(cornerRadius: Offset.pageCornerRadius)
                                .stroke(Color.gray.opacity(0.7), lineWidth: 1)
                        )
                }
            }
        )
        
        return Button(action: {
            withAnimation(.easeInOut(duration: 0.3)) {
                viewModel.selectedIndex = index
            }
        }) {
            tabContent
        }
        .animation(.easeInOut(duration: 0.3), value: isSelected)
        .padding(6)
        .background(
            RoundedRectangle(cornerRadius: Offset.pageCornerRadius)
                .fill(Color.hex000101)
        )
        .padding(.leading, index == 0 ? 0 : Offset.pageLeadingPadding)
    }


    private func addNewItem() {

    }
}

#Preview {
    ContentView()
}

