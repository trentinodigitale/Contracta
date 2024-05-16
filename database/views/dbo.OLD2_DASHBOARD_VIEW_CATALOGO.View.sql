USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_DASHBOARD_VIEW_CATALOGO]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE  VIEW [dbo].[OLD2_DASHBOARD_VIEW_CATALOGO]
AS
--Versione=2&data=2012-06-26&Attvita=38848&Nominativo=Sabato
--Versione=3&data=2014-10-21&Attvita=64472&Nominativo=Enrico
--Versione=4&data=2015-03-12&Attvita=68663&Nominativo=Sabato

--ARTICOLI DELLE CONVENZIONI CON QUOTE LE VEDONO GLI UTENTI DEGLI ENTI CON LE QUOTE
--EP ATT. 480390: SE SONO DEFINITE LE STRUTTURE ABILITATE SUGLI ENTI
--LE VEDONO GLI UTENTI CHE HANNO LA STRUTTURA DI APPARTENENZA COMPRESA NELLE STRUTTURE ABILITATE
--E GLI UTENTI DELL'ENTE CHE NON HANNO UNA STRUTTURA DI APPARTENZA DEFINITA
SELECT 
	 PU.Idpfu  
     , pr.id as idRow
     , pr.idHeader
     , pr.Codice_Regionale as Codice
     , 
		case 
			when TipoAcquisto= 'importo' and Reset_Prezzo ='YES' then 0
			else pr.ValoreEconomico
		end as PrezzoUnitario

	 --   pr.ValoreEconomico as PrezzoUnitario
     , pr.AliquotaIva --as IVA
     , pr.DESCRIZIONE_CODICE_REGIONALE as Descrizione
     , CAST(pr.id AS VARCHAR)                        AS ID_RIGA 
     , DC.id                                             AS Convenzione
     ,'1' as QTDisp
     , DC.IdentificativoIniziativa
	 , PR.ValoreAccessorioTecnico
	 --, CASE TipoConvenzione
	 , CASE TipoAcquisto	
			WHEN 'quantita' then
				case ConAccessori
					when 'si' then ' PrezzoUnitario ' 
					else ' PrezzoUnitario  ValoreAccessorioTecnico '
				end
			ELSE
				case ConAccessori
					when 'si' then ' QTDisp '
					else ' QTDisp  ValoreAccessorioTecnico '
				end
		END   as Not_Editable
	, dc.TipoImporto
	,DC.Macro_Convenzione as Macro_Convenzione_Filtro

	,l.idRow as Lotto
	, Dc.NumOrd
	, PR.unitadimisura
	, AZI_Dest
	, pr.NumeroLotto
	, C1.Titolo
	,CQL.NumeroLotto as NumeroLottoQ
	, isnull(all_field,'') as all_field

  FROM 
	CTL_DOC C1 with(nolock)
	INNER JOIN Document_Convenzione DC  with(nolock) ON C1.id=DC.id
	INNER JOIN Document_Microlotti_Dettagli PR  with(nolock) ON DC.id = PR.idHeader and C1.TipoDoc=pr.TipoDoc
	inner join Document_Convenzione_Lotti l  with(nolock) on l.idheader = c1.id and l.NumeroLotto = pr.NumeroLotto
	INNER JOIN ProfiliUtente PU  with(nolock) on PU.pfuvenditore=0 --on PU.idpfu=C1.Idpfu
	INNER JOIN aziende with(nolock) on idazi=PU.pfuidazi 
	--INNER JOIN ProfiliUtente PU1 on PU1.pfuidazi=PU.pfuidazi 
	--VERIFICA SE HA LA QUOTA
	INNER JOIN Document_Convenzione_Quote_Importo CQ with(nolock) on CQ.idHeader = C1.id and CQ.Azienda = PU.pfuidazi
	--SE LA TIENE PER LOTTO
	LEFT JOIN Document_Convenzione_Quote_Importo_Lotto CQL  with(nolock) on CQL.idHeader = C1.id and CQL.Azienda = PU.pfuidazi and CQL.NumeroLotto=l.NumeroLotto
	cross join (select dbo.PARAMETRI('DASHBOARD_VIEW_CATALOGO','PrezzoUnitario','Reset','YES',-1) as Reset_Prezzo ) as RP
	
	--VADO A VEDERE SE SULL'ENTE SONO STATE DEFINITE LE STRUTTURE ABILITATE
	left join Document_Convenzione_Plant P with (nolock) on c1.id = p.idHeader and p.AZI_Ente = PU.pfuidazi 
	
	--VEDO SE L'UTENTE HA UNA STRUTTURA DI APPARTENZA TRA QUESTE OPPURE SE NON LA TIENE PROPRIO
	left join ProfiliUtenteAttrib PU_S with (nolock) on	PU_S.IdPfu = PU.IdPfu and PU_S.dztNome ='Plant'
														
	
 WHERE 
	C1.TipoDoc='CONVENZIONE'
	AND DC.StatoConvenzione = 'Pubblicato'
	AND DC.Deleted = 0 
	AND CONVERT(VARCHAR(10), DC.DataInizio, 121) <= CONVERT(VARCHAR(10), GETDATE(), 121)
	AND CONVERT(VARCHAR(10), GETDATE(), 121) <= CONVERT(VARCHAR(10), DC.DataFine, 121)
	AND PU.pfudeleted=0
	AND DC.GestioneQuote<>'senzaquote'
	AND PR.statoriga in ('','saved','inserito','variato')
	AND ISNULL(C1.JumpCheck,'') <> 'INTEGRAZIONE'
	AND 
		(
			--non ci sono strutture abilitate definite sull'ente
			isnull(P.Plant,'') = '' 		
			
			--oppure la struttura di appartenenza dell'utente è tra le strutture abilitate dell'ente
			or
			( charindex(PU_S.attValue , P.Plant) > 0  and isnull(P.Plant,'') <> '' and isnull(PU_S.attValue ,'') <> '')
			
			--oppure l'utente non ha una struttura di appartenenza definita
			or	
			--(select count(*) from ProfiliUtenteAttrib with (nolock) where idpfu = PU.IdPfu and PU_S.dztNome ='Plant' and attvalue <>'')=0
			PU_S.IdUsAttr is null or isnull(PU_S.attValue ,'')=''
		)

union all

--ARTICOLI DELLE CONVENZIONI SENZA QUOTE CON LISTA ENTI VUOTA LE VEDONO TUTTI GLI UTENTI DEGLI ENTI
SELECT 
	 PU.Idpfu  
     , pr.id as idRow
     , pr.idHeader
     , pr.Codice_Regionale as Codice
     --, pr.ValoreEconomico as PrezzoUnitario
	  , 
		case 
			when TipoAcquisto= 'importo' and Reset_Prezzo ='YES' then 0
			else pr.ValoreEconomico
		end as PrezzoUnitario

     , pr.AliquotaIva --as IVA
     , pr.DESCRIZIONE_CODICE_REGIONALE as Descrizione
     , CAST(pr.id AS VARCHAR)                        AS ID_RIGA 
     , DC.id                                             AS Convenzione
     ,'1' as QTDisp
     , DC.IdentificativoIniziativa
	 , PR.ValoreAccessorioTecnico
	 --, CASE TipoConvenzione
	 , CASE TipoAcquisto	
			WHEN 'quantita' then
				case ConAccessori
					when 'si' then ' PrezzoUnitario ' 
					else ' PrezzoUnitario  ValoreAccessorioTecnico '
				end
			ELSE
				case ConAccessori
					when 'si' then ' QTDisp '
					else ' QTDisp  ValoreAccessorioTecnico '
				end
		END   as Not_Editable
	  , dc.TipoImporto
	  ,DC.Macro_Convenzione as Macro_Convenzione_Filtro

 	  ,l.idRow as Lotto
	, Dc.NumOrd
	, PR.unitadimisura
	, AZI_Dest
	, pr.NumeroLotto
	, C1.Titolo
	, NULL as NumeroLottoQ
	, isnull(all_field,'') as all_field
  FROM 
	CTL_DOC C1 with(nolock)
	INNER JOIN Document_Convenzione DC with(nolock) ON C1.id=DC.id
	INNER JOIN Document_Microlotti_Dettagli PR with(nolock) ON DC.id = PR.idHeader and C1.TipoDoc=pr.TipoDoc
	inner join Document_Convenzione_Lotti l with(nolock) on l.idheader = c1.id and l.NumeroLotto = pr.NumeroLotto
	INNER JOIN ProfiliUtente PU with(nolock) on PU.pfuvenditore=0 --PU.idpfu=C1.Idpfu
	INNER JOIN aziende with(nolock) on idazi=PU.pfuidazi 
	LEFT OUTER JOIN
		  Document_Convenzione_Plant E with(nolock) on DC.ID=E.IdHeader and PU.pfuidazi=E.AZI_Ente 	
	cross join (select dbo.PARAMETRI('DASHBOARD_VIEW_CATALOGO','PrezzoUnitario','Reset','YES',-1) as Reset_Prezzo ) as RP

 WHERE 
	C1.TipoDoc='CONVENZIONE'
	AND DC.StatoConvenzione = 'Pubblicato'
	AND DC.Deleted = 0 
	AND CONVERT(VARCHAR(10), DC.DataInizio, 121) <= CONVERT(VARCHAR(10), GETDATE(), 121)
	AND CONVERT(VARCHAR(10), GETDATE(), 121) <= CONVERT(VARCHAR(10), DC.DataFine, 121)
	AND PU.pfudeleted=0
	AND DC.GestioneQuote='senzaquote'
	AND (select count(*) from Document_Convenzione_Plant with (nolock) where DC.ID=IdHeader)=0
	AND PR.statoriga in ('','saved','inserito','variato')
	AND ISNULL(C1.JumpCheck,'') <> 'INTEGRAZIONE'
	
union all

--ARTICOLI DELLE CONVENZIONI SENZA QUOTE CON LISTA ENTI PIENA LE VEDONO GLI UTENTI DEGLI ENTI NELLA LISTA
--EP ATT. 480390: SE SONO DEFINITE LE STRUTTURE ABILITATE SUGLI ENTI
--LE VEDONO GLI UTENTI CHE HANNO LA STRUTTURA DI APPARTENENZA COMPRESA NELLE STRUTTURE ABILITATE
--E GLI UTENTI DELL'ENTE CHE NON HANNO UNA STRUTTURA DI APPARTENZA DEFINITA
SELECT 
	 PU.Idpfu  
	 , pr.id as idRow
     , pr.idHeader
     , pr.Codice_Regionale as Codice
     --, pr.ValoreEconomico as PrezzoUnitario
	 , 
		case 
			when TipoAcquisto= 'importo' and Reset_Prezzo ='YES' then 0
			else pr.ValoreEconomico
		end as PrezzoUnitario

     , pr.AliquotaIva --as IVA
     , pr.DESCRIZIONE_CODICE_REGIONALE as Descrizione
     , CAST(pr.id AS VARCHAR)                        AS ID_RIGA 
     , DC.id                                             AS Convenzione
     ,'1' as QTDisp
     , DC.IdentificativoIniziativa
	 , PR.ValoreAccessorioTecnico
	 --, CASE TipoConvenzione
	 , CASE TipoAcquisto	
			WHEN 'quantita' then
				case ConAccessori
					when 'si' then ' PrezzoUnitario ' 
					else ' PrezzoUnitario  ValoreAccessorioTecnico '
				end
			ELSE
				case ConAccessori
					when 'si' then ' QTDisp '
					else ' QTDisp  ValoreAccessorioTecnico '
				end
		END   as Not_Editable
	 , dc.TipoImporto
	 ,DC.Macro_Convenzione as Macro_Convenzione_Filtro
	 ,l.idRow as Lotto
	, Dc.NumOrd
	, PR.unitadimisura
	, AZI_Dest
	, pr.NumeroLotto
	, C1.Titolo
	, NULL as NumeroLottoQ
	, isnull(all_field,'') as all_field
  FROM 
	CTL_DOC C1 with(nolock)
	INNER JOIN Document_Convenzione DC with(nolock) ON C1.id=DC.id
	INNER JOIN Document_Microlotti_Dettagli PR with(nolock) ON DC.id = PR.idHeader and C1.TipoDoc=pr.TipoDoc
	inner join Document_Convenzione_Lotti l with(nolock) on l.idheader = c1.id and l.NumeroLotto = pr.NumeroLotto
	INNER JOIN ProfiliUtente PU with(nolock) on PU.pfuvenditore=0 --PU --PU.idpfu=C1.Idpfu 
	INNER JOIN aziende with(nolock) on idazi=PU.pfuidazi 
	INNER JOIN
		  Document_Convenzione_Plant E with(nolock) on DC.ID=E.IdHeader and PU.pfuidazi=E.AZI_Ente 	
	cross join (select dbo.PARAMETRI('DASHBOARD_VIEW_CATALOGO','PrezzoUnitario','Reset','YES',-1) as Reset_Prezzo ) as RP
	
	--VEDO SE L'UTENTE HA UNA STRUTTURA DI APPARTENZA TRA QUESTE OPPURE SE NON LA TIENE PROPRIO
	left join ProfiliUtenteAttrib PU_S with (nolock) on	PU_S.IdPfu = PU.IdPfu and PU_S.dztNome ='Plant'

 WHERE 
	C1.TipoDoc='CONVENZIONE'
	AND DC.StatoConvenzione = 'Pubblicato'
	AND DC.Deleted = 0 
	AND CONVERT(VARCHAR(10), DC.DataInizio, 121) <= CONVERT(VARCHAR(10), GETDATE(), 121)
	AND CONVERT(VARCHAR(10), GETDATE(), 121) <= CONVERT(VARCHAR(10), DC.DataFine, 121)
	AND PU.pfudeleted=0
	AND DC.GestioneQuote='senzaquote'
	AND PR.statoriga in ('','saved','inserito','variato')
	AND ISNULL(C1.JumpCheck,'') <> 'INTEGRAZIONE'
	AND 
		(
			--non ci sono strutture abilitate definite sull'ente
			isnull(E.Plant,'') = '' 		
			
					
			
			--oppure la struttura di appartenenza dell'utente è tra le strutture abilitate dell'ente
			or
			( charindex(PU_S.attValue , E.Plant) > 0  and isnull(E.Plant,'') <> '' and isnull(PU_S.attValue ,'') <> '')
			
			--oppure l'utente non ha una struttura di appartenenza definita
			or	
			--(select count(*) from ProfiliUtenteAttrib with (nolock) where idpfu = PU.IdPfu and PU_S.dztNome ='Plant' and attvalue <>'')=0
			PU_S.IdUsAttr is null or isnull(PU_S.attValue ,'')=''

		)








GO
