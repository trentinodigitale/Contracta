USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CK_RICHIESTA_CIG_DATI_GARA]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE  PROCEDURE [dbo].[CK_RICHIESTA_CIG_DATI_GARA] ( @idDoc int , @IdUser int )
AS
BEGIN

	SET NOCOUNT ON

	declare @Oggetto nvarchar(max)
	declare @OldOggetto nvarchar(max)
	declare @importoBaseAsta2 float
	declare @COD_LUOGO_ISTAT varchar(50)
	declare @CODICE_CPV varchar(50)
	declare @NumLotti int
	declare @Divisione_lotti varchar(20)
	declare @CIG varchar(50)
	declare @nEqual as int
	declare @IdRichiesta as int
	set @nEqual = 1
	
	--recupero id richiesta cig
	set @IdRichiesta=0
	select @IdRichiesta=ID
		from 
			CTL_DOC with (nolock)
		where 
			LinkedDoc = @idDoc and TipoDoc='RICHIESTA_CIG' and StatoFunzionale='Inviato' and Deleted=0

	if isnull(@IdRichiesta,0) > 0
	begin
		
		select @COD_LUOGO_ISTAT = Value from ctl_doc_value  with(nolock) where idheader = @idDoc and dse_id = 'InfoTec_SIMOG' and dzt_name = 'COD_LUOGO_ISTAT' 
		
		select @CODICE_CPV = Value from ctl_doc_value  with(nolock) where idheader = @idDoc and dse_id = 'InfoTec_SIMOG' and dzt_name = 'CODICE_CPV' 

		select @Oggetto = Body from CTL_DOC with(nolock)  where id = @idDoc
		
		select @OldOggetto = Body from CTL_DOC with(nolock)  where id = @IdRichiesta

		select  
			@importoBaseAsta2 = importoBaseAsta,
			@Divisione_lotti = Divisione_lotti ,
			@CIG = CIG
			from 
				document_bando with(nolock) 
			where idHeader = @idDoc

		select @NumLotti = count(*) 
			from ctl_doc b with(nolock) 
				inner join Document_MicroLotti_Dettagli d with(nolock) on d.IdHeader = b.id and b.TipoDoc = d.TipoDoc 
																		and d.voce = 0 where b.id = @idDoc
					
		if isnull( @NumLotti, 0 ) = 0 
			set @NumLotti = 1

		if exists (
			select idrow from 
				Document_SIMOG_GARA with(nolock) 
				where idHeader = @IdRichiesta
					and (   
							@OldOggetto <> @Oggetto 
							or	
							dbo.AFS_ROUND(@importoBaseAsta2,2) <> dbo.AFS_ROUND(IMPORTO_GARA,2) 
							or  
							@NumLotti <> NUMERO_LOTTI 
						)
			)
			set @nEqual = 0

		--se non ci sono differenze controllo i dettagli
		if @nEqual = 1
		begin
			if exists(
			select 
				d.id
				from ctl_doc b with(nolock) 
					inner join Document_MicroLotti_Dettagli d with(nolock) on d.IdHeader = b.id and b.TipoDoc = d.TipoDoc and d.voce = 0 
					left  join Document_SIMOG_LOTTI l with(nolock) on  l.idheader = @IdRichiesta 
								and 
								(  
									( l.CIG = case when @Divisione_lotti = 0 then @CIG else d.CIG end ) -- i dati della richiesta precedente vanno accoppiato per CIG
									or
									( d.CIG = '' and l.CIG = '' and l.NumeroLotto = d.NumeroLotto ) -- in assenza di CIG si accoppia per numero lotto
								)

				where b.id = @idDoc
							and 
								( 
									d.Descrizione <> l.OGGETTO 
									or
									dbo.AFS_ROUND(d.ValoreImportoLotto,2) <> ( dbo.AFS_ROUND(isnull(l.IMPORTO_LOTTO,0),2) - isnull(l.IMPORTO_OPZIONI,0) - isnull(l.IMPORTO_ATTUAZIONE_SICUREZZA,0) ) 
									--or
									--@CODICE_CPV <> l.CPV 
									--or
									--@COD_LUOGO_ISTAT <> l.LUOGO_ISTAT 
									or
									dbo.AFS_ROUND( isnull(d.IMPORTO_OPZIONI,0),2) <> dbo.AFS_ROUND(isnull(l.IMPORTO_OPZIONI,0),2) 
									or
									dbo.AFS_ROUND(isnull(d.IMPORTO_ATTUAZIONE_SICUREZZA,0),2) <> dbo.AFS_ROUND(isnull(l.IMPORTO_ATTUAZIONE_SICUREZZA,0),2)
								)
			
			)
			set @nEqual = 0
			 
		end
	end

	IF @nEqual = 1
		select 'OK' as Esito
	else
		select 'KO' as Esito

END










GO
