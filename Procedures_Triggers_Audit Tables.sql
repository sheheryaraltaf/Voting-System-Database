-- Procedure to insert a new voter
CREATE PROCEDURE InsertVoter
    @FirstName NVARCHAR(50),
    @LastName NVARCHAR(50),
    @Gender NVARCHAR(10),
    @MaritalStatus NVARCHAR(10),
    @DateOfBirth DATE,
    @Address NVARCHAR(200),
    @CNIC NVARCHAR(15),
    @Disability NVARCHAR(3)
AS
BEGIN
    IF EXISTS (SELECT 1 FROM voter WHERE CNIC = @CNIC)
       OR EXISTS (SELECT 1 FROM PollingAgent WHERE CNIC = @CNIC)
       OR EXISTS (SELECT 1 FROM candidates WHERE CNIC = @CNIC)
       OR EXISTS (SELECT 1 FROM Officer WHERE CNIC = @CNIC)
    BEGIN
        PRINT 'Error: CNIC already exists in the database.';
        RETURN;
    END
    INSERT INTO voter (FirstName, LastName, Gender, MaritalStatus, DateOfBirth, Address, CNIC, Disability)
    VALUES (@FirstName, @LastName, @Gender, @MaritalStatus, @DateOfBirth, @Address, @CNIC, @Disability);
    PRINT 'Voter inserted successfully';
END;
GO


-- Procedure to insert a new candidate
CREATE PROCEDURE InsertCandidate
    @CNIC NVARCHAR(15),
    @FirstName NVARCHAR(50),
    @LastName NVARCHAR(50),
    @Gender NVARCHAR(10),
    @ContactNumber NVARCHAR(15),
    @DateOfBirth DATE,
    @Symbol NVARCHAR(50)
AS
BEGIN
    IF EXISTS (SELECT 1 FROM voter WHERE CNIC = @CNIC)
       OR EXISTS (SELECT 1 FROM PollingAgent WHERE CNIC = @CNIC)
       OR EXISTS (SELECT 1 FROM candidates WHERE CNIC = @CNIC)
       OR EXISTS (SELECT 1 FROM Officer WHERE CNIC = @CNIC)
    BEGIN
        PRINT 'Error: CNIC already exists in the database.';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM Officer WHERE ContactNo = @ContactNumber)
       OR EXISTS (SELECT 1 FROM PollingAgent WHERE ContactNumber = @ContactNumber)
       OR EXISTS (SELECT 1 FROM candidates WHERE ContactNumber = @ContactNumber)
    BEGIN
        PRINT 'Error: Contact number already exists in the database.';
        RETURN;
    END

    INSERT INTO candidates (CNIC, FirstName, LastName, Gender, ContactNumber, DateOfBirth, Symbol)
    VALUES (@CNIC, @FirstName, @LastName, @Gender, @ContactNumber, @DateOfBirth, @Symbol);
    PRINT 'Candidate inserted successfully';
END;
GO

--Insert Constituency
CREATE PROCEDURE InsertConstituency
    @ConstituencyID INT,
    @Population INT,
    @Area NVARCHAR(100),
    @RegisteredVotes INT,
    @PollingStations INT
AS
BEGIN
    INSERT INTO constituency (ConstituencyID, Population, Area, RegisteredVotes, PollingStations)
    VALUES (@ConstituencyID, @Population, @Area, @RegisteredVotes, @PollingStations);
END;

--Insert Department
CREATE PROCEDURE InsertDepartment
    @DepartmentID INT,
    @DepartmentName NVARCHAR(100)
AS
BEGIN
    INSERT INTO department (DepartmentID, DepartmentName)
    VALUES (@DepartmentID, @DepartmentName);
END;


--Delete Voter
CREATE TABLE voter_audit (
    AuditID INT PRIMARY KEY IDENTITY(1,1),
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Gender NVARCHAR(10) NOT NULL,
    MaritalStatus NVARCHAR(10),
    DateOfBirth DATE NOT NULL,
    Address NVARCHAR(200),
    CNIC NVARCHAR(15),
    Disability NVARCHAR(3),
    DeletedAt DATETIME DEFAULT GETDATE(),
    DeletedBy NVARCHAR(100)
);

CREATE PROCEDURE DeleteVoter
    @CNIC NVARCHAR(15),
    @DeletedBy NVARCHAR(100)
AS
BEGIN
    DELETE FROM voter
    WHERE CNIC = @CNIC;
END;
GO

CREATE TRIGGER trg_DeleteVoter
ON voter
INSTEAD OF DELETE
AS
BEGIN
    INSERT INTO voter_audit (
        FirstName, LastName, Gender, MaritalStatus, DateOfBirth, 
        Address, CNIC, Disability, DeletedBy
    )
    SELECT 
        FirstName, LastName, Gender, MaritalStatus, DateOfBirth, 
        Address, CNIC, Disability, 'Admin'
    FROM deleted;
    DELETE FROM voter
    WHERE CNIC IN (SELECT CNIC FROM deleted);
END;
GO

-- Delete candidates
CREATE TABLE candidates_audit (
    AuditID INT PRIMARY KEY IDENTITY(1,1),
    CNIC NVARCHAR(15) NOT NULL,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Gender NVARCHAR(10) NOT NULL CHECK (Gender IN ('male', 'female')),
    ContactNumber NVARCHAR(15) UNIQUE,
    DateOfBirth DATE NOT NULL,
    Symbol NVARCHAR(50) NOT NULL,
    DeletedAt DATETIME DEFAULT GETDATE(),
    DeletedBy NVARCHAR(100)
);

CREATE PROCEDURE DeleteCandidate
    @CNIC NVARCHAR(15),
    @DeletedBy NVARCHAR(100)
AS
BEGIN
    DELETE FROM candidates
    WHERE CNIC = @CNIC;
END;
GO

CREATE TRIGGER trg_DeleteCandidate
ON candidates
INSTEAD OF DELETE
AS
BEGIN
    INSERT INTO candidates_audit (
        CNIC, FirstName, LastName, Gender, ContactNumber, 
        DateOfBirth, Symbol, DeletedBy
    )
    SELECT 
        CNIC, FirstName, LastName, Gender, ContactNumber, 
        DateOfBirth, Symbol, 'Admin' 
    FROM deleted; 
    DELETE FROM candidates
    WHERE CNIC IN (SELECT CNIC FROM deleted);
END;
GO

--Department Update
CREATE TABLE department_audit (
    AuditID INT PRIMARY KEY IDENTITY(1,1),
    DepartmentID INT,
    DepartmentName NVARCHAR(100),
    ModifiedAt DATETIME DEFAULT GETDATE(),
    ModifiedBy NVARCHAR(100)
);

CREATE PROCEDURE UpdateDepartment
    @DepartmentID INT,
    @DepartmentName NVARCHAR(100),
    @ModifiedBy NVARCHAR(100)
AS
BEGIN
    UPDATE department
    SET DepartmentName = @DepartmentName
    WHERE DepartmentID = @DepartmentID;
END;
GO

CREATE TRIGGER trg_UpdateDepartment
ON department
INSTEAD OF UPDATE
AS
BEGIN
    INSERT INTO department_audit (DepartmentID, DepartmentName, ModifiedBy)
    SELECT DepartmentID, DepartmentName, 'Admin'
    FROM deleted;
    UPDATE department
    SET DepartmentName = inserted.DepartmentName
    FROM inserted
    WHERE department.DepartmentID = inserted.DepartmentID;
END;
GO

-- Update PollingStation
CREATE TABLE PollingStation_audit (
    AuditID INT PRIMARY KEY IDENTITY(1,1),
    PollingStationID INT,
    Address NVARCHAR(255),
    VoterSize INT,
    NumBooths INT,
    EmployeeSize INT,
    PresidingOfficerID INT,
    Sensitivity NVARCHAR(50),
    ConstituencyID INT,
    PolicePersonnel INT,
    ModifiedAt DATETIME DEFAULT GETDATE(),
    ModifiedBy NVARCHAR(100)
);

CREATE PROCEDURE UpdatePollingStation
    @PollingStationID INT,
    @Address NVARCHAR(255),
    @VoterSize INT,
    @NumBooths INT,
    @EmployeeSize INT,
    @PresidingOfficerID INT,
    @Sensitivity NVARCHAR(50),
    @ConstituencyID INT,
    @PolicePersonnel INT,
    @ModifiedBy NVARCHAR(100)
AS
BEGIN
    UPDATE PollingStation
    SET Address = @Address,
        VoterSize = @VoterSize,
        NumBooths = @NumBooths,
        EmployeeSize = @EmployeeSize,
        PresidingOfficerID = @PresidingOfficerID,
        Sensitivity = @Sensitivity,
        ConstituencyID = @ConstituencyID,
        PolicePersonnel = @PolicePersonnel
    WHERE PollingStationID = @PollingStationID;
END;
GO

CREATE TRIGGER trg_UpdatePollingStation
ON PollingStation
INSTEAD OF UPDATE
AS
BEGIN
   
    INSERT INTO PollingStation_audit (
        PollingStationID, Address, VoterSize, NumBooths, EmployeeSize, 
        PresidingOfficerID, Sensitivity, ConstituencyID, PolicePersonnel, 
        ModifiedBy
    )
    SELECT PollingStationID, Address, VoterSize, NumBooths, EmployeeSize, 
           PresidingOfficerID, Sensitivity, ConstituencyID, PolicePersonnel, 
           'Admin' 
    FROM deleted;
    UPDATE PollingStation
    SET Address = inserted.Address,
        VoterSize = inserted.VoterSize,
        NumBooths = inserted.NumBooths,
        EmployeeSize = inserted.EmployeeSize,
        PresidingOfficerID = inserted.PresidingOfficerID,
        Sensitivity = inserted.Sensitivity,
        ConstituencyID = inserted.ConstituencyID,
        PolicePersonnel = inserted.PolicePersonnel
    FROM inserted
    WHERE PollingStation.PollingStationID = inserted.PollingStationID;
END;
GO

CREATE TABLE VoteResult_audit (
    AuditID INT PRIMARY KEY IDENTITY(1,1),
    VoteID INT,
    VoterCNIC NVARCHAR(15),
    CandidateSymbol NVARCHAR(50),
    BoothID INT,
    CastTime DATETIME,
    OperationType NVARCHAR(10),
    OperationTime DATETIME DEFAULT GETDATE(),
    ModifiedBy NVARCHAR(100)
);

CREATE TRIGGER trg_UpdateVoteResult
ON VoteResult
INSTEAD OF UPDATE
AS
BEGIN
    INSERT INTO VoteResult_audit (
        VoteID, VoterCNIC, CandidateSymbol, BoothID, CastTime, 
        OperationType, ModifiedBy
    )
    SELECT 
        VoteID, VoterCNIC, CandidateSymbol, BoothID, CastTime, 
        'UPDATE', 'Admin' 
    FROM deleted;

    UPDATE VoteResult
    SET VoterCNIC = inserted.VoterCNIC,
        CandidateSymbol = inserted.CandidateSymbol,
        BoothID = inserted.BoothID,
        CastTime = inserted.CastTime
    FROM inserted
    WHERE VoteResult.VoteID = inserted.VoteID;
END;
GO


CREATE TRIGGER trg_DeleteVoteResult
ON VoteResult
INSTEAD OF DELETE
AS
BEGIN
    INSERT INTO VoteResult_audit (
        VoteID, VoterCNIC, CandidateSymbol, BoothID, CastTime, 
        OperationType, ModifiedBy
    )
    SELECT 
        VoteID, VoterCNIC, CandidateSymbol, BoothID, CastTime, 
        'DELETE', 'Admin' 
    FROM deleted;
    DELETE FROM VoteResult
    WHERE VoteID IN (SELECT VoteID FROM deleted);
END;
GO
