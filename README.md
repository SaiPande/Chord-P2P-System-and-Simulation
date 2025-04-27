# **COP5615: Distributed Operating System Principles**

# **Project 3 - Chord: P2P System and Simulation**

## **Team Members:** <br>
Sai Pande <br>
Arnav Agarval <br>

University of Florida<br>
Computer Science and Information Science Engineering<br>
<br>
 
## **Introduction**
In distributed systems, overlay networks are essential for creating resilient, scalable systems that work without central authority. This project focuses on studying and implementing the Chord protocol, a popular system used in peer-to-peer (P2P) networks. The Chord protocol is known for its ability to quickly find which node in a network holds specific data, making it easier to store and retrieve information across a group of connected, independent nodes.<br>
The goal of this project is to build a simple version of the Chord protocol using Pony language and Actor Model principles. By using Pony’s Actor Model, we can create a network where nodes work independently and communicate effectively, showing how the Chord protocol can enable a reliable, decentralized object-access service.<br>
The main objectives include:<br>
1.	Implement network join and routing as described in the Chord paper<br>
2.	Create a simple key-value store application on top of Chord<br>
3.	Support a configurable number of nodes and requests<br>
4.	Measure the average number of hops for message delivery<br>
5.	Implement the system using actors to model each peer node<br>
<br>

## **Chord Protocol**
Chord protocol, which helps computers in a network locate data efficiently without relying on a central system. Imagine a large group of computers working together to store information; when one computer needs to find a specific piece of data, it has to search through others to locate it.<br>
Here’s a simpler breakdown of how Chord works:<br>
1.	Distributed Storage: Chord spreads data across many computers (or nodes) in a network, so there’s no central storage. Each piece of data has a unique key that maps it to a specific node.<br>
2.	Efficient Searching with Keys: Chord uses keys to find where data is stored. When you want to find data, you only need to know the key, and Chord will help locate the right node storing that key.<br>
3.	Handles Changes Smoothly: In real networks, computers frequently join or leave. Chord is designed to handle these changes automatically and keep the data accessible.<br>
4.	Scalability: Even as the network grows (with more nodes and data), Chord ensures the search time remains short. It achieves this by having each node only know a limited number of other nodes, which keeps the system efficient.<br>
5.	Reliable: If some nodes fail or leave unexpectedly, Chord can still find the data using backup routes, making the network robust.<br>
<br>

## **Problem Statement**
The central challenge in distributed, decentralized networks is locating a node that holds a specific data item in a scalable, efficient manner. Traditional systems struggle with efficient data location, especially as nodes join or leave, requiring a scalable approach that can handle constant network changes without compromising efficiency. The Chord protocol addresses this by assigning keys to nodes through a consistent hashing mechanism and provides an efficient solution that requires only O(log N) state and communication per node, where N is the number of nodes in the system. This project involves implementing the join and routing processes of the Chord protocol to achieve these functionalities. <br>
<br>

**Overview of Chord Algorithm**
              The Chord protocol simplifies key-to-node mapping through a consistent hashing mechanism:<br>
1.	Hashing and Key Assignment: Each node and key is assigned an identifier based on an m-bit hash function. Nodes are arranged in a circular ID space (Chord ring) of 2^m identifiers, where each key is assigned to the node with the identifier closest to it in a clockwise manner.<br>
2.	Lookup Operation: For any given key, the algorithm locates the "successor" node responsible for storing the key. In a network with N nodes, a key lookup requires O(log N) steps by utilizing a finger table at each node, which helps in halving the search space on each hop.<br>
<br>
 
## **Implementation Details**
1.	Pony Language and Actor Model: Each node in the Chord ring is implemented as an independent actor, following the Actor Model, which ensures concurrency and fault tolerance. Each node has a unique actor responsible for handling requests and maintaining its state, including a finger table and successor pointers.<br>
2.	Join Operation: When a new node joins the network, it communicates with existing nodes to identify its successor and predecessor, thereby integrating into the Chord ring. It updates the finger tables and successor lists accordingly.<br>
3.	Routing Mechanism: Each node maintains a finger table with O(log N) entries. This table stores references to other nodes at exponentially increasing intervals around the Chord ring, which enables efficient message routing to any target key.<br>
4.	Data Lookup Requests: The input command initiates a specified number of lookup requests per node, and each node sends one request per second. This allows the calculation of the average number of hops required to locate a node responsible for a given key.<br>
<br>
## **How to Interact with the Program?**
The program is built to be interactive with the user. Once the program is compiled with ponyc command, the user can execute the program using the following command ./project3 10000 10. Where, project3 is the .exe file name, number of nodes is 10000 and 10 is number of requests. In the below example, we get the average hops as 8.22747 for 10000 nodes and 10 requests.<br>
<br>
 
## **Working of the Program**
This code implements a Chord distributed hash table (DHT) system using the Pony programming language. Following are the main components and their functionality:<br>
<br>
Main Components<br>
1.	Main Actor: Entry point of the program<br>
2.	ChordSystem Actor: Manages the overall Chord system<br>
3.	ChordNode Actor: Represents individual nodes in the Chord network<br>
4.	ConstructHash Primitive: Generates hash values for node identifiers<br>
<br>
1.	Main Actor:<br>
•	Parses command-line arguments for the number of nodes and requests<br>
•	Creates a ChordSystem instance with the provided parameters<br>
<br>
2.	ChordSystem Actor:<br>
•	Initializes the Chord network<br>
•	Manages the creation and organization of nodes<br>
•	Handles request distribution and result collection<br>
         Key methods:<br>
•	_initialize_network(): Sets up the Chord network<br>
•	_start_requests(): Initiates lookup requests<br>
•	closest_preceding_node(): Finds the closest preceding node for a given key<br>
•	found_successor(): Tracks successful key lookups<br>
<br>
3.	ChordNode Actor:<br>
The ChordNode actor represents individual nodes in the Chord network:<br>
•	Maintains finger tables, successor, and predecessor information<br>
•	Handles key lookups and finger table updates<br>
<br>
Key methods:<br>
•	initialize(): Sets up the node's initial state<br>
•	find_successor(): Looks up the successor node for a given key<br>
•	fix_fingers(): Updates the finger table entries<br>
•	update_finger_table(): Updates a specific finger table entry<br>
•	update_successor(): Updates the node's successor<br>
<br>
4.	ConstructHash Primitive:<br>
The ConstructHash primitive generates hash values for node identifiers using a simple hash function.<br>
<br>

Workflow:<br>
1.	The program initializes the Chord network with the specified number of nodes.<br>
2.	Each node is assigned a unique identifier and initializes its finger table.<br>
3.	The system starts generating random lookup requests.<br>
4.	Nodes use their finger tables to efficiently route lookup requests.<br>
5.	The system tracks the number of hops required for each lookup.<br>
6.	After processing all requests, the average number of hops is calculated and displayed.<br>
<br>
This implementation demonstrates the core concepts of the Chord DHT, including:<br>
•	Consistent hashing for node and key distribution<br>
•	Finger tables for efficient routing<br>
•	Logarithmic lookup complexity in the number of nodes<br>
The code uses Pony's actor model to handle concurrency and message passing between nodes, making it suitable for distributed systems simulations.<br>
<br>

## **Results:**
Average Hops Analysis: Keeping the number of requests the same number of nodes changed from 5 to 99505 and the average hops were recorded.<br>
'Number of Nodes	Average Jumps<br>
5	0.6<br>
505	4.78059<br>
1005	5.75045<br>
...	...<br>
49005	9.91933<br>
49505	9.93615<br>
50005	9.94927<br>
...	...<br>
74005	10.4018<br>
74505	10.4133<br>
75005	10.4245<br>
...	...<br>
98005	10.6812<br>
98505	10.6874<br>
99005	10.6923<br>'

Through the graph in our report it is evident that our chord network system follows a complexity of O(log N), which is the expected complexity of the chord network. We see that the graph follows a logarithmic curve with increase in number of nodes. In a N-node network, each node has information of O(log N) other nodes.<br>

## **Largest Executed Problem:**
The largest problem we were able to execute was for 250000 number of nodes and 5 number of requests. <br>
<br>

## **What is Working:** 
1.	The Chord network structure is implemented with nodes arranged in a circular identifier space.<br>
2.	A hash function (ConstructHash) is used to generate identifiers for nodes, implementing part of the consistent hashing mechanism.<br>
3.	The system successfully initializes a network of nodes with a specified number of nodes.<br>
4.	Each node maintains a finger table (_dht) with the correct number of entries based on the network size.<br>
5.	The find_successor method implements a basic lookup operation, attempting to find the successor node for a given key.<br>
6.	The system simulates multiple lookup requests across the network, as specified by the user input.<br>
7.	Performance metrics are tracked, including the total number of node jumps and keys found.<br>
8.	The system calculates and reports the average number of jumps for all lookups, providing a basic performance measure.<br>
9.	The code implements a basic structure for updating finger tables (fix_fingers and update_finger_table methods).<br>
10.	The implementation uses Pony's actor model effectively, with separate actors for the overall system (ChordSystem) and individual nodes (ChordNode).<br>
11.	The code handles user input for specifying the number of nodes and requests in the simulation.<br>
<br>

## **Conclusion:**
Implementing the Chord protocol in a distributed, actor-based environment effectively demonstrates the protocol's scalability and resilience in managing P2P lookups. This project verifies that Chord is capable of handling dynamic network changes with minimal performance degradation, achieving logarithmic scalability in both state management and communication costs. Further testing with larger networks provides insights into the practical limitations and scalability of the protocol in real-world settings.
