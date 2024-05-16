USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_CK_SEC_DOC_PREGARA]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE proc [dbo].[OLD_CK_SEC_DOC_PREGARA] ( @SectionName as VARCHAR(255), @IdDoc as VARCHAR(255) , @IdUser as VARCHAR(255))
as
begin
	-- verifico se la sezione puo essere aperta.	
	declare @Blocco nvarchar(1000)
	declare @StatoFunzionale nvarchar(1000)
	set @Blocco = ''

	select @StatoFunzionale  = StatoFunzionale  from CTL_Doc with(nolock) where id = @IdDoc

	IF EXISTS ( select * from [CTL_Relations] where [REL_Type]='DOCUMENT_PREGARA_HIDE_SECTION_For_Stato' and [REL_ValueInput] = @SectionName and [REL_ValueOutput] like '%,' + @StatoFunzionale  + ',%' )
	BEGIN
		set @Blocco = 'NON_VISIBILE'
	END



	
	----Nasconde la sezione se il documento è negli stati 
	---- InLavorazione
 --   -- AnalisiStrategiaNonApp
 --   -- AnalisiStrategia 
 --   if @SectionName in ( 'ATTI' ) 
	--BEGIN
	--	IF EXISTS (select * from CTL_DOC with(nolock) where id=@IdDoc and StatoFunzionale in ('InLavorazione','AnalisiStrategiaNonApp','AnalisiStrategia') )

	--	BEGIN
	--		set @Blocco = 'NON_VISIBILE'
	--	END
		
	--END


	----Nasconde la sezione se il documento è negli stati 
	---- InLavorazione
	---- AnalisiStrategiaNonApp
	---- AnalisiStrategia
	---- CompilazioneAtti
	---- ParereLegaleNonApp
	---- ParereLegale
 --   if @SectionName in ( 'DETERMINA' ) 
	--BEGIN
	--	IF EXISTS ( select * from CTL_DOC with(nolock) where id=@IdDoc and  StatoFunzionale in ('InLavorazione','AnalisiStrategiaNonApp','AnalisiStrategia','CompilazioneAtti','ParereLegaleNonApp','ParereLegale') )
	--	BEGIN
	--		set @Blocco = 'NON_VISIBILE'
	--	END
		
	--END
 


	select @Blocco as Blocco

end

GO
