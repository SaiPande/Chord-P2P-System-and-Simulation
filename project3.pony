use "collections"
use "time"
use "random"

actor Main
  new create(env: Env) =>
    let args = env.args
    if args.size() < 3 then
      env.out.print("Usage: chord <numNodes> <numRequests>")
      return
    end

    let num_nodes = try args(1)?.usize()? else 0 end
    let num_requests = try args(2)?.usize()? else 0 end
    ChordSystem(env, num_nodes, num_requests)

actor ChordSystem
  let _env: Env
  let _num_nodes: USize
  let _num_requests: USize
  let _m: USize
  let _node_list: Array[U64] val
  var _initial_node: U64 = 0
  let _max_uint: U64 = U64.max_value()
  let _nodes: Map[U64, ChordNode] = Map[U64, ChordNode]
  var _total_node_jumps: I64 = 0
  var _keys_found: I64 = 0

  new create(env: Env, num_nodes: USize, num_requests: USize) =>
    _env = env
    _num_nodes = num_nodes
    _num_requests = num_requests
    _m = (_num_nodes.f64().log2().ceil()).usize()
    _node_list = recover val
      let temp = Array[U64]
      for i in Range(0, num_nodes) do
        temp.push(ConstructHash("child" + i.string()))
      end
      Sort[Array[U64], U64](temp)
      temp
    end
    _initialize_network()

  be _initialize_network() =>
    _env.out.print("Initializing the network")
    for node_id in _node_list.values() do
      _nodes(node_id) = ChordNode(this, node_id, _m)
    end
    _initial_node = try _node_list(0)? else 0 end

    for (i, node_id) in _node_list.pairs() do
      try _nodes(node_id)?.initialize(i, _node_list) end
    end

    _start_requests()

  be _start_requests() =>
    let rng = Rand
    for j in Range(0, _num_requests) do
      for i in Range(0, _num_nodes) do
        let random_num = rng.int(_num_nodes.u64())
        let rand_add = rng.int(1000)
        try
          let node_id = _node_list(i)?
          _nodes(node_id)?.find_successor(try _node_list(random_num.usize())? + rand_add else 0 end, 0, "", 0)
        end
      end
      _env.out.print(_num_nodes.string() + " actors processed " + (j + 1).string() + " requests")
    end

  be closest_preceding_node(key: U64, node: U64, start: U64, task: String, ind: USize) =>
    if start < 10 then
      _total_node_jumps = _total_node_jumps + 1
    end
    try _nodes(node)?.find_successor(key, start, task, ind) end

  be found_successor() =>
    _keys_found = _keys_found + 1
    if _keys_found == (_num_nodes.i64() * _num_requests.i64()) then
      let avg_jumps = (_total_node_jumps.f64() / _keys_found.f64())
      _env.out.print("Average jumps for all lookups: " + avg_jumps.string())
    end

primitive ConstructHash
  fun apply(input: String): U64 =>
    var hash: U64 = 5381
    for c in input.values() do
      hash = ((hash << 5) + hash) + c.u64()
    end
    hash

actor ChordNode
  let _system: ChordSystem
  let _node_name: U64
  let _m: USize
  var _node_id: USize = 0
  var _successor: U64 = 0
  var _predecessor: U64 = 0
  var _dht: Array[U64] = Array[U64]

  new create(system: ChordSystem, node_name: U64, m: USize) =>
    _system = system
    _node_name = node_name
    _m = m
    _dht = Array[U64].init(0, _m)

  be initialize(id: USize, node_list: Array[U64] val) =>
    _node_id = id
    for i in Range(0, _m) do
      let index = ((id.f64() + (2 << i).f64()) % node_list.size().f64()).usize()
      try _dht(i)? = node_list(index)? end
    end

    if id == (node_list.size() - 1) then
      _predecessor = try node_list(node_list.size() - 2)? else 0 end
      _successor = try node_list(0)? else 0 end
    elseif id == 0 then
      _predecessor = try node_list(node_list.size() - 1)? else 0 end
      _successor = try node_list(1)? else 0 end
    else
      _predecessor = try node_list(id - 1)? else 0 end
      _successor = try node_list(id + 1)? else 0 end
    end

  be find_successor(key: U64, start: U64, task: String, ind: USize) =>
    var not_found = true
    try
      if ((key >= _node_name) and (key <= _dht(0)?)) or
         ((key >= _node_name) and (_node_name > _dht(0)?)) then
        not_found = false
        if start > 0 then
          _system.closest_preceding_node(key, _successor, start, task, ind)
        else
          _system.found_successor()
        end
      else
        for i in Range(0, _m) do
          if _dht(i)? == key then
            not_found = false
            if start > 0 then
              _system.closest_preceding_node(key, _successor, start, task, ind)
            else
              _system.found_successor()
            end
            break
          elseif (i < (_m - 1)) and
                  (((key < _dht(i + 1)?) and (key > _dht(i)?)) or
                  (_dht(i + 1)? < _dht(i)?)) then
            not_found = false
            _system.closest_preceding_node(key, _dht(i)?, start, task, ind)
            break
          end
        end
      end

      if not_found then
        _system.closest_preceding_node(key, _dht(_m - 1)?, start, task, ind)
      end
    end

  be fix_fingers() =>
    for i in Range(0, _m) do
      let remaining_ring_space = U64.max_value() - _node_name
      let new_add = (2 << i).u64()
      let address = if new_add > remaining_ring_space then
        new_add - remaining_ring_space
      else
        _node_name + new_add
      end
      _system.closest_preceding_node(address, _node_name, _node_name, "fingerTable", i)
    end

  be update_finger_table(ind: USize, value: U64) =>
    try _dht(ind)? = value end

  be update_successor(value: U64) =>
    _successor = value
