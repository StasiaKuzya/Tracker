//
//  TrackerTests.swift
//  TrackerTests
//
//  Created by Анастасия on 07.03.2024.
//

import XCTest
@testable import Tracker
import SnapshotTesting

final class TrackerTests: XCTestCase {

     func testViewController() {
//         isRecording = true
         let vc = TrackerViewController()
         assertSnapshot(matching: vc, as: .image)
     }
    
}
