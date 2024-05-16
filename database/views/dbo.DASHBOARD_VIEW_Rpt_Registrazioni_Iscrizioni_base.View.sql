USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_Rpt_Registrazioni_Iscrizioni_base]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE  view [dbo].[DASHBOARD_VIEW_Rpt_Registrazioni_Iscrizioni_base]
as

SELECT TipoUtente , PeriodoReg , SUM ( qTA ) AS Qta 
from 
(
		-- 16ott.2012 query di tutti gli enti
		select 
			aziRagioneSociale,
			'-----' as pfuNome,
			case 
				when Year(aziDataCreazione) <= '2010' then '2010'
				else Year(aziDataCreazione)
			end	
			as AnnoReg, 
			case 
				when Year(aziDataCreazione) <= '2010' then '12'
				else Month(aziDataCreazione)
			end	
			as MeseReg, 
		'''' + convert( varchar(7) , 
						(case when Year(aziDataCreazione) <= '2010'
								then '2010-12-01' else 
								aziDataCreazione
							end),
					20 ) as PeriodoReg,
			 'Unità Organizzative Enti Aderenti' as TipoUtente,	
			1 as Iscrizione,
			1 as Qta
			from aziende with(nolock)
		WHERE   aziVenditore	<> 2		--- solo enti 
	union
		select aziRagioneSociale, 
			pfuNome,
			case 
				when Year(aziDataCreazione) <= '2010' then '2010'
				else Year(aziDataCreazione)
			end	
			as AnnoReg, 
			case 
				when Year(aziDataCreazione) <= '2010' then '12'
				else Month(aziDataCreazione)
			end	
			as MeseReg, 
		'''' + convert( varchar(7) , 
						(case when Year(aziDataCreazione) <= '2010'
								then '2010-12-01' else 
								aziDataCreazione
							end),
					20 ) as PeriodoReg,
			Case (aziVenditore) 
				when 2 then 'Fornitori iscritti al Portale'
				else 'Buyer'
			end
			as TipoUtente,	
			cast( isnull( d2.vatValore_FT , '0' ) as int ) as Iscrizione,
			1 as Qta
			from aziende with(nolock)
			left outer join dm_attributi d2 on d2.lnk = idazi and d2.dztnome = 'CARBelongTo'
			left outer join dm_attributi d3 on d3.lnk = idazi and d3.dztnome = 'sysHabilitStartDate'
			left outer join ProfiliUtente ON IdAzi = pfuIdAzi and aziAcquirente <> 0 and pfuDeleted = 0 ---- utenti buyer registrati
		union
		select aziRagioneSociale, 
			NULL as pfuNome,
			case 
				when cast(Year(d3.vatValore_FT) as char(4)) <= '2010' then '2010'
				else cast(Year(d3.vatValore_FT) as char(4))
			end	
			as AnnoReg, 
			case 
				when cast(Year(d3.vatValore_FT) as char(4)) <= '2010' then '12'
				else cast(Month(d3.vatValore_FT) as char(2))
			end	
			as MeseReg, 
			'''' + convert( varchar(7) , 
						(case when cast(Year(d3.vatValore_FT) as char(4)) <= '2010'
								then '2010-12-01' else 
								cast(d3.vatValore_FT as datetime)
							end),
					20 ) as PeriodoReg,
			Case (aziVenditore) 
				when 2 then 'Fornitori iscritti in Albo'
				else 'Buyer-iscritti'
			end
			as TipoUtente,	
			1 as Iscrizione,
			cast( isnull( d2.vatValore_FT , '0' ) as int ) as Qta
			from aziende with(nolock)
			join dm_attributi d2 on d2.lnk = idazi and d2.dztnome = 'CARBelongTo'
			join dm_attributi d3 on d3.lnk = idazi and d3.dztnome = 'sysHabilitStartDate'
			where aziVenditore	= 2		---solo fornitori-iscritti	
	union 
		select '-----' as aziRagioneSociale, 
			'-----' as pfuNome,
			cast(Year(getdate()) as char(4)) as AnnoReg, 
			cast(Month(getdate()) as char(2)) as MeseReg, 
			D.PeriodoReg,
			D.TipoUtente,
			0 as Iscrizione,
			D.Qta 
		from .DASHBOARD_VIEW_Rpt_Registrazioni_Iscrizioni_dummy as D

) as a

group by TipoUtente , PeriodoReg





GO
