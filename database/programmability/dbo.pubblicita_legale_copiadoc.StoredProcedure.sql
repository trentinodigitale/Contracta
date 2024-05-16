USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[pubblicita_legale_copiadoc]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[pubblicita_legale_copiadoc] ( @TIPODOC as Varchar(200) ,@IdDoc int , @IdNewDoc int output) 
AS
begin

	insert into CTL_DOC ( TipoDoc ) values ( @TipoDoc  ) 

	set @IdNewDoc = SCOPE_IDENTITY()

	exec COPY_RECORD 'CTL_DOC'   ,@IdDoc  , @IdNewDoc, 'ID'

	update ctl_doc set deleted = 1 where id = @IdNewDoc
	
	--copio nella Document_RicPrevPubblic i dati inseriti nelle sezioni RICHIESTA DI PREVENTIVO,ORDINATIVI_GURI_ALLEGATI,ORDINATIVI_QUOTIDIANI_ALLEGATI per recuperarli nella cronlogia
	insert into Document_RicPrevPubblic 
			( 	IdHeader, Deleted, [Protocol],[Importo],[NumQuotReg], [NumQuotNaz],
				[DomCodiceIPA], [MandatoPagDett], [Allegato], [allegatoVistoContabile], [AllegatoDetermina],
				[StatoRicPrevPubblic], [PEG], [Oggetto],
				[UserDirigente], [DataInvio],  [UserProvveditore], [DataCompilazione], [NumRigheBollo], 
				[AllegatoBURC], [AllegatoGURI], [LinkModified], [StatoDataPubb], [NumRigheGuri], [TipoDocumento], [Tipologia], 
				[CostoBurc], [BudgetProgettoBurc], [BudgetPegBurc], [CoperturaBurc], [CostoGuri], [BudgetProgettoGuri], [BudgetPegGuri], 
				[CoperturaGuri], [NoteRicPrev], [Storico], [RicPubDPE], [RicPubECO], [DataOperazione], 
				[User], [StatoDataPubbBG], [LinkDocRdBE], [IdentificativoIniziativa], [AllegatoIOL], [allegatoFirmato],FAX,NumCaratteri,RigoLungo,NumRighe,Pratica

		)
		select	@IdNewDoc, 1, [Protocol], [Importo],[NumQuotReg], [NumQuotNaz], 
				[DomCodiceIPA], [MandatoPagDett], [Allegato], [allegatoVistoContabile], [AllegatoDetermina],
				[StatoRicPrevPubblic], [PEG], [Oggetto],
				[UserDirigente], [DataInvio],  [UserProvveditore], [DataCompilazione], [NumRigheBollo], 
				[AllegatoBURC], [AllegatoGURI], [LinkModified], [StatoDataPubb], [NumRigheGuri], [TipoDocumento], [Tipologia], 
				[CostoBurc], [BudgetProgettoBurc], [BudgetPegBurc], [CoperturaBurc], [CostoGuri], [BudgetProgettoGuri], [BudgetPegGuri], 
				[CoperturaGuri], [NoteRicPrev], [Storico], [RicPubDPE], [RicPubECO], [DataOperazione], 
				[User], [StatoDataPubbBG], [LinkDocRdBE], [IdentificativoIniziativa], [AllegatoIOL], [allegatoFirmato],FAX,NumCaratteri,RigoLungo,NumRighe,Pratica
			from Document_RicPrevPubblic 
			where IdHeader=@IdDoc

	--copio nella Document_RicPrevPubblic_Quotidiani i dati inseriti nelle sezioni 
	--PREVENTIVO_GURI,PREVENTIVO_QUOTIDIANI,ORDINATIVI_GURI_ELENCO,ORDINATIVI_QUOTIDIANI_ELENCO,DATE_GURI,DATE_QUOTIDIANI per recuperarli nella cronlogia
	insert into Document_RicPrevPubblic_Quotidiani 
			(	IdHeader,
				[Giornale],[Fornitore],[DataPubblicazione], [NumeroGazzetta], [Allegato],
				[idRicPubblic],  [NumMod], [Importo], [StatoQuotidiano], [PEG], [RDP_VDS],  
				[Disponibilita], [Ticket], [Added], [NonEditabili],  [Storico], [Tipo], [CIG], [CostoBollo]
			)
		select	@IdNewDoc,
				[Giornale],[Fornitore],[DataPubblicazione], [NumeroGazzetta], [Allegato],
				[idRicPubblic],  [NumMod], [Importo], [StatoQuotidiano], [PEG], [RDP_VDS],  
				[Disponibilita], [Ticket], [Added], [NonEditabili],  [Storico], [Tipo], [CIG], [CostoBollo]
			from Document_RicPrevPubblic_Quotidiani 
			where IdHeader=@IdDoc
			order by idRow

	--copio nella CTL_ApprovalSteps i dati presenti nelle sezioni CRONOLOGIA,WORKFLOW per recuperarli nella cronologia
	insert into	CTL_ApprovalSteps 
			(	[APS_Doc_Type], [APS_ID_DOC], [APS_State], [APS_Note], [APS_Allegato], 
				[APS_UserProfile], [APS_IdPfu], [APS_IsOld], [APS_Date], [APS_APC_Cod_Node], [APS_NextApprover]
			)
		select	[APS_Doc_Type], @IdNewDoc, [APS_State], [APS_Note], [APS_Allegato], 
				[APS_UserProfile], [APS_IdPfu], [APS_IsOld], [APS_Date], [APS_APC_Cod_Node], [APS_NextApprover]
			from CTL_ApprovalSteps
			where APS_ID_DOC=@IdDoc
			order by APS_ID_ROW

	--copio nella CTL_DOC_SIGN i dati presenti nella sezione  ALLEGATO_IOL per recuperarli nella cronologia
	insert into CTL_DOC_SIGN
			(	[idHeader], 
				[F1_DESC], [F1_SIGN_HASH], [F1_SIGN_ATTACH], [F1_SIGN_LOCK], 
				[F2_DESC], [F2_SIGN_HASH], [F2_SIGN_ATTACH], [F2_SIGN_LOCK], 
				[F3_DESC], [F3_SIGN_HASH], [F3_SIGN_ATTACH], [F3_SIGN_LOCK], 
				[F4_DESC], [F4_SIGN_HASH], [F4_SIGN_ATTACH], [F4_SIGN_LOCK]
			)
		select @IdNewDoc,
				[F1_DESC], [F1_SIGN_HASH], [F1_SIGN_ATTACH], [F1_SIGN_LOCK], 
				[F2_DESC], [F2_SIGN_HASH], [F2_SIGN_ATTACH], [F2_SIGN_LOCK], 
				[F3_DESC], [F3_SIGN_HASH], [F3_SIGN_ATTACH], [F3_SIGN_LOCK], 
				[F4_DESC], [F4_SIGN_HASH], [F4_SIGN_ATTACH], [F4_SIGN_LOCK]
			from CTL_DOC_SIGN
			where idHeader=@IdDoc

	--copio nella CTL_DOC_Value i dati presenti nella sezione  ORDINATIVI_QUOTIDIANI_UFFICIO_PUBB e CRITERI_ECO per recuperarli nella cronologia
	insert into CTL_DOC_Value ( [IdHeader], [DSE_ID], [Row], [DZT_Name], [Value])
		select @IdNewDoc, [DSE_ID], [Row], [DZT_Name], [Value] 
			from  CTL_DOC_Value	
			where IdHeader=@IdDoc and DSE_ID in ('CRITERI_ECO','ORDINATIVI_QUOTIDIANI_UFFICIO_PUBB','HELP','NOT_EDITABLE')
end
GO
