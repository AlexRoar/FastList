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
                XCTAssertEqual(list.get(physic: savedInd[i].0), savedInd[i].1)
            }
        }
        
        func testFillBackwardFast() {
            let list = FastList<Int>(capacity: 0)
            
            var savedInd:[(UInt, Int)] = []
            
            for i in 0...1024 {
                savedInd.append((list.pushFront(value: i), i))
            }
            
            for i in 0..<savedInd.count {
                XCTAssertEqual(list.get(physic: savedInd[i].0), savedInd[i].1)
            }
        }
        
        func testleakCheck() {
            var list:FastList? = FastList<Leaker>(capacity: 0)
            
            for _ in 0...1024 {
                list!.pushBack(value: Leaker())
            }
            for _ in 0...1024 {
                list!.pushFront(value: Leaker())
            }
            
            list = nil
            
            XCTAssertEqual(Leaker.counter, 0)
        }
        
        func testleakCheckRemovals() {
            var list:FastList? = FastList<Leaker>(capacity: 0)
            
            
            for _ in 0...1024 {
                list!.pushBack(value: Leaker())
            }
            
            for _ in 0...1024 {
                list!.pushFront(value: Leaker())
            }
            
            try! list!.remove(physic: 2)
            try! list!.remove(physic: 20)
            
            list = nil
            
            XCTAssertEqual(Leaker.counter, 0)
        }
        
        func testleakCheckClear() {
            var list:FastList? = FastList<Leaker>(capacity: 0)
            
            
            for _ in 0...1024 {
                list!.pushBack(value: Leaker())
            }
            
            for _ in 0...1024 {
                list!.pushFront(value: Leaker())
            }
            
            list = nil
            
            XCTAssertEqual(Leaker.counter, 0)
        }
        
        func testleakCheckDeinit() {
            var list:FastList? = FastList<Leaker>(capacity: 0)
            
            
            for _ in 0...1024 {
                list!.pushBack(value: Leaker())
            }
        
            
            for _ in 0...1024 {
                list!.pushFront(value: Leaker())
            }
            
            try! list!.remove(physic: 2)
            try! list!.remove(physic: 20)
            
            for _ in 0...1024 {
                list!.pushFront(value: Leaker())
            }
            list = nil
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
            let testSize = 100_000
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
                    try! list.remove(logic: 0)
                }
            }
            
            let eval = (evaluateProblem(speedTestFastList), evaluateProblem(speedTestList))
            
            XCTAssertLessThan(eval.0, eval.1)
            print("Remove speed difference: \(eval.0 * 100.0 / eval.1)%")
        }
        
        func testlistCompareRemovalsRandom() {
            let testSize = 100_000
            let speedTestList = {
                var list = Array<Int>()
                list.reserveCapacity(testSize)
                
                for i in 0...testSize {
                    list.append(i)
                }
                
                for i in 0..<testSize {
                    list.remove(at: (i % list.count))
                }
            }
            
            let speedTestFastList = {
                let list = FastList<Int>()
                list.reserveCapacity(testSize)
                
                for i in 0...testSize {
                    list.append(value: i)
                }
                
                XCTAssertEqual(list.isOptimized(), true)
                
                for i in 0..<testSize {
                    try! list.remove(physic: UInt(i + 1))
                }
            }
            
            let eval = (evaluateProblem(speedTestFastList), evaluateProblem(speedTestList))
            
            XCTAssertLessThan(eval.0, eval.1)
            print("Remove random speed difference: \(eval.0 * 100.0 / eval.1)%")
        }
        
        func testpushFront() {
            let testSize = 100_000
            let speedTestList = {
                var list = Array<Int>()
                list.reserveCapacity(testSize)
                
                for i in 0...testSize {
                    list.insert(i, at: 0)
                }
            }
            
            let speedTestFastList = {
                let list = FastList<Int>()
                list.reserveCapacity(testSize)
                
                for i in 0...testSize {
                    list.pushFront(value: i)
                }
            }
            
            let eval = (evaluateProblem(speedTestFastList), evaluateProblem(speedTestList))
            
            XCTAssertLessThan(eval.0, eval.1)
            print("Insert front speed difference: \(eval.0 * 100.0 / eval.1)%")
        }
        
        func testSequence() {
            let list = FastList<Int>()
            
            
            for i in 0...1024 {
                list.append(value: i)
            }
            
            var count = 0;
            for i in list {
                XCTAssertEqual(i, count)
                count += 1
            }
        }
        
        func testoptimizationBasic () {
            let testSize = 100_000
            let list = FastList<Int>()
            
            for i in 0...testSize {
                list.pushBack(value: i)
            }
            
            var count = 0
            
            for i in list {
                XCTAssertEqual(i, count)
                count += 1
            }
            
            list.optimize()
            XCTAssertTrue(list.isOptimized())
            
            for i in list {
                XCTAssertEqual(i, count)
                count += 1
            }
        }
        
        func testoptimizationFront () {
            let testSize = 100_000
            let list = FastList<Int>()
            
            for i in 0...testSize {
                list.pushFront(value: i)
            }
            
            XCTAssertFalse(list.isOptimized())
            
            var count = 0
            
            for i in list {
                XCTAssertEqual(i, count)
                count += 1
            }
            
            list.optimize()
            XCTAssertTrue(list.isOptimized())
            
            for i in list {
                XCTAssertEqual(i, count)
                count += 1
            }
        }
        
        func testoptimizationRandRemovals () {
            let testSize = 100_000
            let list = FastList<Int>()
            
            for i in 0...testSize {
                list.pushBack(value: i)
            }
            
            XCTAssertTrue(list.isOptimized())
            
            var count = 0
            
            for i in list {
                XCTAssertEqual(i, count)
                count += 1
            }
            
            var removed = Set<Int>()
            
            for _ in 0...100 {
                var indPhy = Int.random(in: 1...list.count)
                while (removed.contains(indPhy)) {
                    indPhy = Int.random(in: 1...list.count)
                }
                removed.insert(indPhy)
                XCTAssertNoThrow(try list.remove(physic: UInt(indPhy)))
            }
        
            
            XCTAssertFalse(list.isOptimized())
            list.optimize()
            XCTAssertTrue(list.isOptimized())
        
            
            var add:Int = 0
            for i in 0..<list.count {
                while (removed.contains(i + add + 1)){
                    add += 1
                }
                XCTAssertEqual(list[i], i + add)
            }
        }
    }
