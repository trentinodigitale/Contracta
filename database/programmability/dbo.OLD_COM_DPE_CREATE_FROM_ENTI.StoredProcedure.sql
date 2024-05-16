USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_COM_DPE_CREATE_FROM_ENTI]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create PROCEDURE [dbo].[OLD_COM_DPE_CREATE_FROM_ENTI] 
	( @idDoc int  , @idUser int )
AS
BEGIN
	
	set nocount on

	declare @id as int
	
	insert into document_com_dpe
		( [Owner], [Name], [DataCreazione], [TipoComDPE])
		values
		(@idUser,'',GETDATE(),'ENTI')

	set @Id = SCOPE_IDENTITY()

	-- rirorna l'id della PDA
	select @id as id

END

GO
