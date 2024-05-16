USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_BANDO_GARA_CREATE_FROM_PREGARA]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE  PROCEDURE [dbo].[OLD_BANDO_GARA_CREATE_FROM_PREGARA] ( @idDoc int  , @idUser int )
AS
BEGIN

	declare @id int	
	declare @NewIdRow as int
	declare @Errore as nvarchar(4000)
	declare @CIG as varchar(20)
	declare @Tipo_Rup as varchar(100)
	declare @Id_Ric_Cig as int
	declare @Id_New_Ric_Cig as int
	declare @TipoDocRic as varchar(200)

	set @Errore = ''

	SET NOCOUNT ON

	--CONTROLLO LO STATO DEL PREGARA
	IF EXISTS ( select * from CTL_DOC with(nolock) where Id=@idDoc and StatoFunzionale not in ('Completo','Concluso') )
	BEGIN
		set @Errore =  dbo.CNV( 'Lo stato non è coerente con la funzione richiamata' , 'I' )
	END
	set @id = null

	--SE ESISTE UNA GARA A FRONTE DI QUESTO PREGARA GLI APRIAMO LA GARA
	select @id=id from CTL_DOC with(NOLOCK) where LinkedDoc=@idDoc and TipoDoc='BANDO_GARA' and Deleted=0
	
	--se esiste una GARA con lo stesso numero autorità del pregara allora blocco
	if ISNULL(@id,0)=0 
	begin
		--recupero CIG del PREGARA
		select @CIG = CIG from document_bando with (nolock) where idheader = @id

		if exists (
				select id 
					from ctl_doc with (nolock) 
						inner join document_bando with (nolock)  on idHeader = id 
						where tipodoc in ('BANDO_GARA','BANDO_SEMPLIFICATO') and deleted=0 and CIG = @CIG					
			)
		begin
			set @Errore =  dbo.CNV( 'è già presente una gara con la medesima richiesta CIG, occorre cancellarla per crearne una nuova' , 'I' )
		end
	end

	--CREA LA GARA
	if ISNULL(@id,0)=0 and @Errore = ''
	begin
		
		

		-- genero il record per il nuovo documento
		INSERT into CTL_DOC ( IdPfu,  TipoDoc, Azienda , deleted , StrutturaAziendale,Body )
			select 	P.idpfu ,
					'BANDO_GARA',
					pfuidazi as Azienda ,
					0
					,cast( pfuidazi as varchar) + '#' + '\0000\0000' as StrutturaAziendale			
					--,@idDoc
					,C.Body
				from profiliutente P with(NOLOCK)
					inner join CTL_DOC C with(NOLOCK) on C.Id=@idDoc and C.TipoDoc='PREGARA'
				WHERE P.idpfu = @IdUser

		set @id=SCOPE_IDENTITY()

		

		--memorizzo sulla gara in un campo della ctl_doc_value id_pregara nella sezione delle info SIMOG
		insert into CTL_DOC_Value ( IdHeader , DSE_ID , DZT_Name , Value )
			values
				(@id , 'InfoTec_comune', 'IdDocPreGara',@idDoc )
		

		--SETTO IL RUP SULLA NUOVA GARA
		
		--recupero quale rup deve prendere 
		--select @Tipo_Rup=dbo.PARAMETRI ('SIMOG','TIPO_RUP','DefaultValue','UserRUP',-1) 

		insert into CTL_DOC_Value ( IdHeader , DSE_ID , DZT_Name , Value )
			select @id,'InfoTec_comune','UserRUP',value
				from ctl_doc_value  with(NOLOCK) where idHeader=@idDoc and DSE_ID = 'CRITERI_ECO' and DZT_Name = 'UserRUP'


		--INSERT into Document_bando ( IdHeader )
		--		select @id 	
				
		-- ricopio tutti i valori della	Document_bando			  
		exec INSERT_RECORD_NEW 'Document_bando', @idDoc, @id, 'IdHeader', 
							'IdRow,IdHeader', 
							'', 
							'', 
							'',
							' idheader '
							
		select DZT_Name, Value into #tmp_dati_simog from ctl_doc_value with(nolock) where idheader = @idDoc and dse_id = 'InfoTec_SIMOG'
		
		--select DZT_Name, Value from ctl_doc_value with(nolock) where idheader = 421812 and dse_id = 'InfoTec_SIMOG'

		--SE IN FASE DI PREGARA ERA STATO SCELTO SERVIZI INGEGNERIA COME Tipo di Appalto viene passato a servizi
		update Document_bando 
				set TipoAppaltoGara='3'
			where idHeader=@id and TipoAppaltoGara='5'

		-- RIPORTO I DATI SIMOG/PNRR
		update Document_bando 
				set Appalto_PNC = s8.Value,
					Appalto_PNRR = s9.Value,
					Motivazione_Appalto_PNC = s10.Value,
					Motivazione_Appalto_PNRR = s11.Value,
					Appalto_PNRR_PNC = s1.Value,
					FLAG_MISURE_PREMIALI = s2.Value,
					FLAG_PREVISIONE_QUOTA = s3.Value,
					ID_MISURA_PREMIALE = s4.value,
					ID_MOTIVO_DEROGA = s5.value,
					QUOTA_FEMMINILE = s6.value,
					QUOTA_GIOVANILE = s7.Value
			from document_bando
					left join #tmp_dati_simog s1 on s1.DZT_Name = 'Appalto_PNRR_PNC'
					left join #tmp_dati_simog s2 on s2.DZT_Name = 'FLAG_MISURE_PREMIALI'
					left join #tmp_dati_simog s3 on s3.DZT_Name = 'FLAG_PREVISIONE_QUOTA'
					left join #tmp_dati_simog s4 on s4.DZT_Name = 'ID_MISURA_PREMIALE'
					left join #tmp_dati_simog s5 on s5.DZT_Name = 'ID_MOTIVO_DEROGA'
					left join #tmp_dati_simog s6 on s6.DZT_Name = 'QUOTA_FEMMINILE'
					left join #tmp_dati_simog s7 on s7.DZT_Name = 'QUOTA_GIOVANILE'

					left join #tmp_dati_simog s8 on s7.DZT_Name = 'Appalto_PNC'
					left join #tmp_dati_simog s9 on s7.DZT_Name = 'Appalto_PNRR'
					left join #tmp_dati_simog s10 on s7.DZT_Name = 'Motivazione_Appalto_PNC'
					left join #tmp_dati_simog s11 on s7.DZT_Name = 'Motivazione_Appalto_PNRR'
			where idHeader=@id


		--POPOLA LA SEZIONE ATTI DEL BANDO GARA
		insert into CTL_DOC_ALLEGATI ( idHeader , Descrizione , Allegato)
			select @id , F3_DESC,  case 
										when F4_DESC = 'Atti' then F2_SIGN_ATTACH 
										when F4_DESC = 'DETERMINA' then F1_SIGN_ATTACH 
										else ''
									 end as Allegato							
				from CTL_DOC_SIGN with(nolock) 
				where idHeader=@idDoc and F4_DESC in ('ATTI','DETERMINA')
				order by F4_DESC , idRow

		
		--AGGIORNA LO STATO DEL PREGARA 
		update CTL_DOC set StatoFunzionale='Concluso' , idPfuInCharge=0 where Id=@idDoc
		

		
		---traccio nella cronologia la creazione della gara con isold = 1 APS_STATE = CHECK_OUT e ruolo quello del passo incharge
		declare @userRole as varchar(100)
		select @userRole= APS_UserProfile
			from CTL_ApprovalSteps with(nolock) where APS_ID_DOC=@idDoc and APS_Doc_Type='PREGARA' and APS_State='InCharge'

		insert into CTL_ApprovalSteps 
			( APS_Doc_Type , APS_ID_DOC    , APS_State     , APS_Note    , APS_IdPfu , APS_UserProfile , APS_IsOld , APS_Date ) 
				values ('PREGARA' , @idDoc , 'CREA_GARA' , '' , @idUser     , @userRole       , 1         , getdate() )

		
		update CTL_ApprovalSteps 
			set APS_State='Approved',APS_IdPfu=@iduser,APS_Date= getdate() ,APS_IsOld=1		
				where APS_ID_DOC = @idDoc and APS_Doc_Type='PREGARA' and  APS_IsOld=0 and APS_State='InCharge'		

		--INVOCA LA STORED PER FARE LE STESSE OPERAZIONI DI NUOVA PROCEDURA/CREA_GARA
		EXEC SP_NUOVA_PROCEDURA_SAVE @id , @idUser		


		-- riporta numero indizione e data
		update N 
			set DataIndizione = S.DataIndizione , NumeroIndizione = S.NumeroIndizione , EnteProponente = s.EnteProponente , RupProponente = s.RupProponente
				, cig=s.cig
			from Document_bando N 
				inner join Document_Bando S on s.idheader = @idDoc
			where N.idheader = @id

		--Punteggio tecnico
		insert into CTL_DOC_Value ( IdHeader , DSE_ID , DZT_Name , Value )
			select @id,'CRITERI_ECO','PunteggioTecnico',value
				from ctl_doc_value  with(NOLOCK) where idHeader=@idDoc and DSE_ID = 'CRITERI_ECO' and DZT_Name = 'PunteggioTecnico'

		--Punteggio Economico
		insert into CTL_DOC_Value ( IdHeader , DSE_ID , DZT_Name , Value )
			select @id,'CRITERI_ECO','PunteggioEconomico',value
				from ctl_doc_value  with(NOLOCK) where idHeader=@idDoc and DSE_ID = 'CRITERI_ECO' and DZT_Name = 'PunteggioEconomico'


		---- sovrascrive RUP ed ENTE Espletante
		--declare @Rup int
		--select @Rup = value from ctl_doc_value  with(NOLOCK) where idHeader=@idDoc and DSE_ID = 'CRITERI_ECO' and DZT_Name = 'UserRUP'

		--update c 
		--	set azienda = pfuidazi 
		--	from Ctl_doc c 
		--	inner join ProfiliUtente p on p.idpfu = @Rup
		--	where id = @id


		--prendo la richiesta CIG/SMART CIG associata al PREGARA
		--select 
		--	@Id_Ric_Cig = max(id)  
		--	from 
		--		ctl_Doc with (nolock) 
		--	where TIPODOC in ( 'RICHIESTA_CIG','RICHIESTA_SMART_CIG' ) and linkeddoc =@idDoc   and StatoFunzionale = 'Inviato' and Deleted =0 
		 

		--if isnull(@Id_Ric_Cig ,0) <> 0
		--begin
			
			----recupero tipo richiesta
			--select @TipoDocRic = TipoDoc from ctl_doc with (nolock) where id = @Id_Ric_Cig

			----faccio una copia della richeista cig / smart cig
			--exec COPY_Document @TipoDocRic,@Id_Ric_Cig,@Id_New_Ric_Cig out

			----Preimpostare i campi della richiesta CIG e numero autorità e aggancio la richiesta alla gara 
			--update ctl_doc 
			--	set deleted=0, linkeddoc=@id 
			--	--, statofunzionale='', datainvio=null, protocollo='', 
			--	where id = @Id_New_Ric_Cig
			
			----Riportare luogo istat e CPV
			--insert into CTL_DOC_Value ( IdHeader , DSE_ID , DZT_Name , Value )
			--	select @id,DSE_ID,DZT_Name,value
			--		from ctl_doc_value  with(NOLOCK) 
			--		where idHeader=@idDoc and DSE_ID = 'InfoTec_SIMOG' and DZT_Name in ('COD_LUOGO_ISTAT','CODICE_CPV','DESC_LUOGO_ISTAT')

			----settare richiesta cig a si sulla gara appoena creata
			--update 
			--	document_bando
			--		set RichiestaCigSimog ='si'
			--		where idheader = @id

			exec ASSOCIA_RICHIESTACIG_GARA_FROM_PREGARA  @idDoc ,  @id,  @IdUser

		--end
		--else
		--begin
		--	--settare richiesta cig a no sulla gara appoena creata
		--	update 
		--		document_bando
		--			set RichiestaCigSimog ='no'
		--			where idheader = @id
		--end

		
	end
		

	if @Errore = '' and ISNULL(@id,0) <> 0
	begin
		-- rirorna l'id del doc da aprire
		select @Id as id
				
	end
	else
	begin

		select 'Errore' as id , @Errore as Errore

	end

END
GO
