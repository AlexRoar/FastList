    import XCTest
    @testable import FastList

    final class FastListTests: XCTestCase {
        func testInit() {
            let _ = FastList<Int>(capacity: 128)
        }
        
        func testFillForward() {
            let list = FastList<Int>(capacity: 0)
            
            for i in 0...1024 {
                list.pushBack(value: i)
            }
            
            for i in 0...1024 {
                XCTAssertEqual(list[i], i)
            }
        }
        
        func testFillBackward() {
            let list = FastList<Int>(capacity: 0)
            
            for i in 0...1024 {
                list.pushFront(value: i)
            }
            
            for i in 0...1024 {
                XCTAssertEqual(list[i], 1024 - i)
            }
        }
        
        func testFillForwardFast() {
            let list = FastList<Int>(capacity: 0)
            
            var savedInd:[(UInt, Int)] = []
            
            for i in 0...1024 {
                savedInd.append((list.pushBack(value: i), i))
            }
            
            for i in 0..<savedInd.count {
                XCTAssertEqual(try? list.getBy(id: savedInd[i].0), savedInd[i].1)
            }
        }
        
        func testFillBackwardFast() {
            let list = FastList<Int>(capacity: 0)
            
            var savedInd:[(UInt, Int)] = []
            
            for i in 0...1024 {
                savedInd.append((list.pushFront(value: i), i))
            }
            
            for i in 0..<savedInd.count {
                XCTAssertEqual(try? list.getBy(id: savedInd[i].0), savedInd[i].1)
            }
        }
    }
