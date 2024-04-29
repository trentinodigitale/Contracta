using Core.Authentication.Interfaces;
using System;
using System.Text.Json.Serialization;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Threading.Tasks;

namespace Core.Authentication.DTO.Core
{
    public class LoginDTO : IVerifySessionTokenInput
    {
        public string UserName { get; set; }

        public string Email { get; set; }

        public long? WorkingTenant { get; set; }

        public string Password { get; set; }

        public string Token { get; set; }

        public string RefreshToken { get; set; }

        public Guid? SessionToken { get; set; }
    }
}
