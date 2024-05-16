USE [AFLink_TND]
GO
/****** Object:  View [dbo].[Document_ESITO_PUBBESITO]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[Document_ESITO_PUBBESITO]
AS
select idrow as Row ,tipo,idrow,idheader,datapubblicazione,dbo.GetDescDominioFromDztNome('pubblicazioni','I',pubblicazioni) as vispubblicazioni,aziragionesociale as VisFornitore 
,
case 
	when StatoEsito = 'Liquidated'  then ' DataPubblicazione '
	else '' 
end
as NotEditable
from
document_esito,
document_esito_pubblicazioni left outer join aziende on fornitore = idazi
where  tipo = 'GURI/BURC' and id=idheader

 union all

select idrow as Row,tipo,idrow,idheader,datapubblicazione, dbo.GetDescDominioFromDztNome('pubblicazioni','I',pubblicazioni) as vispubblicazioni,dbo.GetDescDominioFromDztNome('comune','I',comunepub) as VisFornitore  
,
case 
	when StatoEsito = 'Liquidated'  then ' DataPubblicazione '
	else '' 
end
as NotEditable
from
document_esito_pubblicazioni,document_esito
where tipo = 'ALBI' and id=idheader

 union all

select idrow as Row,tipo,idrow,idheader,datapubblicazione,dbo.GetDescValueGerarchicoFromIdTid('Quotidiani','I',Quotidiani) as vispubblicazioni ,aziragionesociale as VisFornitore 
,
case 
	when StatoEsito = 'Liquidated'  then ' DataPubblicazione '
	else '' 
end
as NotEditable
from
document_esito,
document_esito_pubblicazioni left outer join aziende aziende on fornitore=idazi
where  tipo = 'QUOTIDIANI' and id=idheader


 union all

select idrow as Row,tipo,idrow,idheader,datapubblicazione,Quotidiani as vispubblicazioni ,aziragionesociale as VisFornitore 
,
case 
	when StatoEsito = 'Liquidated'  then ' DataPubblicazione '
	else '' 
end
as NotEditable
from
document_esito, 
document_esito_pubblicazioni left outer join aziende on  fornitore=idazi 
where tipo = 'SITI' and id=idheader



GO
