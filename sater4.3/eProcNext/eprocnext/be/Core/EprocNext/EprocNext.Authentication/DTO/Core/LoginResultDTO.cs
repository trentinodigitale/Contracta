using System;
using System.Collections.Generic;
using System.Text;

namespace Core.Authentication.DTO.Core
{
    public class LoginResultDTO
    {
        public string Token { get; set; }
        public string RefreshToken { get; set; }
        public Guid? SessionToken { get; set; }
    }
}
