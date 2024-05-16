USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CK_SEC_COM_DPE]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE PROC [dbo].[CK_SEC_COM_DPE] ( @SectionName as VARCHAR(255), @IdDoc as VARCHAR(255) , @IdUser as VARCHAR(255))
AS
BEGIN


	-- verifico se la sezione puo essere aperta.


	
	declare @Blocco nvarchar(1000)
	set @Blocco = ''

	if @SectionName ='Destinatari' 
		if not exists (select * from Document_Com_DPE  where idcom=@IdDoc and isnull(TipoComDPE,'OE') ='OE' )
			set @Blocco = 'NON_VISIBILE'
	
	if @SectionName ='Enti' 
		if not exists (select * from Document_Com_DPE  where idcom=@IdDoc and TipoComDPE ='ENTI')
			set @Blocco = 'NON_VISIBILE'

	
	select @Blocco as Blocco

end























GO
