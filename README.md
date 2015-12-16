# AUTH_APP 

The iOS app accompaniment for AUTH_API (https://github.com/laterDays/auth_api). This app demonstrates OAUTH communication with a Rails server (AUTH_API) which uses developer authentication to pass AWS Congnito credentials to the iOS application.

## Config

After cloning this repository, create a file "CONFIG_VARS.swift" in the directory "auth_app."

```
import Foundation

public class CONFIG_VARS
{
    public static let S3_BUCKET_NAME = "your s3 bucket name"
    public static let API_DOMAIN_URL = "https://the-auth-api-location.domain.com/"
    public static let API_CLIENT_ID = "client id from auth api"
}
```

