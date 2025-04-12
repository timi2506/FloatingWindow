// Made by timi2506 on iPad Air 5

import SwiftUI

// Custom shape for the resizer handle with a rounded corner.
// It now takes an `edge` parameter to determine which corner to draw.
struct HandleShape: Shape {
    var cornerRadius: CGFloat = 5
    var edge: Alignment = .bottomTrailing
    
    func path(in rect: CGRect) -> Path {
        let r = min(cornerRadius, rect.width / 2, rect.height / 2)
        var path = Path()
        
        // We handle the four common corners:
        switch edge {
        case .bottomTrailing:
            // Corner at (rect.maxX, rect.maxY).
            // Draw horizontal line along the bottom, then an arc, then vertical line along the right.
            path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.maxX - r, y: rect.maxY))
            path.addArc(center: CGPoint(x: rect.maxX - r, y: rect.maxY - r),
                        radius: r,
                        startAngle: .degrees(90),
                        endAngle: .degrees(0),
                        clockwise: true)
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            
        case .bottomLeading:
            // Corner at (rect.minX, rect.maxY).
            // Draw horizontal line along the bottom (from the right edge inward), then an arc, then vertical line along the left.
            path.move(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX + r, y: rect.maxY))
            path.addArc(center: CGPoint(x: rect.minX + r, y: rect.maxY - r),
                        radius: r,
                        startAngle: .degrees(90),
                        endAngle: .degrees(180),
                        clockwise: false)
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
            
        case .topTrailing:
            // Corner at (rect.maxX, rect.minY).
            // Draw horizontal line along the top (from the left edge to near the corner), then an arc, then vertical line along the right.
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX - r, y: rect.minY))
            path.addArc(center: CGPoint(x: rect.maxX - r, y: rect.minY + r),
                        radius: r,
                        startAngle: .degrees(270),
                        endAngle: .degrees(360),
                        clockwise: false)
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            
        case .topLeading:
            // Corner at (rect.minX, rect.minY).
            // Draw horizontal line along the top (from the right edge inward), then an arc, then vertical line along the left.
            path.move(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.minX + r, y: rect.minY))
            path.addArc(center: CGPoint(x: rect.minX + r, y: rect.minY + r),
                        radius: r,
                        startAngle: .degrees(270),
                        endAngle: .degrees(180),
                        clockwise: true)
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            
        default:
            // Fallback: treat as bottomTrailing.
            path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.maxX - r, y: rect.maxY))
            path.addArc(center: CGPoint(x: rect.maxX - r, y: rect.maxY - r),
                        radius: r,
                        startAngle: .degrees(90),
                        endAngle: .degrees(0),
                        clockwise: true)
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        }
        
        return path
    }
}

struct FloatingWindow<WindowContent>: ViewModifier where WindowContent: View {
    let windowContent: () -> WindowContent
    var windowTitle: String
    var windowBarStyle: WindowBarStyle
    @Binding var isPresented: Bool
    @State var width: CGFloat
    @State var height: CGFloat
    @State var lastWidth: CGFloat
    @State var lastHeight: CGFloat
    @State var offset: CGSize = CGSize(width: 0, height: 0)
    @State var lastOffset: CGSize = CGSize(width: 0, height: 0)
    @State var moveWindow = false
    @State var cantClose = false
    let minHeight: CGFloat
    let minWidth: CGFloat
    func body(content: Content) -> some View {
        ZStack {
            content
            if isPresented {
                VStack(spacing: 0) {
                    Group {
                        if windowBarStyle == .titleBar {
                            HStack {
                                Text(windowTitle)
                                Spacer()
                                Image(systemName: "xmark")
                                    .onTapGesture {
                                        isPresented = false
                                        if isPresented {
                                            cantClose = true
                                        }
                                    }
                                    .foregroundStyle(cantClose ? .gray : .primary)
                            }
                            .padding(10)
                            .background(.ultraThinMaterial)
                            .contextMenu(menuItems: {
                                Button("Move Window", systemImage: "arrow.up.left.and.down.right.and.arrow.up.right.and.down.left" ) {
                                    moveWindow.toggle()
                                }
                                Button("Close Window", systemImage: "xmark") {
                                    isPresented = false
                                    if isPresented {
                                        cantClose = true
                                    }
                                }
                                .foregroundStyle(.red)
                                .disabled(cantClose)
                            }) {
                                VStack {
                                    windowContent()
                                        .scaleEffect(0.5)
                                }
                                .frame(width: UIScreen.main.bounds.width / 2, height: UIScreen.main.bounds.height / 2)
                            }
                            
                        } else if windowBarStyle == .minimal {
                            HStack {
                                Spacer()
                                Menu {
                                    Button("Move Window", systemImage: "arrow.up.left.and.down.right.and.arrow.up.right.and.down.left" ) {
                                        moveWindow.toggle()
                                    }
                                    Button("Close Window", systemImage: "xmark") {
                                        isPresented = false
                                        if isPresented {
                                            cantClose = true
                                        }
                                    }
                                    .foregroundStyle(.red)
                                    .disabled(cantClose)
                                }
                                label: {
                                    Image(systemName: "ellipsis")
                                        .padding(5)
                                        .background(
                                            RoundedRectangle(cornerRadius: 15)
                                                .foregroundStyle(.ultraThinMaterial)
                                        )
                                        .padding(5)
                                }
                                Spacer()
                        }
                            .background(.ultraThinMaterial)
                        }
                    }
                    ZStack {
                        Rectangle()
                            .foregroundStyle(.ultraThinMaterial)
                        NavigationStack {
                            windowContent()
                        }
                    }
                }
                .frame(width: width, height: height)
                .clipShape(
                    RoundedRectangle(cornerRadius: 15)
                )
                .overlay {
                    ZStack {
                        if moveWindow {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(.ultraThinMaterial)
                            VStack {
                                Text("Window Moving Mode")
                                Text("Tap to Disable")
                                    .font(.caption)
                                    .foregroundStyle(.primary.opacity(0.5))
                            }
                        }
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(.gray.opacity(0.25), lineWidth: 3)
                       
                    }
                }
                .overlay(alignment: .bottomTrailing) {
                    HandleShape(cornerRadius: 100, edge: .bottomTrailing)
                        .stroke(LinearGradient(colors: [.gray.opacity(0.10), .primary.opacity(0.5), .gray.opacity(0.10)], startPoint: .topTrailing, endPoint: .bottomLeading), lineWidth: 3)
                        .opacity(height <= minHeight ? 0 : 1)
                        .opacity(width <= minWidth ? 0 : 1)
                        .frame(width: 20, height: 20)
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture()
                                .onChanged { gesture in
                                    width = lastWidth + gesture.translation.width
                                    height = lastHeight + gesture.translation.height
                                }
                                .onEnded { _ in
                                    if height <= minHeight {
                                        withAnimation(.bouncy) {
                                            height = minHeight
                                        }
                                    }
                                    if width <= minWidth {
                                        withAnimation(.bouncy) {
                                            width = minWidth
                                        }
                                    }
                                    lastHeight = height
                                    lastWidth = width
                                }
                        )
                }
                
                .offset(offset)
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            if moveWindow {
                                offset = CGSize(width: lastOffset.width + gesture.translation.width,
                                                height: lastOffset.height + gesture.translation.height)
                            }
                        }
                        .onEnded { _ in
                            lastOffset = offset
                        }
                )
                .onTapGesture {
                    if moveWindow {
                        moveWindow.toggle()
                    }
                }
            }
        }
    }
}

extension View {
    public func floatingWindow<WindowContent: View>(
        isPresented: Binding<Bool>? = .constant(true),
        windowTitle: String? = "Window",
        windowBarStyle: WindowBarStyle? = .titleBar,
        minHeight: CGFloat? = 125,
        minWidth: CGFloat? = 150,
        @ViewBuilder content: @escaping () -> WindowContent
    ) -> some View {
        modifier(FloatingWindow(windowContent: content, windowTitle: windowTitle!, windowBarStyle: windowBarStyle!, isPresented: isPresented!, width: minWidth!, height: minHeight!, lastWidth: minWidth!, lastHeight: minHeight!, minHeight: minHeight!, minWidth: minWidth!))
    }
}

public enum WindowBarStyle {
    case titleBar
    case minimal
}
