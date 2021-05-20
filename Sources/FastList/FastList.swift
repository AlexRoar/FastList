public class FastList<T>: CustomStringConvertible {
    enum FastListError: Error {
        case invalidIndex(ind: UInt)
        case underflow
    }

    struct ListNode {
        var value:T;
        var valid:Bool;
        
        var next:UInt;
        var prev:UInt;
    }
    
    var storage:UnsafeMutablePointer<ListNode>
    var capacity:UInt;
    var size:UInt;
    
    var count: Int{
        Int(size)
    }
    
    var isEmpty: Bool{
        size == 0
    }
    
    
    var freeAreaSize:UInt;
    var freeAreaPos:UInt;
    
    var optimized:Bool
    
    var sumSize:UInt {
        freeAreaSize + size
    }
    
    func deinitMemory() {
        var indNow = storage[0].next;
        var counter = 0;
        while(indNow != 0 && counter < size) {
            let offsetPointer = storage + Int(indNow)
            offsetPointer.deinitialize(count: 1)
            indNow = storage[Int(indNow)].next
            counter += 1;
        }
        
        indNow = freeAreaPos
        for _ in 0..<freeAreaSize {
            let offsetPointer = storage + Int(indNow)
            offsetPointer.deinitialize(count: 1)
            indNow = storage[Int(indNow)].next
        }
    }
    
    deinit {
        deinitMemory();
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
        storage = UnsafeMutablePointer<ListNode>.allocate(capacity: Int(capacity))
        storage[0].next = 0
        storage[0].prev = 0
        storage[0].valid = false
        optimized = true
    }
    
    public var description: String {
        let mirror = Mirror(reflecting: self)
        var out:String = "\(mirror.subjectType) {\n"
        var indNow = storage[0].next;
        var counter = 0;
        while(indNow != 0 && counter < size) {
            out += "\(storage[Int(indNow)].value)"
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
        storage.deallocate();
        storage = newStorage
    }
    
    func reallocate() {
        if (size + 1 >= capacity){
            setCapacity(capacity * 2)
        }
    }
    
    func getFreePos() -> UInt {
        reallocate()
        if (freeAreaSize != 0){
            let freePosNow = freeAreaPos
            freeAreaPos = storage[Int(freeAreaPos)].next
            freeAreaSize -= 1
            storage[Int(freePosNow)].valid = true
            return freePosNow
        }
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
    
    @discardableResult public func pushBack(value: T) -> UInt {
        return try! insertAfter(pos: storage[0].prev, value: value);
    }
    
    @discardableResult public func append(value: T) -> UInt {
        return try! insertAfter(pos: storage[0].prev, value: value);
    }
    
    @discardableResult public func pushFront(value: T) -> UInt {
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
    
    public func getBy(id:UInt) throws -> T {
        if (id > capacity || !storage[Int(id)].valid){
            throw FastListError.invalidIndex(ind: id)
        }
        return storage[Int(id)].value
    }
    
    func addFreePos(pos: Int) {
        storage[pos].valid = false;
        storage[pos].prev = UInt(pos);
        storage[pos].next = UInt(pos);
        
        if (freeAreaSize == 0) {
            freeAreaSize = 1;
            freeAreaPos = UInt(pos);
        } else {
            freeAreaSize += 1;
            storage[pos].next = freeAreaPos;
            freeAreaPos = UInt(pos);
        }
    }
    
    public func set(pos: UInt, value:T) throws {
        if (!storage[Int(pos)].valid){
            throw FastListError.invalidIndex(ind: pos)
        }
        storage[Int(pos)].value = value
    }
    
    public func get(pos: UInt) throws -> T {
        if (!storage[Int(pos)].valid){
            throw FastListError.invalidIndex(ind: pos)
        }
        return storage[Int(pos)].value
    }
    
    public func remove(physical: UInt) throws {
        if (size == 0){
            throw FastListError.underflow
        }
        if (!storage[Int(physical)].valid){
            throw FastListError.invalidIndex(ind: physical)
        }
        
        if (physical != storage[0].prev){
            optimized = false;
        }
        
        let pos = Int(physical)

        storage[Int(storage[pos].next)].prev = storage[pos].prev;
        storage[Int(storage[pos].prev)].next = storage[pos].next;

        addFreePos(pos: pos)
        size -= 1;
    }
    
    public func remove(logical: UInt) throws {
        if (size == 0){
            throw FastListError.underflow
        }
        let ind:Int? = logicToPhysic(logic: Int(logical))
        if (ind == nil){
            throw FastListError.invalidIndex(ind: logical)
        }
        try remove(physical: UInt(ind!))
    }
    
    public func popBack() throws {
        try remove(physical: storage[0].prev)
    }
    
    public func popFront() throws {
        try remove(physical: storage[0].next)
    }
    
    public func clear() {
        deinitMemory()
        size = 0
        freeAreaPos = 0
        freeAreaSize = 0
    }
    
    public func getSize() -> UInt {
        size
    }
    
    @discardableResult public func insert(index:Int, value:T) throws -> UInt {
        let ind:Int? = logicToPhysic(logic: index)
        if (ind == nil){
            throw FastListError.invalidIndex(ind: UInt(index))
        }
        
        return try insertBefore(pos: UInt(ind!), value: value)
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
    
    public func reserveCapacity(_ newCapacity:UInt) {
        setCapacity(newCapacity: newCapacity > capacity ? newCapacity: capacity)
    }
}
