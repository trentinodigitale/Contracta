USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DASHBOARD_VIEW_TEMPLATE_DI_GARA]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[OLD_DASHBOARD_VIEW_TEMPLATE_DI_GARA]
AS
  SELECT Cd.Id
         , PA.IdPfu AS Idpfu
         , Cd.Protocollo
         , Cd.DataInvio
         , Cd.StatoFunzionale
         , Db.TipoAppaltoGara
         , Db.ProceduraGara
         , Db.TipoBandoGara
         , Db.Divisione_lotti
         , Db.CriterioAggiudicazioneGara
         , Db.CriterioFormulazioneOfferte
         , Db.Conformita
         --, Cdv1.[Value] AS DescrizioneEstesa
         , CASE WHEN N.id IS NULL THEN Cdv1.[Value] ELSE '<b>( In Modifica )</b> ' + dbo.HTML_Encode(Cdv1.[Value]) END AS DescrizioneEstesa
         , Cdv2.[Value] AS Versione
         , Cdv3.[Value] AS Note
         , dbo.GetDescTipoProcedura(Cd.Tipodoc, Db.TipoProceduraCaratteristica, Db.ProceduraGara, Db.TipoBandoGara) AS DescTipoProcedura -- GetDescTipoProcedura è una FUNCTION
         , ISNULL(Db.TipoProceduraCaratteristica,'') AS TipoProceduraCaratteristica
         , ISNULL(Db.TipoSceltaContraente,'') AS TipoSceltaContraente
		     , Cd.IdPfu AS [Owner]
         , Cd.TipoDoc AS OPEN_DOC_NAME
         , Cd.[Data]
		     , AC.aziRagioneSociale
  FROM CTL_DOC Cd WITH(NOLOCK)
			
			INNER JOIN ProfiliUtente compilatore  WITH(NOLOCK) ON  compilatore.idpfu = cd.idpfu
			inner join Aziende AC WITH(NOLOCK) ON compilatore.pfuIdAzi = AC.idazi
			--INNER JOIN
			--		 ProfiliUtente PA WITH(NOLOCK) ON  SUBSTRING(PA.pfuFunzionalita,543,1)=1 
			cross JOIN ProfiliUtente PA WITH(NOLOCK) 
				--	ProfiliUtenteAttrib PA with (nolock) on PA.dztNome  = 'Profilo' and PA.attValue  = 'GestoreTemplateGara'
					

			--left join
			--		ProfiliUtenteAttrib PA1 with (nolock) on PA.dztNome  = 'Profilo' and PA.attValue  = 'ConsultazioneTemplateGara'
			INNER JOIN Document_Bando Db WITH (NOLOCK) ON Cd.Id = Db.IdHeader
			INNER JOIN CTL_DOC_Value Cdv1 WITH (NOLOCK) ON Cd.Id = Cdv1.IdHeader
															                    AND Cdv1.DSE_ID = 'INFO_TEMPLATE'
															                    AND Cdv1.DZT_Name = 'DescrizioneEstesa'
			INNER JOIN CTL_DOC_Value Cdv2 WITH (NOLOCK) ON Cd.Id = Cdv2.IdHeader
															                    AND Cdv2.DSE_ID = 'INFO_TEMPLATE'
															                    AND Cdv2.DZT_Name = 'Versione'
			LEFT JOIN CTL_DOC_Value Cdv3 WITH (NOLOCK) ON Cd.Id = Cdv3.IdHeader
															                   AND Cdv3.DSE_ID = 'INFO_TEMPLATE'
															                   AND Cdv3.DZT_Name = 'Note'
			LEFT JOIN CTL_DOC N WITH (NOLOCK) ON N.tipodoc = Cd.TipoDoc
                                        AND N.statofunzionale IN ( 'InLavorazione'  )
                                        AND N.PrevDoc = Cd.id
                                        AND N.deleted = 0
                                        AND ISNULL(n.LinkedDoc,0) = 0
			cross JOIN ( select top 1 MP.mpIdAziMaster  from MarketPlace MP WITH (NOLOCK) ) as mp

  WHERE 
		Cd.TipoDoc = 'TEMPLATE_GARA'
    AND Cd.Deleted = 0
		and
		(
			
			( 
				--vedo tutti i miei della stessa azienda se ho la gestione
				( SUBSTRING(PA.pfuFunzionalita,543,1)=1 and PA.pfuIdAzi =  compilatore.pfuIdAzi )
				
				or
				--di quelli publbicati vedo quelli della mia azienda
				--e quelli dell'azi master
				( Cd.StatoFunzionale ='Pubblicato' and  
					
					( 
						mp.mpIdAziMaster = compilatore.pfuIdAzi 
						or
						PA.pfuIdAzi =  compilatore.pfuIdAzi
					)
				)

			)
			
		)

GO
