USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[DEFRAMMENTA_MODELLO]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[DEFRAMMENTA_MODELLO] ( @nomeModello as varchar(4000) )
AS
BEGIN
	
	declare @parametriModello varchar(4000)
	declare @idModAttr int
	declare @newOrd INT

	set @parametriModello = ''
	set @idModAttr = -1
	set @newOrd = 1

	select @parametriModello = a.MOD_Param from CTL_Models a with(nolock) where MOD_ID = @nomeModello

	-- Se è un modello posizionale
	IF  CHARINDEX( 'type=posizionale', @parametriModello) > 0
	BEGIN

		DECLARE curs CURSOR STATIC FOR     
			select a.ma_id from CTL_ModelAttributes a with(nolock) where a.MA_MOD_ID = @nomeModello order by ma_pos asc


		OPEN curs 
		FETCH NEXT FROM curs INTO @idModAttr


		WHILE @@FETCH_STATUS = 0   
		BEGIN  

			UPDATE CTL_ModelAttributes
				set ma_pos = @newOrd
					,ma_order = @newOrd
			WHERE ma_id = @idModAttr

			set @newOrd = @newOrd + 1

			FETCH NEXT FROM curs INTO @idModAttr

		END  


		CLOSE curs   
		DEALLOCATE curs

	END

END
GO
