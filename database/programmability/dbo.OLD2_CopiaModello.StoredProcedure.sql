USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_CopiaModello]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROC [dbo].[OLD2_CopiaModello]( @NewModello as varchar(200) , @Modello as varchar(200) ,  @Modulo as varchar(100) ) as 
begin 

	--set @Modello = 'RDO_OGGETTO'
	--set @NewModello = 'RDO_OGGETTO_SAVE'
	--set @Modulo = 'RDO'
	--delete from LIB_Models where MOD_Name = @NewModello  and @Modulo = MOD_Module


	DELETE FROM CTL_Models
		WHERE   MOD_Name = @NewModello
				AND @Modulo = MOD_Module
	--insert into LIB_Models(


	INSERT INTO           CTL_Models( MOD_ID , MOD_Name , MOD_DescML , MOD_Type , MOD_Sys , MOD_help , MOD_Param , MOD_Module )
		   SELECT            *
			   FROM
			   (
				   SELECT    @NewModello AS MOD_ID , @NewModello AS MOD_Name , @NewModello AS MOD_DescML , MOD_Type , MOD_Sys , CAST(MOD_help AS VARCHAR(1000)) AS MOD_help , CAST(MOD_Param AS VARCHAR(1000)) AS MOD_Param , @Modulo AS MOD_Module
					   FROM  LIB_Models with (nolock)
					   WHERE MOD_Name = @Modello
			   ) AS a

	--delete from LIB_ModelAttributes where MA_MOD_ID = @NewModello and @Modulo = MA_Module
	--insert into LIB_ModelAttributes(


	DELETE FROM CTL_ModelAttributes
		WHERE   MA_MOD_ID = @NewModello
				AND @Modulo = MA_Module

	INSERT INTO                    CTL_ModelAttributes( MA_MOD_ID , MA_DZT_Name , MA_DescML , MA_Pos , MA_Len , MA_Order , MA_Module )
		   SELECT            *
			   FROM
			   (
				   SELECT    @NewModello AS MA_MOD_ID , MA_DZT_Name , MA_DescML , MA_Pos , MA_Len , MA_Order , @Modulo AS MA_Module
					   FROM  LIB_ModelAttributes with (nolock)
					   WHERE MA_MOD_ID = @Modello
			   ) AS a

	--delete from LIB_ModelAttributeProperties where MAP_MA_MOD_ID = @NewModello and @Modulo = MAP_Module
	--insert into LIB_ModelAttributeProperties(


	DELETE FROM CTL_ModelAttributeProperties
		WHERE   MAP_MA_MOD_ID = @NewModello
				AND @Modulo = MAP_Module

	INSERT INTO                             CTL_ModelAttributeProperties( MAP_MA_MOD_ID , MAP_MA_DZT_Name , MAP_Propety , MAP_Value , MAP_Module )
		   SELECT            *
			   FROM
			   (
				   SELECT    @NewModello AS MAP_MA_MOD_ID , MAP_MA_DZT_Name , MAP_Propety , MAP_Value , @Modulo AS MAP_Module
					   FROM  LIB_ModelAttributeProperties with (nolock)
					   WHERE MAP_MA_MOD_ID = @Modello
			   ) AS a
end




GO
