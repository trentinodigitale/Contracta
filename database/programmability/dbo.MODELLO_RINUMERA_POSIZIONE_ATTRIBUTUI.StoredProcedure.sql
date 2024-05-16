USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[MODELLO_RINUMERA_POSIZIONE_ATTRIBUTUI]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[MODELLO_RINUMERA_POSIZIONE_ATTRIBUTUI] (@nomeModelloCtl varchar(500))
AS
BEGIN
	declare @idCtl int;
	declare @inc int = 1;

	declare CTL_ModelAttributes_cursor cursor for
		select MA_ID 
			from CTL_ModelAttributes with(nolock)
			where MA_MOD_ID = @nomeModelloCtl
			order by MA_Order;
				 
	open CTL_ModelAttributes_cursor

	fetch next from CTL_ModelAttributes_cursor into @idCtl;

	while @@FETCH_STATUS = 0 
	begin
		update CTL_ModelAttributes set MA_Pos = @inc, MA_Order = @inc WHERE MA_ID = @idCtl

		SET @inc = @inc + 1

		fetch next from CTL_ModelAttributes_cursor into @idCtl;
	end	

	close CTL_ModelAttributes_cursor
	deallocate CTL_ModelAttributes_cursor
END
GO
