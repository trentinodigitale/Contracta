using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using System.Diagnostics;
using System.IdentityModel.Tokens.Jwt;
using System.Runtime.InteropServices;
using System.Security.Claims;
using System.Text;

namespace eProcurementNext.Authentication
{
    public class JWT : IEprocNextAuthentication
    {
        public IConfiguration _configuration { get; set; }

        public string? _mySecret;
        public SymmetricSecurityKey? _mySecurityKey;
        public string? _myIssuer;
        public string? _myAudience;
        public string? _userToken = null;

        public JWT(IConfiguration configuration)
        {
            _configuration = configuration;
            var JWTObj = _configuration.GetRequiredSection("JWT");

            _mySecret = JWTObj.GetSection("Secret").Value;
            _mySecurityKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_mySecret));
            _myIssuer = JWTObj.GetSection("Issuer").Value;
            _myAudience = JWTObj.GetSection("Audience").Value;
        }

		public JWT(string? mySecret, string? myIssuer, string? myAudience)
		{
			if (
				mySecret == null ||
				myIssuer == null ||
				myAudience == null
				)
			{
				throw new Exception("JWT Authentication initialization failed");
			}
			_mySecret = mySecret;
			_mySecurityKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_mySecret));
			_myIssuer = myIssuer;
			_myAudience = myAudience;
		}

		public string GenerateToken(List<Claim>? listOfClaims = null)
        {
            //Esempio di listOfClaims in ingresso
            //listOfClaims = new Claim[]{
            //	new Claim(ClaimTypes.NameIdentifier, userId.ToString()),
            //			new Claim("role", "admin"),
            //			new Claim("userId", userId.ToString()),
            //			new Claim("nome", "nome dell'utente"),
            //			new Claim("cognome", "cognome dell'utente")
            //			};
            if (listOfClaims == null)
            {
                listOfClaims = new List<Claim>();
            }

            listOfClaims.Add(new Claim("GeneratedAt", DateTime.Now.Ticks.ToString()));

            var tokenHandler = new JwtSecurityTokenHandler();

            //risolve il problema https://social.msdn.microsoft.com/Forums/en-US/ec2ecd60-43ef-48c2-bfdc-664095ec61ba/claimtypes-value-is-different-than-what-it-seems?forum=aspsecurity
            tokenHandler.OutboundClaimTypeMap.Clear();

            var tokenDescriptor = new SecurityTokenDescriptor
            {
                Subject = new ClaimsIdentity(listOfClaims),
                //Expires = DateTime.UtcNow.AddDays(7),
                Issuer = _myIssuer,
                Audience = _myAudience,
                SigningCredentials = new SigningCredentials(_mySecurityKey, SecurityAlgorithms.HmacSha256)
            };
            var token = tokenHandler.CreateToken(tokenDescriptor);
            return tokenHandler.WriteToken(token);
        }

        public bool ValidateCurrentToken(string token, bool isProd = true)
        {
            var tokenHandler = new JwtSecurityTokenHandler();
            try
            {
                tokenHandler.ValidateToken(token, new TokenValidationParameters
                {
                    ValidateIssuerSigningKey = true,
                    ValidateIssuer = true,
                    ValidateAudience = true,
                    ValidIssuer = _myIssuer,
                    ValidAudience = _myAudience,
                    ValidateLifetime = false,
                    IssuerSigningKey = _mySecurityKey
                }, out SecurityToken validatedToken);
            }
            catch (Exception ex)
            {
				try
				{
					string sSource = "JWT ValidateCurrentToken";
					string sLog = "ApplicationRefactoring";
					string sMachine = ".";
					if (RuntimeInformation.IsOSPlatform(OSPlatform.Windows))
					{
						EventSourceCreationData SourceData = new EventSourceCreationData(sSource, $"{sLog}{sMachine}");

						if (!EventLog.SourceExists(sSource, sMachine))
							System.Diagnostics.EventLog.CreateEventSource(SourceData);

						EventLog ELog = new EventLog(sLog, sMachine, sSource);
						ELog.WriteEntry(ex.ToString(), EventLogEntryType.Error);
					}
				}
				catch { }
				
                if (isProd)
                {
                    return false;
                }
                else
                {
                    throw;
                }
			}
            return true;
        }

        public static string? GetClaim(string token, string claimType)
        {
            var tokenHandler = new JwtSecurityTokenHandler();
            var securityToken = tokenHandler.ReadToken(token) as JwtSecurityToken;
            if (securityToken != null)
            {
                var stringClaimValue = securityToken.Claims.First(claim => claim.Type == claimType).Value;
                return stringClaimValue;
            }
            return null;
        }

        public string? RefreshToken(string token, int userId)
        {
            if (ValidateCurrentToken(token))
            {
                return null;
            }
            else
            {
                return null;
            }
        }

    }

    public class CookieHandlerEvents : CookieAuthenticationEvents
    {
        public override async Task ValidatePrincipal(CookieValidatePrincipalContext context)
        {
            //Viene chiamato ogni qual volta viene settato il ClaimsPrincipal nei cookies
            var userPrincipal = context.Principal;
            //Console.WriteLine($"\nValidatePrincipal: in {context.Request.Path.Value}");
            if (userPrincipal != null)
            {
                var JWT_Token = (from c in userPrincipal.Claims
                                 where c.Type == "JWT_Token"
                                 select c.Value).FirstOrDefault();

                //Console.WriteLine($"User logged,  Token: {JWT_Token}");

            }
            else
            {
                //Console.WriteLine("User not logged?");
            }

        }
    }

}