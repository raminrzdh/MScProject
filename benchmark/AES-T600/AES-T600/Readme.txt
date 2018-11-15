1.Home directory includes:

1.1 src
	---Codes for the AES algorithm, the test bench, and the Trojan

2.Trojan
Trojan Description
	After detecting a specific input plaintext, the Trojan leaks the secret key of AES-128 through the leakage current. 
	The leakage circuit (LC) consists of a shift register holding the secret key and two inverters. The least significant 
	bit of the shift register is connected to one inverter whose output connected to the input of the other inverter. 
	Whenever the least significant bit is '0', a direct path between power and ground composed by the PMOS of the first 
	inverter and the NMOS of the second inverter is created for a limited time. Therefore, the secret key can be retrieved 
	by measuring the leakage current.


Trojan Taxonomy
	Insertion phase: Design
	Abstraction level: Register Transfer level  
	Activation mechanism: Internally conditionally triggered
	Effects: Leak Information
 	Location: Processor
	Physical characteristics: Functional