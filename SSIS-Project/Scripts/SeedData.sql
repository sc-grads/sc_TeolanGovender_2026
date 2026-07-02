USE [TimesheetDb_tg];
GO

PRINT 'Initializing remote data migration bridge...';

-- 1. Wipe out any stale linked server connections cleanly
IF EXISTS (SELECT * FROM sys.servers WHERE name = 'SourceMasterTunnel')
    EXEC sp_dropserver 'SourceMasterTunnel', 'droplogins';
GO

-- 2. Open the temporary secure tunnel connection to your machine
EXEC sp_addlinkedserver 
    @server = 'SourceMasterTunnel', 
    @srvproduct = '',
    @provider = 'MSOLEDBSQL', 
    @datasrc = '$(LocalTunnelAddress)';
GO

-- Authenticate using your local connection credentials passed from GitHub
EXEC sp_addlinkedsrvlogin 
    @rmtsrvname = 'SourceMasterTunnel', 
    @useself = 'FALSE', 
    @locallogin = NULL, 
    @rmtuser = '$(LocalTunnelUser)', 
    @rmtpassword = '$(LocalTunnelPass)';
GO

-- 3. Sync lookup datasets row-by-row (handling identity allocations safely)
IF EXISTS (SELECT * FROM [SourceMasterTunnel].[TimesheetDb].[dbo].[Consultant])
BEGIN
    PRINT 'Populating Consultant dataset...';
    SET IDENTITY_INSERT dbo.Consultant ON;
    
    INSERT INTO dbo.Consultant (ConsultantID, FirstName, LastName)
    SELECT ConsultantID, FirstName, LastName 
    FROM [SourceMasterTunnel].[TimesheetDb].[dbo].[Consultant] src
    WHERE NOT EXISTS (SELECT 1 FROM dbo.Consultant tgt WHERE tgt.ConsultantID = src.ConsultantID);
    
    SET IDENTITY_INSERT dbo.Consultant OFF;
END;

IF EXISTS (SELECT * FROM [SourceMasterTunnel].[TimesheetDb].[dbo].[Client])
BEGIN
    PRINT 'Populating Client dataset...';
    SET IDENTITY_INSERT dbo.Client ON;
    
    INSERT INTO dbo.Client (ClientID, ClientName)
    SELECT ClientID, ClientName 
    FROM [SourceMasterTunnel].[TimesheetDb].[dbo].[Client] src
    WHERE NOT EXISTS (SELECT 1 FROM dbo.Client tgt WHERE tgt.ClientID = src.ClientID);
    
    SET IDENTITY_INSERT dbo.Client OFF;
END;

-- 4. Sever the cross-network link cleanly
EXEC sp_dropserver 'SourceMasterTunnel', 'droplogins';
PRINT 'Data migration complete. Bridge closed securely.';
GO