--- YOU MUST EXECUTE THE FOLLOWING SCRIPT IN SQLCMD MODE.
:Connect sqlvm01

IF (SELECT state FROM sys.endpoints WHERE name = N'Microsoft SQL VM HA Container Mirroring Endpoint') <> 0
BEGIN
	ALTER ENDPOINT [Microsoft SQL VM HA Container Mirroring Endpoint] STATE = STARTED
END


GO

use [master]

GO

GRANT CONNECT ON ENDPOINT::[Microsoft SQL VM HA Container Mirroring Endpoint] TO [SQLHA\svcsql]

GO

:Connect sqlvm01

IF EXISTS(SELECT * FROM sys.server_event_sessions WHERE name='AlwaysOn_health')
BEGIN
  ALTER EVENT SESSION [AlwaysOn_health] ON SERVER WITH (STARTUP_STATE=ON);
END
IF NOT EXISTS(SELECT * FROM sys.dm_xe_sessions WHERE name='AlwaysOn_health')
BEGIN
  ALTER EVENT SESSION [AlwaysOn_health] ON SERVER STATE=START;
END

GO

:Connect sqlvm02

IF (SELECT state FROM sys.endpoints WHERE name = N'Microsoft SQL VM HA Container Mirroring Endpoint') <> 0
BEGIN
	ALTER ENDPOINT [Microsoft SQL VM HA Container Mirroring Endpoint] STATE = STARTED
END


GO

use [master]

GO

GRANT CONNECT ON ENDPOINT::[Microsoft SQL VM HA Container Mirroring Endpoint] TO [SQLHA\svcsql]

GO

:Connect sqlvm02

IF EXISTS(SELECT * FROM sys.server_event_sessions WHERE name='AlwaysOn_health')
BEGIN
  ALTER EVENT SESSION [AlwaysOn_health] ON SERVER WITH (STARTUP_STATE=ON);
END
IF NOT EXISTS(SELECT * FROM sys.dm_xe_sessions WHERE name='AlwaysOn_health')
BEGIN
  ALTER EVENT SESSION [AlwaysOn_health] ON SERVER STATE=START;
END

GO

:Connect sqlvm01

USE [master]

GO

CREATE AVAILABILITY GROUP [sqlag]
WITH (AUTOMATED_BACKUP_PREFERENCE = SECONDARY,
DB_FAILOVER = OFF,
DTC_SUPPORT = NONE,
REQUIRED_SYNCHRONIZED_SECONDARIES_TO_COMMIT = 0)
FOR DATABASE [TestDB]
REPLICA ON N'sqlvm01' WITH (ENDPOINT_URL = N'TCP://sqlvm01.sqlha.net:5022', FAILOVER_MODE = AUTOMATIC, AVAILABILITY_MODE = SYNCHRONOUS_COMMIT, BACKUP_PRIORITY = 50, SEEDING_MODE = AUTOMATIC, SECONDARY_ROLE(ALLOW_CONNECTIONS = NO)),
	N'sqlvm02' WITH (ENDPOINT_URL = N'TCP://sqlvm02.sqlha.net:5022', FAILOVER_MODE = AUTOMATIC, AVAILABILITY_MODE = SYNCHRONOUS_COMMIT, BACKUP_PRIORITY = 50, SEEDING_MODE = AUTOMATIC, SECONDARY_ROLE(ALLOW_CONNECTIONS = NO));

GO

:Connect sqlvm02

ALTER AVAILABILITY GROUP [sqlag] JOIN;

GO

ALTER AVAILABILITY GROUP [sqlag] GRANT CREATE ANY DATABASE;

GO


GO


