using System;
using Dapper;
using AutoMapper;
using Core.Repositories.Interfaces;
using System.Text.Json.Serialization;
using RepoDb.Attributes;

namespace EprocNext.Repositories.Models
{
    /// <summary>
    /// A class which represents the Aziende table.
    /// </summary>
    /// 
    [Table("Aziende")]
    [Map("[Aziende]")]
    public partial class Aziende
    {
        [Key]
        [Primary]
        public virtual int IdAzi { get; set; }
        public virtual byte[] aziTS { get; set; } // nel DB è un campo timestamp
        public virtual string aziLog { get; set; }
        public virtual DateTime aziDataCreazione { get; set; }
        public virtual string aziRagioneSociale { get; set; }
        public virtual string aziRagioneSocialeNorm { get; set; }
        public virtual int? aziIdDscFormaSoc { get; set; }
        public virtual string aziPartitaIVA { get; set; }
        public virtual string aziE_mail { get; set; }
        public virtual int aziAcquirente { get; set; }
        public virtual int aziVenditore { get; set; }
        public virtual int aziProspect { get; set; }
        public virtual string aziIndirizzoLeg { get; set; }
        public virtual string aziIndirizzoOp { get; set; }
        public virtual string aziLocalitaLeg { get; set; }
        public virtual string aziLocalitaOp { get; set; }
        public virtual string aziProvinciaLeg { get; set; }
        public virtual string aziProvinciaOp { get; set; }
        public virtual string aziStatoLeg { get; set; }
        public virtual string aziStatoOp { get; set; }
        public virtual string aziCAPLeg { get; set; }
        public virtual string aziCapOp { get; set; }
        public virtual string aziPrefisso { get; set; }
        public virtual string aziTelefono1 { get; set; }
        public virtual string aziTelefono2 { get; set; }
        public virtual string aziFAX { get; set; }
        public virtual byte[]? aziLogo { get; set; } // nel db è un canpo IMAGE
        public virtual int? aziIdDscDescrizione { get; set; }
        public virtual int aziProssimoProtRdo { get; set; }
        public virtual int aziProssimoProtOff { get; set; }
        public virtual int? aziGphValueOper { get; set; }
        public virtual bool aziDeleted { get; set; } // nel DB è un tinyint. Meglio gestirlo come Byte o lasciamo un boolean?
        public virtual int? aziDBNumber { get; set; }
        public virtual string aziAtvAtecord { get; set; }
        public virtual string aziSitoWeb { get; set; }
        public virtual int? aziCodEurocredit { get; set; }
        public virtual string aziProfili { get; set; }
        public virtual string aziProvinciaLeg2 { get; set; }
        public virtual string aziStatoLeg2 { get; set; }
        public virtual string aziFunzionalita { get; set; }
        public virtual string CertificatoIscrAtt { get; set; }
        public virtual string TipoDiAmministr { get; set; }
        public virtual string aziLocalitaLeg2 { get; set; }
        public virtual int? daValutare { get; set; }
        public virtual string aziNumeroCivico { get; set; }

    }

    /// <summary>
    /// A DTO class for Aziende Table
    /// </summary>
    public class AziendeDTO : IDtoResolver, ISecurityDTO
    {
        [Key]
        public virtual int IdAzi { get; set; }
        public virtual byte[] aziTS { get; set; } // nel DB è un campo timestamp
        public virtual string aziLog { get; set; }
        public virtual DateTime aziDataCreazione { get; set; }
        public virtual string aziRagioneSociale { get; set; }
        public virtual string aziRagioneSocialeNorm { get; set; }
        public virtual int? aziIdDscFormaSoc { get; set; }
        public virtual string aziPartitaIVA { get; set; }
        public virtual string aziE_mail { get; set; }
        public virtual int aziAcquirente { get; set; }
        public virtual int aziVenditore { get; set; }
        public virtual int aziProspect { get; set; }
        public virtual string aziIndirizzoLeg { get; set; }
        public virtual string aziIndirizzoOp { get; set; }
        public virtual string aziLocalitaLeg { get; set; }
        public virtual string aziLocalitaOp { get; set; }
        public virtual string aziProvinciaLeg { get; set; }
        public virtual string aziProvinciaOp { get; set; }
        public virtual string aziStatoLeg { get; set; }
        public virtual string aziStatoOp { get; set; }
        public virtual string aziCapLeg { get; set; }
        public virtual string aziCapOp { get; set; }
        public virtual string aziPrefisso { get; set; }
        public virtual string aziTelefono1 { get; set; }
        public virtual string aziTelefono2 { get; set; }
        public virtual string aziFax { get; set; }
        public virtual byte[]? aziLogo { get; set; } // nel db è un canpo IMAGE
        public virtual int? aziIdDscDescrizione { get; set; }
        public virtual int aziProssimoProtRdo { get; set; }
        public virtual int aziProssimoProtOff { get; set; }
        public virtual int? aziGphValueOper { get; set; }
        public virtual bool aziDeleted { get; set; } // nel DB è un tinyint. Meglio gestirlo come Byte o lasciamo un boolean?
        public virtual int? aziDBNumber { get; set; }
        public virtual string aziAtvAtecord { get; set; }
        public virtual string aziSitoWeb { get; set; }
        public virtual int? aziCodEurocredit { get; set; }
        public virtual string aziProfili { get; set; }
        public virtual string aziProvinciaLeg2 { get; set; }
        public virtual string aziStatoLeg2 { get; set; }
        public virtual string aziFunzionalita { get; set; }
        public virtual string CertificatoIscrAtt { get; set; }
        public virtual string TipoDiAmministr { get; set; }
        public virtual string aziLocalitaLeg2 { get; set; }
        public virtual int? daValutare { get; set; }
        public virtual string aziNumeroCivico { get; set; }

        #region Reserved
        /// <summary>
        /// It's used for get Resolver at runtime (for example in join command query)
        /// </summary>
        [JsonIgnore]
        public Type Resolver => throw new NotImplementedException();

        /// <summary>
		/// It's used for integrity check to avoid cross tenant violations
		/// </summary>
        public uint Hash { get => throw new NotImplementedException(); set => throw new NotImplementedException(); }
        #endregion Reserved
    }

    public class AziendeDTOMap : Profile, IResolver
    {
        /// <summary>
        /// A class that define mapping between Aziende and AziendeDTO class
        /// </summary>
        /// 

        public AziendeDTOMap()
        {
            CreateMap<Aziende, AziendeDTO>()
                .ForMember(dest => dest.IdAzi, opt => opt.MapFrom(src => src.IdAzi))
                .ForMember(dest => dest.aziTS, opt => opt.MapFrom(src => src.aziTS))
                .ForMember(dest => dest.aziLog, opt => opt.MapFrom(src => src.aziLog))
                .ForMember(dest => dest.aziDataCreazione, opt => opt.MapFrom(src => src.aziDataCreazione))
                .ForMember(dest => dest.aziRagioneSociale, opt => opt.MapFrom(src => src.aziRagioneSociale))
                .ForMember(dest => dest.aziRagioneSocialeNorm, opt => opt.MapFrom(src => src.aziRagioneSocialeNorm))
                .ForMember(dest => dest.aziIdDscFormaSoc, opt => opt.MapFrom(src => src.aziIdDscFormaSoc))
                .ForMember(dest => dest.aziPartitaIVA, opt => opt.MapFrom(src => src.aziPartitaIVA))
                .ForMember(dest => dest.aziE_mail, opt => opt.MapFrom(src => src.aziE_mail))
                .ForMember(dest => dest.aziAcquirente, dest => dest.MapFrom(src => src.aziAcquirente))
                .ForMember(dest => dest.aziVenditore, opt => opt.MapFrom(src => src.aziVenditore))
                .ForMember(dest => dest.aziProspect, opt => opt.MapFrom(src => src.aziProspect))
                .ForMember(dest => dest.aziIndirizzoLeg, opt => opt.MapFrom(src => src.aziIndirizzoLeg))
                .ForMember(dest => dest.aziIndirizzoOp, opt => opt.MapFrom(src => src.aziIndirizzoOp))
                .ForMember(dest => dest.aziLocalitaLeg, opt => opt.MapFrom(src => src.aziLocalitaLeg))
                .ForMember(dest => dest.aziLocalitaOp, opt => opt.MapFrom(src => src.aziLocalitaOp))
                .ForMember(dest => dest.aziLocalitaLeg2, opt => opt.MapFrom(src => src.aziLocalitaLeg2))
                .ForMember(dest => dest.aziProvinciaLeg, opt => opt.MapFrom(src => src.aziProvinciaLeg))
                .ForMember(dest => dest.aziProvinciaOp, opt => opt.MapFrom(src => src.aziProvinciaOp))
                .ForMember(dest => dest.aziProvinciaLeg2, opt => opt.MapFrom(src => src.aziProvinciaLeg2))
                .ForMember(dest => dest.aziStatoLeg, opt => opt.MapFrom(src => src.aziStatoLeg))
                .ForMember(dest => dest.aziStatoOp, opt => opt.MapFrom(src => src.aziStatoOp))
                .ForMember(dest => dest.aziStatoLeg2, opt => opt.MapFrom(src => src.aziStatoLeg2))
                .ForMember(dest => dest.aziCapLeg, opt => opt.MapFrom(src => src.aziCAPLeg))
                .ForMember(dest => dest.aziCapOp, opt => opt.MapFrom(src => src.aziCapOp))
                .ForMember(dest => dest.aziPrefisso, opt => opt.MapFrom(src => src.aziPrefisso))
                .ForMember(dest => dest.aziTelefono1, opt => opt.MapFrom(src => src.aziTelefono1))
                .ForMember(dest => dest.aziTelefono2, opt => opt.MapFrom(src => src.aziTelefono2))
                .ForMember(dest => dest.aziFax, opt => opt.MapFrom(src => src.aziFAX))
                .ForMember(dest => dest.aziLogo, opt => opt.MapFrom(src => src.aziLogo))
                .ForMember(dest => dest.aziIdDscDescrizione, opt => opt.MapFrom(src => src.aziIdDscDescrizione))
                .ForMember(dest => dest.aziProssimoProtRdo, opt => opt.MapFrom(src => src.aziProssimoProtRdo))
                .ForMember(dest => dest.aziProssimoProtOff, opt => opt.MapFrom(src => src.aziProssimoProtOff))
                .ForMember(dest => dest.aziGphValueOper, opt => opt.MapFrom(src => src.aziGphValueOper))
                .ForMember(dest => dest.aziDeleted, opt => opt.MapFrom(src => src.aziDeleted))
                .ForMember(dest => dest.aziDBNumber, opt => opt.MapFrom(src => src.aziDBNumber))
                .ForMember(dest => dest.aziAtvAtecord, opt => opt.MapFrom(src => src.aziAtvAtecord))
                .ForMember(dest => dest.aziSitoWeb, opt => opt.MapFrom(src => src.aziSitoWeb))
                .ForMember(dest => dest.aziCodEurocredit, opt => opt.MapFrom(src => src.aziCodEurocredit))
                .ForMember(dest => dest.aziProfili, opt => opt.MapFrom(src => src.aziProfili))
                .ForMember(dest => dest.aziFunzionalita, opt => opt.MapFrom(src => src.aziFunzionalita))
                .ForMember(dest => dest.CertificatoIscrAtt, opt => opt.MapFrom(src => src.CertificatoIscrAtt))
                .ForMember(dest => dest.TipoDiAmministr, opt => opt.MapFrom(src => src.TipoDiAmministr))
                .ForMember(dest => dest.daValutare, opt => opt.MapFrom(src => src.daValutare))
                .ForMember(dest => dest.aziNumeroCivico, opt => opt.MapFrom(src => src.aziNumeroCivico))
                .ReverseMap();
                }

        /// <summary>
        /// Resolver needed to convert query with AziendeDTO's column name in Aziende column name.
        /// It's called by query resolvers.
        /// </summary>
        /// <param name="dtoColumnName">dto column name (case insensitive)</param>
        /// <returns>Model column name</returns>
        public string FieldResolver(string fieldName)
        {
            return fieldName.ToUpper() switch
            {
                "aziCapLeg" => "aziCAPLeg",
                "aziCapOp" => "aziCapOp",
                "aziPrefisso" => "aziPrefisso",
                "aziTelefono1" => "aziTelefono1",
                "aziTelefono2" => "aziTelefono2",
                "aziFax" => "aziFAX",
                "aziLogo" => "aziLogo",
                "aziIdDscDescrizione" => "aziIdDscDescrizione",
                "aziProssimoProtRdo" => "aziProssimoProtRdo",
                "aziProssimoProtOff" => "aziProssimoProtOff",
                "aziGphValueOper" => "aziGphValueOper",
                "aziDeleted" => "aziDeleted",
                "aziDBNumber" => "aziDBNumber",
                "aziAtvAtecord" => "aziAtvAtecord",
                "aziSitoWeb" => "aziSitoWeb",
                "aziCodEurocredit" => "aziCodEurocredit",
                "aziProfili" => "aziProfili",
                "aziProvinciaLeg2" => "aziProvinciaLeg2",
                "aziStatoLeg2" => "aziStatoLeg2",
                "aziFunzionalita" => "aziFunzionalita",
                "CertificatoIscrAtt" => "CertificatoIscrAtt",
                "TipoDiAmministr" => "TipoDiAmministr",
                "aziLocalitaLeg2" => "aziLocalitaLeg2",
                "daValutare" => "daValutare",
                "aziNumeroCivico" => "aziNumeroCivico",
                _ => fieldName
            };
        }

    }
}
