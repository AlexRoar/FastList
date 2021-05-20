public class FastList<T>: CustomStringConvertible, Collection, Sequence {
    public func index(after i: Int) -> Int {
        Int(storage[i].next)
    }
    
    public var startIndex: Int {
        0
    }
    
    public var endIndex: Int {
        0
    }
    
    enum FastListError: Error {
        case invalidIndex(ind: UInt)
        case underflow
    }

    struct ListNode {
        var value:T?;
        var valid:Bool;
        
        var next:UInt;
        var prev:UInt;
        
        init(){
            value = nil
            valid = false
            next = 0
            prev = 0
        }
    }
    
    var storage:UnsafeMutablePointer<ListNode>
    var capacity:UInt;
    var size:UInt;
    
    public var count: Int {
        Int(size)
    }
    
    public var isEmpty: Bool {
        size == 0
    }
    
    
    var freeAreaSize:UInt;
    var freeAreaPos:UInt;
    
    var optimized:Bool
    
    var sumSize:UInt {
        freeAreaSize + size
    }
    
    func initMemory(pointer: UnsafeMutablePointer<ListNode>, size: UInt){
        pointer.initialize(repeating: ListNode(), count: Int(size))
    }
    
    deinit {
        storage.deinitialize(count: Int(capacity))
        storage.deallocate();
    }

    
    public init(capacity initCapacity:UInt = 16) {
        size = 0
        freeAreaPos = 0
        freeAreaSize = 0
        capacity = initCapacity
        if (capacity == 0){
            capacity = 1
        }
        optimized = true
        storage = UnsafeMutablePointer<ListNode>.allocate(capacity: Int(capacity))
        initMemory(pointer: storage, size: capacity)
        storage[0].next = 0
        storage[0].prev = 0
        storage[0].valid = false
        
    }
    
    public var description: String {
        let mirror = Mirror(reflecting: self)
        var out:String = "\(mirror.subjectType) {\n"
        var indNow = storage[0].next;
        var counter = 0;
        while(indNow != 0 && counter < size) {
            out += "\(String(describing: storage[Int(indNow)].value!))"
            if (counter != size - 1){
                out += ", "
            }
            indNow = storage[Int(indNow)].next
            counter += 1;
        }
        out += "\n}"
        return out
    }
    
    func setCapacity(newCapacity: UInt){
        let lastCapacity = capacity
        capacity = newCapacity
        let newStorage = UnsafeMutablePointer<ListNode>.allocate(capacity: Int(capacity))
        newStorage.moveInitialize(from: storage, count: Int(lastCapacity))
        initMemory(pointer: newStorage.advanced(by: Int(lastCapacity)),
                   size: (capacity - lastCapacity))
        storage.deallocate();
        storage = newStorage
    }
    
    func reallocate() {
        if (size + 1 >= capacity){
            setCapacity(newCapacity: capacity * 2)
        }
    }
    
    func getFreePos() -> UInt {
        if (freeAreaSize != 0) {
            let freePosNow = freeAreaPos
            freeAreaPos = storage[Int(freeAreaPos)].next
            freeAreaSize -= 1
            storage[Int(freePosNow)].valid = true
            return freePosNow
        }
        reallocate()
        storage[Int(size + 1)].valid = true
        return size + 1
    }
    
    func insertAfter(pos: UInt, value: T) throws -> UInt  {
        if (pos > sumSize + 1 || (!storage[Int(pos)].valid && pos != 0)){
            throw FastListError.invalidIndex(ind: pos)
        }
        let newPos = getFreePos()
        
        if (newPos != size + 1){
            optimized = false
        }

        storage[Int(newPos)].value = value
        storage[Int(newPos)].prev = pos
        storage[Int(newPos)].next = storage[Int(pos)].next;
        storage[Int(storage[Int(pos)].next)].prev = newPos;
        storage[Int(pos)].next = newPos;

        size += 1;
        
        return newPos
    }
    
    func insertBefore(pos: UInt, value: T) throws -> UInt  {
        if (pos > sumSize || pos == 0){
            throw FastListError.invalidIndex(ind: pos)
        }
        let afterPos = storage[Int(pos)].prev;
        return try insertAfter(pos: afterPos, value: value)
    }
    
    @discardableResult public func append(value: T) -> UInt {
        return try! insertAfter(pos: storage[0].prev, value: value);
    }
    
    @discardableResult public func appendFront(value: T) -> UInt {
        optimized = false
        return try! insertAfter(pos: 0, value: value);
    }
    
    public func logicToPhysic(logic: Int, forward:Bool = true) -> Int? {
        if (optimized){
            return logic + 1;
        }
        if (logic >= size){
            return nil
        }
        var indStart = Int(forward ? storage[0].next : storage[0].prev)
        for _ in 0..<logic {
            indStart = Int(forward ? storage[indStart].next : storage[indStart].prev)
        }
        return indStart
    }
    
    public func get(physic:UInt) -> T? {
        if (physic >= capacity || !storage[Int(physic)].valid){
            return nil
        }
        return storage[Int(physic)].value
    }
    
    func addFreePos(pos: Int) {
        storage[pos].value = nil
        storage[pos].valid = false;
        storage[pos].prev = UInt(pos);
        storage[pos].next = UInt(pos);
        
        if (freeAreaSize != 0) {
            storage[pos].next = freeAreaPos;
        }
        freeAreaSize += 1;
        freeAreaPos = UInt(pos);
    }
    
    public func set(physic: UInt, value:T) throws {
        if (!storage[Int(physic)].valid){
            throw FastListError.invalidIndex(ind: physic)
        }
        storage[Int(physic)].value = value
    }
    
    public func remove(physic: UInt) throws {
        if (size == 0){
            throw FastListError.underflow
        }
        if (!storage[Int(physic)].valid){
            throw FastListError.invalidIndex(ind: physic)
        }
        
        if (physic != storage[0].prev){
            optimized = false;
        }
        
        let pos = Int(physic)

        storage[Int(storage[pos].next)].prev = storage[pos].prev;
        storage[Int(storage[pos].prev)].next = storage[pos].next;

        addFreePos(pos: pos)
        size -= 1;
    }
    
    public func remove(logic: UInt) throws {
        if (size == 0){
            throw FastListError.underflow
        }
        let ind:Int? = logicToPhysic(logic: Int(logic))
        if (ind == nil){
            throw FastListError.invalidIndex(ind: logic)
        }
        try remove(physic: UInt(ind!))
    }
    
    public func popBack() throws {
        try remove(physic: storage[0].prev)
    }
    
    public func popFront() throws {
        try remove(physic: storage[0].next)
    }
    
    public func clear() {
        size = 0
        freeAreaPos = 0
        freeAreaSize = 0
    }
    
    @discardableResult public func insert(logic:Int, value:T) throws -> UInt {
        let ind:Int? = logicToPhysic(logic: logic)
        if (ind == nil){
            throw FastListError.invalidIndex(ind: UInt(logic))
        }
        
        return try insertBefore(pos: UInt(ind!), value: value)
    }
    
    @discardableResult public func insert(physic:Int, value:T) throws -> UInt {
        return try insertBefore(pos: UInt(physic), value: value)
    }
    
    public subscript(index:Int) -> T? {
        get {
            let ind:Int? = logicToPhysic(logic: index)
            if (ind == nil){
                return nil
            }
            return storage[ind!].value
        }
        set(newElm) {
            let ind:Int? = logicToPhysic(logic: index)
            if (ind == nil){
                return
            }
            storage[ind!].value = newElm!
            }
        }
    
    public func isOptimized() -> Bool {
        optimized
    }
    
    public func reserveCapacity(_ newCapacity:Int) {
        setCapacity(newCapacity: UInt(newCapacity > capacity ? UInt(newCapacity): capacity))
    }
    
    public func optimize() {
        if (optimized){
            return
        }
        let newStorage = UnsafeMutablePointer<ListNode>.allocate(capacity: Int(capacity))
        newStorage.initialize(repeating: ListNode(), count: Int(capacity))
        
        var nowPos = storage[0].next
            
        for i in 0..<count {
            newStorage[i + 1].value = storage[Int(nowPos)].value
            newStorage[i + 1].valid = true
            newStorage[i + 1].prev = UInt(i)
            newStorage[i].next = UInt(i + 1)
            
            nowPos = storage[Int(nowPos)].next
        }
        storage.initialize(repeating: ListNode(), count: Int(sumSize))
        
        newStorage[0].prev = size
        newStorage[count].next = 0
        
        optimized = true
        freeAreaPos = 0
        freeAreaSize = 0
        
        storage.deinitialize(count: Int(capacity))
        storage.deallocate()
        storage = newStorage
    }
}
