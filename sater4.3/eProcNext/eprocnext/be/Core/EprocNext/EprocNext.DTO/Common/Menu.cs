using System.Collections.Generic;

namespace Cloud.EprocNext.DTO
{
    /// <summary>
    /// Classe che rappresenta il menu dell'applicazione
    /// </summary>
    public class Menu
    {
        public long Id { get; set; }

        public string Title { get; set; }

        public string Routing { get; set; }

        public string Icon { get; set; }

        public long? ParentId { get; set; }
    }


    public class ProfileAndVersionFeatures : Menu
    {
        public long? FeatureId { get; set; }
        public string Profiles { get; set; }
        public string Versions { get; set; }
    }

    public class RoleFeatures : Menu
    {
        public long? FeatureId { get; set; }
        public string Roles { get; set; }
    }

    public class ConfigMenuFunctions
    {
        public List<ProfileAndVersionFeatures> ProfileAndVersionFeatures { get; set; }

        public List<RoleFeatures> RoleFeatures { get; set; }

        public List<string> Roles { get; set; }

        public List<string> Profiles { get; set; }

        public List<string> Versions { get; set; }
    }
}

