USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DASHBOARD_VIEW_LISTINI_CONVENZIONI]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[OLD_DASHBOARD_VIEW_LISTINI_CONVENZIONI] as 

    SELECT 
              pr.id as idRow
             , pr.idHeader
             , pr.Codice_Regionale as Codice
             , pr.ValoreEconomico as PrezzoUnitario
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
            , dc.NumOrd as  numeroConvenzioneCompleta
            , isnull(C1.protocollogenerale,'') as rspic
            ,DC.Macro_Convenzione
            , azi.aziRagioneSociale as ragioneSociale
            , dm1.vatValore_FT as codiceFiscale
            ,DC.DataInizio
            ,DC.DataFine
            ,PR.StatoRiga
            , PR.idHeaderLotto
            , VD.DataDecorrenza
			, C1.IdPfu
        FROM 
            CTL_DOC C1 with(nolock)
				INNER JOIN Document_Convenzione DC with(nolock) ON C1.id=DC.id
				left join aziende azi with(nolock) on azi.idazi = dc.Mandataria and azi.aziDeleted = 0
				left join DM_Attributi dm1 with(nolock) on dm1.lnk = azi.idazi and dm1.dztNome = 'codicefiscale'
				INNER JOIN Document_Microlotti_Dettagli PR with(nolock) ON DC.id = PR.idHeader and C1.TipoDoc=pr.TipoDoc
				inner join Document_Convenzione_Lotti l with(nolock) on l.idheader = c1.id and l.NumeroLotto = pr.NumeroLotto
            
				--recupera la data decorrenza della variazione prezzo
				left join (
                    select p.idheaderlotto , cast ( MAX( v.Value  ) as varchar(100)) as DataDecorrenza
                        from CTL_DOC d with(nolock) 
                            inner join Document_PRZ_PRODOTTI_Dettagli p with(nolock) on p.IdHeader = d.id 
                            inner join CTL_DOC_Value v with(nolock) on v.IdHeader = d.id and v.DSE_ID = 'MOTIVAZIONE' and v.DZT_Name = 'DataDecorrenza'
                        where d.TipoDoc = 'CONVENZIONE_PRZ_PRODOTTI' and StatoFunzionale = 'Inviato'
                            --and  convert( DATETIME , v.Value  , 121 ) <= GETDATE() 
                            and v.Value   <= GETDATE() -- solo se la data decorrenza Ã¨ stata superata
                            and p.PREZZO_OFFERTO_PER_UM_CORRENTE <> p.PREZZO_OFFERTO_PER_UM_VARIATO --prendo solo le righe dove il prezzo Ã¨ variato
                        group by p.idheaderlotto  
                ) as VD on VD.idHeaderLotto = PR.id

        WHERE 
            C1.TipoDoc='CONVENZIONE'
            AND C1.StatoFunzionale <> 'InLavorazione'
            AND DC.Deleted = 0 
            --AND CONVERT(VARCHAR(10), DC.DataInizio, 121) <= CONVERT(VARCHAR(10), GETDATE(), 121)
            --AND CONVERT(VARCHAR(10), GETDATE(), 121) <= CONVERT(VARCHAR(10), DC.DataFine, 121)

            --AND PR.statoriga in ('','saved','inserito','variato')
            AND ISNULL(C1.JumpCheck,'') <> 'INTEGRAZIONE'

            --and PR.StatoRiga = 'Variato'
            --and PR.IdHeader = 196865

GO
