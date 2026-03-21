# Quiz 2
###### Student Num: 1008837840
###### utoid: wuchangz
###### name: Changze Wu


### Question 1 Data Ingestion and Graph Creation (20 marks):
##### Data Description:
###### Dataset:
>1. **Suppliers:** (`: Supplier {name: String, location: String, score： Float}`)
>2. **Manufacturers:** ( `: Manufacturer {name : String, location : String, capacity : Int}`)
>3. **Distributors:** (`: Distributor {name : String, location : String, efficiency : Float}`)
>4. **Products:** (` : Product {name : String, category : String, cost : Int}`)
###### Relationship:
>1. **SUPPLIES:** (`(:Supplier)-[:SUPPLIES {cost: Int}]->(:Manufacturer)`)
>2. **MANUFACTURES:** (`(:Manufacturer)-[:MANUFACTURES {time: Int}]->(:Product)`)
>3. **DISTRIBUTES:** (`(:Distributor)-[:DISTRIBUTES {time: Int}]->(:Product)`)

##### Cypher Queries:
```
// Create Supplier nodes
CREATE (:Supplier {name: 'S1', location: 'L1', score: 0.1}),
       (:Supplier {name: 'S2', location: 'L2', score: 0.8});

// Create Manufacturer nodes
CREATE (:Manufacturer {name: 'M1', location: 'L1', capacity: 1000}),
       (:Manufacturer {name: 'M2', location: 'L2', capacity: 2000});

// Create Distributor nodes
CREATE (:Distributor {name: 'D1', location: 'L1', efficiency: 0.75}),
       (:Distributor {name: 'D2', location: 'L2', efficiency: 0.85});

// Create Product nodes
CREATE (:Product {name: 'P1', category: 'C1', cost: 500}),
       (:Product {name: 'P2', category: 'C2', cost: 600});

// Create relationships
MATCH (s:Supplier {name: 'S1'}), (m:Manufacturer {name: 'M1'})
CREATE (s)-[:SUPPLIES {cost: 50}]->(m);

MATCH (m:Manufacturer {name: 'M1'}), (p:Product {name: 'P1'})
CREATE (m)-[:MANUFACTURES {time: 10}]->(p);

MATCH (d:Distributor {name: 'D1'}), (p:Product {name: 'P1'})
CREATE (d)-[:DISTRIBUTES {time: 5}]->(p);
```

### Question 2: Identify Key Suppliers Based on Reliability and Cost (20 marks):
##### Cypher Queries:
```
MATCH (s:Supplier)-[r:SUPPLIES]->(m:Manufacturer)
RETURN s.name AS Supplier,
       COUNT(m) AS ManufacturersSupplied,
       s.reliability AS Reliability,
       SUM(r.cost) AS TotalTransportationCost,
       COUNT(m) * s.reliability / SUM(r.cost) AS Score
ORDER BY Score DESC
LIMIT 1;
```

### Question 3: Find Top Manufacturers by Capacity and Production Time (20 marks):
##### Cypher Queries:
```
MATCH (m:Manufacturer)-[r:MANUFACTURES]->(p:Product)
RETURN m.name AS Manufacturer,
       m.capacity AS Capacity,
       AVG(r.time) AS AvgProductionTime,
       m.capacity / AVG(r.time) AS Efficiency
ORDER BY Efficiency DESC
LIMIT 3;
```


### Question 4: Analyze Distribution Efficiency (20 marks):
##### Cypher Queries:
```
MATCH (d:Distributor)-[r:DISTRIBUTES]->(p:Product)
RETURN d.name AS Distributor,
       COUNT(p) AS ProductsDistributed,
       d.efficiency AS Efficiency,
       AVG(r.time) AS AvgDeliveryTime,
       COUNT(p) * d.efficiency / AVG(r.time) AS Score
ORDER BY Score DESC
LIMIT 1;
```

### Question 5: Identify the Most Expensive Product to Produce (20 marks)
##### Cypher Queries:
```
MATCH (s:Supplier)-[r1:SUPPLIES]->(m:Manufacturer)-[r2:MANUFACTURES]->(p:Product)<-[r3:DISTRIBUTES]-(d:Distributor)
RETURN p.name AS Product,
       r1.cost + p.cost + r3.time AS TotalCost
ORDER BY TotalCost DESC
LIMIT 1;
```

### Bonus: Supply Chain Optimization (20 marks)
##### Cypher Queries:
```
MATCH (s:Supplier)-[r1:SUPPLIES]->(m:Manufacturer)-[r2:MANUFACTURES]->(p:Product)<-[r3:DISTRIBUTES]-(d:Distributor)
RETURN p.name AS Product,
       s.name AS Supplier,
       m.name AS Manufacturer,
       d.name AS Distributor,
       r1.cost + r2.time + r3.time AS TotalCost,
       s.reliability * d.efficiency AS ReliabilityEfficiencyScore
ORDER BY TotalCost ASC, ReliabilityEfficiencyScore DESC
LIMIT 1;
```