USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[GD_Rettifica]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].[GD_Rettifica](@IdMsg as int) AS
--Versione=2&data=2014-01-28&Attivita=52126&Nominativo=Enrico
declare @IdDoc as varchar(50)
declare @TipoBando as varchar(50)
declare @SQL_OLD as varchar(4000)
declare @NewIdMsg as int

--select * from tab_messaggi_fields where idmsg=79879

--RECUPERO GUID DEL BANDO E TIPOBANDO
select @IdDoc=IdDoc,@TipoBando=TipoBando from tab_messaggi_fields where idmsg=@IdMsg

if @TipoBando <> '3'
	
	--SE SI TRATTA DI UN AVVISO,BANDO ALLORA CANCELLO I DOCUMENTI PUBBLICI (-10)	
	update 
		tab_utenti_messaggi
	set 
		umstato=1
	where 
		umidmsg in ( select umidmsg from tab_messaggi_fields,tab_utenti_messaggi where iddoc=@IdDoc and umidmsg=idmsg and advancedstate='6'  and umidpfu=-10 ) and umidmsg <> @IdMsg

else
	--SI TRATTA DI INVITI ALLORA CANCELLO I DOCUMENTI DEI FORNITORI
	update 
		tab_utenti_messaggi
	set 
		umstato=1
	where 
		umidmsg in ( select umidmsg from tab_messaggi_fields,tab_utenti_messaggi where iddoc=@IdDoc and umidmsg=idmsg and advancedstate='6') and umidmsg <> @IdMsg	


--select TipoBando,umidpfu,umstato,uminput,* from tab_messaggi_fields,tab_utenti_messaggi where 
--iddoc='335790EA3B2344CB8DF0E05E282BC826'
--and umidmsg=idmsg and umidpfu>0 and advancedstate='6' and stato=2 and uminput=0
--and isubtype=168

--SE SI TRATTA DI AVVISO/BANDO PER QUELLI CHE HANNO SCARICATO
--GIA' IL BANDO SOSTITUISCO I BLOB/PARTE PIATTA SUI MESSAGGI GIA' SCARICATI PER AGGIRONARLI CON LA RETTIFICA
if @TipoBando <> '3'
begin

	--recupero il nuovo messaggio pubblico generato
--	select top 1 umidmsg from tab_messaggi_fields,tab_utenti_messaggi where 
--	iddoc='28BEC0B6B6EA416F93925621E6A8E866' 
--	and umidmsg=idmsg and umidpfu=-10 and advancedstate='0' and stato=2 and uminput=0 and umstato=0 order by umidmsg desc

    select top 1 @NewIdMsg=umidmsg from tab_messaggi_fields,tab_utenti_messaggi where 
	iddoc=@IdDoc
	and umidmsg=idmsg and umidpfu=-10 and advancedstate='0' and stato=2 and uminput=0 and umstato=0 order by umidmsg desc

		

    if not @NewIdMsg is null
    begin
		--select attidobj,attorderfile from tab_attach where attidmsg=79870
	
		--recupero i messaggi su cui aggiornare i blob
--		select TipoBando,umidpfu,umstato,uminput,* from tab_messaggi_fields,tab_utenti_messaggi where 
--		iddoc='4947B88E8A6A409393D1041DE625955D'
--		and umidmsg=idmsg and umidpfu>0 and advancedstate='6' and stato=2 and uminput=0 and umstato=0
--
--		select attidobj,attorderfile from tab_attach where attidmsg=79867    	
		
		--CREO TABELLA TEMPORANEA CON I NUOVI ATTIDOBJ
		select * into #GD_TempRettifica from tab_attach where attidmsg=@NewIdMsg --79870

		--CREO TABELLA TEMPORANEA CON I VECCHI IDMSG DA AGGIORNARE
		select umidmsg 
		into #GD_TempRettifica_Idmsg 
		--select *
		from 
			tab_messaggi_fields,tab_utenti_messaggi where 
			iddoc=@IdDoc  --'4947B88E8A6A409393D1041DE625955D'
			and umidmsg=idmsg and umidpfu>0 and advancedstate='6' and stato=2 and uminput=0 and umstato=0
		
--		
--		UPDATE 
--			tab_attach 
--		SET
--			tab_attach.attidobj = T2.attidobj
--		--select T1.attidobj , T2.attidobj
--		FROM
--			tab_attach T1 
--		INNER JOIN
--			--tab_attach T2
--			#GD_TempRettifica T2
--		ON 
--			T1.attorderfile = T2.attorderfile
--		WHERE 
--			T2.attidmsg=@NewIdMsg --79870
--			and T1.attidmsg in (select umidmsg from #GD_TempRettifica_Idmsg)
		
		--CANCELLO I VECCHI LEGAMI TRA I MESSAGGI E I BLOB
		delete from 
		--select 
		--	* 
		--from 
			tab_attach 
		where attidmsg in (select umidmsg from #GD_TempRettifica_Idmsg)
	
		--INSERISCO I NUOVI LEGAMI (DEL NUOVO MESSAGGIO) SU TUTTI I MESSAGGI 
		insert into TAB_ATTACH
			(attIdMsg, attIdObj, attOrderFile)
			select 
				umidmsg, attidobj, attorderfile
			from 
			    #GD_TempRettifica_Idmsg,tab_attach where attidmsg=@NewIdMsg


		--AGGIORNO PARTE PIATTA  
		select * into #GD_TempRettifica1 from tab_messaggi where idmsg=@NewIdMsg 
		
		UPDATE 		
			tab_messaggi
		SET
			msgtext=A.msgtext
		FROM
			tab_messaggi B
		INNER JOIN
			#GD_TempRettifica1 A
		ON
			A.idmsg=@NewIdMsg
			and B.idmsg in (select umidmsg from #GD_TempRettifica_Idmsg)

		
		--AGGIORONO TAB_MESSAGGI_FIELDS
		DELETE tab_messaggi_fields where idmsg in (select umidmsg from #GD_TempRettifica_Idmsg)
		
		INSERT INTO
			tab_messaggi_fields
			   (IdMsg, iType, iSubType, IdDoc, Stato, AdvancedState, PersistenceType, IdMarketPlace, Name, Protocol, IdMittente, IdDestinatario, [Read], Data, ReceivedDataMsg, ExpiryDate, ProtocolloBando, Object, Object_Cover1, ProtocolloOfferta, ProceduraGaraTradizionale, tipoappalto, CriterioAggiudicazioneGara, AuctionState, DataInizioAsta, DataFineAsta, ImportoBaseAsta, ImportoAppalto, ProceduraGara, ProtocolBG, AggiudicazioneGara, CriterioFormulazioneOfferte, NumProduct_BANDO_rettifiche, ModalitaDiPartecipazione, RagSoc, ReceivedOff, ReceivedQuesiti, TipoProcedura, NameBG, TipoAsta, ReceivedDomanda, ReceivedIscrizioni, sysHabilitStartDate, CIG, FaseGara, DataAperturaOfferte, DataAperturaDomande, DataIISeduta, DataSedutaGara, TermineRichiestaQuesiti, VisualizzaNotifiche, TipoBando, EvidenzaPubblica, IdAziendaAti, ECONOMICA_ENCRYPT, TECNICA_ENCRYPT, ProtocolloInformaticoUscita, DataProtocolloInformaticoUscita, ValutazioneTecnicaRUP, DataPubblicazioneBando, ListaModelliMicrolotti, ImportoBaseAsta2, Rispondere_dal, ValoreOfferta, RichiestaQuesito)
		select 
				umIdMsg, iType, iSubType, IdDoc, Stato, AdvancedState, PersistenceType, IdMarketPlace, Name, Protocol, IdMittente, IdDestinatario, [Read], Data, ReceivedDataMsg, ExpiryDate, ProtocolloBando, Object, Object_Cover1, ProtocolloOfferta, ProceduraGaraTradizionale, tipoappalto, CriterioAggiudicazioneGara, AuctionState, DataInizioAsta, DataFineAsta, ImportoBaseAsta, ImportoAppalto, ProceduraGara, ProtocolBG, AggiudicazioneGara, CriterioFormulazioneOfferte, NumProduct_BANDO_rettifiche, ModalitaDiPartecipazione, RagSoc, ReceivedOff, ReceivedQuesiti, TipoProcedura, NameBG, TipoAsta, ReceivedDomanda, ReceivedIscrizioni, sysHabilitStartDate, CIG, FaseGara, DataAperturaOfferte, DataAperturaDomande, DataIISeduta, DataSedutaGara, TermineRichiestaQuesiti, VisualizzaNotifiche, TipoBando, EvidenzaPubblica, IdAziendaAti, ECONOMICA_ENCRYPT, TECNICA_ENCRYPT, ProtocolloInformaticoUscita, DataProtocolloInformaticoUscita, ValutazioneTecnicaRUP, DataPubblicazioneBando, ListaModelliMicrolotti, ImportoBaseAsta2, Rispondere_dal, ValoreOfferta, RichiestaQuesito
		from #GD_TempRettifica_Idmsg , tab_messaggi_fields 
		where idmsg=@NewIdMsg
		
		--CANCELLO LE TABLE TEMP
		drop table #GD_TempRettifica
		drop table #GD_TempRettifica1
		drop table #GD_TempRettifica_Idmsg
		
	end	
end

GO
