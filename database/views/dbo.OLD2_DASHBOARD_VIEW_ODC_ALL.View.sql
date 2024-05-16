USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_DASHBOARD_VIEW_ODC_ALL]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [dbo].[OLD2_DASHBOARD_VIEW_ODC_ALL]
AS

SELECT 
	c1.* 

     , TotalIva - RDA_Total                     AS ValoreIva 
     , Id_Convenzione                           AS Convenzione
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
	 , IdAziDest as Azi_Dest
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
	 , convert( varchar(19) , F.dataapposizionefirma , 121 ) as dataapposizionefirmaDal
	 --,F.dataapposizionefirma as dataapposizionefirmaAl
	 , convert( varchar(10) , F.dataapposizionefirma , 121 ) as dataapposizionefirmaAl
	 ,RDA_DataScad
	 ,con.Macro_Convenzione
	 ,con.NumOrd

	 , convert( varchar(10) , c1.DataInvio , 121 ) as DataInvioAl
	  ,convert( varchar(10) , c1.DataInvio , 121 ) as DataInvioDal

	  , idazi as azi_ente
	  

	 ,case 
		when isnull(O.IdDocIntegrato,0) > 0 then 'si'
		else 'no'
	  end as Multiplo

	 , da.APS_Date
	 , isnull(Note.Value,'') as NoteContratto
	 , po.pfuNome 

	 --,	case	when c1.StatoDoc = 'Sended' then c1.StatoDoc 
		--	when rda_stato='Saved' then  rda_stato
		--	else c1.StatoDoc
		--end as StatoDoc1

		, c1.statofunzionale as StatoDoc1
		,O.CIG
		,con.ambito
		,con.CIG_MADRE
FROM  ctl_doc C1 with(nolock)
		inner join	Document_ODC O  with(nolock) on O.rda_id=C1.id 
		--INNER JOIN ProfiliUtente P  with(nolock) ON O.RDA_Owner = CAST(P.IdPfu AS VARCHAR)
		INNER JOIN ProfiliUtente P  with(nolock) ON P.IdPfu = C1.idpfu
		inner join aziende AZ  with(nolock) on AZ.idazi=p.pfuidazi	

		left outer join dbo.DM_Attributi d1  with(nolock) on d1.dztNome = 'TIPO_AMM_ER' and d1.idApp = 1 and d1.lnk = AZ.idazi
		left outer join LIB_DomainValues with(nolock) on  dmv_dm_id='TIPO_AMM_ER' and dmv_cod=d1.vatValore_FT
		left outer join ctl_doc OI  with(nolock) on OI.id=iddocIntegrato

		left outer join ( 	select att_hash ,min(dataapposizionefirma) as  dataapposizionefirma
								from CTL_SIGN_ATTACH_INFO  with(nolock) 
								where isnull(att_hash,'')<>'' group by att_hash ) F on F.att_hash=dbo.GetColumnValue(c1.sign_attach,'*','4')
								--where isnull(att_hash,'')<>'' group by att_hash ) F on F.att_hash=dbo.getPos(c1.sign_attach,'*','4')
				

		inner join document_convenzione con  with(nolock) on con.id = Id_Convenzione

		left outer join ( 	select APS_ID_DOC , APS_Date
								from CTL_ApprovalSteps  with(nolock) where APS_Doc_Type = 'ODC' and APS_State in ( 'Accettato','Rifiutato' )  and APS_IsOld=0 ) DA  on  DA.APS_ID_DOC = c1.id
	
		left outer join ctl_doc_value Note 	with(nolock) on Note.IdHeader=C1.id and dse_id='NOTECONTRATTO' and DZT_Name='NoteContratto' and Row=0

		left outer join ProfiliUtente PO  with(nolock) ON PO.IdPfu = o.UserRUP 

		

WHERE 
	--O.RDA_Deleted = ' ' or O.RDA_Deleted=0
	--c1.statofunzionale not in ( 'InLavorazione' , 'NotApproved' , 'InApprove' )
	--AND 
	C1.DELETED = 0 
	--and isnull(c1.sign_attach,'')<>''
	and C1.TipoDoc='ODC'



GO
