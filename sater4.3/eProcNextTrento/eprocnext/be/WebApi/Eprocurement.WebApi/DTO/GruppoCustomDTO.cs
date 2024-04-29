using Core.Repositories.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EprocNext.WebApi.DTO
{
    public class ElementoLnkDTO
    {
        public string Id { get; set; }
        public string Percentuale { get; set; }
        public uint Hash { get; set; }
    }
    
    public class GruppoCustomDTO : ISecurityDTO
    {
        public uint Hash { get; set; }
        public string Id { get; set; }
        public string Descrizione { get; set; }
        public ElementoLnkDTO[]  ElencoId_Perc { get; set; } 
    }

}
