USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CATALOGO_MEA_CREATE_FROM_MODIFICA]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[CATALOGO_MEA_CREATE_FROM_MODIFICA] 
	( @idDoc int  , @idUser int )
AS

BEGIN
	BEGIN TRAN

	SET NOCOUNT ON	-- set nocount ON è importantissimo

	declare @Id int = 0
	declare @LastId int = @idDoc;
	declare @lastPrevDoc int = @idDoc;
	declare @idAlbo int;
	declare @Errore nvarchar(2000) = '';
	declare @statoFunzionale varchar(100);
	declare @linkedDoc int;
	declare @azienda varchar(100);
	declare @newId int = -1;
	declare @idEnte int;

	--recupero le informazioni del documento tramite idDoc
	select 
			@linkedDoc = LinkedDoc, --albo
			@idalbo =  LinkedDoc,
			@Id = IdDoc, --modello
			@azienda = Azienda,
			@statoFunzionale = StatoFunzionale
		from CTL_DOC with(nolock)
		where TipoDoc = 'CATALOGO_MEA' and id = @idDoc

	--verifico che il documento di partenza sia nello stato pubblicato 
	if @statoFunzionale = 'Pubblicato'
		begin

			--Verifica che il modello collegato al precedente catalogo sia ancora nello stato pubblicato
			declare @prevStatoFunzionale varchar(100) = '';
			declare @prevIdDoc int = 0;
	
			Select 
				@prevStatoFunzionale = StatoFunzionale, 
				@prevIdDoc = Id
				from CTL_DOC with(nolock)
				where Id = @Id

			if @prevStatoFunzionale = 'Pubblicato'
				begin

					--Verifica che l'albo collegato al precedente catalogo sia ancora nello stato pubblicato altrimenti esce con Errore "il Mercato Elettronico del catalogo non è più pubblicato. Procedere con la compilazione di un nuovo catalogo"
					declare @prevAlboStatoFunzionale varchar(100);

					select @prevAlboStatoFunzionale = StatoFunzionale
						from CTL_DOC with(nolock)
						where Id = @linkedDoc

					if @prevAlboStatoFunzionale = 'Pubblicato'
						begin 
							--Verifica che l'iscrizione all'albo l'albo collegato sia ancora valida ( ISCRITTO) 
							declare @StatoIscrizione varchar(100) = '';
						
							select 
								@StatoIscrizione = StatoIscrizione
								from CTL_DOC_Destinatari with(nolock)
								where idHeader = @linkedDoc and IdAzi = @azienda

							if @StatoIscrizione = 'Iscritto'
								begin	
								
								-- verifico se esiste un documento CATALOGO_MEA collegato al modello ( idDoc ) ed all'albo ( LinkedDoc ) nello stato inLavorazione
								select top 1 
									@newId = id
									from CTL_DOC with(nolock) 
									where tipodoc = 'CATALOGO_MEA' and Azienda = @azienda and LinkedDoc = @linkedDoc and IdDoc = @Id and Deleted = 0 and StatoFunzionale = 'InLavorazione'
									order by Id desc

									if @newId = -1 
										begin 
				
											-- creo il documento per il nuovo catalogo
											insert into CTL_DOC (  idpfu, TipoDoc, StatoDoc, Data, Protocollo, PrevDoc, Deleted,
															fascicolo,linkedDoc,richiestaFirma, 
															protocolloRiferimento, strutturaAziendale,
															Body, Azienda, DataScadenza, Destinatario_Azi, 
															Destinatario_User, JumpCheck , IdDoc , idPfuInCharge
															, SIGN_LOCK , SIGN_HASH
															)
												select @idUser as idpfu , 'CATALOGO_MEA' as Tipodoc , 'Saved' as StatoDoc, getdate() as Data, '' as Protocollo, @idDoc as PrevDoc, 0 as Deleted 
													,Fascicolo, Linkeddoc , richiestaFirma, 
													protocolloRiferimento , strutturaAziendale
													,Body, Azienda , DataScadenza, Destinatario_Azi, 
													Destinatario_User, JumpCheck, IdDoc, @idUser as idPfuInCharge
													,  '0'  as SIGN_LOCK, '' as SIGN_HASH
													from CTL_DOC with(nolock) 
													where Id = @idDoc 

											IF @@ERROR <> 0 
												BEGIN
													raiserror ('Errore creazione record in ctl_doc.  ', 16, 1)  --, CAST(@@ERROR AS NVARCHAR(4000)))
													rollback tran
													return 99
												END

											set @newId = @@identity

											-- recupero il mome modello del precedente documento
											declare @NomeModello varchar(1000)
											select  @NomeModello = [MOD_Name]
												from CTL_DOC_SECTION_MODEL with(nolock) 
												where [IdHeader] = @idDoc and [DSE_ID] = 'PRODOTTI' 



											-- ricopiamo le righe prese dal precedente catalogo
											declare @Filter as nvarchar(max)
											set @Filter = 'Tipodoc=''CATALOGO_MEA'' and idheader=' + cast(@IdDoc as varchar(50)) 																																									
											exec INSERT_RECORD_NEW 'Document_MicroLotti_Dettagli', @idDoc, @newId, 'IdHeader', 'id', @Filter, '', '', 'id'	


											-----------------------------------------------------
											--Copio il modello per specializzare il filtro sulle classi con l'intersezione di classi fra modello e abilitazione
											-----------------------------------------------------
											--declare @NomeModello varchar(1000)
											declare @NomeModelloNew varchar(1000)

											select  @NomeModello = 'MODELLI_MEA_' + Titolo + '_Mod_Modello'
												from CTL_DOC with(nolock) 
												where Id = @id  --Modello

											set @NomeModelloNew = @NomeModello + '_' + CAST( @newId as varchar(100))

											insert into CTL_Models  ( [MOD_ID], [MOD_Name], [MOD_DescML], [MOD_Type], [MOD_Sys], [MOD_help], [MOD_Param], [MOD_Module], [MOD_Template] )
												select  @NomeModelloNew as [MOD_ID], @NomeModelloNew as [MOD_Name], [MOD_DescML], [MOD_Type], [MOD_Sys], [MOD_help], [MOD_Param], [MOD_Module], [MOD_Template]
													from CTL_Models with(nolock) 
													where [MOD_ID] = @NomeModello

											insert into CTL_ModelAttributes ( [MA_MOD_ID], [MA_DZT_Name], [MA_DescML], [MA_Pos], [MA_Len], [MA_Order], [DZT_Type], [DZT_DM_ID], [DZT_DM_ID_Um], [DZT_Len], [DZT_Dec], [DZT_Format], [DZT_Help], [DZT_Multivalue], [MA_Module] )
												select @NomeModelloNew as [MA_MOD_ID], [MA_DZT_Name], [MA_DescML], [MA_Pos], [MA_Len], [MA_Order], [DZT_Type], [DZT_DM_ID], [DZT_DM_ID_Um], [DZT_Len], [DZT_Dec], [DZT_Format], [DZT_Help], [DZT_Multivalue], [MA_Module] 
													from CTL_ModelAttributes with(nolock) 
													where  [MA_MOD_ID] = @NomeModello
													order by [MA_ID]

											insert into CTL_ModelAttributeProperties ([MAP_MA_MOD_ID], [MAP_MA_DZT_Name], [MAP_Propety], [MAP_Value], [MAP_Module] ) 
												select @NomeModelloNew as [MAP_MA_MOD_ID], [MAP_MA_DZT_Name], [MAP_Propety], [MAP_Value], [MAP_Module]
													from CTL_ModelAttributeProperties 
													where [MAP_MA_MOD_ID] = @NomeModello
													order by [MAP_ID]



											
											-- associo il modello per la sezione prodotti del precedente documento
											insert into CTL_DOC_SECTION_MODEL ( [IdHeader], [DSE_ID], [MOD_Name] ) 
												select  @newId , 'PRODOTTI' , @NomeModelloNew

											-- inserisco il nome del modello per le operazioni di upload e download
											insert into CTL_DOC_VALUE ( [IdHeader], [DSE_ID], Value , [Row] , [DZT_Name]) 
												select  @newId , 'TESTATA_PRODOTTI' , @NomeModelloNew , 0 , 'Modello'



											-- specializzo il filtro sulle classi merceologiche per eventuali cambiamenti di abilitazione


											-----------------------------------------------------------
											-- recupero le classi di iscrizione dell'azienda utente prese dall'ultima conferma
											-----------------------------------------------------------
											declare @ClasseIscriz				varchar(max)	
											set @ClasseIscriz = ''
											select @ClasseIscriz = @ClasseIscriz + Cl.Value 

												from CTL_DOC AL with (nolock)

													-- recupera l'ultima istanza approvata
													inner join CTL_DOC_Destinatari I with (nolock) on I.idHeader = AL.id and I.IdAzi = @azienda

													-- approvazione dell'istanza dove sono presenti le classi di iscrizione valide
													inner join CTL_DOC Ap with(nolock) on Ap.LinkedDoc = I.Id_Doc and Ap.TipoDoc = 'CONFERMA_ISCRIZIONE' and Ap.Deleted = 0  

													-- recupero le classi confermate
													inner join ctl_doc_value Cl with(nolock ) on Cl.IdHeader = Ap.Id and   Cl.DZT_Name = 'ClasseIscriz' 

												where AL.id = @idalbo


											-----------------------------------------------------------
											-- esplode la selezione sulle foglie nel caso in cui sia stato consentito selezionare un ramo 
											-- le interseco con quelle del modello per restringere ulteriormente
											-----------------------------------------------------------
											set @ClasseIscriz =  dbo.ExplodeClasseIscriz( @ClasseIscriz )

											delete from CTL_ModelAttributeProperties where  MAP_MA_MOD_ID = @NomeModelloNew and  MAP_MA_DZT_Name = 'ClasseIscriz_S' and   MAP_Propety = 'Filter'
											insert into CTL_ModelAttributeProperties(MAP_MA_MOD_ID, MAP_MA_DZT_Name, MAP_Value, MAP_Propety, MAP_Module) 			
												select
														@NomeModelloNew as MAP_MA_MOD_ID, 
														'ClasseIscriz_S' as MAP_MA_DZT_Name, 
														[dbo].[GetSQL_WHERE]('ClasseIscriz_S', dbo.Intersezione_Insiemi( @ClasseIscriz , Value , '###' ) ), 
														'Filter' as MAP_Propety, 
														'MODELLI_MEA' as MAP_Module
													from CTL_DOC_Value with(nolock)
													where DZT_Name = 'ClasseIscrizFoglie'and IdHeader = @Id	


										end								
								end	
							else
								begin 
									set @Errore = 'Non si risulta iscritti a questo Mercato Elettronico del catalogo. Procedere con la compilazione di un nuovo catalogo';
								end
						end
					else
						begin
							set @Errore = 'il Mercato Elettronico del catalogo non è più pubblicato. Procedere con la compilazione di un nuovo catalogo'
						end
				end
			else	
				begin
					set @Errore = 'Il modello per la compilazione del catalogo non è più supportato. Procedere con la compilazione di un nuovo catalogo';
				end
		end
	else	
		begin
			set @Errore = 'La modifica è possibile solo da un catalogo pubblicato';
		end	



	if @Errore = ''
		begin

		-- rirorna l'id del doc appena creato o quello del doc in lavorazione
		select @newId as id, 'CATALOGO_MEA' as TYPE_TO, 'CATALOGO_MEA' as JSCRIPT
	
		end
	else
		begin

		-- rirorna l'errore
		select 'Errore' as id , @Errore as Errore

	end

	COMMIT TRAN
END




GO
