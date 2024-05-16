USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_RISOLVE_VERBALE_CONTRATTO_GARA]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE  PROCEDURE [dbo].[OLD2_RISOLVE_VERBALE_CONTRATTO_GARA] 
	( @value nvarchar(max) , @Id int ,  @contesto as varchar(200), @value_out nvarchar(max)  output )
AS
BEGIN
	declare @attributo as nvarchar(max)
	declare @sql as nvarchar(max)
	declare @valore_calcolato as nvarchar(max)
	declare @idbando as int
	declare @idPDA as int
	declare @divisione_lotti as int	
	declare @Ente varchar(1000)
	declare @NumeroLotto as varchar(100)
	declare @IdAzi_OE as int
	set @value_out=''

	select @idbando=GARA.id , @idPDA=PDA.id , @divisione_lotti=Divisione_lotti , @Ente = CONTR.Azienda,@IdAzi_OE = CONTR.Destinatario_Azi
			
		from 
			ctl_doc CONTR with(nolock) 
				inner join CTL_DOC COM with(nolock)   on COM.id=CONTR.LinkedDoc and COM.Deleted =0
				inner join ctl_doc PDA with (nolock)  on PDA.id=COM.LinkedDoc
				inner join ctl_doc GARA with (nolock)  on GARA.id=PDA.LinkedDoc
				inner join Document_Bando DB with(nolock) on DB.idHeader=GARA.id	
		where CONTR.id=@Id
		
		
	select @value as valore into #t
	select top 1 * into #S from VERBALE_GARA_STIPULA_CONTRATTO_SetAttibValues where id=@Id
	
	--CON IL CURSORE RISOLVE UNA SERIE DI VALORI CHE TROVA IN MACHING CON I NOMI DI COLONNE DELLA VISTA VERBALE_GARA_SetAttibValues
	DECLARE curs CURSOR STATIC FOR
		select c.name
			from syscolumns c
				inner join sysobjects o on o.id = c.id
				inner join systypes s on c.xusertype = s.xusertype
		where o.name = 'VERBALE_GARA_STIPULA_CONTRATTO_SetAttibValues'

	OPEN curs
	FETCH NEXT FROM curs INTO @Attributo
	WHILE @@FETCH_STATUS = 0
	BEGIN		
					
		set @sql = 'update t set valore = replace ( valore , ''#DOCUMENT.' + @Attributo + '#'' , S.' + @Attributo + ') from #t as t cross join #S as S '
		exec ( @sql)

		FETCH NEXT FROM curs INTO @Attributo
	END

	CLOSE curs
	DEALLOCATE curs	
	
	select @value_out=valore from #t
	drop table #t
	drop table #s

		----RISOLVO I CASI SPECIFICI
		if ( CHARINDEX( '#Document.Lotti_Contratto#',@value_out) > 0 )
		BEGIN
			set @valore_calcolato=''
			select @valore_calcolato=dbo.RISOLVE_VERBALEGARA_Document_Lotti_Contratto(@Id,@contesto)		
			set @value_out=replace(@value_out,'#Document.Lotti_Contratto#',ISNULL(@valore_calcolato,''))
		END

	
		if ( CHARINDEX( '#Document.CriterioAggiudicazioneGara#',@value_out) > 0 )
		BEGIN
			set @valore_calcolato=''
			select @valore_calcolato=dbo.RISOLVE_VERBALEGARA_Document_CriterioAggiudicazioneGara(@idbando)				
			set @value_out=replace(@value_out,'#Document.CriterioAggiudicazioneGara#',ISNULL(@valore_calcolato,''))
				
		END
	
		
		if ( CHARINDEX( '#Document.NomeUfficio#',@value_out) > 0 )
		BEGIN
			set @valore_calcolato=''
			select @valore_calcolato=dbo.RISOLVE_VERBALEGARA_Document_NomeUfficio(@idbando)				
			set @value_out=replace(@value_out,'#Document.NomeUfficio#',ISNULL(@valore_calcolato,''))
				
		END


		if ( CHARINDEX( '#Document.SettoriCCNL#',@value_out) > 0 )
		BEGIN
			set @valore_calcolato=''
			select @valore_calcolato=dbo.RISOLVE_VERBALEGARA_Document_SettoreCCNL(@IdAzi_OE)				
			set @value_out=replace(@value_out,'#Document.SettoriCCNL#',ISNULL(@valore_calcolato,''))
				
		END

		if ( CHARINDEX( '#Document.ValoreOfferta#',@value_out) > 0 )
		BEGIN
			set @valore_calcolato=''
			--select @valore_calcolato=dbo.RISOLVE_VERBALEGARA_Document_ValoreOfferta_Contratto(@Id,@contesto)				
			--set @value_out=replace(@value_out,'#Document.ValoreOfferta#',ISNULL(@valore_calcolato,''))

			CREATE TABLE #TempCheck(
						[Esito] [nvarchar](max) collate DATABASE_DEFAULT NULL
					)  
				
			insert into #TempCheck select top 0 '' as Esito
				
			--chiamo la stored per recuperare il valore offerto dei lotti
			insert into #TempCheck  exec RISOLVE_VERBALEGARA_Document_ValoreOfferta_Contratto @Id,@contesto						
				
			select @valore_calcolato=Esito from #TempCheck

			set @value_out=replace(@value_out,'#Document.ValoreOfferta#',ISNULL(@valore_calcolato,''))
			--cancello la tabella temporanea
			drop table #TempCheck
				
		END
		
		if ( CHARINDEX( '#Document.Oneri#',@value_out) > 0 )
		BEGIN
			set @valore_calcolato=''
			select @valore_calcolato=dbo.RISOLVE_VERBALEGARA_Document_Oneri_Contratto(@Id,@contesto)				
			set @value_out=replace(@value_out,'#Document.Oneri#',ISNULL(@valore_calcolato,''))
				
		END

		if ( CHARINDEX( '#Document.CostiSicurezza#',@value_out) > 0 )
		BEGIN
			set @valore_calcolato=''
			select @valore_calcolato=dbo.RISOLVE_VERBALEGARA_Document_CostiSicurezza_Contratto(@Id,@contesto)				
			set @value_out=replace(@value_out,'#Document.CostiSicurezza#',ISNULL(@valore_calcolato,''))
				
		END
		
		if ( CHARINDEX( '#Document.LogoGestore#',@value_out) > 0 )
		BEGIN
			set @valore_calcolato=''
			-- solo per l'ente gestore si mette il logo
			if exists( select IdMp from MarketPlace with(nolock) where mpIdAziMaster = @Ente )
			begin
				set @valore_calcolato=DBO.CNV_ESTESA( 'HEADER_STAMPE' , 'I' )
			end
			set @value_out=replace(@value_out,'#Document.LogoGestore#',ISNULL(@valore_calcolato,''))		
		END
		
		

	
END


GO
