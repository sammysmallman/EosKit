//
//  EosPreset.swift
//  EosKit
//
//  Created by Sam Smallman on 12/05/2020.
//  Copyright © 2020 Sam Smallman. https://github.com/SammySmallman
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation
import OSCKit

public struct EosPreset: EosTarget, Hashable {
    
    static var stepCount: Int = 4
    static let target: EosRecordTarget = .preset
    let number: Double
    let uuid: UUID
    let label: String
    let absolute: Bool
    let locked: Bool
    let channels: Set<Double>
    let byTypeChannels: Set<Double>
    let effects: Set<Double>
    
    init?(messages: [OSCMessage]) {
        guard messages.count == Self.stepCount,
              let indexMessage = messages.first(where: { $0.addressPattern.contains("channels") == false &&
                                                         $0.addressPattern.contains("byType") == false &&
                                                         $0.addressPattern.contains("fx") == false }),
              let channelsMessage = messages.first(where: { $0.addressPattern.contains("channels") == true }),
              let byTypeMessage = messages.first(where: { $0.addressPattern.contains("byType") == true }),
              let fxMessage = messages.first(where: { $0.addressPattern.contains("fx") == true }),
              let number = indexMessage.number(), number == channelsMessage.number(), number == byTypeMessage.number(), number == fxMessage.number(),
              let double = Double(number),
              let uuid = indexMessage.uuid(),
              let label = indexMessage.arguments[2] as? String,
              let absolute = indexMessage.arguments[3] as? OSCArgument,
              let locked = indexMessage.arguments[4] as? OSCArgument
        else { return nil }
        self.number = double
        self.uuid = uuid
        self.label = label
        self.absolute = absolute == .oscTrue
        self.locked = locked == .oscTrue
        
        var channelsList: Set<Double> = []
        for argument in channelsMessage.arguments[2...] where channelsMessage.arguments.count >= 3 {
            let channelsAsDoubles = EosOSCNumber.doubles(from: argument)
            channelsList = channelsList.union(channelsAsDoubles)
        }
        self.channels = channelsList
        
        var byTypeChannelsList: Set<Double> = []
        for argument in byTypeMessage.arguments[2...] where byTypeMessage.arguments.count >= 3 {
            let byTypeChannelsAsDoubles = EosOSCNumber.doubles(from: argument)
            byTypeChannelsList = byTypeChannelsList.union(byTypeChannelsAsDoubles)
        }
        self.byTypeChannels = byTypeChannelsList
        
        var effectsList: Set<Double> = []
        for argument in fxMessage.arguments[2...] where fxMessage.arguments.count >= 3 {
            let effectsAsDoubles = EosOSCNumber.doubles(from: argument)
            effectsList = effectsList.union(effectsAsDoubles)
        }
        self.effects = effectsList
    }

}