USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CK_SEC_DOC_PUBBLICITA_LEGALE]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE proc [dbo].[CK_SEC_DOC_PUBBLICITA_LEGALE] ( @SectionName as VARCHAR(255), @IdDoc as VARCHAR(255) , @IdUser as VARCHAR(255))
as
begin
	-- verifico se la sezione puo essere aperta.	
	declare @Blocco nvarchar(1000)
	declare @StatoFunzionale nvarchar(1000)
		declare @jumpcheck nvarchar(20)
		
	set @Blocco = 'NON_VISIBILE'
	--RECUPERARE JUMPCHECK
	select @StatoFunzionale  = StatoFunzionale, @jumpcheck=JumpCheck  from CTL_Doc with(nolock) where id = @IdDoc



	IF EXISTS ( select * from [CTL_Relations] where [REL_Type]='PUBBLICITA_LEGALE_'+@jumpcheck+'_SECTION_VISIBLE'  and [REL_ValueInput] like '%,' + @StatoFunzionale  + ',%' and [REL_ValueOutput] like '%,' + @SectionName  + ',%')
	BEGIN
		set @Blocco = ''

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
