USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[DOCUMENT_LOAD_SEC_PDA_CONCORSO]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO













-- in sostituzione della vista PDA_MICROLOTTI_VIEW_TESTATA


CREATE PROCEDURE [dbo].[DOCUMENT_LOAD_SEC_PDA_CONCORSO](  @DocName nvarchar(500) , @Section nvarchar (500) , @IdDoc nvarchar(500) , @idUser int )
AS
begin
	
	set nocount on

	--RECUPERO INFO PDA E RIFERIMENTI DELLA GARA
	select
		d.* 
		, dbo.ListRiferimentiBando(d.linkeddoc , 'Bando' ) as UsersRiferimentiBando
		, 1 as APERTURA_BUSTE
		, 1 as APERTURA_BUSTE_TECNICHE
		into #INFO_PDA
		from
			ctl_doc d with (nolock) 
		where id=@IdDoc

	--RECUPERO ALTRE INFO DELLA PDA
	select 
		t.*,d.* into #INFO_PDA_2 
		from 
			Document_PDA_TESTATA t with (nolock) 
				CROSS JOIN #INFO_PDA d
		where t.idHeader=@IdDoc


	drop table #INFO_PDA

	--TRAVASO LE INFO DELL PADA E DELLA GARA IN UNA TEMP #INFO_PDA_GARA
	select  
		d.*
		,isnull(B.TipoSceltaContraente,'') as TipoSceltaContraente
		, b.TipoAggiudicazione 
		, b.RegoleAggiudicatari
		, ISNULL(b.TipoProceduraCaratteristica,'') as TipoProceduraCaratteristica
		, case when b.TipoBandoGara = '2' and b.ProceduraGara = '15477' then '1' else '0' end as bandoRistretta
		, b.TipoSedutaGara
		, ISNULL(b.StatoSeduta,'chiusa') as StatoSeduta
		, IsNull(b.StatoChat, 'CLOSE') as StatoChat
		, isnull(b.Concessione,'no') as Concessione
		, b.Visualizzazione_Offerta_Tecnica
		, b.InversioneBuste
		, b.GeneraConvenzione
		, b.Accordo_di_Servizio
		, b.Divisione_lotti
		, b.CalcoloAnomalia
		
		into #INFO_PDA_GARA
		from Document_Bando  b  with (nolock)
				cross join #INFO_PDA_2 d 
		where d.LinkedDoc=b.idHeader

	drop table #INFO_PDA_2

	DECLARE @DataInvioGara datetime --da riportare in output
	DECLARE @SCELTA_CRITERIO_CALCOLO_ANOMALIA varchar (1) --da riportare in output
	DECLARE @gara_id int --da riportare in output
	DECLARE @bloccaVerificaAnomalia varchar (1) --da riportare in output
	DECLARE @NumeroOfferte int --da riportare in output

	DECLARE @FaseConcorso varchar (20)

	--Recupero dalla PDA il flag dei dati in chiaro per l'anonimato
	DECLARE @DatiInChiaro int = 0

	select 
		@DatiInChiaro = isnull(value,0)
		from 
			ctl_doc_value 
		where idheader = @IdDoc
			and DSE_ID = 'ANONIMATO'
			and DZT_Name = 'DATI_IN_CHIARO'
	

	select 
		@DataInvioGara = gara.DataInvio 
		, @SCELTA_CRITERIO_CALCOLO_ANOMALIA = case when gara.DataInvio < '2019-04-19' then '1' else '0' end 
		, @gara_id = gara.id
		, @bloccaVerificaAnomalia= case when isnull(offers.numOff,0) < 5 and RICHIESTA_CALCOLO_ANOMALIA = 'SI' and gara.DataInvio >= '2017-05-20' then '1' else '0' end
		, @NumeroOfferte = isnull(numOff , 0)
		from 
			ctl_doc gara with(nolock) 
				
				left join ( 
							select 
								count(IdHeader) as numOff, IdHeader
								from 
									Document_PDA_OFFERTE with(nolocK)
								where 
									StatoPDA in ( '2' , '22', '222' ,'8' ,'9') 
								group by IdHeader 
							) as offers on offers.IdHeader = @IdDoc
				
				cross join #INFO_PDA_GARA d 

		where gara.id = d.LinkedDoc


	--Recupero dalla gara il campo FaseConcorso
	select 
		@FaseConcorso = isnull(FaseConcorso,'')
		from
			Document_Bando with (nolock)
		where idheader = @gara_id

	
	--RECUPERA IL RUP DELLA GARA
	DECLARE @UserRUP nvarchar(max)  -- DA ritornare in output

	select 
		@UserRUP=rup.Value
		from 
			ctl_doc_value rup with(nolock) 
		where  
			rup.idHeader = @gara_id and rup.dse_id = 'InfoTec_comune' and rup.dzt_name = 'UserRup' 
	

	DECLARE @AttivaFilePending nvarchar(max)  -- DA ritornare in output

	select 
		@AttivaFilePending=cp.value 
		from 
			ctl_doc_value cp with(nolock) 
		where 
			cp.IdHeader = @gara_id and cp.DSE_ID = 'PARAMETRI' and cp.DZT_Name = 'AttivaFilePending' -- parametro della gara
						
	--TRAVASO I MODELLI LEGATI ALLA PDA NELLA TEMP #INFO_MOD_PDA
	select 
		d.*
		, ModelloPDA
		, ModelloPDA_DrillTestata
		, ModelloPDA_DrillLista
		, ModelloOfferta_Drill
		
		into #INFO_MOD_PDA
		from 
			--Document_Modelli_MicroLotti m with(nolock) 
				--cross join #INFO_PDA_GARA d
				#INFO_PDA_GARA d
					left outer join Document_Modelli_MicroLotti m with(nolock) on m.Codice = d.ListaModelliMicrolotti
		--where 
			
	

	DROP TABLE #INFO_PDA_GARA


	DECLARE @Exequo int  -- DA ritornare in output
	DECLARE @l_id int
	DECLARE @StatoRiga varchar(50)  -- DA ritornare in output
	DECLARE @InValutazione varchar(1)  -- DA ritornare in output
	set @InValutazione=0
	--RECUPERO STATO LOTTO 1 SULLA PDA
	SELECT 
		@Exequo=l.Exequo
		, @l_id=l.id
		, @StatoRiga= l.statoriga
		, @InValutazione = case when StatoRiga in ( 'daValutare', 'InValutazione' ) then '1' else '0' end  
		FROM  
			Document_Microlotti_Dettagli l with(nolock) 
		WHERE 
			l.idheader = @IdDoc and l.tipoDoc = 'PDA_MICROLOTTI' and l.NumeroLotto = '1' and l.Voce = 0 



	
	DECLARE @COM_ID INT

	--RECUPERO UTENTI DELLA COMMISSIONE
	SELECT 
		@COM_ID = COM.ID
		FROM
			ctl_doc COM with(nolock) 
				CROSS JOIN #INFO_MOD_PDA D
		WHERE 
			COM.linkeddoc=d.linkeddoc and COM.tipodoc='COMMISSIONE_PDA' and COM.deleted=0 and COM.statofunzionale='pubblicato'
					


	--RECUPERO PRESIDENTE DELLA COMMISSIONE GIUDICATRICE (A)
	DECLARE @presidente_commissione  nvarchar (200)  -- DA ritornare in output
	set @presidente_commissione='0'
	select 
		@presidente_commissione=ISNULL(CU.UtenteCommissione,0)  
		from 
			Document_CommissionePda_Utenti CU with(nolock) 
		where 
			CU.idheader=@COM_ID and CU.TipoCommissione='A' and CU.ruolocommissione='15548'
					

	--RECUPERO PRESIDENTE DELLA COMMISSIONE ECONOMICA (C) se esiste
	DECLARE @PresAgg  int  -- DA ritornare in output
	set @PresAgg=@presidente_commissione
	select
		@PresAgg=coalesce(CEco.UtenteCommissione,@presidente_commissione,0) 
		from 
			Document_CommissionePda_Utenti CEco with(nolock) 
		where 
			CEco.idheader=@COM_ID and CEco.TipoCommissione='C' and CEco.ruolocommissione='15548'
					


	--RECUPERO PRESIDENTE DELLA COMMISSIONE TECNICA (G)
	DECLARE @PresTec  nvarchar (200)  -- DA ritornare in output
	set @PresTec='0'
	select 
		@PresTec= isnull(CTec.UtenteCommissione,0)
		from 
			Document_CommissionePda_Utenti CTec with(nolock) 
		where 
			CTec.idheader=@COM_ID and CTec.TipoCommissione='G' and CTec.ruolocommissione='15548'


	--RECUPERO SE HO ESEGUITO IL COMANDO DI APERTURA BUSTE TECNICHE
	DECLARE @comando_eseguito  varchar (50)  -- DA ritornare in output
	set @comando_eseguito='0'
	select 
		@comando_eseguito= isnull(CTA.APS_State,0) 
		from 
			CTL_ApprovalSteps CTA with(nolock) 
		where
			CTA.APS_ID_DOC=@IdDoc and ctA.APS_Doc_Type='PDA_CONCORSO' and CTA.APS_State='PDA_AVVIO_APERTURE_BUSTE_TECNICHE'

		
	--RECUPERO ESISTENZA DOC DI CRITERIO_CALCOLO_ANOMALIA
	DECLARE @ESISTENZA_RICHIESTA_CALCOLO_ANOMALIA   varchar (2)  -- DA ritornare in output
		select  
			@ESISTENZA_RICHIESTA_CALCOLO_ANOMALIA = case when not CSA.id is null then 'SI' else '' end 
			from 
				ctl_doc CSA with(nolock) 
			where 
				CSA.LinkedDoc=@IdDoc and CSA.TipoDoc='CRITERIO_CALCOLO_ANOMALIA' and CSA.Deleted=0




	-- case when CT.DataScadenza < GETDATE()  or ISNULL(num.count_risposte_da_inviare,1) = 0 or num.LinkedDoc is null then '1' else '0' end as CAN_TERMINA
	--left join ctl_doc CT with(nolock) on CT.tipodoc='PDA_COMUNICAZIONE' and CT.LinkedDoc=d.id and CT.VersioneLinkedDoc=l.id and CT.StatoFunzionale in ( 'Inviato','Inviata Risposta') and CT.JumpCheck='1-OFFERTA'
	--RECUPERO INFO CAN TERMINA
	declare @ct_id as int
	declare @ct_datascadenza as datetime
	select 
		@ct_id=ct.id
		, @ct_datascadenza=DataScadenza
		from  
			ctl_doc CT with(nolock) 
				
		where 
			CT.tipodoc='PDA_COMUNICAZIONE' and CT.LinkedDoc=@IdDoc and CT.VersioneLinkedDoc=@l_id 
				and CT.StatoFunzionale in ( 'Inviato','Inviata Risposta') and CT.JumpCheck='1-OFFERTA'





	declare @count_risposte_da_inviare as int

	select @count_risposte_da_inviare=count(*)  
		from ctl_doc with(nolock) 
		where  tipodoc='PDA_COMUNICAZIONE_OFFERTA'  and statofunzionale <> 'Inviata Risposta' and LinkedDoc =@ct_id
		



	DECLARE @CAN_TERMINA   varchar (1)  -- DA ritornare in output
	set @CAN_TERMINA='0'
	select 	@CAN_TERMINA=case when @ct_datascadenza < GETDATE()  or ISNULL(@count_risposte_da_inviare,1) = 0 or @ct_id is null then '1' else '0' end





	--RECUPERO INFO ATTIVA INVITO
	DECLARE @attivaInvito   varchar (1)  -- DA ritornare in output
	set @attivaInvito=1
	select 
		@attivaInvito=case when ISNULL( attivaInvito.numDom, 0) > 0 then '0' else '1' end 
		from ( 
			select 
				count(IdHeader) as numDom, IdHeader 
				from 
					Document_PDA_OFFERTE with(nolocK) 
				where 
					TipoDoc = 'DOMANDA_PARTECIPAZIONE' and StatoPDA not in ( '1' , '2', '99' ) group by IdHeader 
				) as attivaInvito 
		where attivaInvito.IdHeader =@IdDoc


	--RECUPERO INFO OwnerChat
	DECLARE @OwnerChat   nvarchar (MAX)  -- DA ritornare in output

	select
		@OwnerChat = o.Value 
		from 
			CTL_DOC_Value o with(nolock) 
		where
			o.IdHeader = @IdDoc and o.DSE_ID = 'CHAT' and o.DZT_Name = 'OwnerChat'	
		

	--RECUPERA INFO @PUNTEGGI_ORIGINALI E @ATTIVA_COMANDI_PDA_SEDUTA
	DECLARE @ATTIVA_COMANDI_PDA_SEDUTA   varchar (1)  -- DA ritornare in output
	DECLARE @PUNTEGGI_ORIGINALI   nvarchar (max)  -- DA ritornare in output

	select  
		@PUNTEGGI_ORIGINALI=pa.PUNTEGGI_ORIGINALI
		, @ATTIVA_COMANDI_PDA_SEDUTA=
			Case 
				when psv.Apertura='manuale' then '1'
				when psv.Apertura='automatica' and psv.Chiusura = 'ammessa' then '1'
			else 
				'0'
			end
		from 
			#INFO_MOD_PDA d
				cross join ( select  dbo.PARAMETRI('PDA_CONCORSO','PUNTEGGI_ORIGINALI','SHOW','NO',-1) as PUNTEGGI_ORIGINALI ) as PA
				cross join 	Document_Parametri_Sedute_Virtuali psv with(nolock)  
		where 
			psv.deleted = 0 	


	DECLARE @Lista_Utenti_Commissione VARCHAR(max)  -- DA ritornare in output
	select 	@Lista_Utenti_Commissione =  dbo.Get_Utenti_Commissione(@COM_ID)
	--RITORNO LE INFO INTERESSATE
	select 
			*
			,@DataInvioGara as DataInvioGara
			,@SCELTA_CRITERIO_CALCOLO_ANOMALIA as SCELTA_CRITERIO_CALCOLO_ANOMALIA
			,@gara_id as gara_id
			,@bloccaVerificaAnomalia as bloccaVerificaAnomalia
			,@NumeroOfferte as NumeroOfferte
			,@UserRUP as UserRUP
			,@AttivaFilePending as AttivaFilePending
			,@Exequo as Exequo
			,@StatoRiga as StatoRiga
			,@InValutazione as InValutazione
			,@Lista_Utenti_Commissione as Lista_Utenti_Commissione
			,@presidente_commissione as presidente_commissione
			,@PresAgg as PresAgg
			,@PresTec as PresTec
			,@comando_eseguito as comando_eseguito
			,@ESISTENZA_RICHIESTA_CALCOLO_ANOMALIA as ESISTENZA_RICHIESTA_CALCOLO_ANOMALIA
			,@CAN_TERMINA as CAN_TERMINA
			,@attivaInvito as attivaInvito
			,@OwnerChat as OwnerChat
			,@ATTIVA_COMANDI_PDA_SEDUTA as ATTIVA_COMANDI_PDA_SEDUTA
			,@PUNTEGGI_ORIGINALI as PUNTEGGI_ORIGINALI
			,@DatiInChiaro as DATI_IN_CHIARO
			, dbo.CAN_CREATE_COMUNICAZIONI(@idUser , @COM_ID, 'BASE') as CAN_CREATE_COMUNICAZIONI
			, dbo.CAN_CREATE_COMUNICAZIONI(@idUser , @COM_ID, 'OFFERTA') as CAN_CREATE_COM_INTEGRATIVA_TEC
			,case
				when @FaseConcorso = 'prima' then 1
				else 0
			 end as PDA_CONCORSO_PRIMO_GIRO
			--	into temp_controllo
			from 
				#INFO_MOD_PDA



end

GO
