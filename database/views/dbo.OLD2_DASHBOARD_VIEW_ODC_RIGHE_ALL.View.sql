USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_DASHBOARD_VIEW_ODC_RIGHE_ALL]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[OLD2_DASHBOARD_VIEW_ODC_RIGHE_ALL]
AS
SELECT c1.* 
     , TotalIva - RDA_Total                     AS ValoreIva 
     , cast(Id_Convenzione     as varchar(100))                       AS Convenzione
	 , case fuoripiattaforma 
		when 'si' then 'ODC_FUORIPIATTAFORMA'
		else 'ODC'
		end  as OPEN_DOC_NAME
	 , rda_stato 
	 , fuoripiattaforma
	 , RDA_DataCreazione
	 , RDA_ID
	 , aziRagioneSociale
	 , round (RDA_Total, 2) as RDA_Total
	 , cast ( IdAziDest  as varchar(100))   as Azi_Dest
	 , convert( varchar(10) , RDA_DataCreazione , 121 ) as DataA
	 , convert( varchar(10) , RDA_DataCreazione , 121 ) as DataI
	 , SUBSTRING ( dmv_father ,1 , charindex('-',dmv_father)-1 ) as PrimoLivelloStruttura
	 , d1.vatValore_FT  as TIPO_AMM_ER
	 ,o.UserRup
	 ,aziprovinciaLeg
	 ,aziprovinciaLeg2 as aziprovinciaLeg3
	 ,rda_object
	 ,c1.protocollo as NumeroOrdinativo
	 ,OI.protocollo as ProtocolloOrdinativoIntegrato
	 ,F.dataapposizionefirma
	 --,F.dataapposizionefirma as dataapposizionefirmaDal
	 , convert( varchar(10) , F.dataapposizionefirma , 121 ) as dataapposizionefirmaDal
	 --,F.dataapposizionefirma as dataapposizionefirmaAl
	 , convert( varchar(10) , F.dataapposizionefirma , 121 ) as dataapposizionefirmaAl
	 ,D.CODICE_ARTICOLO_FORNITORE
	 ,D.DENOMINAZIONE_ARTICOLO_FORNITORE
	 ,D.AREA_MERCEOLOGICA
	 ,D.UM_QUANTITA_PRODOTTO_SINGOLO_PEZZO
	 ,D.qty
	 ,D.valoreeconomico
	 ,D.valoreaccessoriotecnico
	 , D.Qty*D.ValoreEconomico as totaleordinato
	 ,D.AliquotaIva
	 ,con.Macro_Convenzione
	 , d.CODICE_REGIONALE
	 , d.DESCRIZIONE_CODICE_REGIONALE
	 , numeroriga
	 , d.NumeroLotto

	 , convert( varchar(10) , c1.DataInvio , 121 ) as DataInvioAl
	  ,convert( varchar(10) , c1.DataInvio , 121 ) as DataInvioDal

	  , cast(IdAzi     as varchar(100))                       AS azi_ente
	  --, idazi as azi_ente

	  , c1.statofunzionale as StatoDoc1
	  , D.UnitadiMisura
	  ,con.IdentificativoIniziativa
	  ,con.Ambito
	  ,u.IdPfu as Owner_Idpfu 
FROM  ctl_doc C1 with(nolock) 
	
	--inner join	Document_ODC O WITH (NOLOCK, INDEX (ix_01)) on O.rda_id=C1.id 
	inner join	Document_ODC O WITH (NOLOCK) on O.rda_id=C1.id 
	inner join document_microlotti_dettagli D with(nolock) on D.idheader=C1.id and D.TipoDoc='ODC'
	--INNER JOIN ProfiliUtente P with(nolock) ON O.RDA_Owner = CAST(P.IdPfu AS VARCHAR)
	INNER JOIN ProfiliUtente P with(nolock) ON c1.idpfu = P.IdPfu
	inner join aziende AZ with(nolock) on AZ.idazi=p.pfuidazi	
	left outer join dbo.DM_Attributi d1 with(nolock) on d1.dztNome = 'TIPO_AMM_ER' and d1.idApp = 1 and d1.lnk = AZ.idazi
	left outer join LIB_DomainValues with(nolock) on dmv_dm_id='TIPO_AMM_ER' and dmv_cod=d1.vatValore_FT
	left outer join ctl_doc OI with(nolock) on OI.id=iddocIntegrato

	left outer join ( 	select att_hash ,min(dataapposizionefirma) as  dataapposizionefirma
							from CTL_SIGN_ATTACH_INFO with(nolock) where isnull(att_hash,'')<>'' group by att_hash ) F 
								on F.att_hash=dbo.getPos(c1.sign_attach,'*','4')
				


	inner join document_convenzione con  with(nolock) on con.id = Id_Convenzione

	left outer join ProfiliUtente PO  with(nolock) ON PO.IdPfu = o.UserRUP 
	inner join CTL_DOC Convenzione with(nolock) on Convenzione.Id=con.id
	inner join ProfiliUtente compilatore with(nolock) on compilatore.idpfu = Convenzione.idpfu
	inner join ProfiliUtente u with(nolock) on u.pfuidazi = compilatore.pfuidazi
WHERE 
	C1.Tipodoc = 'ODC' 
	and c1.Deleted = 0
	--( O.RDA_Deleted = ' ' or O.RDA_Deleted = '0')
	--and isnull(c1.sign_attach,'')<>''
	--and c1.statofunzionale not in ( 'InLavorazione' , 'NotApproved' , 'InApprove' )
GO
