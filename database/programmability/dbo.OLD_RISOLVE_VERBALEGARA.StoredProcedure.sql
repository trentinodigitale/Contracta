USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_RISOLVE_VERBALEGARA]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  PROCEDURE [dbo].[OLD_RISOLVE_VERBALEGARA] 
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
	set @value_out=''

	select @idbando=C.LinkedDoc , @idPDA=C.id , @divisione_lotti=Divisione_lotti , @Ente = B.Azienda, 
			@NumeroLotto = numerolotto
		from Document_MicroLotti_Dettagli DM with(nolock) 
			inner join CTL_DOC C with(nolock) on  C.TipoDoc='PDA_MICROLOTTI' and DM.IdHeader=C.id and C.Deleted=0	
			inner join Document_Bando DB with(nolock) on DB.idHeader=C.LinkedDoc		
			inner join CTL_DOC B with(nolock) on C.LinkedDoc=B.id  -- BANDO
		where DM.id=@Id
	
	
		
	select @value as valore into #t	
	select * into #S from VERBALE_GARA_SetAttibValues where id=@Id
	
	--CON IL CURSORE RISOLVE UNA SERIE DI VALORI CHE TROVA IN MACHING CON I NOMI DI COLONNE DELLA VISTA VERBALE_GARA_SetAttibValues
	DECLARE curs CURSOR STATIC FOR
		select c.name
			from syscolumns c
				inner join sysobjects o on o.id = c.id
				inner join systypes s on c.xusertype = s.xusertype
		where o.name = 'VERBALE_GARA_SetAttibValues'

	OPEN curs
	FETCH NEXT FROM curs INTO @Attributo
	WHILE @@FETCH_STATUS = 0
	BEGIN		
					
		set @sql = 'update t set valore = replace ( valore , ''#DOCUMENT.' + @Attributo + '#'' , ISNULL(S.' + @Attributo + + ','''')) from #t as t cross join #S as S '
		exec ( @sql)

		FETCH NEXT FROM curs INTO @Attributo
	END

	CLOSE curs
	DEALLOCATE curs	
	
	select @value_out=valore from #t
	drop table #t
	drop table #s

		--RISOLVO I CASI SPECIFICI
		if ( CHARINDEX( '#Document.CIG#',@value_out) > 0 )
		BEGIN
			set @valore_calcolato=''
			select @valore_calcolato=dbo.RISOLVE_VERBALEGARA_Document_CIG(@Id,@contesto)		
			set @value_out=replace(@value_out,'#Document.CIG#',ISNULL(@valore_calcolato,''))
		END

		--Dati presenti nella sezione Informazioni Tecniche della gara (Pubblicazioni Gazzette, Altre Pubblicazioni e Quotidiani)
		if ( CHARINDEX( '#Document.Dati_Pubblicazione#',@value_out) > 0 )
		BEGIN
			set @valore_calcolato=''
			select @valore_calcolato=dbo.RISOLVE_VERBALEGARA_Document_Dati_Pubblicazione(@Id,@idbando)				
			set @value_out=replace(@value_out,'#Document.Dati_Pubblicazione#',ISNULL(@valore_calcolato,''))
				
		END
	
		if ( CHARINDEX( '#Document.Seggio_di_gara_atti#',@value_out) > 0 )
		BEGIN
			set @valore_calcolato=''
			select @valore_calcolato=dbo.RISOLVE_VERBALEGARA_Document_Seggio_di_gara(@Id,@idbando,1)				
			set @value_out=replace(@value_out,'#Document.Seggio_di_gara_atti#',ISNULL(@valore_calcolato,''))		
		END

		if ( CHARINDEX( '#Document.Seggio_di_gara#',@value_out) > 0 )
		BEGIN
			set @valore_calcolato=''
			select @valore_calcolato=dbo.RISOLVE_VERBALEGARA_Document_Seggio_di_gara(@Id,@idbando,0)				
			set @value_out=replace(@value_out,'#Document.Seggio_di_gara#',ISNULL(@valore_calcolato,''))		
		END

		if ( CHARINDEX( '#Document.Commissione_Giudicatrice_atti#',@value_out) > 0 )
		BEGIN
			set @valore_calcolato=''
			select @valore_calcolato=dbo.RISOLVE_VERBALEGARA_Document_Commissione_Giudicatrice(@Id,@idbando,1)				
			set @value_out=replace(@value_out,'#Document.Commissione_Giudicatrice_atti#',ISNULL(@valore_calcolato,''))		
		END

		
		if ( CHARINDEX( '#Document.Commissione_Giudicatrice#',@value_out) > 0 )
		BEGIN
			set @valore_calcolato=''
			select @valore_calcolato=dbo.RISOLVE_VERBALEGARA_Document_Commissione_Giudicatrice(@Id,@idbando,0)				
			set @value_out=replace(@value_out,'#Document.Commissione_Giudicatrice#',ISNULL(@valore_calcolato,''))		
		END

		if ( CHARINDEX( '#Document.Concorrenti#',@value_out) > 0 )
		BEGIN
			set @valore_calcolato=''
			select @valore_calcolato=dbo.RISOLVE_VERBALEGARA_Document_Concorrenti(@Id,@idbando,@idPDA,@divisione_lotti)	
			set @value_out=replace(@value_out,'#Document.Concorrenti#',ISNULL(@valore_calcolato,''))		
		END

		if ( CHARINDEX( '#Document.Esame_Verifica_Amministrativa#',@value_out) > 0 )
		BEGIN
			set @valore_calcolato=''
			select @valore_calcolato=dbo.RISOLVE_VERBALEGARA_Document_Esame_Verifica_Amministrativa(@idPDA)	
			set @value_out=replace(@value_out,'#Document.Esame_Verifica_Amministrativa#',ISNULL(@valore_calcolato,''))		
		END

		if ( CHARINDEX( '#Document.Esito_Valutazione_Amministrativa#',@value_out) > 0 )
		BEGIN
			set @valore_calcolato=''
			select @valore_calcolato=dbo.RISOLVE_VERBALEGARA_Document_Esito_Valutazione_Amministrativa(@Id,@idbando,@idPDA,@divisione_lotti)
			set @value_out=replace(@value_out,'#Document.Esito_Valutazione_Amministrativa#',ISNULL(@valore_calcolato,''))		
		END
		if ( CHARINDEX( '#Document.Esame_Valutazione_Tecnica#',@value_out) > 0 )
		BEGIN
			set @valore_calcolato=''
			select @valore_calcolato=dbo.RISOLVE_VERBALEGARA_Document_Esame_Valutazione_Tecnica(@Id,@idPDA,@divisione_lotti)	
			set @value_out=replace(@value_out,'#Document.Esame_Valutazione_Tecnica#',ISNULL(@valore_calcolato,''))		
		END
		if ( CHARINDEX( '#Document.Esito_Valutazione_Tecnica#',@value_out) > 0 )
		BEGIN
			set @valore_calcolato=''
			select @valore_calcolato=dbo.RISOLVE_VERBALEGARA_Document_Esito_Valutazione_Tecnica(@Id,@idbando,@idPDA,@divisione_lotti)	
			set @value_out=replace(@value_out,'#Document.Esito_Valutazione_Tecnica#',ISNULL(@valore_calcolato,''))		
		END

		if ( CHARINDEX( '#Document.Esame_Valutazione_economica#',@value_out) > 0 )
		BEGIN
			set @valore_calcolato=''
			select @valore_calcolato=dbo.RISOLVE_VERBALEGARA_Document_Esame_Valutazione_Economica(@Id,@idPDA,@divisione_lotti)	
			set @value_out=replace(@value_out,'#Document.Esame_Valutazione_economica#',ISNULL(@valore_calcolato,''))		
		END
		if ( CHARINDEX( '#Document.Esito_Valutazione_Economica#',@value_out) > 0 )
		BEGIN
			set @valore_calcolato=''
			select @valore_calcolato=dbo.RISOLVE_VERBALEGARA_Document_Esito_Valutazione_Economica(@Id,@idbando,@idPDA,@divisione_lotti)	
			set @value_out=replace(@value_out,'#Document.Esito_Valutazione_Economica#',ISNULL(@valore_calcolato,''))		
		END
		if ( CHARINDEX( '#Document.Gradutatoria_Finale#',@value_out) > 0 )
		BEGIN
			set @valore_calcolato=''
			select @valore_calcolato=dbo.RISOLVE_VERBALEGARA_Document_Gradutatoria_Finale(@Id,@idbando,@idPDA,@divisione_lotti)	
			--insert into CTL_DOC_Value (IdHeader,DSE_ID,Value)
			--select -1000,'XXX' , CAST( @Id as varchar(10)) + '@' + CAST( @idbando as varchar(10))  + '@' + CAST( @idPDA as varchar(10)) + '@' + CAST( @divisione_lotti as varchar(10) )
			
			set @value_out=replace(@value_out,'#Document.Gradutatoria_Finale#',ISNULL(@valore_calcolato,''))		
		END
		if ( CHARINDEX( '#Document.Soglia_Anomalia#',@value_out) > 0 )
		BEGIN
			set @valore_calcolato=''
			select @valore_calcolato=dbo.RISOLVE_VERBALEGARA_Document_Soglia_Anomalia(@Id,@idbando,@idPDA,@divisione_lotti)	
			set @value_out=replace(@value_out,'#Document.Soglia_Anomalia#',ISNULL(@valore_calcolato,''))		
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


		if ( CHARINDEX( '#Document.LogoVerbale#',@value_out) > 0 )
		BEGIN
			set @valore_calcolato=''
			-- solo per l'ente gestore si mette il logo
			if exists( select IdMp from MarketPlace with(nolock) where mpIdAziMaster = @Ente )
			begin
				set @valore_calcolato=DBO.CNV_ESTESA( 'LogoVerbale' , 'I' )
			end
			set @value_out=replace(@value_out,'#Document.LogoVerbale#',ISNULL(@valore_calcolato,''))		
		END
		

		if ( CHARINDEX( '#Document.Frase_Aggiudicazione_Senza_Anomalia#',@value_out) > 0 )
		BEGIN
			set @valore_calcolato=''
			-- solo se non richiesta anomalia sul lotto risolvo il pattern
			if exists( 
					select idlotto 
					from 
						BANDO_GARA_CRITERI_VALUTAZIONE_PER_LOTTO 
					where idBando = @idbando  and N_Lotto = @NumeroLotto and CalcoloAnomalia <> '1'  
					)
			begin
								
				select @valore_calcolato=dbo.RISOLVE_VERBALEGARA_Document_Frase_Aggiudicazione_Senza_Anomalia(@Id,@idbando,@idPDA,@divisione_lotti)	
				
			end
			set @value_out=replace(@value_out,'#Document.Frase_Aggiudicazione_Senza_Anomalia#',ISNULL(@valore_calcolato,''))		
		END

		
	--	insert into CTL_TRACE (idDoc,contesto,descrizione)
		--	select @id,@contesto, @@value_out
	
END


GO
