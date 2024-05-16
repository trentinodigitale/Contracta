USE [AFLink_TND]
GO
/****** Object:  View [dbo].[Province]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[Province]
AS
select '001' as id, 'AG' as Sigla, 'Agrigento' as Denominazione, '02' as Territorio
union
select '002' as id, 'AL' as Sigla, 'Alessandria' as Denominazione, '02' as Territorio
union
select '003' as id, 'AN' as Sigla, 'Ancona' as Denominazione, '02' as Territorio
union
select '004' as id, 'AO' as Sigla, 'Aosta' as Denominazione, '02' as Territorio
union
select '005' as id, 'AP' as Sigla, 'Ascoli Piceno' as Denominazione, '02' as Territorio
union
select '006' as id, 'AQ' as Sigla, 'Aquila' as Denominazione, '02' as Territorio
union
select '007' as id, 'AR' as Sigla, 'Arezzo' as Denominazione, '02' as Territorio
union
select '008' as id, 'AT' as Sigla, 'Asti' as Denominazione, '02' as Territorio
union
select '009' as id, 'AV' as Sigla, 'Avellino' as Denominazione, '02' as Territorio
union
select '010' as id, 'BA' as Sigla, 'Bari' as Denominazione, '01' as Territorio
union
select '011' as id, 'BG' as Sigla, 'Bergamo' as Denominazione, '02' as Territorio
union
select '012' as id, 'BI' as Sigla, 'Biella' as Denominazione, '02' as Territorio
union
select '013' as id, 'BL' as Sigla, 'Belluno' as Denominazione, '02' as Territorio
union
select '014' as id, 'BN' as Sigla, 'Benevento' as Denominazione, '02' as Territorio
union
select '015' as id, 'BO' as Sigla, 'Bologna' as Denominazione, '02' as Territorio
union
select '016' as id, 'BR' as Sigla, 'Brindisi' as Denominazione, '01' as Territorio
union
select '017' as id, 'BS' as Sigla, 'Brescia' as Denominazione, '02' as Territorio
union
select '018' as id, 'BT' as Sigla, 'Barletta-Andria-Trani' as Denominazione, '01' as Territorio
union
select '018' as id, 'BT' as Sigla, 'BAT' as Denominazione, '01' as Territorio
union
select '019' as id, 'BZ' as Sigla, 'Bolzano' as Denominazione, '02' as Territorio
union
select '020' as id, 'CA' as Sigla, 'Cagliari' as Denominazione, '02' as Territorio
union
select '021' as id, 'CB' as Sigla, 'Campobasso' as Denominazione, '02' as Territorio
union
select '022' as id, 'CE' as Sigla, 'Caserta' as Denominazione, '02' as Territorio
union
select '023' as id, 'CH' as Sigla, 'Chieti' as Denominazione, '02' as Territorio
union
select '024' as id, 'CI' as Sigla, 'Carbonia-Iglesias' as Denominazione, '02' as Territorio
union
select '025' as id, 'CL' as Sigla, 'Caltanissetta' as Denominazione, '02' as Territorio
union
select '026' as id, 'CN' as Sigla, 'Cuneo' as Denominazione, '02' as Territorio
union
select '027' as id, 'CO' as Sigla, 'Como' as Denominazione, '02' as Territorio
union
select '028' as id, 'CR' as Sigla, 'Cremona' as Denominazione, '02' as Territorio
union
select '029' as id, 'CS' as Sigla, 'Cosenza' as Denominazione, '02' as Territorio
union
select '030' as id, 'CT' as Sigla, 'Catania' as Denominazione, '02' as Territorio
union
select '031' as id, 'CZ' as Sigla, 'Catanzaro' as Denominazione, '02' as Territorio
union
select '032' as id, 'EN' as Sigla, 'Enna' as Denominazione, '02' as Territorio
union
select '033' as id, 'FC' as Sigla, 'Forlì-Cesena' as Denominazione, '02' as Territorio
union
select '034' as id, 'FE' as Sigla, 'Ferrara' as Denominazione, '02' as Territorio
union
select '035' as id, 'FG' as Sigla, 'Foggia' as Denominazione, '01' as Territorio
union
select '036' as id, 'FI' as Sigla, 'Firenze' as Denominazione, '02' as Territorio
union
select '037' as id, 'FM' as Sigla, 'Fermo' as Denominazione, '02' as Territorio
union
select '038' as id, 'FR' as Sigla, 'Frosinone' as Denominazione, '02' as Territorio
union
select '039' as id, 'GE' as Sigla, 'Genova' as Denominazione, '02' as Territorio
union
select '040' as id, 'GO' as Sigla, 'Gorizia' as Denominazione, '02' as Territorio
union
select '041' as id, 'GR' as Sigla, 'Grosseto' as Denominazione, '02' as Territorio
union
select '042' as id, 'IM' as Sigla, 'Imperia' as Denominazione, '02' as Territorio
union
select '043' as id, 'IS' as Sigla, 'Isernia' as Denominazione, '02' as Territorio
union
select '044' as id, 'KR' as Sigla, 'Crotone' as Denominazione, '02' as Territorio
union
select '045' as id, 'LC' as Sigla, 'Lecco' as Denominazione, '02' as Territorio
union
select '046' as id, 'LE' as Sigla, 'Lecce' as Denominazione, '01' as Territorio
union
select '047' as id, 'LI' as Sigla, 'Livorno' as Denominazione, '02' as Territorio
union
select '048' as id, 'LO' as Sigla, 'Lodi' as Denominazione, '02' as Territorio
union
select '049' as id, 'LT' as Sigla, 'Latina' as Denominazione, '02' as Territorio
union
select '050' as id, 'LU' as Sigla, 'Lucca' as Denominazione, '02' as Territorio
union
select '051' as id, 'MB' as Sigla, 'Monza' as Denominazione, '02' as Territorio
union
select '052' as id, 'MC' as Sigla, 'Macerata' as Denominazione, '02' as Territorio
union
select '053' as id, 'ME' as Sigla, 'Messina' as Denominazione, '02' as Territorio
union
select '054' as id, 'MI' as Sigla, 'Milano' as Denominazione, '02' as Territorio
union
select '055' as id, 'MN' as Sigla, 'Mantova' as Denominazione, '02' as Territorio
union
select '056' as id, 'MO' as Sigla, 'Modena' as Denominazione, '02' as Territorio
union
select '057' as id, 'MS' as Sigla, 'Massa-Carrara' as Denominazione, '02' as Territorio
union
select '0589' as id, 'MT' as Sigla, 'Matera' as Denominazione, '02' as Territorio
union
select '059' as id, 'NA' as Sigla, 'Napoli' as Denominazione, '02' as Territorio
union
select '060' as id, 'NO' as Sigla, 'Novara' as Denominazione, '02' as Territorio
union
select '061' as id, 'NU' as Sigla, 'Nuoro' as Denominazione, '02' as Territorio
union
select '062' as id, 'OG' as Sigla, 'Ogliastra' as Denominazione, '02' as Territorio
union
select '063' as id, 'OR' as Sigla, 'Oristano' as Denominazione, '02' as Territorio
union
select '064' as id, 'OT' as Sigla, 'Olbia-Tempio' as Denominazione, '02' as Territorio
union
select '065' as id, 'PA' as Sigla, 'Palermo' as Denominazione, '02' as Territorio
union
select '066' as id, 'PC' as Sigla, 'Piacenza' as Denominazione, '02' as Territorio
union
select '067' as id, 'PD' as Sigla, 'Padova' as Denominazione, '02' as Territorio
union
select '068' as id, 'PE' as Sigla, 'Pescara' as Denominazione, '02' as Territorio
union
select '069' as id, 'PG' as Sigla, 'Perugia' as Denominazione, '02' as Territorio
union
select '070' as id, 'PI' as Sigla, 'Pisa' as Denominazione, '02' as Territorio
union
select '071' as id, 'PN' as Sigla, 'Pordenone' as Denominazione, '02' as Territorio
union
select '072' as id, 'PO' as Sigla, 'Prato' as Denominazione, '02' as Territorio
union
select '073' as id, 'PR' as Sigla, 'Parma' as Denominazione, '02' as Territorio
union
select '074' as id, 'PT' as Sigla, 'Pistoia' as Denominazione, '02' as Territorio
union
select '075' as id, 'PU' as Sigla, 'Pesaro-Urbino' as Denominazione, '02' as Territorio
union
select '076' as id, 'PV' as Sigla, 'Pavia' as Denominazione, '02' as Territorio
union
select '077' as id, 'PZ' as Sigla, 'Potenza' as Denominazione, '02' as Territorio
union
select '078' as id, 'RA' as Sigla, 'Ravenna' as Denominazione, '02' as Territorio
union
select '079' as id, 'RC' as Sigla, 'Reggio Calabria' as Denominazione, '02' as Territorio
union
select '080' as id, 'RE' as Sigla, 'Reggio Emilia' as Denominazione, '02' as Territorio
union
select '081' as id, 'RG' as Sigla, 'Ragusa' as Denominazione, '02' as Territorio
union
select '082' as id, 'RI' as Sigla, 'Rieti' as Denominazione, '02' as Territorio
union
select '083' as id, 'RM' as Sigla, 'Roma' as Denominazione, '02' as Territorio
union
select '084' as id, 'RN' as Sigla, 'Rimini' as Denominazione, '02' as Territorio
union
select '085' as id, 'RO' as Sigla, 'Rovigo' as Denominazione, '02' as Territorio
union
select '086' as id, 'SA' as Sigla, 'Salerno' as Denominazione, '02' as Territorio
union
select '087' as id, 'SI' as Sigla, 'Siena' as Denominazione, '02' as Territorio
union
select '088' as id, 'SO' as Sigla, 'Sondrio' as Denominazione, '02' as Territorio
union
select '089' as id, 'SP' as Sigla, 'La Spezia' as Denominazione, '02' as Territorio
union
select '090' as id, 'SR' as Sigla, 'Siracusa' as Denominazione, '02' as Territorio
union
select '091' as id, 'SS' as Sigla, 'Sassari' as Denominazione, '02' as Territorio
union
select '092' as id, 'SV' as Sigla, 'Savona' as Denominazione, '02' as Territorio
union
select '093' as id, 'TA' as Sigla, 'Taranto' as Denominazione, '01' as Territorio
union
select '094' as id, 'TE' as Sigla, 'Teramo' as Denominazione, '02' as Territorio
union
select '095' as id, 'TN' as Sigla, 'Trento' as Denominazione, '02' as Territorio
union
select '096' as id, 'TO' as Sigla, 'Torino' as Denominazione, '02' as Territorio
union
select '097' as id, 'TP' as Sigla, 'Trapani' as Denominazione, '02' as Territorio
union
select '098' as id, 'TR' as Sigla, 'Terni' as Denominazione, '02' as Territorio
union
select '099' as id, 'TS' as Sigla, 'Trieste' as Denominazione, '02' as Territorio
union
select '100' as id, 'TV' as Sigla, 'Treviso' as Denominazione, '02' as Territorio
union
select '101' as id, 'UD' as Sigla, 'Udine' as Denominazione, '02' as Territorio
union
select '102' as id, 'VA' as Sigla, 'Varese' as Denominazione, '02' as Territorio
union
select '103' as id, 'VB' as Sigla, 'Verbano-Cusio-Ossola' as Denominazione, '02' as Territorio
union
select '104' as id, 'VC' as Sigla, 'Vercelli' as Denominazione, '02' as Territorio
union
select '105' as id, 'VE' as Sigla, 'Venezia' as Denominazione, '02' as Territorio
union
select '106' as id, 'VI' as Sigla, 'Vicenza' as Denominazione, '02' as Territorio
union
select '107' as id, 'VR' as Sigla, 'Verona' as Denominazione, '02' as Territorio
union
select '108' as id, 'VS' as Sigla, 'Medio Campidano' as Denominazione, '02' as Territorio
union
select '109' as id, 'VT' as Sigla, 'Viterbo' as Denominazione, '02' as Territorio
union
select '110' as id, 'VV' as Sigla, 'Vibo Valentia' as Denominazione, '02' as Territorio
union
select '111' as id, 'RSM' as Sigla, 'RSM' as Denominazione, '03' as Territorio
union
select '111' as id, 'RSM' as Sigla, 'R.S.M.' as Denominazione, '03' as Territorio
union
select '111' as id, 'RSM' as Sigla, 'Repubblica San Marino' as Denominazione, '03' as Territorio
union
select '036' as id, 'FI' as Sigla, 'REGGELLO' as Denominazione, '02' as Territorio


GO
