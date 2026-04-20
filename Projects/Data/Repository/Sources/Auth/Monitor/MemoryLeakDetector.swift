//
//  MemoryLeakDetector.swift
//  Repository
//
//  Created by Network Optimizer on 1/10/26.
//

import Foundation
import LogMacro

#if DEBUG
/// 개발 시 메모리 누수 감지 도구
public final class MemoryLeakDetector {
    public static let shared = MemoryLeakDetector()

    private var trackedObjects: [WeakWrapper] = []
    private let queue = DispatchQueue(label: "memory.leak.detector", qos: .utility)
    private var timer: Timer?

    private init() {
        startMonitoring()
    }

    /// 객체 추적 시작
    public func trackObject<T: AnyObject>(_ object: T, name: String) {
        queue.async { [weak self] in
            self?.trackedObjects.append(WeakWrapper(object: object, name: name))
        }
    }

    private func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] _ in
            self?.checkForLeaks()
        }
    }

    private func checkForLeaks() {
        queue.async { [weak self] in
            guard let self = self else { return }

            let beforeCount = self.trackedObjects.count
            self.trackedObjects = self.trackedObjects.filter { wrapper in
                if wrapper.object == nil {
                    return false // 해제된 객체는 제거
                }
                return true
            }
            let afterCount = self.trackedObjects.count

            if afterCount > 0 {
                #logDebug("""
                📊 [Memory Leak Check]
                Total tracked objects: \(afterCount)
                Recently released: \(beforeCount - afterCount)
                Living objects: \(self.trackedObjects.map { $0.name }.joined(separator: ", "))
                """)

                // 메모리 누수 의심 객체 감지 (10개 이상)
                if afterCount > 10 {
                    #logError("🚨 Potential memory leak detected: \(afterCount) objects still alive")
                }
            }
        }
    }
}

private struct WeakWrapper {
    weak var object: AnyObject?
    let name: String
}
#else
/// Release 빌드에서는 비활성화
final class MemoryLeakDetector {
    static let shared = MemoryLeakDetector()
    private init() {}
    func trackObject<T: AnyObject>(_ object: T, name: String) {}
}
#endif