    import XCTest
    @testable import FastList
    
    class Leaker {
        public var id: UUID
        static public var counter:Int = 0
        
        public init() {
            id = UUID()
            Leaker.counter += 1
        }
        
        deinit {
            Leaker.counter -= 1
        }
        
        public func getId()-> UUID {
            id
        }
    }

    final class FastListTests: XCTestCase {
        func testInit() {
            let _ = FastList<Int>(capacity: 128)
        }
        
        func testFillForward() {
            let list = FastList<Int>(capacity: 0)
            
            for i in 0...1024 {
                list.pushBack(value: i)
                XCTAssertEqual(list.isOptimized(), true)
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
            XCTAssertEqual(list.isOptimized(), false)
            
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
        
        func testleakCheck() {
            let list = FastList<Leaker>(capacity: 0)
            
            
            for _ in 0...1024 {
                list.pushBack(value: Leaker())
            }
            
            for _ in 0...1024 {
                list.pushFront(value: Leaker())
            }
            
            list.clear()
            
            XCTAssertEqual(Leaker.counter, 0)
        }
        
        func testleakCheckRemovals() {
            let list = FastList<Leaker>(capacity: 0)
            
            
            for _ in 0...1024 {
                list.pushBack(value: Leaker())
            }
            
            for _ in 0...1024 {
                list.pushFront(value: Leaker())
            }
            
            try! list.remove(physical: 2)
            try! list.remove(physical: 20)
            
            list.clear()
            
            XCTAssertEqual(Leaker.counter, 0)
        }
        
        func testleakCheckClear() {
            let list = FastList<Leaker>(capacity: 0)
            
            
            for _ in 0...1024 {
                list.pushBack(value: Leaker())
            }
            
            for _ in 0...1024 {
                list.pushFront(value: Leaker())
            }
            
            list.clear()
            
            XCTAssertEqual(Leaker.counter, 0)
        }
        
        func testleakCheckDeinit() {
            let list = FastList<Leaker>(capacity: 0)
            
            
            for _ in 0...1024 {
                list.pushBack(value: Leaker())
            }
            
            print(Leaker.counter)
            
            for _ in 0...1024 {
                list.pushFront(value: Leaker())
            }
            
            try! list.remove(physical: 2)
            try! list.remove(physical: 20)
            
            for _ in 0...1024 {
                list.pushFront(value: Leaker())
            }
            list.clear()
            XCTAssertEqual(Leaker.counter, 0)
        }
        
       func evaluateProblem(_ problemBlock: () -> Void) -> Double {

            let start = DispatchTime.now() // <<<<<<<<<< Start time
            problemBlock()
            let end = DispatchTime.now()   // <<<<<<<<<<   end time

            let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds
            let timeInterval = Double(nanoTime) / 1_000_000_000

            return timeInterval
        }
        
        func testlistCompareRemovals() {
            let testSize = 20_000
            let speedTestList = {
                var list = Array<Int>()
                
                for i in 0...testSize {
                    list.append(i)
                }
                
                for i in 0...testSize {
                    let _ = list[i]
                }
                
                for _ in 0..<testSize {
                    list.remove(at: 0)
                }

            }
            
            let speedTestFastList = {
                let list = FastList<Int>()
                
                for i in 0...testSize {
                    list.pushBack(value: i)
                }
                
                XCTAssertEqual(list.isOptimized(), true)
                
                for i in 0...testSize {
                    let _ = list[i]
                }
                
                for _ in 0..<testSize {
                    try! list.remove(logical: 0)
                }
            }
            
            XCTAssertLessThan(evaluateProblem(speedTestFastList), evaluateProblem(speedTestList))
        }
        
        func testlistCompareRemovalsRandom() {
            let testSize = 20_000
            let speedTestList = {
                var list = Array<Int>()
                
                for i in 0...testSize {
                    list.append(i)
                }
                
                for i in 0...testSize {
                    let _ = list[i]
                }
                
                for i in 0..<testSize {
                    list.remove(at: (i % list.count))
                }
            }
            
            let speedTestFastList = {
                let list = FastList<Int>()
                
                for i in 0...testSize {
                    list.pushBack(value: i)
                }
                
                XCTAssertEqual(list.isOptimized(), true)
                
                for i in 0...testSize {
                    let _ = list[i]
                }
                
                for i in 0..<testSize {
                    try! list.remove(physical: UInt(i + 1))
                }
            }
            
            XCTAssertLessThan(evaluateProblem(speedTestFastList), evaluateProblem(speedTestList))
        }
    }
