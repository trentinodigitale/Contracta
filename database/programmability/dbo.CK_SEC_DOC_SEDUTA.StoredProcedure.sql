USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CK_SEC_DOC_SEDUTA]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[CK_SEC_DOC_SEDUTA] ( @SectionName as VARCHAR(255), @IdDoc as VARCHAR(255) , @IdUser as VARCHAR(255))
as
begin
	SET NOCOUNT ON
	-- verifico se la sezione puo essere aperta.
	declare @idPfu int
	declare @idPDA int
	set @idPDA = @IdDoc
	declare @Blocco nvarchar(1000)
	set @Blocco = ''

	--IF EXISTS (Select * from Ctl_doc 
	--			inner join TAB_MESSAGGI_FIELDS on LinkedDoc=IdMsg and iSubType =68 
	--			where id=@IdDoc and ISNULL(JumpCheck,'') ='' )
	--BEGIN
	--	set @Blocco = 'NON_VISIBILE'
	--END

	--IF @SectionName='COMM' and EXISTS (Select * from Ctl_doc with(nolock)
	--			inner  join Document_Bando  with(nolock)  on LinkedDoc=idHeader
	--			where id=@IdDoc and ProceduraGara in ('15583','15479') )
	--BEGIN
	--	set @Blocco = 'NON_VISIBILE'
	--END

	--if @Blocco = ''
		IF  EXISTS (Select * from Ctl_doc with(nolock)
				inner  join Document_Bando  with(nolock)  on LinkedDoc=idHeader
				where id=@IdDoc and TipoProceduraCaratteristica = 'RFQ' )
					set @Blocco = 'NON_VISIBILE'


	select @Blocco as Blocco
end


GO
