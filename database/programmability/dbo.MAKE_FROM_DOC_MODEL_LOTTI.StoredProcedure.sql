USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[MAKE_FROM_DOC_MODEL_LOTTI]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Proc [dbo].[MAKE_FROM_DOC_MODEL_LOTTI] ( @NomeModello as varchar(200) , @Att as varchar(50) ,  @idDoc as int , @Modulo as varchar(200))
as
begin

	exec CREA_MODELLI_FROM_CONFIG_MODELLI @NomeModello, @Att, @idDoc, @Modulo 

end
GO
