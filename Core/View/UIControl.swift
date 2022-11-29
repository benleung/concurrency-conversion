//
//  UIControl.swift
//  currency-conversion
//
//  Created by Ben Leung on 2022/11/25.
//

import Combine
import UIKit

/// A syntax sugar to subscribe UIKit's UIControl.Event
/// example use: button.publisher(for: .touchUpInside).sink { ... }
private class EventControlSubscription<EventSubscriber: Subscriber>: Subscription where EventSubscriber.Input == UIControl, EventSubscriber.Failure == Never {
    let control: UIControl
    let event: UIControl.Event
    var subscriber: EventSubscriber?

    var demand: Subscribers.Demand = .none

    init(control: UIControl, event: UIControl.Event, subscriber: EventSubscriber) {
        self.control = control
        self.event = event
        self.subscriber = subscriber
        control.addTarget(self, action: #selector(eventRaised), for: event)
    }

    func request(_ demand: Subscribers.Demand) {
        self.demand += demand
    }

    func cancel() {
        subscriber = nil
        control.removeTarget(self, action: #selector(eventRaised), for: event)
    }

    @objc func eventRaised() {
        if demand > 0 {
            demand += subscriber?.receive(control) ?? .none
            demand -= 1
        }
    }
}

public struct EventControlPublisher: Publisher {
    public typealias Output = UIControl
    public typealias Failure = Never

    let control: UIControl
    let controlEvent: UIControl.Event

    public func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        let subscription = EventControlSubscription(control: control, event: controlEvent, subscriber: subscriber)
        subscriber.receive(subscription: subscription)
    }
}

public extension UIControl {
    func publisher(for event: UIControl.Event) -> EventControlPublisher {
        EventControlPublisher(control: self, controlEvent: event)
    }
}
