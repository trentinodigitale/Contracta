USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DASHBOARD_VIEW_ODC_RIGHE_ALL]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[OLD_DASHBOARD_VIEW_ODC_RIGHE_ALL]
AS
SELECT 
		c1.*,
		TotalIva - RDA_Total AS ValoreIva,
		cast(Id_Convenzione AS varchar(100)) AS Convenzione,
		case fuoripiattaforma 
			when 'si' then 'ODC_FUORIPIATTAFORMA'
		else 'ODC'
		end AS OPEN_DOC_NAME,
		rda_stato, 
		fuoripiattaforma,
		RDA_DataCreazione,
		RDA_ID,
		aziRagioneSociale,
		round (RDA_Total, 2) AS RDA_Total,
		cast ( IdAziDest  AS varchar(100))   AS Azi_Dest,
		convert( varchar(10) , RDA_DataCreazione , 121 ) AS DataA,
		convert( varchar(10) , RDA_DataCreazione , 121 ) AS DataI,
		SUBSTRING ( dmv_father ,1 , charindex('-',dmv_father)-1 ) AS PrimoLivelloStruttura,
		d1.vatValore_FT  AS TIPO_AMM_ER,
		o.UserRup,
		aziprovinciaLeg,
		aziprovinciaLeg2 AS aziprovinciaLeg3,
		rda_object,
		c1.protocollo AS NumeroOrdinativo,
		OI.protocollo AS ProtocolloOrdinativoIntegrato,
		F.dataapposizionefirma,
		--,F.dataapposizionefirma AS dataapposizionefirmaDal
		convert( varchar(10) , F.dataapposizionefirma , 121 ) AS dataapposizionefirmaDal,
		--,F.dataapposizionefirma AS dataapposizionefirmaAl
		convert( varchar(10) , F.dataapposizionefirma , 121 ) AS dataapposizionefirmaAl,
		D.CODICE_ARTICOLO_FORNITORE,
		D.DENOMINAZIONE_ARTICOLO_FORNITORE,
		D.AREA_MERCEOLOGICA,
		D.UM_QUANTITA_PRODOTTO_SINGOLO_PEZZO,
		D.qty,
		D.valoreeconomico,
		D.valoreaccessoriotecnico,
		D.Qty*D.ValoreEconomico AS totaleordinato,
		D.AliquotaIva,
		con.Macro_Convenzione,
		d.CODICE_REGIONALE,
		d.DESCRIZIONE_CODICE_REGIONALE,
		numeroriga,
		d.NumeroLotto,
		convert( varchar(10) , c1.DataInvio , 121 ) AS DataInvioAl,
		convert( varchar(10) , c1.DataInvio , 121 ) AS DataInvioDal,
		cast(IdAzi     AS varchar(100)) AS azi_ente,
		--, idazi AS azi_ente,
		c1.statofunzionale AS StatoDoc1,
		D.UnitadiMisura,
		con.IdentificativoIniziativa,
		con.Ambito,
		u.IdPfu AS Owner_Idpfu,
		o.CIG,
		NumeroConvenzione,
		CodiceATC,
		PrincipioAttivo

	FROM  ctl_doc C1                                        WITH (NOLOCK) 	
			--INNER JOIN Document_ODC O                     WITH (NOLOCK, INDEX (ix_01)) on O.rda_id=C1.id 
			INNER JOIN	Document_ODC O                      WITH (NOLOCK)  ON O.rda_id=C1.id 
			INNER JOIN document_microlotti_dettagli D       WITH (NOLOCK)  ON D.idheader=C1.id and D.TipoDoc='ODC'
			--INNER JOIN ProfiliUtente P                    WITH (NOLOCK)  ON O.RDA_Owner = CAST(P.IdPfu AS VARCHAR)
			INNER JOIN ProfiliUtente P                      WITH (NOLOCK)  ON c1.idpfu = P.IdPfu
			INNER JOIN aziende AZ                           WITH (NOLOCK)  ON AZ.idazi=p.pfuidazi	
			LEFT  OUTER JOIN dbo.DM_Attributi d1            WITH (NOLOCK)  ON d1.dztNome = 'TIPO_AMM_ER' and d1.idApp = 1 and d1.lnk = AZ.idazi
			LEFT  OUTER JOIN LIB_DomainValues               WITH (NOLOCK)  ON dmv_dm_id='TIPO_AMM_ER' and dmv_cod=d1.vatValore_FT
			LEFT  OUTER JOIN ctl_doc OI                     WITH (NOLOCK)  ON OI.id=iddocIntegrato
			LEFT  OUTER JOIN (select 
							          att_hash ,min(dataapposizionefirma) AS  dataapposizionefirma
							      from CTL_SIGN_ATTACH_INFO WITH (NOLOCK) 
							      where isnull(att_hash,'')<>'' 
								  group by att_hash ) F 
																		   ON F.att_hash=dbo.getPos(c1.sign_attach,'*','4')		
			INNER JOIN document_convenzione con             WITH (NOLOCK)  ON con.id = Id_Convenzione
			LEFT  OUTER JOIN ProfiliUtente PO               WITH (NOLOCK)  ON PO.IdPfu = o.UserRUP 
			INNER JOIN CTL_DOC Convenzione                  WITH (NOLOCK)  ON Convenzione.Id=con.id
			INNER JOIN ProfiliUtente compilatore            WITH (NOLOCK)  ON compilatore.idpfu = Convenzione.idpfu
			INNER JOIN ProfiliUtente u                      WITH (NOLOCK)  ON u.pfuidazi = compilatore.pfuidazi
	WHERE 
		C1.Tipodoc = 'ODC' 
		and c1.Deleted = 0
		--( O.RDA_Deleted = ' ' or O.RDA_Deleted = '0')
		--and isnull(c1.sign_attach,'')<>''
		--and c1.statofunzionale not in ( 'InLavorazione' , 'NotApproved' , 'InApprove' )
GO
