Create database supplier;
use supplier;
CREATE TABLE Suppliers (
    sid INT PRIMARY KEY,
    sname VARCHAR(50) NOT NULL,
    city VARCHAR(50)
);

CREATE TABLE Parts (
    pid INT PRIMARY KEY,
    pname VARCHAR(50) NOT NULL,
    color VARCHAR(30)
);

CREATE TABLE Catalog (
    sid INT,
    pid INT,
    cost DECIMAL(10,2) NOT NULL CHECK (cost >= 0),
    PRIMARY KEY (sid, pid),
    FOREIGN KEY (sid) REFERENCES Suppliers(sid),
    FOREIGN KEY (pid) REFERENCES Parts(pid)
);

INSERT INTO Suppliers VALUES
(10001, 'Acme Widget', 'Bangalore'),
(10002, 'Johns', 'Kolkata'),
(10003, 'Vimal', 'Mumbai'),
(10004, 'Reliance', 'Delhi');

INSERT INTO Parts VALUES
(20001, 'Book', 'Red'),
(20002, 'Pen', 'Red'),
(20003, 'Pencil', 'Green'),
(20004, 'Mobile', 'Green'),
(20005, 'Charger', 'Black');

INSERT INTO Catalog VALUES
(10001, 20001, 10),
(10001, 20002, 10),
(10001, 20003, 30),
(10001, 20004, 10),
(10001, 20005, 10),
(10002, 20001, 10),
(10002, 20002, 20),
(10003, 20003, 30),
(10004, 20003, 40);

SELECT DISTINCT P.pname
FROM Parts P
JOIN Catalog C
ON P.pid = C.pid order by pname asc;

SELECT S.sname
FROM Suppliers S
WHERE NOT EXISTS (
    SELECT P.pid
    FROM Parts P
    WHERE NOT EXISTS (
        SELECT C.pid
        FROM Catalog C
        WHERE C.sid = S.sid
        AND C.pid = P.pid
    )
);

SELECT S.sname
FROM Suppliers S
WHERE NOT EXISTS (
    SELECT P.pid
    FROM Parts P
    WHERE P.color = 'Red'
    AND NOT EXISTS (
        SELECT C.pid
        FROM Catalog C
        WHERE C.sid = S.sid
        AND C.pid = P.pid
    )
);

SELECT P.PNAME
FROM Parts P
JOIN Catalog C
ON P.PID = C.PID
JOIN Suppliers S
ON C.SID = S.SID
WHERE S.SNAME = 'Acme Widget'
AND NOT EXISTS (
    SELECT *
    FROM Catalog C2
    WHERE C2.PID = P.PID
    AND C2.SID <> S.SID
);

SELECT DISTINCT C1.sid
FROM Catalog C1
WHERE C1.cost > (
    SELECT AVG(C2.cost)
    FROM Catalog C2
    WHERE C2.pid = C1.pid
);
SELECT C.PID, S.SNAME
FROM Catalog C
JOIN Suppliers S
ON C.SID = S.SID
WHERE C.COST = (
    SELECT MAX(C2.COST)
    FROM Catalog C2
    WHERE C2.PID = C.PID
)
ORDER BY S.SNAME, C.PID;

SELECT P.pname, S.sname, C.cost
FROM Catalog C
JOIN Suppliers S
ON C.sid = S.sid
JOIN Parts P
ON C.pid = P.pid
WHERE C.cost = (
    SELECT MAX(C2.cost)
    FROM Catalog C2
    WHERE C2.pid = C.pid
);
SELECT P.pname, S.sname, C.cost
FROM Parts P
JOIN Catalog C ON P.pid = C.pid
JOIN Suppliers S ON C.sid = S.sid
WHERE C.cost = (
    SELECT MAX(cost)
    FROM Catalog
);
SELECT S.sname
FROM Suppliers S
WHERE NOT EXISTS (
    SELECT *
    FROM Catalog C
    JOIN Parts P ON C.pid = P.pid
    WHERE C.sid = S.sid
    AND P.color = 'Red'
);
SELECT S.sname, COALESCE(SUM(C.cost), 0) AS total_value
FROM Suppliers S
LEFT JOIN Catalog C ON S.sid = C.sid
GROUP BY S.sid, S.sname;
SELECT S.sname, COUNT(C.pid) AS total_parts
FROM Suppliers S
JOIN Catalog C ON S.sid = C.sid
WHERE C.cost < 20
GROUP BY S.sid, S.sname
HAVING COUNT(C.pid) >= 2;
SELECT P.pname, S.sname, C.cost
FROM Parts P
JOIN Catalog C ON P.pid = C.pid
JOIN Suppliers S ON C.sid = S.sid
WHERE C.cost = (
    SELECT MIN(C2.cost)
    FROM Catalog C2
    WHERE C2.pid = P.pid
)ORDER BY P.pname;
CREATE VIEW Expensive_Supplier AS
SELECT P.pname, S.sname, C.cost
FROM Parts P
JOIN Catalog C ON P.pid = C.pid
JOIN Suppliers S ON C.sid = S.sid
WHERE C.cost = (
    SELECT MAX(C2.cost)
    FROM Catalog C2
    WHERE C2.pid = P.pid
);SELECT * FROM Expensive_Supplier;
DELIMITER //
CREATE TRIGGER Default_Cost
BEFORE INSERT ON Catalog
FOR EACH ROW
BEGIN
    IF NEW.cost IS NULL OR NEW.cost = 0 THEN
        SET NEW.cost = 10;
    END IF;
END //
DELIMITER ;
DELIMITER //

CREATE TRIGGER Check_Cost
BEFORE INSERT ON Catalog
FOR EACH ROW
BEGIN
    IF NEW.cost < 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cost cannot be less than 1';
    END IF;
END //

DELIMITER ;
