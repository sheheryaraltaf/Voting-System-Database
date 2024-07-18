-- Reports
use votingSystem_fa22_bcs_047

-- Detailed voting statistics, including the number of votes cast and voter turnout percentage, for each polling station within each constituency.
SELECT 
    c.ConstituencyID,
    c.Area,
    ps.PollingStationID,
    ps.Address,
    COUNT(vr.VoterCNIC) AS VotesCast,
    c.RegisteredVotes,
    (COUNT(vr.VoterCNIC) * 100.0 / c.RegisteredVotes) AS TurnoutPercentage
FROM 
    Constituency c
JOIN 
    PollingStation ps ON c.ConstituencyID = ps.ConstituencyID
LEFT JOIN 
    PollingBooth pb ON ps.PollingStationID = pb.PollingStationID
LEFT JOIN 
    VoteResult vr ON pb.BoothID = vr.BoothID
GROUP BY 
    c.ConstituencyID, c.Area, ps.PollingStationID, ps.Address, c.RegisteredVotes;


-- Report is to rank candidates within each constituency based on the number of votes they received
SELECT 
    c.CNIC,
    c.FirstName,
    c.LastName,
    cs.ConstituencyID,
    cs.Area,
    COUNT(vr.VoterCNIC) AS VotesReceived,
    RANK() OVER (PARTITION BY cs.ConstituencyID ORDER BY COUNT(vr.VoterCNIC) DESC) AS RankInConstituency
FROM 
    Candidates c
LEFT JOIN 
    VoteResult vr ON c.Symbol = vr.CandidateSymbol
LEFT JOIN 
    PollingBooth pb ON vr.BoothID = pb.BoothID
LEFT JOIN 
    PollingStation ps ON pb.PollingStationID = ps.PollingStationID
LEFT JOIN 
    Constituency cs ON ps.ConstituencyID = cs.ConstituencyID
GROUP BY 
    c.CNIC, c.FirstName, c.LastName, cs.ConstituencyID, cs.Area;

-- Report on demographic statistics of voters for constituency who have cast votes, including their count.
SELECT 
    cs.ConstituencyID,
    cs.Area,
    v.Gender,
    v.MaritalStatus,
    DATEDIFF(YEAR, v.DateOfBirth, GETDATE()) AS Age,
    COUNT(v.CNIC) AS VoterCount
FROM 
    Voter v
JOIN 
    VoteResult vr ON v.CNIC = vr.VoterCNIC
JOIN 
    PollingBooth pb ON vr.BoothID = pb.BoothID
JOIN 
    PollingStation ps ON pb.PollingStationID = ps.PollingStationID
JOIN 
    Constituency cs ON ps.ConstituencyID = cs.ConstituencyID
GROUP BY 
    cs.ConstituencyID, cs.Area, v.Gender, v.MaritalStatus, DATEDIFF(YEAR, v.DateOfBirth, GETDATE());

-- Report to determine the voting hour during which the highest number of votes were cast.
SELECT 
    DATEPART(HOUR, vr.CastTime) AS VotingHour,
    COUNT(vr.VoteID) AS VotesCast
FROM 
    VoteResult vr
GROUP BY 
    DATEPART(HOUR, vr.CastTime)
ORDER BY 
    VotingHour;

-- Report to identify the polling booth that received the highest votes at each polling station
SELECT 
    ps.PollingStationID,
    pb.BoothID,
    ps.Address AS StationAddress,
    COUNT(vr.VoteID) AS VotesCast
FROM 
    PollingStation ps
JOIN 
    PollingBooth pb ON ps.PollingStationID = pb.PollingStationID
LEFT JOIN 
    VoteResult vr ON pb.BoothID = vr.BoothID
GROUP BY 
    ps.PollingStationID, pb.BoothID, ps.Address
HAVING COUNT(vr.VoteID) = (
    SELECT 
        MAX(VotesCast) 
    FROM (
        SELECT 
            pb.BoothID,
            COUNT(vr.VoteID) AS VotesCast
        FROM 
            PollingStation ps
        JOIN 
            PollingBooth pb ON ps.PollingStationID = pb.PollingStationID
        LEFT JOIN 
            VoteResult vr ON pb.BoothID = vr.BoothID
        GROUP BY 
            pb.BoothID
    ) AS BoothVotes
);

-- Report to identify the polling booth that received the fewest votes at each polling station
SELECT 
    ps.PollingStationID,
    pb.BoothID,
    ps.Address AS StationAddress,
    COUNT(vr.VoteID) AS VotesCast
FROM 
    PollingStation ps
JOIN 
    PollingBooth pb ON ps.PollingStationID = pb.PollingStationID
LEFT JOIN 
    VoteResult vr ON pb.BoothID = vr.BoothID
GROUP BY 
    ps.PollingStationID, pb.BoothID, ps.Address
HAVING COUNT(vr.VoteID) = (
    SELECT 
        MIN(VotesCast) 
    FROM (
        SELECT 
            pb.BoothID,
            COUNT(vr.VoteID) AS VotesCast
        FROM 
            PollingStation ps
        JOIN 
            PollingBooth pb ON ps.PollingStationID = pb.PollingStationID
        LEFT JOIN 
            VoteResult vr ON pb.BoothID = vr.BoothID
        GROUP BY 
            pb.BoothID
    ) AS BoothVotes
);

-- Report to lists candidates showing the total number of votes each candidate received
SELECT 
    c.FirstName + ' ' + c.LastName AS CandidateName,
    c.Symbol AS CandidateSymbol,
    cs.ConstituencyID,
    COUNT(vr.VoteID) AS VotesReceived
FROM 
    Candidates c
LEFT JOIN 
    VoteResult vr ON c.Symbol = vr.CandidateSymbol
LEFT JOIN 
    PollingBooth pb ON vr.BoothID = pb.BoothID
LEFT JOIN 
    PollingStation ps ON pb.PollingStationID = ps.PollingStationID
LEFT JOIN 
    Constituency cs ON ps.ConstituencyID = cs.ConstituencyID
GROUP BY 
    c.FirstName, c.LastName, c.Symbol, cs.ConstituencyID
ORDER BY 
    COUNT(vr.VoteID) DESC;

-- Report to retrieve the number of votes cast at each polling booth within each polling station, and calculates the voter turnout percentage 
SELECT 
    ps.PollingStationID,
    pb.BoothID,
    ps.Address AS StationAddress,
    COUNT(vr.VoteID) AS VotesCast,
    (COUNT(vr.VoteID) * 100.0) / NULLIF((
        SELECT 
            SUM(c.RegisteredVotes) 
        FROM 
            Constituency c 
        WHERE 
            c.ConstituencyID = (SELECT ConstituencyID FROM PollingStation WHERE PollingStationID = ps.PollingStationID)
    ), 0) AS TurnoutPercentage
FROM 
    PollingStation ps
JOIN 
    PollingBooth pb ON ps.PollingStationID = pb.PollingStationID
LEFT JOIN 
    VoteResult vr ON pb.BoothID = vr.BoothID
GROUP BY 
    ps.PollingStationID, pb.BoothID, ps.Address;

-- report to show total votal turnout in a constituency
CREATE VIEW VoterParticipationByConstituency
AS
SELECT 
    c.ConstituencyID,
    c.Area,
    c.RegisteredVotes,
    COUNT(vr.VoterCNIC) AS VotesCast,
    COUNT(vr.VoterCNIC) * 100.0 / c.RegisteredVotes AS ParticipationRate
FROM 
    dbo.constituency c
JOIN 
    dbo.PollingStation ps ON c.ConstituencyID = ps.ConstituencyID
JOIN 
    dbo.PollingBooth pb ON ps.PollingStationID = pb.PollingStationID
JOIN 
    dbo.VoteResult vr ON pb.BoothID = vr.BoothID
GROUP BY 
    c.ConstituencyID, c.Area, c.RegisteredVotes;

select * from VoterParticipationByConstituency

--Report shows the number of deletions per month from candidate table.
SELECT 
    YEAR(DeletedAt) AS Year, 
    MONTH(DeletedAt) AS Month, 
    COUNT(*) AS DeletionsCount
FROM candidates_audit
GROUP BY YEAR(DeletedAt), MONTH(DeletedAt)
ORDER BY Year, Month;
