//
//  MyOperation.swift
//  BackgroundTasksExercise
//
//  Created by 윤성우 on 2020/07/15.
//  Copyright © 2020 윤성우. All rights reserved.
//

import Foundation

class MyOperation: Operation {
    let runLoop = RunLoop.current
    var startTimer = Timer()

    
    override func main() {
        startTimer = Timer(fireAt: Date(timeIntervalSinceNow: 3.0), interval: 6.0/*secondsPerDay*/, target: self, selector: #selector(alarmStarts), userInfo: nil, repeats: true)

        runLoop.add(self.startTimer, forMode: .default)
        self.startTimer.tolerance = 5.0
    }
    
    @objc func alarmStarts() {
        // TODO
        print("hello?")
        scheduleNotifications()
    }
}
