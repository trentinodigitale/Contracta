USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OFFERTA_ANOMALIE_AMMINISTRATIVA_CREATE_FROM_OFFERTA]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO











CREATE  proc [dbo].[OFFERTA_ANOMALIE_AMMINISTRATIVA_CREATE_FROM_OFFERTA] ( @idoff as int, @idPfu as int) 
as
BEGIN
	SET NOCOUNT ON;

	declare @Errore as nvarchar(2000)
	declare @Id as INT
	declare @idbando as int

	select @idbando=LinkedDoc from ctl_doc with (nolock) where id=@idoff

	set @Errore=''
	
	IF EXISTS (Select * from ctl_doc where id=@idoff and tipodoc='OFFERTA' and StatoFunzionale <> 'InvioInCorso_amministrativa'  )
	BEGIN
		set @Errore='Operazione non consentita per lo stato del documento'
	END

	select @Id=id from ctl_doc where LinkedDoc=@idoff and TipoDoc='OFFERTA_ANOMALIE_AMMINISTRATIVA' and StatoFunzionale <> 'Annullato' and Deleted=0
	
	if @Errore='' and @id is null
	BEGIN
		exec START_OFFERTA_CHECK @idoff , @idPfu
		
			insert into ctl_doc(IdPfu,TipoDoc,LinkedDoc,idPfuInCharge,Destinatario_Azi,Caption)
				select @idPfu,'OFFERTA_ANOMALIE_AMMINISTRATIVA',@idoff,@idPfu,Destinatario_Azi,TipoDoc + '_ANOMALIE_AMMINISTRATIVA' as Caption					
					from ctl_doc with(NOLOCK) where id=@idoff

			set @id = SCOPE_IDENTITY()

			--TABELLA DI LAVORO DOVE INSERISCO TUTTE LE ANOMALIE E LA USO PER POPOLARE LA CTL_DOC_VALUE
			--CREATE TABLE [dbo].TMP_WORK_AMMI
			create table #TMP_WORK_AMMI
			(
				[IdRow] [int] IDENTITY(1,1) NOT NULL,
				[EsitoRiga] [nvarchar](max) COLLATE database_default NULL,
				[Descrizione] [nvarchar](max) COLLATE database_default NULL
		     )

			--RECUPERO ANOMALIE DGUE MANDATARIA SE RICHIESTO
			IF EXISTS (Select idrow from ctl_doc_value with (nolock) where idheader=@idbando and DSE_ID='DGUE' and DZT_Name='PresenzaDGUE' and ISNULL(value,'')='si')
			BEGIN
				if not exists ( Select id from ctl_doc with (nolock) where tipodoc='MODULO_TEMPLATE_REQUEST' and LinkedDoc=@idoff and deleted = 0 and ISNULL(SIGN_ATTACH,'')<>''  )
				BEGIN					
					 insert into #TMP_WORK_AMMI ([EsitoRiga],Descrizione)
						select '<img src="../images/Domain/State_Warning.gif"><br>Allegato DGUE non presente',NULL					
				END
			END
			



			--RECUPERO ANOMALIE GRIGLIE
			insert into #TMP_WORK_AMMI ([EsitoRiga],Descrizione)				
				select EsitoRiga, TipoRiferimento + ' - ' + RagSoc
					from Document_Offerta_Partecipanti 
					where IdHeader=@idoff and EsitoRiga <> '' and EsitoRiga <>'<img src="../images/Domain/State_OK.gif">'
					order by 
						case 
							when TipoRiferimento = 'RTI' then 1 
							when TipoRiferimento = 'AUSILIARIE' then 2
							when TipoRiferimento = 'SUBAPPALTO' then 3
							when TipoRiferimento = 'ESECUTRICI' then 4
						end ,idrow asc			
			
			 --RECUPERO LE ANOMALIE SUGLI ALLEGATI
			 insert into #TMP_WORK_AMMI ([EsitoRiga],Descrizione)
				 select EsitoRiga,Descrizione
					from CTL_DOC_ALLEGATI CA with(NOLOCK)
					where CA.idHeader=@idoff and  ISNULL(CA.Esitoriga,'')<>''and ISNULL(CA.Esitoriga,'')<>'<img src="../images/Domain/State_OK.gif">'
					order by CA.idrow
			
			--RECUPERO ANOMALIE ATTESTATO PARTECIPAZIONE SE RICHIESTO			
			IF EXISTS (select idheader from document_bando with (nolock) where IdHeader=@idbando and ISNULL(ClausolaFideiussoria,0)=1)
			BEGIN
				IF EXISTS ( select * from CTL_DOC_SIGN where idHeader=@idoff and ISNULL(F2_SIGN_ATTACH,'') = '')
				BEGIN
					 insert into #TMP_WORK_AMMI ([EsitoRiga],Descrizione)
						select '<img src="../images/Domain/State_Warning.gif"><br>Manca Attestato di Partecipazione',NULL					
				END
			END		


			--RECUPERO ANOMALIE QUESTIONARIO AMMINISTRATIVO SE RICHIESTO
			IF EXISTS (Select idrow from ctl_doc_value with (nolock)  where idheader=@idbando and DSE_ID='QUESTIONARIO' and DZT_Name='PresenzaQuestionario' and ISNULL(value,'')='si')
			BEGIN
				if NOT exists ( Select id from ctl_doc with (nolock) where tipodoc='MODULO_QUESTIONARIO_AMMINISTRATIVO' and LinkedDoc=@idoff and deleted = 0 and ISNULL(SIGN_ATTACH,'')<>''  )
				BEGIN					
					 insert into #TMP_WORK_AMMI ([EsitoRiga],Descrizione)
						select '<img src="../images/Domain/State_Warning.gif"><br>Allegato QUESTIONARIO non presente',NULL					
				END
			END
	


			--COLLEZIONO ELENCO ANOMALIE SUL DOCUMENTO
			insert into CTL_DOC_Value (IdHeader,DSE_ID,DZT_Name,Value,Row)
				select @id,'DETTAGLI','EsitoRiga',EsitoRiga,[IdRow]-1 
					from #TMP_WORK_AMMI 
					order by [IdRow]
				
			insert into CTL_DOC_Value (IdHeader,DSE_ID,DZT_Name,Value,Row)
				select @id,'DETTAGLI','Descrizione',[Descrizione], [IdRow]-1 
					from #TMP_WORK_AMMI 
					order by [IdRow]
						
		

			

			 drop table #TMP_WORK_AMMI;
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
