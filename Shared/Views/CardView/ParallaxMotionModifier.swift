import CoreMotion
/// https://trailingclosure.com/device-motion-effect/
import SwiftUI

struct ParallaxMotionModifier: ViewModifier {
    @ObservedObject var manager: MotionManager
    var magnitude: Double

    func body(content: Content) -> some View {
        content
            .rotation3DEffect(.degrees(2.5), axis: (manager.pitch, manager.roll, 0))
            .offset(x: CGFloat(manager.roll * magnitude), y: CGFloat(manager.pitch * magnitude))
    }
}

class MotionManager: ObservableObject {
    @Published var pitch: Double = 0.0
    @Published var roll: Double = 0.0

    private var manager: CMMotionManager

    init() {
        manager = CMMotionManager()
        manager.deviceMotionUpdateInterval = 1 / 60
        manager.startDeviceMotionUpdates(to: .main) { motionData, error in
            guard error == nil else {
                print(error!)
                return
            }

            if let motionData = motionData {
                withAnimation(.spring()) {
                    self.pitch = motionData.attitude.pitch
                    self.roll = motionData.attitude.roll
                }
            }
        }
    }
}
