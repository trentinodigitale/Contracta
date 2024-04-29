using System;

namespace Core.Authentication.Interfaces
{
    public interface IVerifySessionTokenInput
    {
        string Email { get; }
        Guid? SessionToken { get; }
    }
}
