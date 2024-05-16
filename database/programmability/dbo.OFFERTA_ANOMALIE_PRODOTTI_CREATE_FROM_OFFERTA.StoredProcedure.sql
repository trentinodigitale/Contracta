USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OFFERTA_ANOMALIE_PRODOTTI_CREATE_FROM_OFFERTA]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE  proc [dbo].[OFFERTA_ANOMALIE_PRODOTTI_CREATE_FROM_OFFERTA] ( @idoff as int, @idPfu as int) 
AS
BEGIN

	SET NOCOUNT ON

	declare @Errore as nvarchar(2000)
	declare @Id as INT
	declare @idbando as int

	select @idbando=LinkedDoc from ctl_doc with(nolock) where id=@idoff

	set @Errore=''
	
	IF EXISTS (Select * from ctl_doc with(nolock) where id=@idoff and tipodoc='OFFERTA'  AND StatoFunzionale <> 'InvioInCorso_prodotti' )
	BEGIN
		set @Errore='Operazione non consentita per lo stato del documento'
	END

	select @Id=id from ctl_doc with(nolock) where LinkedDoc=@idoff and TipoDoc='OFFERTA_ANOMALIE_PRODOTTI' and StatoFunzionale <> 'Annullato' and Deleted=0
	
	if @Errore='' and @id is null
	BEGIN

		exec START_OFFERTA_CHECK @idoff , @idPfu
		
		insert into ctl_doc(IdPfu,TipoDoc,LinkedDoc,idPfuInCharge,Destinatario_Azi)
			select @idPfu,'OFFERTA_ANOMALIE_PRODOTTI',@idoff,@idPfu,Destinatario_Azi
				from ctl_doc with(NOLOCK) 
				where id=@idoff

		set @id = SCOPE_IDENTITY()

		--TABELLA DI LAVORO DOVE INSERISCO TUTTE LE ANOMALIE E LA USO PER POPOLARE LA CTL_DOC_VALUE
		--CREATE TABLE [dbo].TMP_WORK_PRO
		create table #TMP_WORK_PRO
		(
			[IdRow] [int] IDENTITY(1,1) NOT NULL,
			[NumeroLotto]int NULL,
			[EsitoRiga] [nvarchar](max)  COLLATE database_default NULL,
			[Descrizione] [nvarchar](max)  COLLATE database_default NULL
		)

		--AGGIUNGO I LOTTI CHE HANNO ERRORI NELLE RIGHE DI PRODOTTI
		--insert into TMP_WORK_PRO ([NumeroLotto],[EsitoRiga],Descrizione)
		-- select numerolotto,EsitoRiga,Descrizione
		--	from Document_MicroLotti_Dettagli 
		--		where IdHeader=@idoff and tipodoc='OFFERTA' and voce=0 and EsitoRiga <> '' 
		--				and EsitoRiga <> '<img src="../images/Domain/State_OK.gif">' 
		--				and left(ISNULL(EsitoRiga,''),50) <> '<br><img src="../images/Domain/State_Warning.gif">'
			
			
		--AGGIUNGO ALTRI LOTTI CHE HANNO ANOMALIE SULLE BUSTE
		insert into #TMP_WORK_PRO ([NumeroLotto],[EsitoRiga],Descrizione)
			select V.NumeroLotto,V.EsitoRiga,V.Descrizione 
				from OFFERTA_LISTA_BUSTE_VIEW V		
					-- esclude dai controlli sulla busta dei prodotti nel caso in cui non sia prevista la presenza di firma per sningolo lotto
					inner join Document_bando B with(nolock) on B.idheader = @idbando and not 
												(	B.divisione_lotti = '0'										-- gara senza lotti
													or B.ProceduraGara = '15583'								-- Affidamento Diretto
													or B.ProceduraGara = '15479'								-- richiesta di preventivo
													or   (B.ProceduraGara = '15477' and B.TipoBandoGara='2')	-- primo giro della ristretta
												)
					where V.idheader=@idoff and RichiestaFirma='si' and  TipoDoc = 'OFFERTA' 
						and	( Esito_Busta_Tec  not in ('firmato' , '', 'pronto', 'pending')  or  Esito_Busta_Eco  not in ('firmato' , 'pronto', 'pending') ) 
						and voce = 0 


			
		
		--COLLEZIONO ELENCO ANOMALIE SUL DOCUMENTO
		insert into CTL_DOC_Value (IdHeader,DSE_ID,DZT_Name,Value,Row)
			select @id,'DETTAGLI','NumeroLotto',[NumeroLotto],[IdRow]-1 
				from #TMP_WORK_PRO 
				order by [IdRow]

		insert into CTL_DOC_Value (IdHeader,DSE_ID,DZT_Name,Value,Row)
			select @id,'DETTAGLI','EsitoRiga',EsitoRiga,[IdRow]-1 
				from #TMP_WORK_PRO 
				order by [IdRow]
				
		insert into CTL_DOC_Value (IdHeader,DSE_ID,DZT_Name,Value,Row)
			select @id,'DETTAGLI','Descrizione',[Descrizione], [IdRow]-1 
				from #TMP_WORK_PRO 
				order by [IdRow]
			
		--INSERISCO EVENTUALI WARNING PRESENTI SUI PRODOTTI DELL'OFFERTA
		insert into CTL_DOC_Value (IdHeader,DSE_ID,DZT_Name,Value,Row)
			select @id,'TESTATA','EsitoRiga','<img src="../images/Domain/State_Warning.gif"><br/>' + value, 0
				from CTL_DOC_Value with(nolock)
				where IdHeader=@idoff and DSE_ID='TESTATA_PRODOTTI_TMP' and DZT_Name='EsitoRiga_TMP_WRN'  and Row=0 and ISNULL(value,'')<>''
								
				

		drop table #TMP_WORK_PRO

		exec END_OFFERTA_CHECK @idoff , @idPfu

	END


	if @Errore = ''
	begin
		-- rirorna l'id della nuova comunicazione appena creata
		select @Id as id
	
	end
	else
	begin
		-- rirorna l'errore
		select 'Errore' as id , @Errore as Errore
	end

END




GO
