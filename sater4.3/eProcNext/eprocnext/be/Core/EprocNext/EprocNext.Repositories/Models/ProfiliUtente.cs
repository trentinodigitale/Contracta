using System;
using Dapper;
using AutoMapper;
using Core.Repositories.Interfaces;
using System.Text.Json.Serialization;
using RepoDb.Attributes;

namespace EprocNext.Repositories.Models
{
    /// <summary>
    /// A class which represents the ProfiliUtente table.
    /// </summary>
    [Table("ProfiliUtente")]
    [Map("ProfiliUtente")]
    public partial class ProfiliUtente
    {
        [Key]
        [Primary]
        public virtual int IdPfu { get; set; }
        public virtual byte[] pfuTs { get; set; } // nel db è un timestamp
        public virtual int pfuIdAzi { get; set; }
        public virtual string pfuNome { get; set; }
        public virtual string pfuLogin { get; set; }
        public virtual string pfuRuoloAziendale { get; set; }
        public virtual string pfuPassword { get; set; }
        public virtual string pfuPrefissoProt { get; set; }
        public virtual bool pfuAdmin { get; set; } // nel db è un campo bit
        public virtual bool pfuAcquirente { get; set; } // nel db è un campo bit
        public virtual bool pfuVenditore { get; set; } // 
        public virtual bool pfuInvRdO { get; set; }
        public virtual bool pfuRcvOff { get; set; }
        public virtual bool pfuInvOff { get; set; }
        public virtual int? pfuIdPfuBCopiaA { get; set; }
        public virtual int? pfuIdPfuSCopiaA { get; set; }
        public virtual bool pfuCopiaRdo { get; set; }
        public virtual bool pfuCopiaOffRic { get; set; }
        public virtual decimal pfuImpMaxRdO { get; set; }
        public virtual decimal pfuImpMaxOff { get; set; }
        public virtual decimal pfuImpMaxRdoAnn { get; set; }
        public virtual decimal pfuImpMaxOffAnn { get; set; }
        public virtual int pfuIdLng { get; set; }
        public virtual string pfuParametriBench { get; set; }
        public virtual int? pfuSkillLevel1 { get; set; }
        public virtual int? pfuSkillLevel2 { get; set; }
        public virtual int? pfuSkillLevel3 { get; set; }
        public virtual int? pfuSkillLevel4 { get; set; }
        public virtual int? pfuSkillLevel5 { get; set; }
        public virtual int? pfuSkillLevel6 { get; set; }
        public virtual string pfuE_Mail { get; set; }
        public virtual string pfuTestoSollecito { get; set; }
        public virtual bool pfuDeleted { get; set; }
        public virtual string pfuBizMail { get; set; }
        public virtual bool pfuCatalogo { get; set; }
        public virtual string pfuProfili { get; set; }
        public virtual string pfuFunzionalita { get; set; }
        public virtual string pfuopzioni { get; set; }
        public virtual string pfuTel { get; set; }
        public virtual string pfuCell { get; set; }
        public virtual string pfuSIM { get; set; }
        public virtual int? pfuIdMpMod { get; set; }
        public virtual string pfuToken { get; set; }
        public virtual string pfuCodiceFiscale { get; set; }
        public virtual DateTime? pfuLastLogin { get; set; }
        public virtual string pfuAlgoritmoPassword { get; set; }
        public virtual DateTime? pfuDataCambioPassword { get; set; }
        public virtual string pfuStato { get; set; }
        public virtual int? pfuTentativiLogin { get; set; }
        public virtual int? pfuResponsabileUtente { get; set; }
        public virtual string pfuTitolo { get; set; }
        public virtual string pfuCognome { get; set; }
        public virtual string pfunomeutente { get; set; }
        public virtual DateTime? pfuDataCreazione { get; set; }
        public virtual bool? UtenteFedera { get; set; }
        public virtual bool? PasswordScaduta { get; set; }
        public virtual string pfuUserID { get; set; }
        public virtual string pfuSessionID { get; set; }
        public virtual string pfuIpServerLogin { get; set; }

        public virtual string pfuRefreshToken { get; set; }
        
    }

    /// <summary>
    /// A DTO class of ProfiliUtente table.
    /// </summary>
    [Table("ProfiliUtente")]
    public class ProfiliUtenteDTO : IDtoResolver, ISecurityDTO
    {
        [Key]
        public virtual int IdPfu { get; set; }
        public virtual byte[] pfuTs { get; set; } // nel db è un timestamp
        public virtual int pfuIdAzi { get; set; }
        public virtual string pfuNome { get; set; }
        public virtual string pfuLogin { get; set; }
        public virtual string pfuRuoloAziendale { get; set; }
        public virtual string pfuPassword { get; set; }
        public virtual string pfuPrefissoProt { get; set; }
        public virtual bool pfuAdmin { get; set; } // nel db è un campo bit
        public virtual bool pfuAcquirente { get; set; } // nel db è un campo bit
        public virtual bool pfuVenditore { get; set; } // 
        public virtual bool pfuInvRdO { get; set; }
        public virtual bool pfuRcvOff { get; set; }
        public virtual bool pfuInvOff { get; set; }
        public virtual int? pfuIdPfuBCopiaA { get; set; }
        public virtual int? pfuIdPfuSCopiaA { get; set; }
        public virtual bool pfuCopiaRdo { get; set; }
        public virtual bool pfuCopiaOffRic { get; set; }
        public virtual decimal pfuImpMaxRdO { get; set; }
        public virtual decimal pfuImpMaxOff { get; set; }
        public virtual decimal pfuImpMaxRdoAnn { get; set; }
        public virtual decimal pfuImpMaxOffAnn { get; set; }
        public virtual int pfuIdLng { get; set; }
        public virtual string pfuParametriBench { get; set; }
        public virtual int? pfuSkillLevel1 { get; set; }
        public virtual int? pfuSkillLevel2 { get; set; }
        public virtual int? pfuSkillLevel3 { get; set; }
        public virtual int? pfuSkillLevel4 { get; set; }
        public virtual int? pfuSkillLevel5 { get; set; }
        public virtual int? pfuSkillLevel6 { get; set; }
        public virtual string pfuE_Mail { get; set; }
        public virtual string pfuTestoSollecito { get; set; }
        public virtual bool pfuDeleted { get; set; }
        public virtual string pfuBizMail { get; set; }
        public virtual bool pfuCatalogo { get; set; }
        public virtual string pfuProfili { get; set; }
        public virtual string pfuFunzionalita { get; set; }
        public virtual string pfuopzioni { get; set; }
        public virtual string pfuTel { get; set; }
        public virtual string pfuCell { get; set; }
        public virtual string pfuSIM { get; set; }
        public virtual int? pfuIdMpMod { get; set; }
        public virtual string pfuToken { get; set; }
        public virtual string pfuCodiceFiscale { get; set; }
        public virtual DateTime? pfuLastLogin { get; set; }
        public virtual string pfuAlgoritmoPassword { get; set; }
        public virtual DateTime? pfuDataCambioPassword { get; set; }
        public virtual string pfuStato { get; set; }
        public virtual int? pfuTentativiLogin { get; set; }
        public virtual int? pfuResponsabileUtente { get; set; }
        public virtual string pfuTitolo { get; set; }
        public virtual string pfuCognome { get; set; }
        public virtual string pfunomeutente { get; set; }
        public virtual DateTime? pfuDataCreazione { get; set; }
        public virtual bool? UtenteFedera { get; set; }
        public virtual bool? PasswordScaduta { get; set; }
        public virtual string pfuUserID { get; set; }
        public virtual string pfuSessionID { get; set; }
        public virtual string pfuIpServerLogin { get; set; }

        public virtual string pfuRefreshToken { get; set; }
        

        #region Reserved
        /// <summary>
        /// It's used for integrity check to avoid cross tenant violations
        /// </summary>
        public virtual uint Hash { get; set; }
        /// <summary>
        /// It's used for get Resolver at runtime (for example in join command query)
        /// </summary>
        [JsonIgnore]
        public Type Resolver => typeof(ProfiliUtenteDTOMap);
        #endregion Reserver

    }


    /// <summary>
    /// A class that define mapping between ProfiliUtente and ProfiliUtenteDTO class
    /// </summary>
	public class ProfiliUtenteDTOMap : Profile, IResolver
    {
        /// <summary>
        /// _map initialization called at startup
        /// </summary>
        public ProfiliUtenteDTOMap()
        {
            CreateMap<ProfiliUtente, ProfiliUtenteDTO>()
            .ForMember(dest => dest.IdPfu, opt => opt.MapFrom(src => src.IdPfu))
            .ForMember(dest => dest.IdPfu, opt => opt.MapFrom(src => src.IdPfu))
            .ForMember(dest => dest.pfuTs, opt => opt.MapFrom(src => src.pfuTs))
            .ForMember(dest => dest.pfuIdAzi, opt => opt.MapFrom(src => src.pfuIdAzi))
            .ForMember(dest => dest.pfuNome, opt => opt.MapFrom(src => src.pfuNome))
            .ForMember(dest => dest.pfuLogin, opt => opt.MapFrom(src => src.pfuLogin))
            .ForMember(dest => dest.pfuRuoloAziendale, opt => opt.MapFrom(src => src.pfuRuoloAziendale))
            .ForMember(dest => dest.pfuPassword, opt => opt.MapFrom(src => src.pfuPassword))
            .ForMember(dest => dest.pfuPrefissoProt, opt => opt.MapFrom(src => src.pfuPrefissoProt))
            .ForMember(dest => dest.pfuAdmin, opt => opt.MapFrom(src => src.pfuAdmin))
            .ForMember(dest => dest.pfuAcquirente, opt => opt.MapFrom(src => src.pfuAcquirente))
            .ForMember(dest => dest.pfuVenditore, opt => opt.MapFrom(src => src.pfuVenditore))
            .ForMember(dest => dest.pfuInvRdO, opt => opt.MapFrom(src => src.pfuInvRdO))
            .ForMember(dest => dest.pfuRcvOff, opt => opt.MapFrom(src => src.pfuRcvOff))
            .ForMember(dest => dest.pfuInvOff, opt => opt.MapFrom(src => src.pfuInvOff))
            .ForMember(dest => dest.pfuIdPfuBCopiaA, opt => opt.MapFrom(src => src.pfuIdPfuBCopiaA))
            .ForMember(dest => dest.pfuIdPfuSCopiaA, opt => opt.MapFrom(src => src.pfuIdPfuSCopiaA))
            .ForMember(dest => dest.pfuCopiaRdo, opt => opt.MapFrom(src => src.pfuCopiaRdo))
            .ForMember(dest => dest.pfuCopiaOffRic, opt => opt.MapFrom(src => src.pfuCopiaOffRic))
            .ForMember(dest => dest.pfuImpMaxRdO, opt => opt.MapFrom(src => src.pfuImpMaxRdO))
            .ForMember(dest => dest.pfuImpMaxOff, opt => opt.MapFrom(src => src.pfuImpMaxOff))
            .ForMember(dest => dest.pfuImpMaxRdoAnn, opt => opt.MapFrom(src => src.pfuImpMaxRdoAnn))
            .ForMember(dest => dest.pfuImpMaxOffAnn, opt => opt.MapFrom(src => src.pfuImpMaxOffAnn))
            .ForMember(dest => dest.pfuIdLng, opt => opt.MapFrom(src => src.pfuIdLng))
            .ForMember(dest => dest.pfuParametriBench, opt => opt.MapFrom(src => src.pfuParametriBench))
            .ForMember(dest => dest.pfuSkillLevel1, opt => opt.MapFrom(src => src.pfuSkillLevel1))
            .ForMember(dest => dest.pfuSkillLevel2, opt => opt.MapFrom(src => src.pfuSkillLevel2))
            .ForMember(dest => dest.pfuSkillLevel3, opt => opt.MapFrom(src => src.pfuSkillLevel3))
            .ForMember(dest => dest.pfuSkillLevel4, opt => opt.MapFrom(src => src.pfuSkillLevel4))
            .ForMember(dest => dest.pfuSkillLevel5, opt => opt.MapFrom(src => src.pfuSkillLevel5))
            .ForMember(dest => dest.pfuSkillLevel6, opt => opt.MapFrom(src => src.pfuSkillLevel6))
            .ForMember(dest => dest.pfuE_Mail, opt => opt.MapFrom(src => src.pfuE_Mail))
            .ForMember(dest => dest.pfuTestoSollecito, opt => opt.MapFrom(src => src.pfuTestoSollecito))
            .ForMember(dest => dest.pfuDeleted, opt => opt.MapFrom(src => src.pfuDeleted))
            .ForMember(dest => dest.pfuBizMail, opt => opt.MapFrom(src => src.pfuBizMail))
            .ForMember(dest => dest.pfuCatalogo, opt => opt.MapFrom(src => src.pfuCatalogo))
            .ForMember(dest => dest.pfuProfili, opt => opt.MapFrom(src => src.pfuProfili))
            .ForMember(dest => dest.pfuFunzionalita, opt => opt.MapFrom(src => src.pfuFunzionalita))
            .ForMember(dest => dest.pfuopzioni, opt => opt.MapFrom(src => src.pfuopzioni))
            .ForMember(dest => dest.pfuTel, opt => opt.MapFrom(src => src.pfuTel))
            .ForMember(dest => dest.pfuCell, opt => opt.MapFrom(src => src.pfuCell))
            .ForMember(dest => dest.pfuSIM, opt => opt.MapFrom(src => src.pfuSIM))
            .ForMember(dest => dest.pfuIdMpMod, opt => opt.MapFrom(src => src.pfuIdMpMod))
            .ForMember(dest => dest.pfuToken, opt => opt.MapFrom(src => src.pfuToken))
            .ForMember(dest => dest.pfuCodiceFiscale, opt => opt.MapFrom(src => src.pfuCodiceFiscale))
            .ForMember(dest => dest.pfuLastLogin, opt => opt.MapFrom(src => src.pfuLastLogin))
            .ForMember(dest => dest.pfuAlgoritmoPassword, opt => opt.MapFrom(src => src.pfuAlgoritmoPassword))
            .ForMember(dest => dest.pfuDataCambioPassword, opt => opt.MapFrom(src => src.pfuDataCambioPassword))
            .ForMember(dest => dest.pfuStato, opt => opt.MapFrom(src => src.pfuStato))
            .ForMember(dest => dest.pfuTentativiLogin, opt => opt.MapFrom(src => src.pfuTentativiLogin))
            .ForMember(dest => dest.pfuResponsabileUtente, opt => opt.MapFrom(src => src.pfuResponsabileUtente))
            .ForMember(dest => dest.pfuTitolo, opt => opt.MapFrom(src => src.pfuTitolo))
            .ForMember(dest => dest.pfuCognome, opt => opt.MapFrom(src => src.pfuCognome))
            .ForMember(dest => dest.pfunomeutente, opt => opt.MapFrom(src => src.pfunomeutente))
            .ForMember(dest => dest.pfuDataCreazione, opt => opt.MapFrom(src => src.pfuDataCreazione))
            .ForMember(dest => dest.UtenteFedera, opt => opt.MapFrom(src => src.UtenteFedera))
            .ForMember(dest => dest.PasswordScaduta, opt => opt.MapFrom(src => src.PasswordScaduta))
            .ForMember(dest => dest.pfuUserID, opt => opt.MapFrom(src => src.pfuUserID))
            .ForMember(dest => dest.pfuSessionID, opt => opt.MapFrom(src => src.pfuSessionID))
            .ForMember(dest => dest.pfuIpServerLogin, opt => opt.MapFrom(src => src.pfuIpServerLogin))
            .ForMember(dest => dest.pfuRefreshToken, opt => opt.MapFrom(src => src.pfuRefreshToken))
            
            .ReverseMap();
        }

        /// <summary>
        /// Resolver needed to convert query with ProfiliUtenteDTO's column name in ProfiliUtente column name.
        /// It's called by query resolvers.
        /// </summary>
        /// <param name="dtoColumnName">dto column name (case insensitive)</param>
        /// <returns>Model column name</returns>
        public string FieldResolver(string fieldName)
        {
            return fieldName.ToUpper() switch
            {
                "IdPfu" => " IdPfu",
                "pfuTs" => " pfuTs",
                "pfuIdAzi" => " pfuIdAzi",
                "pfuNome" => " pfuNome",
                "pfuLogin" => " pfuLogin",
                "pfuRuoloAziendale" => " pfuRuoloAziendale",
                "pfuPassword" => " pfuPassword",
                "pfuPrefissoProt" => " pfuPrefissoProt",
                "pfuAdmin" => " pfuAdmin",
                "pfuAcquirente" => " pfuAcquirente",
                "pfuVenditore" => " pfuVenditore",
                "pfuInvRdO" => " pfuInvRdO",
                "pfuRcvOff" => " pfuRcvOff",
                "pfuInvOff" => " pfuInvOff",
                "pfuIdPfuBCopiaA" => " pfuIdPfuBCopiaA",
                "pfuIdPfuSCopiaA" => " pfuIdPfuSCopiaA",
                "pfuCopiaRdo" => " pfuCopiaRdo",
                "pfuCopiaOffRic" => " pfuCopiaOffRic",
                "pfuImpMaxRdO" => " pfuImpMaxRdO",
                "pfuImpMaxOff" => " pfuImpMaxOff",
                "pfuImpMaxRdoAnn" => " pfuImpMaxRdoAnn",
                "pfuImpMaxOffAnn" => " pfuImpMaxOffAnn",
                "pfuIdLng" => " pfuIdLng",
                "pfuParametriBench" => " pfuParametriBench",
                "pfuSkillLevel1" => " pfuSkillLevel1",
                "pfuSkillLevel2" => " pfuSkillLevel2",
                "pfuSkillLevel3" => " pfuSkillLevel3",
                "pfuSkillLevel4" => " pfuSkillLevel4",
                "pfuSkillLevel5" => " pfuSkillLevel5",
                "pfuSkillLevel6" => " pfuSkillLevel6",
                "pfuE_Mail" => " pfuE_Mail",
                "pfuTestoSollecito" => " pfuTestoSollecito",
                "pfuDeleted" => " pfuDeleted",
                "pfuBizMail" => " pfuBizMail",
                "pfuCatalogo" => " pfuCatalogo",
                "pfuProfili" => " pfuProfili",
                "pfuFunzionalita" => " pfuFunzionalita",
                "pfuopzioni" => " pfuopzioni",
                "pfuTel" => " pfuTel",
                "pfuCell" => " pfuCell",
                "pfuSIM" => " pfuSIM",
                "pfuIdMpMod" => " pfuIdMpMod",
                "pfuToken" => " pfuToken",
                "pfuCodiceFiscale" => " pfuCodiceFiscale",
                "pfuLastLogin" => " pfuLastLogin",
                "pfuAlgoritmoPassword" => " pfuAlgoritmoPassword",
                "pfuDataCambioPassword" => " pfuDataCambioPassword",
                "pfuStato" => " pfuStato",
                "pfuTentativiLogin" => " pfuTentativiLogin",
                "pfuResponsabileUtente" => " pfuResponsabileUtente",
                "pfuTitolo" => " pfuTitolo",
                "pfuCognome" => " pfuCognome",
                "pfunomeutente" => " pfunomeutente",
                "pfuDataCreazione" => " pfuDataCreazione",
                "UtenteFedera" => " UtenteFedera",
                "PasswordScaduta" => " PasswordScaduta",
                "pfuUserID" => " pfuUserID",
                "pfuSessionID" => " pfuSessionID",
                "pfuIpServerLogin" => " pfuIpServerLogin",
                _ => fieldName
            };
        }
    }

}
