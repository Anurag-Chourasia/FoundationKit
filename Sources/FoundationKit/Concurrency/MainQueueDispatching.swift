import Dispatch

public protocol MainQueueDispatching: Sendable {
    func async(execute work: @escaping @Sendable () -> Void)
}

public struct MainQueueDispatcher: MainQueueDispatching {
    public init() {}

    public func async(execute work: @escaping @Sendable () -> Void) {
        DispatchQueue.main.async(execute: work)
    }
}
