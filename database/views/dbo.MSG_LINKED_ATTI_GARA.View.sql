USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MSG_LINKED_ATTI_GARA]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[MSG_LINKED_ATTI_GARA]
AS

SELECT     
		a.id AS id, a.Fascicolo, b.idpfu, 
		CASE WHEN DOC_NAME IS NULL THEN 1 ELSE 0 END AS bread, '187_188' AS tipo, 
        a.ProtocolloRiferimento AS ProtocolloBando, a.Protocollo, a.Titolo, a.linkeddoc, 'Ricevuto' AS StatoDoc, a.DataInvio AS Data, 
        CASE WHEN a.TipoDoc = 'INVIO_ATTI_GARA' THEN a.TipoDoc + '_IA' ELSE a.TipoDoc END AS OPEN_DOC_NAME
	
	FROM    ctl_doc AS a 
				INNER JOIN ctl_doc AS b ON a.linkeddoc = b.id AND b.tipodoc = 'RICHIESTA_ATTI_GARA' 
				LEFT OUTER JOIN CTL_DOC_READ r ON DOC_NAME = a.tipoDoc + '_IA' AND a.id = r.id_Doc AND b.idPfu = r.idPfu
	WHERE     a.tipodoc = 'INVIO_ATTI_GARA' AND a.statodoc <> 'saved'

UNION

SELECT     
		CTL_DOC.ID AS id, Fascicolo, CTL_DOC.idpfu AS idpfu, 
		CASE WHEN DOC_NAME IS NULL THEN 0 ELSE 0 END AS bread, '187_188' AS tipo, 
        ProtocolloRiferimento AS ProtocolloBando, Protocollo, Titolo, linkeddoc, StatoDoc, DataInvio AS Data, 
        CASE WHEN TipoDoc = 'INVIO_ATTI_GARA' THEN TipoDoc + '_IA' ELSE TipoDoc END AS OPEN_DOC_NAME

	FROM         
			ctl_doc LEFT OUTER JOIN
                      CTL_DOC_READ r ON DOC_NAME = tipoDoc AND ctl_doc.id = ctl_doc.Id AND CTL_DOC.idPfu = r.idPfu
--WHERE     tipoDoc IN ('RICHIESTA_ATTI_GARA', 'INVIO_ATTI_GARA') AND Deleted = 0 AND statodoc <> 'Sended'
WHERE     tipoDoc IN ('RICHIESTA_ATTI_GARA') AND Deleted = 0 --AND statodoc <> 'Sended'



GO
