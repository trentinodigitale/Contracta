USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_ANALISI_LOG_TAB_riepilogo]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






---------------------------------------------------------------
-- recupera i dati per la scheda di riepilogo
---------------------------------------------------------------
CREATE proc [dbo].[OLD_ANALISI_LOG_TAB_riepilogo]
(
	@ProtocolloGara   as varchar(50)  , 
	@RagioneSocialeOE   as varchar(50)  
)
as
begin
	
	SET NOCOUNT ON

	
	declare @IdDoc as int
	declare @DataCreazione as datetime
	declare @DataScadenza as datetime
	declare @IdDocBando as int
	declare @Errore as varchar(1000)
	
	set @IdDocBando = 0
	set @IdDoc = 0
	set @Errore =''

	
	-- cerca la presenza del bando
	select @IdDocBando = id from ctl_doc with(nolock) where protocollo = @ProtocolloGara and deleted = 0 



	if @IdDocBando = 0 
		set @Errore ='Protocollo non trovato'



	-- cerca le offerte compilate dall'OE
	if @Errore = ''
	begin

		if exists( select o.id 
					from CTL_DOC o with(nolock) 
						inner join aziende a with(nolock) on o.azienda = a.IdAzi and aziRagioneSociale like '%' + @RagioneSocialeOE + '%'
					where o.LinkedDoc = @IdDocBando and Deleted = 0 )
		begin

			-- ritorno i dati per compilare la scheda di riepilogo
			select '' as Errore ,
					e.aziRagionesociale as Ente ,
					b.Protocollo as ProtocolloGara , 
					b.Titolo as TitoloBando,
					CONVERT(varchar, B.DataInvio, 120) as DataPubblicazione ,
					b.Body as OggettoGara, 
					CONVERT(varchar, ba.DataAperturaOfferte , 120) as DataAperturaOfferte,
					a.aziRagioneSociale ,
					a.aziLog ,
					u.pfuLogin , 
					u.pfuNome ,
					o.Titolo as TitoloOfferta ,
					o.Statofunzionale as StatoOfferta ,
					CONVERT(varchar, o.Data , 120) as DataCreazione ,
					CONVERT(varchar, ba.DataScadenzaOfferta , 120) as DataScadenzaOfferta,
					CONVERT(varchar, ba.DataPresentazioneRisposte , 120) as DataPresentazioneRisposte,
					CONVERT(varchar, ba.DataRiferimentoFine , 120) as DataRiferimentoFine,


					u.idPfu,
					o.id as IdOfferta

				from CTL_DOC b with(nolock) 
					inner join CTL_DOC o with(nolock) on o.LinkedDoc = b.id and o.TipoDoc in ('OFFERTA','MANIFESTAZIONE_INTERESSE','DOMANDA_PARTECIPAZIONE')
					inner join aziende e with(nolock) on e.IdAzi = b.azienda
					inner join aziende a with(nolock) on o.azienda = a.IdAzi and a.aziRagioneSociale like '%' + @RagioneSocialeOE + '%'
					inner join ProfiliUtente u with(nolock) on u.IdPfu = o.idpfu
					inner join Document_Bando ba with(nolock) on ba.idHeader = b.id
				where b.Id = @IdDocBando and o.Deleted = 0 

				order by a.aziRagioneSociale , u.pfuNome , o.Data
		end
		else
			set @Errore ='Non sono presenti documenti per la ragione sociale indicata'			

	end

	-- in caso si sia presentato un problema si ritorna il messaggio di errore riscontrato
	if @Errore <> ''
		select @Errore as Errore


end

GO
