function FindProxyForURL(url, host) {
  if (host == 'music.163.com' || host == 'ip.ws.126.net') {
    return 'PROXY 207.148.27.51:80';
  } else if (host == 'music.httpdns.c.163.com') {
    return 'PROXY 127.0.0.1:9999';
  }
  return 'DIRECT';
}
