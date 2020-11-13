#include "::/Home/Net/SerialNetv2.HC"
// Send HTTP requests
// use 80 for HTTP and 443 for HTTPS.
// The python tunnel uses a ssl wrapper when on port 443

// Imagine someone actually using the internet with this

U8 *USER_AGENT = "TempleOS COM Port Tunneled Internet";

U0 HttpGet(U8 *host,I64 port,U8 *path)
{


TunnelConnect(host,port,
"GET /%s HTTP/1.1\r\nHost: %s\r\nConnection: close\r\nCache-Control: max-age=0\r\nUser-Agent: %s\r\nAccept: */*\r\nAccept-Language: pt-BR,pt;q=0.9,en-US;q=0.8,en;q=0.7\r\n\r\n",
path,
host,
USER_AGENT
);


}




SerialBegin(1,9600);

TunnelPing();
Print("\n");

HttpGet("templeos.org",443,"");
