USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[DB_CLEANING_EVENT_VIEWER]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DB_CLEANING_EVENT_VIEWER](@recordAlive as INT = 2000) 
AS

	SET NOCOUNT ON

	declare @minID int 

	--step 1. recupero l'id limite dopo il quale preservare i record
	select top(@recordAlive) id into #records from CTL_EVENT_VIEWER with(nolock) order by id desc --prendiamo gli ultimi N

	--step 2. prendo il record di ID minimo rispetto agli N preselezionati
	select @minID = min(id) from #records

	--step 3. cancello i record più vecchi di min ID
	delete from CTL_EVENT_VIEWER where id < @minID

	--step 4. cancello i record più vecchi anche dalla tabella collegata
	delete from CTL_EVENT_VIEWER_DATES where idHeader < @minID
	

	drop table #records

GO
