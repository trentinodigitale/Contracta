USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[COM_DPE_CREATE_FROM_OE]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[COM_DPE_CREATE_FROM_OE] 
	( @idDoc int  , @idUser int )
AS
BEGIN
	
	set nocount on

	declare @id as int
	
	insert into document_com_dpe
		( [Owner], [Name], [DataCreazione], [TipoComDPE], DataScadenzaCom )
		values
		(@idUser,'',GETDATE(),'OE',null)

	set @Id = SCOPE_IDENTITY()

	-- rirorna l'id della PDA
	select @id as id

END

GO
