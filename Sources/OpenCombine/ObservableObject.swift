//
//  ObservableObject.swift
//  
//
//  Created by Sergej Jaskiewicz on 08/09/2019.
//

/// A type of object with a publisher that emits before the object has changed.
///
/// By default an `ObservableObject` will synthesize an `objectWillChange`
/// publisher that emits before any of its `@Published` properties changes:
///
///     class Contact : ObservableObject {
///         @Published var name: String
///         @Published var age: Int
///
///         init(name: String, age: Int) {
///             self.name = name
///             self.age = age
///         }
///
///         func haveBirthday() -> Int {
///             age += 1
///         }
///     }
///
///     let john = Contact(name: "John Appleseed", age: 24)
///     john.objectWillChange.sink { _ in print("will change") }
///     print(john.haveBirthday)
///     // Prints "will change"
///     // Prints "25"
///
public protocol ObservableObject: AnyObject {

    /// The type of publisher that emits before the object has changed.
    associatedtype ObjectWillChangePublisher: Publisher = ObservableObjectPublisher
        where ObjectWillChangePublisher.Failure == Never

    /// A publisher that emits before the object has changed.
    var objectWillChange: ObjectWillChangePublisher { get }
}

extension ObservableObject where ObjectWillChangePublisher == ObservableObjectPublisher {

    /// A publisher that emits before the object has changed.
    public var objectWillChange: ObservableObjectPublisher {
        let publisher = ObservableObjectPublisher()
        // TODO: Store references to publisher in each @Published field.
        return publisher
    }
}

/// The default publisher of an `ObservableObject`.
public final class ObservableObjectPublisher: Publisher {

    public typealias Output = Void

    public typealias Failure = Never

    private var subject: PassthroughSubject<Void, Never>

    public init() {
        subject = .init()
    }

    public func receive<Downstream: Subscriber>(subscriber: Downstream)
        where Downstream.Input == Void, Downstream.Failure == Never
    {
        subject.subscribe(subscriber)
    }

    public func send() {
        subject.send()
    }
}
