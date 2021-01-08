//
//  ContentView.swift
//  PlanesGame
//
//  Created by Vicentiu Petreaca on 05/01/2021.
//

import SwiftUI
import UniformTypeIdentifiers

struct Draggable: ViewModifier {
    let condition: Bool
    let data: () -> NSItemProvider

    @ViewBuilder
    func body(content: Content) -> some View {
        if condition {
            content.onDrag(data)
        } else {
            content
        }
    }
}

extension View {
    public func drag(if condition: Bool, data: @escaping () -> NSItemProvider) -> some View {
        self.modifier(Draggable(condition: condition, data: data))
    }
}

struct ContentView: View {
    @StateObject private var model = Model()

    @State private var dragging: Point?

    var body: some View {
        GeometryReader { proxy in
            LazyVGrid(columns: model.columns, spacing: 2) {
                ForEach(model.data) { point in
                    Rectangle()
                        .frame(width: proxy.size.width / 10 - 1, height: proxy.size.width / 10 - 1)
                        .foregroundColor(Color.init(white: 0.8))
                        .drag(if: true /* replace with real value */) {
                            self.dragging = point
                            return NSItemProvider(object: String(point.id) as NSString)
                        }
                        .onDrop(of: [UTType.text], delegate: DragRelocateDelegate(item: point, listData: $model.data, current: $dragging))
                }
            }
        }
//        .animation(.default, value: model.data)
        .padding()
    }
}


class Model: ObservableObject {
    @Published var data = (0..<10).map { row in
        (0..<10).map { column in
            Point(x: row, y: column)
        }
    }.flatMap { $0 }

    let columns = (0..<10).map { _ in GridItem(.flexible()) }
}

struct DragRelocateDelegate: DropDelegate {
    let item: Point
    @Binding var listData: [Point]
    @Binding var current: Point?

    func dropEntered(info: DropInfo) {
        if item != current {
            let from = listData.firstIndex(of: current!)!
            let to = listData.firstIndex(of: item)!
            if listData[to].id != current!.id {
                listData.move(fromOffsets: IndexSet(integer: from),
                    toOffset: to > from ? to + 1 : to)
            }
        }
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }

    func performDrop(info: DropInfo) -> Bool {
        self.current = nil
        return true
    }
}

struct Point: Identifiable, Equatable {
    var id: String {
        String(format: "%d,%d", x, y)
    }

    let x, y: Int

    static func coordinatesFromId(id: String) -> (row: Int, column: Int) {
        (row: Int(id.components(separatedBy: ",").first!)!,
         column: Int(id.components(separatedBy: ",").last!)!)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
        }
    }
}
